#------------------
# NLDAS
# Jianzhao Bi
# 2/12/2017
#------------------

library(ncdf4)

setwd('/home/jbi6/NYS_Project/NLDAS/')

source('src/fun.R')
source('../src/fun.R')

# Arguments from R script
Args <- commandArgs()

# Time 
year <- as.numeric(Args[6])
numdays <- numOfYear(year)

# Paths
inpath_a <- paste('/home/jbi6/aura/NLDAS_ORI/data/NLDAS_FORA0125_H.002/', as.character(year), sep = '')
inpath_b <- paste('/home/jbi6/aura/NLDAS_ORI/data/NLDAS_FORB0125_H.002/', as.character(year), sep = '')
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/NLDAS'

# New Grid
new.loc.path <- '../MAIAC_GRID/output/maiac_grid.csv'
new.loc <- read.csv(new.loc.path, stringsAsFactors = F)

## Passing time range (Matching the satellite passing time)
# for terra, the passing time is LT 1030
time.range <- 15 : 21 # GMT 1400 - 2000, correspoding to EST 0900 - 1500

## ---------- PARALLEL ---------- ##

this.doys <- split.doy(cluster.idx = as.numeric(Args[7]),
                       cluster.num = as.numeric(Args[8]), 
                       year = year, start.date = 1, 
                       end.date = numOfYear(as.numeric(year))) 

## ---------- RUN ---------- ##
for (i.this.doy.char in 1 : length(this.doys)) {
  
  # This is the actually DOY!!!!!
  doy <- as.numeric(substring(this.doys[i.this.doy.char], 5, 7))
  
  # DOY to Date
  file.pattern <- as.Date(doy - 1, origin = paste(as.character(year), '01', '01', sep = '-'), format = '%Y-%m-%d')
  file.pattern <- as.character(file.pattern)
  file.pattern <- gsub(pattern = '-', replacement = '', x = file.pattern) # Remove '-' in the string
  print(file.pattern)
  
  ## ---------- LOAD ---------- ##
  # Loading NLDAS data
  files.daily.a <- dir(inpath_a, pattern = file.pattern)
  files.daily.b <- dir(inpath_b, pattern = file.pattern)
  nldas.daily <- hourly.to.daily(time.range, inpath_a, files.daily.a, inpath_b, files.daily.b)
  # Cutting the NLDAS data
  nldas.daily <- subset(nldas.daily, lon >= -81 & lon <= -70 & lat >= 39 & lat <= 47)
  
  ## ---------- IDW ---------- ##
  for (i in 3 : ncol(nldas.daily)) { # First 2 columns are lat/lon
    
    df.tmp <- idw.interp.final(nldas.daily, new.loc, i)
    if (i == 3){
      nldas.daily.new <- df.tmp
    } else {
      nldas.daily.new[[i]] <- df.tmp[[3]]
      colnames(nldas.daily.new)[i] <- colnames(df.tmp)[3]
    }
  }
  
  ## ---------- OUTPUT ---------- ##
  outpath.file <- file.path(outpath, as.character(year))
  if (!file.exists(outpath.file)){
    dir.create(outpath.file, recursive = T)
  }
  file.name <- paste(as.character(year), sprintf('%03d', doy), sep = '')
  save(nldas.daily.new, file = file.path(outpath.file, paste(file.name, '_NLDAS.RData', sep = '')))
  #write.csv(x = nldas.daily.new, file = file.path(outpath.file, paste(file.name, '_NLDAS.csv', sep = '')), row.names = F)
  
  gc()
  
}

## ---------- PLOT ---------- ##
library(ggplot2)
#ggplot() + geom_tile(data = nldas.daily.new, aes(lon, lat, fill = surf_pres, width = 0.047, height = 0.047), alpha = 1.0)
#ggplot() + geom_tile(data = nldas.daily, aes(lon, lat, fill = surf_pres, width = 0.15, height = 0.15), alpha = 1.0)
