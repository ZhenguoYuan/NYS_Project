
setwd('/home/jbi6/NYS_Project/CaseStudies/WildFire')

source('../..//Validations/PLOT2D/src/plot_fun.R')

# Location of the center of the wildfire
# lat: 41.65
# lon: -74.40

# Time range of the wildfire
# 2015-05-03 ~ 2015-05-05
# Julian day 123 - 125

year <- 2015

start.date.temp <- 93
end.date.temp <- 155

lat.range.temp <- c(41.63, 41.67)
lon.range.temp <- c(-74.42, -74.38)

start.date.spatial <- 124
end.date.spatial <- 125

lat.range.spatial <- c(41.15, 42.15)
lon.range.spatial <- c(-74.9, -73.9)

# ----- PM2.5 ----- #

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_PRED_RFMODEL/2015/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/WildFire/'
if (!file.exists(outpath)) {
  dir.create(outpath, recursive = T)
}

n <- 0
pm25.temp <- c()
# Temporal
for (i in start.date.temp : end.date.temp) {
  
  print(paste('PM2.5 Temporal', as.character(i)))
  
  n <- n + 1
  
  dat <- read.csv(file = file.path(inpath, paste(as.character(year), sprintf('%03d', i), '_PM25PRED_RF.csv', sep = '')), stringsAsFactors = F)
  # Subset by lat/lon range
  dat.temp <- subset(dat, Lat >= min(lat.range.temp) & Lat <= max(lat.range.temp) & Lon >= min(lon.range.temp) & Lon <= max(lon.range.temp))
  # Temporal trend
  pm25.temp[n] <- mean(dat.temp$PM25_Pred, na.rm = T)

}

# Spatial
n <- 0
for (j in start.date.spatial : end.date.spatial) {
  
  print(paste('PM2.5 Spatial', as.character(j)))
  
  n <- n + 1
  
  dat <- read.csv(file = file.path(inpath, paste(as.character(year), sprintf('%03d', j), '_PM25PRED_RF.csv', sep = '')), stringsAsFactors = F)
  dat.spatial <- subset(dat, Lat >= min(lat.range.spatial) & Lat <= max(lat.range.spatial) & Lon >= min(lon.range.spatial) & Lon <= max(lon.range.spatial))
  
  # Spatial pattern
  if (n == 1) {
    pm25.spatial.tmp <- dat.spatial
  } else {
    dat.spatial$Lat <- NULL
    dat.spatial$Lon <- NULL
    pm25.spatial.tmp <- merge(x = pm25.spatial.tmp, y = dat.spatial, by = c('ID'), all = T)
  }
}

# Averaging the PM2.5 spatial pattern
pm25.spatial <- data.frame(ID = pm25.spatial.tmp$ID, Lat = pm25.spatial.tmp$Lat, Lon = pm25.spatial.tmp$Lon)
pm25.spatial$PM25_Mean <- rowMeans(x = pm25.spatial.tmp[4 : ncol(pm25.spatial.tmp)], na.rm = T)

# Save the file
pm25.fire <- list(pm25.spatial = pm25.spatial, pm25.temp = pm25.temp)
save(pm25.fire, file = file.path(outpath, 'pm25_fire.RData'))


# ----- AOD ----- #

inpath.aaot <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/2015/aqua550/'
inpath.taot <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/2015/terra550/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/WildFire/'
if (!file.exists(outpath)) {
  dir.create(outpath, recursive = T)
}

# Temporal
n <- 0
aaot.temp <- c()
taot.temp <- c()
for (i in start.date.temp : end.date.temp) {
  
  print(paste('AOT Temporal', as.character(i)))
  
  n <- n + 1
  
  # Load the AOD data
  load(file = file.path(inpath.aaot, paste(as.character(year), sprintf('%03d', i), '_RF.RData', sep = ''))) # AAOT
  dat.aaot <- rf.result
  load(file = file.path(inpath.taot, paste(as.character(year), sprintf('%03d', i), '_RF.RData', sep = ''))) # TAOT
  dat.taot <- rf.result
  
  # Subset by lat/lon range
  # AAOT
  dat.aaot.temp <- subset(dat.aaot, Lat >= min(lat.range.temp) & Lat <= max(lat.range.temp) & Lon >= min(lon.range.temp) & Lon <= max(lon.range.temp))
  # TAOT
  dat.taot.temp <- subset(dat.taot, Lat >= min(lat.range.temp) & Lat <= max(lat.range.temp) & Lon >= min(lon.range.temp) & Lon <= max(lon.range.temp))
  
  # Only select gap-filling AOD (remove original AOD)
  dat.aaot.temp$AAOT550_New[dat.aaot.temp$Gapfill_tag_AAOT550 == 0] <- NA
  dat.taot.temp$TAOT550_New[dat.taot.temp$Gapfill_tag_TAOT550 == 0] <- NA
  
  # Temporal trend
  aaot.temp[n] <- mean(dat.aaot.temp$AAOT550_New, na.rm = T) # AAOT
  taot.temp[n] <- mean(dat.taot.temp$TAOT550_New, na.rm = T) # TAOT
  
}

# Spatial
n <- 0
for (j in start.date.spatial : end.date.spatial) {
  
  print(paste('AOT Spatial', as.character(j)))
  
  n <- n + 1
  
  # Load the AOD data
  load(file = file.path(inpath.aaot, paste(as.character(year), sprintf('%03d', j), '_RF.RData', sep = ''))) # AAOT
  dat.aaot <- rf.result
  load(file = file.path(inpath.taot, paste(as.character(year), sprintf('%03d', j), '_RF.RData', sep = ''))) # TAOT
  dat.taot <- rf.result
  
  # Subset by lat/lon range
  dat.aaot.spatial <- subset(dat.aaot, Lat >= min(lat.range.spatial) & Lat <= max(lat.range.spatial) & Lon >= min(lon.range.spatial) & Lon <= max(lon.range.spatial))
  dat.taot.spatial <- subset(dat.taot, Lat >= min(lat.range.spatial) & Lat <= max(lat.range.spatial) & Lon >= min(lon.range.spatial) & Lon <= max(lon.range.spatial))
  
  # Only select gap-filling AOD (remove original AOD)
  dat.aaot.spatial$AAOT550_New[dat.aaot.spatial$Gapfill_tag_AAOT550 == 0] <- NA
  dat.taot.spatial$TAOT550_New[dat.taot.spatial$Gapfill_tag_TAOT550 == 0] <- NA
  
  # Spatial pattern
  if (n == 1) {
    dat.aaot.spatial[ , 5] <- NULL
    aaot.spatial.tmp <- dat.aaot.spatial
    dat.taot.spatial[ , 5] <- NULL
    taot.spatial.tmp <- dat.taot.spatial
  } else {
    # AAOT
    dat.aaot.spatial[ , 5] <- NULL
    dat.aaot.spatial$Lat <- NULL
    dat.aaot.spatial$Lon <- NULL
    aaot.spatial.tmp <- merge(x = aaot.spatial.tmp, y = dat.aaot.spatial, by = c('ID'), all = T)
    # TAOT
    dat.taot.spatial[ , 5] <- NULL
    dat.taot.spatial$Lat <- NULL
    dat.taot.spatial$Lon <- NULL
    taot.spatial.tmp <- merge(x = taot.spatial.tmp, y = dat.taot.spatial, by = c('ID'), all = T)
  }
  
}

# Averaging the AOD spatial pattern
aaot.spatial <- data.frame(ID = aaot.spatial.tmp$ID, Lat = aaot.spatial.tmp$Lat, Lon = aaot.spatial.tmp$Lon)
aaot.spatial$AAOT550_Mean <- rowMeans(x = aaot.spatial.tmp[4 : ncol(aaot.spatial.tmp)], na.rm = T)
taot.spatial <- data.frame(ID = taot.spatial.tmp$ID, Lat = taot.spatial.tmp$Lat, Lon = taot.spatial.tmp$Lon)
taot.spatial$TAOT550_Mean <- rowMeans(x = taot.spatial.tmp[4 : ncol(taot.spatial.tmp)], na.rm = T)

# Save the file
# AAOT
aaot.fire <- list(aaot.spatial = aaot.spatial, aaot.temp = aaot.temp)
save(aaot.fire, file = file.path(outpath, 'aaot_fire.RData'))
# TAOT
taot.fire <- list(taot.spatial = taot.spatial, taot.temp = taot.temp)
save(taot.fire, file = file.path(outpath, 'taot_fire.RData'))

