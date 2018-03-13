# Combine the AOD data
#
# Author: Jianzhao
# Date: Mar 6, 2018

setwd('/home/jbi6/NYS_Project/Validations/PLOT2D/')

source('../../src/fun.R')
source('src/fun.R')

## ---------- Combining ---------- ##

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/PLOT2D/PLOTAOD/'
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

year <- 2015
ndays <- numOfYear(year)
day.range <- 1 : ndays

## ---------- RF ---------- ##
# AAOT550 overall
aaot550.combine <- aodCombine(year, day.range, inpath, 'aqua550', 'overall')
names(aaot550.combine)[4] <- 'AAOT550_Mean'
save(aaot550.combine, file = file.path(outpath, 'aaot550_combine.RData'))
# AAOT550 original
aaot550.combine.ori <- aodCombine(year, day.range, inpath, 'aqua550', 'original')
names(aaot550.combine.ori)[4] <- 'AAOT550_Mean_Ori'
save(aaot550.combine.ori, file = file.path(outpath, 'aaot550_combine_ori.RData'))
# AAOT550 gapfilled
aaot550.combine.gap <- aodCombine(year, day.range, inpath, 'aqua550', 'gapfilled')
names(aaot550.combine.gap)[4] <- 'AAOT550_Mean_Gap'
save(aaot550.combine.gap, file = file.path(outpath, 'aaot550_combine_gap.RData'))

# TAOT550 overall
taot550.combine <- aodCombine(year, day.range, inpath, 'terra550', 'overall')
names(taot550.combine)[4] <- 'TAOT550_Mean'
save(taot550.combine, file = file.path(outpath, 'taot550_combine.RData'))
# TAOT550 original
taot550.combine.ori <- aodCombine(year, day.range, inpath, 'terra550', 'original')
names(taot550.combine.ori)[4] <- 'TAOT550_Mean_Ori'
save(taot550.combine.ori, file = file.path(outpath, 'taot550_combine_ori.RData'))
# TAOT550 gapfilled
taot550.combine.gap <- aodCombine(year, day.range, inpath, 'terra550', 'gapfilled')
names(taot550.combine.gap)[4] <- 'TAOT550_Mean_Gap'
save(taot550.combine.gap, file = file.path(outpath, 'taot550_combine_gap.RData'))


# ## ---------- MI ---------- ##
# for (i in 1 : 300) { # How many days
#   
#   doy <- sprintf('%03d', i)
#   
#   file.mi <- file.path(inpath, 'MI', paste('2009', doy, '_MI.RData', sep = ''))
#   
#   if (file.exists(file.mi)) {
#     
#     print(file.mi)
#     
#     file.comebine <- file.path(inpath, 'Combine', paste('2009', doy, '_combine.RData', sep = ''))
#     
#     load(file.mi)
#     load(file.comebine)
#     
#     mi.result$year <- NULL
#     mi.result$doy <- NULL
#     mi.combine <- merge(combine, mi.result, by.x = 'ID', by.y = 'ID', all = T)
#     
#     mi.combine$AOT550_MI <- rowMeans(cbind(mi.combine$AOT550_1, mi.combine$AOT550_2, mi.combine$AOT550_3, mi.combine$AOT550_4, mi.combine$AOT550_5))
#     mi.combine <- subset(mi.combine, select = c(ID, Lat, Lon, AOT550_MI))
#     
#     # Calculating Averages
#     if (i == 1){
#       mi.combine.plot <- mi.combine
#     } else {
#       mi.combine$Lat <- NULL
#       mi.combine$Lon <- NULL
#       mi.combine.plot <- merge(mi.combine.plot, mi.combine, by.x = 'ID', by.y = 'ID', all = T)
#     }
#   }
#   
#   gc()
#   
# }
# 
# mi.combine.plot$AOT550_MI_Mean <- rowMeans(mi.combine.plot[4 : ncol(mi.combine.plot)])
# mi.combine.plot <- subset(mi.combine.plot, select = c(ID, Lat, Lon, AOT550_MI_Mean))
# 
# save(mi.combine.plot, file = file.path(outpath, 'mi_combine_plot.RData'))