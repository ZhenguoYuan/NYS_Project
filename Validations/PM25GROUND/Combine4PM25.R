setwd('/home/jbi6/NYS_Project/Validations/PM25GROUND/')

source('../../src/fun.R')

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations'
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

year <- 2009
numdays <- numOfYear(as.numeric(year))

# ---------- Combining ---------- #
combine.pm25 <- data.frame()
for (i in 1 : numdays) { # How many days
  
  doy <- sprintf('%03d', i)
  
  file.rf <- file.path(inpath, 'RF', paste(as.character(year), doy, '_RF.RData', sep = ''))
  file.comebine <- file.path(inpath, 'Combine', paste(as.character(year), doy, '_combine.RData', sep = ''))
  file.pm25pred <- file.path(inpath, 'Modeling/PM25_PRED_RFMODEL', paste(as.character(year), doy, '_PM25PRED_RF.csv', sep = ''))
  
  if (file.exists(file.pm25pred) & 
      file.exists(file.comebine) &
      file.exists(file.rf)) {
    
    print(doy)
    
    load(file.rf)
    load(file.comebine)
    pm25pred <- read.csv(file = file.pm25pred, stringsAsFactors = F)
    
    dat <- merge(combine, rf.result, by = c('ID'), all = T)
    dat <- merge(dat, pm25pred, by = c('ID'), all = T)
    
    dat <- subset(dat, !is.na(PM25))
    dat <- subset(dat, select = c(ID, Lat, Lon, PM25, PM25_Pred, Gapfill_tag))
    
    combine.pm25 <- rbind(combine.pm25, dat)
  }
  
  gc()
  
}

save(combine.pm25, file = file.path(outpath, 'combine_pm25.RData'))
