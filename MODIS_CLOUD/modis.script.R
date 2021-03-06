#---------------------
# MODIS Cloud
# Jianzhao Bi
# 9/23/2017
#---------------------
# Resample the MODIS Cloud into MAIAC Grid

# Time starting
ptm <- proc.time()

setwd('/home/jbi6/NYS_Project/MODIS_CLOUD/')

# Arguments for R script
Args <- commandArgs()

source('../src/fun.R') # Load interp functions
source('src/modis.fun.R') # Load functions used in MODIS Cloud processing

### ---------- Parameters --------- ###

# Year
year <- Args[6] # 6th argument is the first custom argument
# Dataset
datset <- c('MOD06_L2', 'MYD06_L2')
# MAIAC grid
new.loc <- read.csv('../MAIAC_GRID/output/maiac_grid.csv', stringsAsFactors = F)

# Parallel parameters
cluster.idx <- as.numeric(Args[7]) # This cluster's number
cluster.num <- as.numeric(Args[8]) # Total number of clusters

options(warn = -1)
jobs <- split(1 : numOfYear(as.numeric(year)), 1 : cluster.num) # Job list of DOY
options(warn = 0)
this.jobs <- jobs[[cluster.idx]] # DOY indecies in this job
this.doys <- sprintf(paste(year, '%03d', sep = ''), this.jobs) # DOYs

### ---------- RUN --------- ###
for (i in 1 : length(datset)) {
  # Input path
  inpath <- paste('/home/jbi6/terra/MODIS_Cloud/', datset[i], '/', year, '/csv/', sep = '')
  # Output path
  outpath <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/MODIS_Cloud/', year, '/', datset[i], '/', sep = '')
  # Run
  modis.cloud(inpath, outpath, new.loc, datset[i], this.doys)
}



# Time ending
proc.time() - ptm

### ---------- Test Plot ---------- ###
# a <- read.csv('~/Google Drive/New folder/output/2006001.csv', stringsAsFactors = F)
# library(ggplot2)
# gg1 <- ggplot()+geom_tile(data = a, aes(Lon, Lat, fill = Cloud_Frac, width = 0.02, height = 0.02), alpha = 1)
# gg2 <- ggplot()+geom_tile(data = dat.tmp, aes(Lon, Lat, fill = Cloud_Frac, width = 0.1, height = 0.1), alpha = 1)




