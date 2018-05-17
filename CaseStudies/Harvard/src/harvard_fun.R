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
      harvmod <- gam(sqrtPM25_Pred ~ sqrtDailyEPAMean + s(X_Lon, Y_Lat), data = dat.fit.train)
      sqrtPred <- predict(harvmod, dat.fit.test)
      y.pred <- sqrtPred * sqrtPred
      cv.r2[i.fold + fold * (i_cv - 1)] <- cor(x = y, y = y.pred, use = "complete.obs") * cor(x = y, y = y.pred, use = "complete.obs")
      
      print(paste('CV R2 ', as.character(i_cv), '_',as.character(i.fold), ': ', as.character(cv.r2[i.fold + fold * (i_cv - 1)]), sep = ''))
      
      gc()
      
    }
    
  }
  
  print(paste('Mean CV R2:', as.character(mean(cv.r2, na.rm = T))))
  print('============== CV Completed ==============')
  
}

#------------------------#
# Calculate each row's buffer mean
bufferMean <- function(df.row, dat, buffer) {
  ### df.row - a row of the input data frame
  ### dat - the data with EPA observations
  # X and Y
  x.tmp <- df.row['X_Lon']
  y.tmp <- df.row['Y_Lat']
  # Mean calculation
  dat.tmp <- subset(dat, sqrt((X_Lon - x.tmp)^2 + (Y_Lat - y.tmp)^2) <= buffer)
  DailyEPAMean.tmp <- mean(dat.tmp$PM25, na.rm = T) # Using EPA stations to calculate daily mean
  
  return(DailyEPAMean.tmp)
}
