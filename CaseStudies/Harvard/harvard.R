# ----------------
# Name: harvard.R
# Author: Jianzhao Bi
# Description: Harvard Gap-filling (Monthly, Parallel)
# Date: Mar 12, 2018
# ----------------

library(mgcv)
library(lubridate)

setwd('/home/jbi6/NYS_Project/CaseStudies/Harvard/')

source('../../src/fun.R')

# Arguments for R script
Args <- commandArgs()

# Time
year <- Args[6]

# -------------------- #
# ----- Parallel ----- #
# Parallel parameters
cluster.idx <- as.numeric(Args[7]) # This cluster's number
cluster.num <- as.numeric(Args[8]) # Total number of clusters
# Split tasks
options(warn = -1)
jobs <- split(1 : 12, 1 : cluster.num) # Job list of DOY
options(warn = 0)
this.jobs <- jobs[[cluster.idx]]
# ----- Parallel ----- #
# -------------------- #

# ----- Parameters -----
# 12 Months
month.start <- c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335)
month.end <- c(31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365)

# Paths
inpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_PRED_RFMODEL', as.character(year))
inpath.rf.aaot <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/', as.character(year), '/aqua550/', sep = '')
inpath.rf.taot <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/', as.character(year), '/terra550/', sep = '')
outpath.fit <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/Harvard/PM25_FIT_HARVARD', as.character(year))
if (!file.exists(outpath.fit)) {
  dir.create(outpath.fit,recursive = T)
}
outpath.pred <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/Harvard/PM25_PRED_HARVARD', as.character(year))
if (!file.exists(outpath.pred)) {
  dir.create(outpath.pred,recursive = T)
}

# Buffer
buffer <- 100 # in km

#------------------------#
## Cross-validation of Harvard Gap-filling
harvardCV <- function(all, fold = 10, times = 1) {
  # fold: how many parts the data are divided into, in which one of this parts is used for testing, and the remaining are used for training
  # times: how many times the CV should run
  
  print('============== CV Started ==============')
  
  cv.r2 <- c()
  for (i_cv in 1 : times) {
    
    ## ----- Split ----- ##
    
    # Randonly reorder the sequence
    idx <- 1 : nrow(all)
    idx <- sample(idx, size = length(idx), replace = F)
    # Splitting the dataset by the number of fold
    groups <- split(1 : length(idx), 1 : fold)
    
    # For each fold
    for (i.fold in 1 : fold) {
      
      # ----- Allocation ----- #
      dat.fit.train <- all[-unlist(groups[i.fold]), ]
      dat.fit.test <- all[unlist(groups[i.fold]), ]
      
      y <- dat.fit.test$sqrtPM25_Pred
      dat.fit.test$sqrtPM25_Pred <- NULL
      
      ## ----- CV ----- ##
      harvmod <- gam(sqrtPM25_Pred ~ sqrtDailyMean + s(X_Lon, Y_Lat, k = 10), data = dat.fit.train)
      sqrtPred <- predict(harvmod, dat.fit.test)
      y.pred <- sqrtPred * sqrtPred
      cv.r2[i.fold + fold * (i_cv - 1)] <- cor(y, y.pred) * cor(y, y.pred)
      
      print(paste('CV R2 ', as.character(i_cv), '_',as.character(i.fold), ': ', as.character(cv.r2[i.fold + fold * (i_cv - 1)]), sep = ''))
      
      gc()
      
    }
    
  }
  
  print(paste('Mean CV R2:', as.character(mean(cv.r2))))
  print('============== CV Completed ==============')
  
}
#------------------------#
# Calculate each row's buffer mean
bufferMean <- function(df.row, dat, buffer) {
  ### df.row - a row of the input data frame
  ### dat - the data including original MAIAC AOD
  
  # Sampling the data
  idx <- sample(1 : nrow(dat), 0.5*nrow(dat))
  dat.reduced <- dat[idx, ]
  # X and Y
  x.tmp <- df.row['X_Lon']
  y.tmp <- df.row['Y_Lat']
  # Mean calculation
  dat.tmp <- subset(dat.reduced, sqrt((X_Lon - x.tmp)^2 + (Y_Lat - y.tmp)^2) <= buffer)
  DailyMean.tmp <- mean(dat.tmp$PM25_Pred, na.rm = T) # Using non-gapfilling data to calculate daily mean
  
  return(DailyMean.tmp)
}


for (m in this.jobs) { # For a month
  
  dat.monthly.fit <- data.frame()
  dat.monthly.pred <- data.frame()
  
  # --- Combine Daily Data --- #
  
  for (i.doy in month.start[m] : month.end[m]) { 
    
    print(i.doy)
    print(Sys.time())
    
    # Load the PM2.5 data set
    pm25.filename <- file.path(inpath, paste(as.character(year), sprintf('%03d', i.doy), '_PM25PRED_RF.csv', sep = ''))
    
    if (file.exists(pm25.filename)) {
      
      dat <- read.csv(file = pm25.filename, stringsAsFactors = F)
      
      # Load the RF gap-filling data set to get the gap-filling tag
      load(file.path(inpath.rf.aaot, paste(as.character(year), sprintf('%03d', i.doy), '_RF.RData', sep = '')))
      aaot <- rf.result
      gapfill.tag.aaot <- aaot$Gapfill_tag_AAOT550
      load(file.path(inpath.rf.taot, paste(as.character(year), sprintf('%03d', i.doy), '_RF.RData', sep = '')))
      taot <- rf.result
      gapfill.tag.taot <- taot$Gapfill_tag_TAOT550
      gapfill.tag <- gapfill.tag.aaot | gapfill.tag.taot
      dat.tag <- data.frame(ID = aaot$ID, gapfill.tag = gapfill.tag) # Indicating whether this PM2.5 is estimated from original AOD
      
      # merge PM2.5 prediction and the tag
      dat.daily <- merge(dat, dat.tag, by = c('ID'), all = F)
      
      # Add time
      dat.daily$month <- m
      dat.daily$doy <- i.doy
      
      # Lat/Lon to KM
      xy <- xy.latlon(Lat = dat.daily$Lat, Long = dat.daily$Lon)
      dat.daily <- cbind(dat.daily, xy)
      
      # Daily Mean
      # for (i.mean in 1 : nrow(dat.daily)){
      #   x.tmp <- dat.daily$X_Lon[i.mean]
      #   y.tmp <- dat.daily$Y_Lat[i.mean]
      #   DailyMean.tmp <- mean(dat.daily[dat.daily$gapfill.tag == F & sqrt((dat.daily$X_Lon - x.tmp)^2 + (dat.daily$Y_Lat - y.tmp)^2) <= buffer, ]$PM25_Pred, 
      #                         na.rm = T) # Using non-gapfilling data to calculate daily mean
      #   dat.daily$DailyMean[i.mean] <- DailyMean.tmp
      #   dat.daily$sqrtDailyMean[i.mean] <- sqrt(DailyMean.tmp)
      # }
      dat.daily.original <- subset(dat.daily, gapfill.tag == F) # Select the PM2.5 values predicted by original AOD
      DailyMean <- apply(dat.daily, 1, FUN = bufferMean, dat.daily.original, buffer)
      dat.daily$DailyMean <- DailyMean
      dat.daily$sqrtDailyMean <- sqrt(DailyMean)
      
      # Sqrt PM2.5
      dat.daily$sqrtPM25_Pred <- sqrt(dat.daily$PM25_Pred)
      
      # Fitting and predicting data sets
      dat.daily.fit <- dat.daily[dat.daily$gapfill.tag == F, ]
      dat.daily.pred <- dat.daily[dat.daily$gapfill.tag == T,]
      
      # Combine daily data sets
      dat.monthly.fit <- rbind(dat.monthly.fit, dat.daily.fit)
      dat.monthly.pred <- rbind(dat.monthly.pred, dat.daily.pred)
      
    }
    
  }
  
  # --- Harvard Gap-filling --- #
  
  harvmod <- gam(sqrtPM25_Pred ~ sqrtDailyMean + s(X_Lon, Y_Lat, k = 10), data = dat.monthly.fit)
  sqrtPred <- predict(harvmod, dat.monthly.pred)
  Pred <- sqrtPred * sqrtPred
  
  # Assign gap-filled values
  dat.monthly.pred$PM25_Pred_Harvard <- Pred
  dat.monthly.pred$harvard.fill.tag <- 1
  
  dat.monthly.fit$PM25_Pred_Harvard <- dat.monthly.fit$PM25_Pred
  dat.monthly.fit$harvard.fill.tag <- 0
  
  # Combining fit and pred data sets
  dat.monthly <- rbind(dat.monthly.fit, dat.monthly.pred)
  dat.monthly <- dat.monthly[order(dat.monthly$ID),]
  
  # --- Cross-validation --- #
  # Output screen contents to file
  sink(file = file.path(outpath.fit, paste(as.character(year), sprintf('%02d', m), 'HarvardModel.txt', sep = '_')))
  # Cross-validation
  harvardCV(dat.monthly.fit)
  # End the screen output
  sink()
  
  # --- Save Predicted Data --- #
  
  for (i.doy in month.start[m] : month.end[m]) {
    
    dat.daily.harvard <- subset(dat.monthly, month == m & doy == i.doy)
    if (nrow(dat.daily.harvard) > 0) {
      save(dat.daily.harvard, file = file.path(outpath.pred, paste(as.character(year), sprintf('%03d', i.doy), '_HARVARD.RData', sep = '')))
    }
  }
  
  gc()
  
  
}


# # ----- Plot ----- #
# shp.name <- '~/Google Drive/Projects/Codes/Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp'
# myshp <- readShapePoly(shp.name)
# jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
# 
# ## Harvard Gap-filling
# dat.ori <- dat.final[dat.final$harvard.fill.tag == 0,]
# pp.ori <- plot2d(data = dat.ori, fill = dat.ori$PM25_Pred, colorbar = jet.colors, shp = myshp)
# 
# dat.gap <- dat.final[dat.final$harvard.fill.tag == 1,]
# pp.gap <- plot2d(data = dat.gap, fill = dat.gap$PM25_Pred, colorbar = jet.colors, shp = myshp)
# 
# pp.final <- plot2d(data = dat.final, fill = dat.final$PM25_Pred, colorbar = jet.colors, shp = myshp)
# 
# ## RF Gap-filling
# pp.rf <- plot2d(data = dat.rf, fill = dat.rf$PM25_Pred, colorbar = jet.colors, shp = myshp, colorbar_limits = c(5, 15))


