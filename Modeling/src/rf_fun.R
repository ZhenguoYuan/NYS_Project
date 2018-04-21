#----------------------------
# Functions used in RF Modeling and Prediction
# 
# Jianzhao Bi
# 3/7/2018
#----------------------------

library(MASS)
library(mgcv)
library(pls)
library(lubridate)
library(randomForest)
library(sp)
library(caret)
library(VSURF)
library(doSNOW)

## ------------------------
## Organizing data for RF
DAT_ORG <- function(dat, year) {
  
  # Adding other necessary parameters
  # dat$AOD550_TAOT.y2 <- dat$AOD550_TAOT.y^2 # AOD^2
  # dat$short_flux_surf_NLDAS2 <- dat$short_flux_surf_NLDAS^2 # Surface Incident Shortwave Flux ^ 2
  dat$WIND_NARR <- sqrt(dat$UWND_NARR^2 + dat$VWND_NARR^2) # Wind speed
  dat$month <- month(as.Date(dat$doy - 1, origin = paste(as.character(year), '-01-01', sep = '')))
  
  return(dat)
  
}

## ------------------------
## Random Forest for PM2.5 Modeling
RF_MODEL <- function(all, formula, if.print = T, is.cv = F) {
  
  if (if.print) {
    print(paste(Sys.time(), '-- RF Modeling'))
  }
  
  # RF Modeling
  # rf.fit <- randomForest(PM25 ~ HPBL_NARR + short_flux_surf_NLDAS + RHUM_NARR +
  #                          AOD550_TAOT.y + AOD550_TAOT.y * HPBL_NARR + AOD550_TAOT.y2 + 
  #                          wind + total_prec_NLDAS + short_flux_surf_NLDAS2 + 
  #                          AIR_NARR + X_Lon + Y_Lat + pop + HighwayDist + MajorDist + PM_cov, data = all, ntree = 200)
  
  # rf.fit <- train(formula, data = all, method = "rf", #tuneGrid = data.frame(mtry = 5 : 12), 
  #                 #trControl = trainControl(method = "cv", number = 10),
  #                 na.action = na.omit)
  # # rf.fit <- VSURF(formula, data = all, na.action = na.omit)
  # # summary(rf.fit)
  
  if (is.cv == F) {
    #Rprof(tmp <- tempfile())
    rf.fit <- randomForest(formula, data = all, ntree = 1000, importance = T)
    #Rprof()
    #summaryRprof(tmp)
  } else {
    registerDoSNOW(makeCluster(5, type="SOCK"))
    rf.fit <- foreach(ntree = rep(200, 5), .combine = combine, .packages = "randomForest") %dopar%
      randomForest(formula, data = all, ntree = ntree, importance = T)
  }
  
  if (if.print) {
    print(paste(Sys.time(), '-- RF Complete'))
    print(rf.fit)
    # Variable Importance
    # print(rf.fit$importance[order(rf.fit$importance, decreasing = T), ])
    # Importance (two types)
    im1 <- importance(rf.fit, type = 1) # mean decrease in accuracy
    im1 <- im1[order(im1, decreasing = T), ]
    print('Mean decrease in accuracy')
    print(im1)
    im2 <- importance(rf.fit, type = 2) # mean decrease in node impurity
    im2 <- im2[order(im2, decreasing = T), ]
    print('Mean decrease in node impurity')
    print(im2)
  }
  
  return(rf.fit)
}

## ------------------------
## Cross-validation of Random Forest for PM2.5 Modeling
RF_CV <- function(all, formula, fold = 10, times = 1, by = '') {
  # fold: how many parts the data are divided into, in which one of this parts is used for testing, and the remaining are used for training
  # times: how many times the CV should run
  # by: which variable in "all" is used as the randomly splitting variable (Used for spatial and temporal CV). If by == '', then randomly splitting all data
  
  print('============== CV Started ==============')
  
  cv.r2 <- c()
  for (i_cv in 1 : times) {
    
    ## ----- Split ----- ##
    
    ## set the seed to make your partition reproductible
    if (by == '') {
      
      # Randonly reorder the sequence
      idx <- 1 : nrow(all)
      set.seed(1118)
      idx <- sample(idx, size = length(idx), replace = F)
      # Splitting the dataset by the number of fold
      groups <- split(1 : length(idx), 1 : fold)
      
    } else { # Splitting the 'all' by a certain variable
      
      # Extracting the splitting variable
      var <- unlist(with(all, mget(by)), use.names = F)
      # Getting unique values of the splitting variable
      var.unique <- unique(var)
      # Randonly reorder the sequence
      set.seed(1118)
      var.unique <- sample(var.unique, size = length(var.unique), replace = F)
      # Splitting the dataset by the number of fold
      groups.unique <- split(var.unique, 1 : fold)
      
      
    }
    
    # For each fold
    y.all <- c()
    y.pred.all <- c()
    for (i.fold in 1 : fold) {
      
      # ----- Allocation ----- #
      if (by == '') {
        dat.fit.train <- all[-unlist(groups[i.fold]), ]
        dat.fit.test <- all[unlist(groups[i.fold]), ]
      } else {
        # Sampling the variable
        train.id <- which(var %in% unlist(groups.unique[i.fold]))
        dat.fit.train <- all[-train.id, ]
        dat.fit.test <- all[train.id, ]
      }
      
      y <- dat.fit.test$PM25
      dat.fit.test$PM25 <- NULL
      
      ## ----- CV ----- ##
      rf.fit.cv <- RF_MODEL(dat.fit.train, formula, if.print = F, is.cv = T)
      y.pred <- predict(rf.fit.cv, dat.fit.test)
      cv.r2[i.fold + fold * (i_cv - 1)] <- cor(y, y.pred) * cor(y, y.pred)
      
      # Save the original values and predicted values
      y.all <- c(y.all, y)
      y.pred.all <- c(y.pred.all, y.pred)
      
      print(paste('CV R2 ', as.character(i_cv), '_',as.character(i.fold), ': ', as.character(cv.r2[i.fold + fold * (i_cv - 1)]), sep = ''))
      
      gc()
      
    }
    
  }
  
  print(paste('Mean CV R2:', as.character(mean(cv.r2))))
  print('============== CV Completed ==============')
  
  y.list <- list(y = y.all, y.pred = y.pred.all)
  return(y.list)
  
}

## ------------------------
# Convolutional Layer for RF Modeling
covModel <- function(dat) {
  
  result <- c()
  for (k in 1 : nrow(dat)) {
    
    ga.pm.one <- dat[k, ]
    ga.pm.other <- dat[-k, ]
    
    ga.pm.other$point_x <- cbind(ga.pm.other$X_Lon, ga.pm.other$Y_Lat)[, 1]
    ga.pm.other$point_y <- cbind(ga.pm.other$X_Lon, ga.pm.other$Y_Lat)[, 2]
    coordinates(ga.pm.other) <- ~ point_x + point_y
    
    ExtendedGrid <- ga.pm.one[, c("X_Lon", "Y_Lat")]
    coordinates(ExtendedGrid) = ~X_Lon + Y_Lat
    
    ga.k <- idw(PM25 ~ 1, ga.pm.other, ExtendedGrid, nmax = 15, idp = 5)
    ga.pm.one$PM_cov <- ga.k$var1.pred
    result <- rbind(result, ga.pm.one)
  }
  
  return(result)
  
}

## ------------------------
# Convolutional Layer for RF Prediction
covPred <- function(dat) {
  
  # Convolutional Layer
  dat_sub <- dat[!is.na(dat$PM25), ]
  
  if (nrow(dat_sub) != 0) {
    
    dat_sub$point_x <- cbind(dat_sub$X_Lon, dat_sub$Y_Lat)[, 1]
    dat_sub$point_y <- cbind(dat_sub$X_Lon, dat_sub$Y_Lat)[, 2]
    coordinates(dat_sub) <- ~point_x + point_y
    ExtendedGrid <- dat[, c("X_Lon", "Y_Lat")]
    coordinates(ExtendedGrid) = ~X_Lon + Y_Lat
    ga.k <- idw(PM25 ~ 1, dat_sub, ExtendedGrid, nmax = 15, idp = 5)
    dat$PM_cov <- ga.k$var1.pred
    #print(paste('Convolution rows:', nrow(dat)))
    
    return(dat)
    
  } else {
    
    return(NULL)
    
  }
  
  
  
}

