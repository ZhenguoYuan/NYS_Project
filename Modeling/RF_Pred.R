#-------------------------------------
# Random Forest for PM2.5 Prediction
# 
# Jianzhao Bi
# 3/3/2017
#-------------------------------------

library(randomForest)
library(MASS)

setwd('/home/jbi6/NYS_Project/Modeling/')
source('../src/fun.R') # Load interp functions
source('src/rf_fun.R')

# # Arguments for R script
# Args <- commandArgs()
# # Parameters
# year <- Args[6] # 6th argument is the first custom argument

for (year in 2002 : 2007) {
  
  numdays <- numOfYear(as.numeric(year))
  # Input paths
  inpath <- file.path('/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/Modeling/PM25_FIT_RFMODEL', as.character(year))
  inpath.rf <- file.path('/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/RF', as.character(year))
  inpath.cm <- file.path('/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/Combine', as.character(year))
  # Output path
  outpath <- file.path('/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/Modeling/PM25_PRED_RFMODEL', as.character(year))
  if (!file.exists(outpath)){
    dir.create(outpath, recursive = T)
  }
  
  ## ---------- PARALLEL ---------- ##
  
  # this.doys <- split.doy(cluster.idx = as.numeric(Args[7]),
  #                        cluster.num = as.numeric(Args[8]), 
  #                        year = year, start.date = 1, 
  #                        end.date = numOfYear(as.numeric(year))) 
  
  this.doys <- split.doy(cluster.idx = 1,
                         cluster.num = 1, 
                         year = year, start.date = 1, 
                         end.date = numOfYear(as.numeric(year))) 
  
  
  ## ---------- RUN ---------- ##
  
  for (i in 1 : length(this.doys)) {
    
    # DOY
    doy_tmp <- as.numeric(substring(this.doys[i], 5, 7))
    
    print(paste(Sys.time(), "----processing doy " ,doy_tmp, sep = ''))
    
    ## ---------- Input ---------- ##
    # File paths
    file.rf.aqua <- file.path(inpath.rf, 'aqua550', paste(year, sprintf('%03d', doy_tmp), '_RF.RData', sep = ''))
    file.rf.terra <- file.path(inpath.rf, 'terra550', paste(year, sprintf('%03d', doy_tmp), '_RF.RData', sep = ''))
    file.cm <- file.path(inpath.cm, paste(year, sprintf('%03d', doy_tmp), '_combine.RData', sep = ''))
    
    if (file.exists(file.rf.aqua) & file.exists(file.rf.terra) & file.exists(file.cm)) {
      
      # Gap-filled Aqua AOD
      load(file.rf.aqua)
      rf.result$Lat <- NULL
      rf.result$Lon <- NULL
      rf.result.aqua <- rf.result
      # Gap-filled Terra AOD
      load(file.rf.terra)
      rf.result$Lat <- NULL
      rf.result$Lon <- NULL
      rf.result.terra <- rf.result
      # Combine data
      load(file.cm)
      
      # Combining RF and combine
      RF_Pred_Raw <- merge(combine, rf.result.aqua, by = c('ID'), all = T)
      RF_Pred_Raw <- merge(RF_Pred_Raw, rf.result.terra, by = c('ID'), all = T)
      
      ## ---------- Organizing ---------- ##
      RF_Pred_Raw <- DAT_ORG(RF_Pred_Raw, year)
      # Removing missing AOD
      RF_Pred_Raw <- subset(RF_Pred_Raw, !is.na(AAOT550_New) & !is.na(TAOT550_New))
      
      # Check if all AOD data are missing
      if (nrow(RF_Pred_Raw) != 0) { # Skipping if there is no data
        
        ## ---------- Prediction ---------- ##
        # Load Random Forest fitting results
        load(file.path(inpath, paste(year, '_RFMODEL_RF.RData', sep = '')))
        
        # Comvolutional Layer
        RF_Pred_Raw <- covPred(RF_Pred_Raw)
        
        if (!is.null(RF_Pred_Raw)) { # Skipping if there is no data
          
          # Prediction
          PM25_Pred <- predict(rf.fit, RF_Pred_Raw)
          RF_Pred_Raw$PM25_Pred <- PM25_Pred
          Pred <- subset(RF_Pred_Raw, select = c(ID, Lat, Lon, PM25_Pred))
          
          ## ---------- Output ---------- ##
          write.csv(x = Pred, file = file.path(outpath, paste(year, sprintf('%03d', doy_tmp), '_PM25PRED_RF.csv', sep = '')), row.names = F)
          print(paste(Sys.time(), "----completed doy ", doy_tmp, sep = ''))
          
        } else {
          print(paste(Sys.time(), "----skipped doy ", doy_tmp, sep = ''))
        }
        
      } else {
        print(paste(Sys.time(), "----skipped doy ", doy_tmp, sep = ''))
      }
    }
    
    gc()
    
  }
  
}
