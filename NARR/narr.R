#---------------------
# NARR
#
# Jianzhao Bi
# 2/12/2018
#---------------------

setwd('/home/jbi6/NYS_Project/NARR/')

source('../src/fun.R') # Loading interp functions
source('src/fun.R') # Loading NARR functions

## ---------- Parameters---------- ##
# Arguments from R script
Args <- commandArgs()
year <- as.numeric(Args[6])
# Paths
inpath <- '/home/jbi6/terra/NARR_ORI/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/NARR/'
if (file.exists(outpath) == F) {
  dir.create(outpath, recursive = T)
}
# New data grid
new.loc <- read.csv('../MAIAC_GRID/output/maiac_grid.csv')

## Passing time range (Matching the satellite passing time)
# for terra, the passing time is LT 1030
time.range <- c(15, 21) # GMT 1500, 1800, 2100, correspoding to EST 1000, 1300, 1600


## ----------- RUN ------------ ##

file.prefix <- c('dlwrf', 'dpt.2m', 'dswrf', 'hpbl', 'pres.sfc', 'rhum.2m', 'air.2m', 'uwnd.10m', 'vis', 'vwnd.10m')
var.name <- c('dlwrf', 'dpt', 'dswrf', 'hpbl', 'pres', 'rhum', 'air', 'uwnd', 'vis', 'vwnd')


# ---------- Parallel Computing ---------- #
library(snow)
# Making the cluster
cl <- makeCluster(type = 'SOCK', c('localhost', 'localhost', 'localhost', 'localhost', 'localhost'))
clusterExport(cl, list = ls()) # For windows
# Splitting the jobs
pc.split(cl, file.prefix, var.name, year, inpath, outpath, new.loc, time.range)
stopCluster(cl)

# ---------- Non-parallel ---------- #
# for (i in 1 : length(file.prefix)) {
#   narr.daily(file.prefix = file.prefix[i], var.name = var.name[i], year, inpath, outpath, new.loc, time.range)
# }


