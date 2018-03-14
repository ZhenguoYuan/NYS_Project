#---------------------------
# Combining gap-filled AOD files by random forest for plotting AOD 2D distribution
aodCombine <- function(year, day.range, inpath, type, filter.tag = 'overall') {
  # filter.tag can be "overall", "original", and "gapfilled"
  
  aot.combine <- data.frame()
  for (i in day.range) { # How many days
    
    doy <- sprintf('%03d', i)
    file.rf <- file.path(inpath, as.character(year), type, paste(as.character(year), doy, '_RF.RData', sep = ''))
    print(file.rf)
    
    load(file.rf)
    aot <- rf.result
    
    # Filter original or gapfilled AODs
    if (filter.tag == 'overall') {
      aot <- aot
    } else if (filter.tag == 'original') {
      idx <- aot[, 5]
      tmp <- aot[, 4]
      tmp[idx == 1] <- NA
      aot[, 4] <- tmp
    } else if (filter.tag == 'gapfilled') {
      idx <- aot[, 5]
      tmp <- aot[, 4]
      tmp[idx == 0] <- NA
      aot[, 4] <- tmp
    } else {
      stop('Error in filter.tag!')
    }
    
    # Calculating Averages
    if (i == 1) {
      aot[, 5] <- NULL
      aot.combine <- aot
    } else {
      aot[, 5] <- NULL
      aot$Lat <- NULL
      aot$Lon <- NULL
      aot.combine <- merge(aot.combine, aot, by = 'ID', all = T)
    }
    
    gc()
    
  }
  
  aot.combine$AOT_Mean <- rowMeans(aot.combine[4 : ncol(aot.combine)], na.rm = T)
  aot.combine <- subset(aot.combine, select = c(ID, Lat, Lon, AOT_Mean))
  
  return(aot.combine)
  
}

#---------------------------
# Combining PM2.5 CSV files for plotting PM2.5 2D distribution

combine4pm25 <- function (doys, year, inpath, suffix = '_PM25PRED_RF.csv', 
                          id.var = c('ID'), cor.var = c('Lat', 'Lon'), 
                          pred.var = c('PM25_Pred')) {
  
  ## ---------- Combining ---------- ##
  num <- 0
  for (i in doys) {
    
    # Path
    doy <- sprintf('%03d', i)
    file.pm25pred <- file.path(inpath, paste(year, doy, suffix, sep = ''))
    
    if (file.exists(file.pm25pred)) {
      
      print(file.pm25pred)
      num <- num + 1
      
      # Read csv
      dat.tmp <- read.csv(file = file.pm25pred, stringsAsFactors = F)
      dat.tmp <- subset(dat.tmp, select = c(id.var, cor.var, pred.var))
      
      # Binding
      if (num == 1){
        dat <- dat.tmp
      } else {
        dat.tmp$Lon <- NULL
        dat.tmp$Lat <- NULL
        dat <- merge(dat, dat.tmp, by = id.var, all = T)
      }
    }
  }
  
  ## ---------- Average ---------- ##
  dat$PM25_Pred_Avg <- rowMeans(dat[(length(id.var) + length(cor.var) + 1) : ncol(dat)], na.rm = T)
  pm25_combine_plot <- subset(dat, select = c(id.var, cor.var, 'PM25_Pred_Avg'))
  
  return(pm25_combine_plot)
  
}

#---------------------------
# Combining PM2.5 RData files for plotting PM2.5 2D distribution (Harvard Gap-filling)

combine4pm25RData <- function (doys, year, inpath, suffix = '_HARVARD.RData', 
                               id.var = c('ID'), cor.var = c('Lat', 'Lon'), 
                               pred.var = c('PM25_Pred_Harvard')) {
  
  ## ---------- Combining ---------- ##
  num <- 0
  for (i in doys) {
    
    # Path
    doy <- sprintf('%03d', i)
    file.pm25pred <- file.path(inpath, paste(year, doy, suffix, sep = ''))
    
    if (file.exists(file.pm25pred)) {
      
      print(file.pm25pred)
      num <- num + 1
      
      # Read csv
      load(file.pm25pred)
      dat.tmp <- subset(dat.daily.harvard, select = c(id.var, cor.var, pred.var))
      
      # Binding
      if (num == 1){
        dat <- dat.tmp
      } else {
        dat.tmp$Lon <- NULL
        dat.tmp$Lat <- NULL
        dat <- merge(dat, dat.tmp, by = id.var, all = T)
      }
    }
  }
  
  ## ---------- Average ---------- ##
  dat$PM25_Pred_Avg <- rowMeans(dat[(length(id.var) + length(cor.var) + 1) : ncol(dat)], na.rm = T)
  pm25_combine_plot <- subset(dat, select = c(id.var, cor.var, 'PM25_Pred_Avg'))
  
  return(pm25_combine_plot)
  
}