#----------------------------
# LME_GAM Prediction for RF
# 
# Jianzhao Bi
# 11/30/2017
#----------------------------

library(mgcv)
library(lubridate)

setwd('/home/jbi6/NYS_Project/Modeling/')
source('../src/fun.R')
source('src/fun.R')

# Arguments for R script
Args <- commandArgs()
# Parameters
year <- Args[6] # 6th argument is the first custom argument
numdays <- numOfYear(as.numeric(year))
# Input paths
inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling'
inpath.rf <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF'
inpath.cm <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine'
# Output path
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/LME_GAM/PM25_PRED'
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

## ---------- RUN ---------- ##

for(i_day in 1 : numdays) {
  
  print(paste(Sys.time(), "----processing doy " ,i_day, sep = ''))
  
  ## ---------- Input ---------- ##
  # File paths
  file.rf <- file.path(inpath.rf, paste(year, sprintf('%03d', i_day), '_RF.RData', sep = ''))
  file.cm <- file.path(inpath.cm, paste(year, sprintf('%03d', i_day), '_combine.RData', sep = ''))
  
  if (file.exists(file.rf) & file.exists(file.cm)) {
    
    # Gap-fiiled AOD
    load(file.rf)
    rf.result$Lat <- NULL
    rf.result$Lon <- NULL
    # Combine data
    load(file.cm)
    
    # Combining RF and combine
    LME_Pred_Raw <- merge(combine, rf.result, by.x = c('ID'), by.y = c('ID'))
    
    ## ---------- Organizing ---------- ##
    
    LME_Pred_Raw <- LME_GAM_ORG(LME_Pred_Raw, year)
    # Removing missing AOD
    LME_Pred_Raw <- subset(LME_Pred_Raw, !is.na(AOD550_TAOT.y))
    
    ## ---------- Prediction ---------- ##
    # Load LME_GAM fitting results
    load(file.path(inpath, paste(year, '_LMEGAM_RF.RData', sep = '')))
    # Prediction
    Pred <- LME_GAM_PRED(LME_Pred_Raw, LME_GAM_result, year)
    
    ## ---------- Output ---------- ##
    write.csv(x = Pred, file = file.path(outpath, paste(year, sprintf('%03d', i_day), '_PM25PRED_RF.csv', sep = '')), row.names = F)
    print(paste(Sys.time(), "----completed doy ", i_day, sep = ''))
    
  }
  
  gc()
}
