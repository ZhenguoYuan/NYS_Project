#library(ncdf4)
#library(ggplot2)

# Time starting
ptm <- proc.time()

setwd('/home/jbi6/NYS_Project/POP/')

source('../src/fun.R')
source('src/fun.R')
source('../src/latlon.R')

# Paths
inpath <- '/home/jbi6/terra/POP_ORI/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/POP/'
if(!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

# Arguments for R script
Args <- commandArgs()
year <- Args[6]

# # NC files
# file.all <- dir(inpath, pattern = '*.nc')
# CSV files
file.all <- dir(inpath, pattern = '*.csv')
# Find the proper file
file <- file.all[grep(year, file.all)]

# Reference Lat/Lon
new.loc <- read.csv('../MAIAC_GRID/output/maiac_grid.csv', stringsAsFactors = F)

## ---------- RUN ---------- ##
print(file)
# Load pop data
#pop.dat <- load.pop(inpath, file)
pop.dat <- read.csv(file = file.path(inpath, file))

# ----- Population Assginment ----- #
# Clipping
pop.dat <- subset(pop.dat, lon >= min(lon.range) & lon <= max(lon.range) & lat >= min(lat.range) & lat <= max(lat.range))
# New data
pop.dat.new <- new.loc
pop.dat.new$pop <- 0
# Assignment
print('Assigning population...')
for (i in 1 : nrow(pop.dat)) {
  new.idx <- over.idx(pop.dat[i, ], new.loc)
  pop.dat.new[new.idx,]$pop <- pop.dat.new[new.idx,]$pop + pop.dat[i,]$pop
}
print('Done!')
# IDW
#pop.dat.new <- idw.interp(pop.dat$lon, pop.dat$lat, pop.dat$pop, new.loc$Lon, new.loc$Lat, nmax = 1)
names(pop.dat.new) <- c('ID', 'lat', 'lon', 'pop')

# ----- Save files ----- #
write.csv(x = pop.dat.new, file = file.path(outpath, paste(substring(file, first = 1, last = 9), '.csv', sep = '')), row.names = F)

# Time ending
proc.time() - ptm

