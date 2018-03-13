#---------------------
# MAIAC AOD
# Jianzhao Bi
# 9/23/2017
#---------------------
# Produce daily MAIAC AOD

# Time starting
ptm <- proc.time()

setwd('/home/jbi6/NYS_Project/MAIAC_AOD/')

# Arguments for R script
Args <- commandArgs()
# Load functions
source('../src/fun.R') 
source('src/maiac.fun.R') 

### ---------- Parameters --------- ###

year <- Args[6]
type <- Args[7]
new.loc.path <- '../MAIAC_GRID/output/maiac_grid.csv'

## Files and DOYs
# h04v03 files and doys
inpath03 <- paste('/home/jbi6/aura/NYS_MAIAC_CSV/h04v03/', year, '/', type, '/', sep = '')
# aod03.info <- doy.get(inpath03)
# h04v04 files and doys
inpath04 <- paste('/home/jbi6/aura/NYS_MAIAC_CSV/h04v04/', year, '/', type, '/', sep = '')
# aod04.info <- doy.get(inpath04)

# Output path
outpath <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/MAIAC_AOD/', year, '/', type, '/', sep = '')

# Parallel parameters
cluster.idx <- as.numeric(Args[8]) # This cluster's number
cluster.num <- as.numeric(Args[9]) # Total number of clusters

options(warn = -1)
jobs <- split(1 : numOfYear(as.numeric(year)), 1 : cluster.num) # Job list of DOY
options(warn = 0)
this.jobs <- jobs[[cluster.idx]] # DOY indecies in this job
this.doys <- sprintf(paste(year, '%03d', sep = ''), this.jobs) # DOYs

### ---------- RUN --------- ###

for (di in this.doys) {
  print(di)
  aod.combine(di, inpath03, inpath04, outpath, new.loc.path, type)
}

# Time ending
proc.time() - ptm

### ---------- Test Plot ---------- ###
# a <- read.csv('~/Downloads/2006006_AAOT.csv', stringsAsFactors = F)
# library(ggplot2)
# gg1 <- ggplot()+geom_tile(data = a, aes(Lon, Lat, fill = AOD470, width = 0.02, height = 0.02), alpha = 1)


