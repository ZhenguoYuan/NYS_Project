setwd('/home/jbi6/NYS_Project/Validations/AERONET/')

## ---------- Combining ---------- ##

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/AERONET/'
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

## ---------- MI ---------- ##
mi.combine.aero <- data.frame()
for (i in 1 : 300) { # How many days
  
  doy <- sprintf('%03d', i)
  
  file.mi <- file.path(inpath, 'MI', paste('2009', doy, '_MI.RData', sep = ''))
  
  if (file.exists(file.mi)) {
    
    print(file.mi)
    
    file.comebine <- file.path(inpath, 'Combine', paste('2009', doy, '_combine.RData', sep = ''))
    
    load(file.mi)
    load(file.comebine)
    
    mi.result$year <- NULL
    mi.result$doy <- NULL
    mi.combine <- merge(combine, mi.result, by.x = 'ID', by.y = 'ID', all = T)
    
    # Gap-filling Tag
    gap.idx <- as.numeric(is.na(mi.combine$AOD550_TAOT))
    mi.combine$mi_tag <- gap.idx
    
    # Keep rows with available AERONET data
    mi.combine <- subset(mi.combine, subset = !is.na(AERONET_AOD550))
    
    # Binding rows
    mi.combine.aero <- rbind(mi.combine.aero, mi.combine)
  }
  
  gc()
  
}

save(mi.combine.aero, file = file.path(outpath, 'mi_combine_aero.RData'))

## ---------- RF ---------- ##
rf.combine.aero <- data.frame()
for (i in 1 : 300) { # How many days
  
  doy <- sprintf('%03d', i)
  
  file.rf <- file.path(inpath, 'RF', paste('2009', doy, '_RF.RData', sep = ''))
  
  if (file.exists(file.rf)) {
    
    print(file.rf)
    
    file.comebine <- file.path(inpath, 'Combine', paste('2009', doy, '_combine.RData', sep = ''))
    
    load(file.rf)
    load(file.comebine)
    
    names(rf.result)[4] <- 'AOD550TAOT_RF'
    rf.result$Lat <- NULL
    rf.result$Lon <- NULL
    rf.combine <- merge(combine, rf.result, by.x = 'ID', by.y = 'ID', all = T)
    
    # Gap-filling Tag
    rf.combine$rf_tag <- as.numeric(is.na(rf.combine$AOD550_TAOT))
    
    # Keep rows with available AERONET data
    rf.combine <- subset(rf.combine, subset = !is.na(AERONET_AOD550))
    
    # Binding rows
    rf.combine.aero <- rbind(rf.combine.aero, rf.combine)
  }
  
  gc()
  
}

save(rf.combine.aero, file = file.path(outpath, 'rf_combine_aero.RData'))
