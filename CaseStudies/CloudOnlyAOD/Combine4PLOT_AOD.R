# Combine the AOD data for Cloud Only Case Study
#
# Author: Jianzhao
# Date: Mar 8, 2018

setwd('/home/jbi6/NYS_Project/CaseStudies/CloudOnlyAOD/')

source('../../src/fun.R')
source('../../Validations/PLOT2D/src/fun.R')

year <- 2015
ndays <- numOfYear(year)
day.range <- 1 : 112

### ---------- Cloud Only ---------- ###

## ---------- Combining ---------- ##

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/RF_CloudOnly/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/PLOT2D/PLOTAOD/'
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

## ---------- RF ---------- ##
# AAOT550 cloud-only gapfilled
aaot550.combine.cldonly <- aodCombine(year, day.range, inpath, 'aqua550', 'gapfilled')
names(aaot550.combine.cldonly)[4] <- 'AAOT550_Mean'
save(aaot550.combine.cldonly, file = file.path(outpath, 'aaot550_combine_cloudonly.RData'))

# TAOT550 cloud-only gapfilled
taot550.combine.cldonly <- aodCombine(year, day.range, inpath, 'terra550', 'gapfilled')
names(taot550.combine.cldonly)[4] <- 'TAOT550_Mean'
save(taot550.combine.cldonly, file = file.path(outpath, 'taot550_combine_cloudonly.RData'))


### ---------- Cloud & Snow ---------- ###

## ---------- Combining ---------- ##

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/PLOT2D/PLOTAOD/'
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

## ---------- RF ---------- ##
# AAOT550 cloud+snow gapfilled
aaot550.combine.cldsnw <- aodCombine(year, day.range, inpath, 'aqua550', 'gapfilled')
names(aaot550.combine.cldsnw)[4] <- 'AAOT550_Mean'
save(aaot550.combine.cldsnw, file = file.path(outpath, 'aaot550_combine_cloudsnow.RData'))

# TAOT550 cloud+snow gapfilled
taot550.combine.cldsnw <- aodCombine(year, day.range, inpath, 'terra550', 'gapfilled')
names(taot550.combine.cldsnw)[4] <- 'TAOT550_Mean'
save(taot550.combine.cldsnw, file = file.path(outpath, 'taot550_combine_cloudsnow.RData'))

