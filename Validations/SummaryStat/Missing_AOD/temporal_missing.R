# Temporal trends of missing rate of AOD
#
# Author: Jianzhao Bi
# Date: Mar 5, 2018

library(ggplot2)
library(ggmap)
library(viridis)
library(RColorBrewer)
library(maptools)

setwd('/home/jbi6/NYS_Project/Validations/SummaryStat/Missing_AOD/')

source('src/fun.R')
source('../../../src/fun.R')

# Arguments from R script
Args <- commandArgs()

year <- as.numeric(Args[6])
inpath <- '/home/jbi6/aura/NYS_MAIAC_CSV_Validation/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/SummaryStat/Missing_AOD/'
if (!file.exists(outpath)) {
  dir.create(outpath, recursive = T)
}

# For each day
rates.aaot <- data.frame()
rates.taot <- data.frame()
for (doy in 1 : numOfYear(year)) {
  print(doy)
  
  ## For AAOT
  rates.daily.aaot <- calDailyMissingRate(inpath, aottype = 'AAOT', year, doy, shp.path = '../../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
  if (!is.null(rates.daily.aaot)) {
    # List to Data Frame
    rates.daily.aaot <- as.data.frame(rates.daily.aaot)
    rates.daily.aaot <- subset(rates.daily.aaot, select = c('year', 'doy', 'overall', 'cloud', 'snow', 'waterice'))
  } else {
    rates.daily.aaot <- data.frame(year = year, doy = doy, overall = NA, cloud = NA, snow = NA, waterice = NA)
  }
  # Combine data frame
  rates.aaot <- rbind(rates.aaot, rates.daily.aaot)
  
  ## For TAOT
  rates.daily.taot <- calDailyMissingRate(inpath, aottype = 'TAOT', year, doy, shp.path = '../../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
  if (!is.null(rates.daily.taot)) {
    # List to Data Frame
    rates.daily.taot <- as.data.frame(rates.daily.taot)
    rates.daily.taot <- subset(rates.daily.taot, select = c('year', 'doy', 'overall', 'cloud', 'snow', 'waterice'))
  } else {
    rates.daily.taot <- data.frame(year = year, doy = doy, overall = NA, cloud = NA, snow = NA, waterice = NA)
  }
  # Combine data frame
  rates.taot <- rbind(rates.taot, rates.daily.taot)
}

# Save data frames
save(rates.aaot, file = file.path(outpath, paste(as.character(year), 'AAOT_Temporal.RData', sep = '_')))
save(rates.taot, file = file.path(outpath, paste(as.character(year), 'TAOT_Temporal.RData', sep = '_')))






