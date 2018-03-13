# Calculating the daily AOD missingness
#
# Author: Jianzhao Bi
# May 10, 2018

library(maptools)

setwd('/home/jbi6/NYS_Project/Validations/SummaryStat/Missing_AOD/')

source('src/fun.R')
source('../../../src/fun.R')

year <- 2015

inpath.aaot <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/MAIAC_AOD/2015/AAOT'
inpath.taot <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/MAIAC_AOD/2015/TAOT'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/SummaryStat/Missing_AOD/'
if (!file.exists(outpath)) {
  dir.create(outpath, recursive = T)
}

shp.name = '../../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp'

aaot.daily.missing <- c()
taot.daily.missing <- c()
for (i in 1 : 365) {
  
  print(i)
  
  # Load the data
  dat.aaot <- read.csv(file = file.path(inpath.aaot, paste(as.character(year), sprintf('%03d', i), '_AAOT.csv', sep = '')), stringsAsFactors = F)
  dat.taot <- read.csv(file = file.path(inpath.taot, paste(as.character(year), sprintf('%03d', i), '_TAOT.csv', sep = '')), stringsAsFactors = F)
  
  # Cut by NYS shapefile
  dat.aaot.sub <- cutByShp(shp.name, dat.aaot)
  dat.taot.sub <- cutByShp(shp.name, dat.taot)
  
  # Calculate missing data percentage
  aaot.daily.missing[i] <- sum(is.na(dat.aaot.sub$AOD550)) / nrow(dat.aaot.sub)
  taot.daily.missing[i] <- sum(is.na(dat.taot.sub$AOD550)) / nrow(dat.taot.sub)
  
}

# Save files
daily.missing <- list(aaot.daily.missing = aaot.daily.missing, taot.daily.missing = taot.daily.missing)
save(daily.missing, file = file.path(outpath, 'Daily_Missing.RData'))
