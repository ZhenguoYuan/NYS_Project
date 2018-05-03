#-------------------------------------
# Random Forest for PM2.5 Prediction
# 
# Jianzhao Bi
# 3/13/2018
#-------------------------------------

library(randomForest)
library(MASS)

setwd('/home/jbi6/NYS_Project/CaseStudies/Model_AOD')

source('../../src/fun.R') # Load interp functions
source('../../Modeling/src/rf_fun.R') # Load RF modeling functions
source('src/fun.R')

# Arguments for R script
Args <- commandArgs()
# Parameters
year <- Args[6] # 6th argument is the first custom argument
numdays <- numOfYear(as.numeric(year))

inpath.cm <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine', as.character(year))

## ---------- Without AOD ---------- ##

# Input paths
inpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/WithoutAOD/PM25_FIT_RFMODEL', as.character(year))
inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF', as.character(year))
# Output path
outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/WithoutAOD/PM25_PRED_RFMODEL', as.character(year))
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

RFPredAOD(inpath, inpath.rf, inpath.cm, outpath, year, start.date = 1, end.date = numdays, tag = 'WithoutAOD') 

# ## ---------- Original AOD ---------- ##
# 
# # Input paths
# inpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/Original/PM25_FIT_RFMODEL', as.character(year))
# inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF', as.character(year))
# # Output path
# outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/Original/PM25_PRED_RFMODEL', as.character(year))
# if (!file.exists(outpath)){
#   dir.create(outpath, recursive = T)
# }
# 
# RFPredAOD(inpath, inpath.rf, inpath.cm, outpath, year, start.date = 1, end.date = numdays, tag = 'Original') 
# 
# ## ---------- Gapfilled AOD (Cloud + Snow) ---------- ##
# 
# # Input paths
# inpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/Gapfilled/PM25_FIT_RFMODEL', as.character(year))
# inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF', as.character(year))
# # Output path
# outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/Gapfilled/PM25_PRED_RFMODEL', as.character(year))
# if (!file.exists(outpath)){
#   dir.create(outpath, recursive = T)
# }
# 
# RFPredAOD(inpath, inpath.rf, inpath.cm, outpath, year, start.date = 1, end.date = numdays, tag = 'Gapfilled') 
# 
# 
# ## ---------- Cloud Only Gapfilled AOD ---------- ##
# 
# # Input paths
# inpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/CloudOnly/PM25_FIT_RFMODEL', as.character(year))
# inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/RF_CloudOnly', as.character(year))
# # Output path
# outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/CloudOnly/PM25_PRED_RFMODEL', as.character(year))
# if (!file.exists(outpath)){
#   dir.create(outpath, recursive = T)
# }
# 
# RFPredAOD(inpath, inpath.rf, inpath.cm, outpath, year, start.date = 1, end.date = numdays, tag = 'Cloud Only') 


