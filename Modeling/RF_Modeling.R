#-------------------------------------
# Random Forest for PM2.5 Modeling
# 
# Jianzhao Bi
# 3/3/2018
#-------------------------------------

library(randomForest)
library(MASS)

setwd('/home/jbi6/NYS_Project/Modeling/')

source('../src/fun.R') # Load interp functions
source('src/rf_fun.R')

## -------------------------------------- ##
## -------------- Modeling -------------- ##
## -------------------------------------- ##

## ---------- Parameters ---------- ##

# Arguments for R script
Args <- commandArgs()
# Year
year <- Args[6] # 6th argument is the first custom argument
numdays <- numOfYear(as.numeric(year))
inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF', as.character(year))
inpath.cm <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine', as.character(year))
outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_FIT_RFMODEL', as.character(year))
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

# ---------- Formula ---------- ##
fm <- PM25 ~ 
  # --- AOD --- #
  AAOT550_New + 
  TAOT550_New +
  # --- Meteorology --- #
  # AIR_NARR +
  HPBL_NARR +
  # RHUM_NARR +
  DPT_NARR +
  VIS_NARR +
  WIND_NARR +
  temp_2m_NLDAS +
  surf_pres_NLDAS +
  pot_evap_NLDAS +
  # long_radi_surf_NLDAS +
  # short_radi_surf_NLDAS +
  short_flux_surf_NLDAS +
  spec_humi_2m_NLDAS +
  # total_prec_NLDAS +
  cape_NLDAS +
  # --- LULC --- #
  pop +
  HighwayDist + 
  MajorDist +
  DEM +
  # GRIDCODE +
  NDVI +
  PM_cov +
  # --- Time --- #
  month + 
  doy
  
## ---------- Data Organization ---------- ##

# Checking if the file "YYYY_COMBINE_RF.RData" exists.
# If yes, then directly loading the file and skipping the combination process.
if (!file.exists(file.path(outpath, paste(year, '_COMBINE_RF.RData', sep = '')))) {
  
  all <- data.frame()
  for (i_day in 1 : numdays) {
    
    print(i_day)
    
    # File paths
    file.rf.aqua <- file.path(inpath.rf, 'aqua550', paste(year, sprintf('%03d', i_day), '_RF.RData', sep = ''))
    file.rf.terra <- file.path(inpath.rf, 'terra550', paste(year, sprintf('%03d', i_day), '_RF.RData', sep = ''))
    file.cm <- file.path(inpath.cm, paste(year, sprintf('%03d', i_day), '_combine.RData', sep = ''))
    
    # Check if RF and Combine files exist
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
      dat.tmp <- merge(combine, rf.result.aqua, by = c('ID'), all = T)
      dat.tmp <- merge(dat.tmp, rf.result.terra, by = c('ID'), all = T)
      # Removing missing AOD & PM2.5
      dat.tmp <- subset(dat.tmp, !is.na(AAOT550_New) & !is.na(TAOT550_New) & !is.na(PM25))
      
      # Check if all AOD are missing
      if (nrow(dat.tmp) > 1) { 
        
        # Creating the convolutional layer
        dat.tmp <- covModel(dat.tmp)
        # Combining daily data
        all <- rbind(all, dat.tmp) 
        
      }
    }
  }
  
  # Save 'all'
  save(all ,file = file.path(outpath, paste(year, '_COMBINE_RF.RData', sep = '')))
  
} else {
  
  # Load 'all'
  load(file = file.path(outpath, paste(year, '_COMBINE_RF.RData', sep = '')))
  
}

##################################
# Output screen contents to file #
sink(file = file.path(outpath, paste(as.character(year), 'RFModel.txt', sep = '_')))
##################################

## ---------- Modeling ---------- ##

# Organizing
all <- DAT_ORG(all, year)
# RF Modeling
rf.fit <- RF_MODEL(all, fm)
# Output
save(rf.fit ,file = file.path(outpath, paste(year, '_RFMODEL_RF.RData', sep = '')))

## -------------------------------------- ##
## ---------- Cross-Validation ---------- ##
## -------------------------------------- ##

print('Modeling CV using all AOD')
RF_CV(all, fm, fold = 10, times = 1)

## ---------- Original or Gap-filling Cross-validation ---------- ##
# Using only original AOD or gap-filled AOD to predict PM2.5 and to calculate CV R2
# This process will not include the grid cells with only gap-filled AAOTor only gap-filled TAOT!

# Original AOD
print('Modeling CV using original AOD')
all_ori <- subset(all, Gapfill_tag_AAOT550 == 0 & Gapfill_tag_TAOT550 == 0) # Only select grid cells with original AOTs
RF_CV(all_ori, fm, fold = 10, times = 1)

# Gap-filled AOD
print('Modeling CV using gap-filled AOD')
all_gap <- subset(all, Gapfill_tag_AAOT550 == 1 & Gapfill_tag_TAOT550 == 1) # Only select grid cells with gap-filled AAOT and TAOT
RF_CV(all_gap, fm, fold = 10, times = 1)

## ---------- Spatial and Temporal Cross-validation ---------- ##

# Spatial CV
# Randomly removing certain PM2.5 sites to get the CV R2
print('Spatial CV')
all$site <- interaction(all$Lat, all$Lon) # Using Lat and Lon to locate a PM2.5 site
RF_CV(all, fm, fold = 10, times = 1, by = 'site')

# Temporal CV
# Randomly removing certain days of PM2.5 to get the CV R2
print('Temporal CV')
RF_CV(all, fm, fold = 10, times = 1, by = 'doy')

##################################
# Output screen contents to file #
sink()
##################################

## -------------------------------------- ##
## --------------- Tuning --------------- ##
## -------------------------------------- ##

# # Plot importance
# varImpPlot(rf.fit)
# # Plot MSE with number of trees
# plot(rf.fit)
# # RF CV
# # rfcv()
# # Tree size
# hist(treesize(rf.fit,terminal = TRUE))

