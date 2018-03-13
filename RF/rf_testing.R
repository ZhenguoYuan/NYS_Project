# To test if the fitting ability of RF decreases as choosing less sample size

library(randomForest)
library(MASS)
library(foreach)
library(doSNOW)

setwd('/home/jbi6/NYS_Project/RF/')
source('../src/fun.R') # Load interp functions

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine/2009/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF_TEST'
if (!file.exists(outpath)) {
  dir.create(outpath, recursive = T)
}

# Different Sample Sizes
for (sampsize in c(10000, 30000, 50000, 100000, 840000)) {
  
  print(format(sampsize, scientific = F))
  
  i_day <- 244 # 244 days in 2009
  
  # Read adjacent days' data
  adj_factor <- 1 # 3 days
  dat <- data.frame()
  year_tmp <- 2009
  doy_tmp <- i_day
  for (j_adj in -adj_factor : adj_factor) { # Previous day, this day, and following day
    file.adj <- file.path(inpath, paste(year_tmp, sprintf('%03d', doy_tmp + j_adj), '_combine.RData', sep = ''))
    if (file.exists(file.adj)) {
      print(file.adj)
      load(file.adj)
      dat <- rbind(dat, combine)
    }
  }
  
  dat.fit <- subset(dat, select = c(AOD550_TAOT, Y_Lat, X_Lon, 
                                    Cloud_Frac_Day_Terra, Snow_Cover_Terra, DEM, 
                                    RHUM_NARR, spec_humi_2m_NLDAS, temp_2m_NLDAS, total_prec_NLDAS))
  
  # Remove rows with NAs
  idx <- rowMeans(dat.fit)
  dat.fit <- subset(dat.fit, subset = !is.na(idx))
  
  dat.fit$X2 <- dat.fit$X_Lon*dat.fit$X_Lon
  dat.fit$Y2 <- dat.fit$Y_Lat*dat.fit$Y_Lat
  dat.fit$XY <- dat.fit$X_Lon*dat.fit$Y_Lat
  dat.fit$tag <- 1
  
  # Random choosing subset of the data
  idx_sub <- sample(seq_len(nrow(dat.fit)), size = sampsize)
  dat.fit <- dat.fit[idx_sub, ]
  
  print(paste('dimension:', dim(dat.fit)))
  
  ptm <- proc.time()
  
  #RF Fitting
  # registerDoSNOW(makeCluster(10, type="SOCK"))
  # rf.fit <- foreach(ntree = rep(20, 10), .combine = combine, .packages = "randomForest") %dopar%
  #   randomForest(AOD550_TAOT ~ Cloud_Frac_Day_Terra + Snow_Cover_Terra + DEM +
  #                  RHUM_NARR + spec_humi_2m_NLDAS + temp_2m_NLDAS + total_prec_NLDAS +
  #                  Y_Lat + X_Lon, data = dat.fit, ntree = ntree)
  
  rf.fit <- randomForest(AOD550_TAOT ~ Cloud_Frac_Day_Terra + Snow_Cover_Terra + DEM +
                   RHUM_NARR + spec_humi_2m_NLDAS + temp_2m_NLDAS + total_prec_NLDAS +
                   Y_Lat + X_Lon + X2 + Y2 + XY, data = dat.fit, ntree = 200)
  
  
  print(proc.time() - ptm)
  print(rf.fit)
  # Variable Importance
  print(rf.fit$importance[order(rf.fit$importance, decreasing = T),])
  
  ## ---------- Prediction ---------- ##
  # Prediction data set
  dat.pred.test <- subset(dat, select = c(ID, Lat, Lon, Y_Lat, X_Lon, AOD550_TAOT,
                                     Cloud_Frac_Day_Terra, Snow_Cover_Terra, DEM,
                                     RHUM_NARR, spec_humi_2m_NLDAS, temp_2m_NLDAS, total_prec_NLDAS))
  dat.pred.test <- subset(dat.pred.test, subset = is.na(idx))
  dat.pred.test$AOD550_TAOT <- NULL
  
  dat.pred.test$X2 <- dat.pred.test$X_Lon*dat.pred.test$X_Lon
  dat.pred.test$Y2 <- dat.pred.test$Y_Lat*dat.pred.test$Y_Lat
  dat.pred.test$XY <- dat.pred.test$X_Lon*dat.pred.test$Y_Lat
  dat.pred.test$tag <- 0
  
  # Prediction
  AOD550_TAOT_pred <- predict(rf.fit, dat.pred.test)
  dat.pred.test$AOD550_TAOT <- AOD550_TAOT_pred
  dat.pred.test <- subset(dat.pred.test, select = c(ID, Lat, Lon, AOD550_TAOT))
  
  # Save the RF results
  save(dat.pred.test, file = file.path(outpath, paste(as.character(i_day), '_', format(sampsize, scientific = F), '_TEST_RF.RData', sep='')))
  
}
