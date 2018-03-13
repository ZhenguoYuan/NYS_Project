#---------------------
# PM2.5 Ground
# Jianzhao Bi
# 10/26/2017
#---------------------
# Generating files of ground PM2.5 observations

setwd('~/Google Drive/MAIAC Project/Codes/NYS_Project/PM25/')

source('../src/latlon.R')
source('src/fun.R')

inputpath.aqs <- 'data/AQS/'
inputpath.naps <- 'data/NAPS/'

## ----- Site Information ----- ##
site.info <- read.xls(file.path(inputpath.naps, 'Stations2016_v4.xlsx'), sheet = 1)

# For a single year
for (year in 2002 : 2016) {
  
  ## ----- EPA AQS ----- ##
  
  print(paste('AQS', year))
  dat.aqs <- epa.aqs(year, inputpath.aqs)
  
  ## ----- NAPS ----- ##
  print(paste('NAPS', year))
  if (year < 2010) { # Old NAPS
    dat.naps <- naps.old(year, site.info, inputpath.naps)
  } else {
    dat.naps <- naps.new(year, site.info, inputpath.naps)
  }
  
  ## ----- Combining ----- ##
  dat.final <- rbind(dat.aqs, dat.naps)
  # Ordering the data
  dat.final <- dat.final[order(dat.final$year, dat.final$doy), ]
  # Outputing the data
  write.csv(x = dat.final, file = paste('output/PM25_', as.character(year), '.csv', sep = ''), row.names = F)

}
