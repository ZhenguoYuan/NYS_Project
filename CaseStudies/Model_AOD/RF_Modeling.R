#-------------------------------------
# Random Forest for PM2.5 Modeling
# Using different types of AOD
# 
# Jianzhao Bi
# 3/7/2018
#-------------------------------------

library(randomForest)
library(MASS)

setwd('/home/jbi6/NYS_Project/CaseStudies/Model_AOD')

source('../../src/fun.R') # Load interp functions
source('../../Modeling/src/rf_fun.R') # Load RF modeling functions
source('src/fun.R')

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

fm.no.aod <- PM25 ~ 
  # --- AOD --- #
  #AAOT550_New + 
  #TAOT550_New +
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


## ---------- Parameters ---------- ##

# Arguments for R script
Args <- commandArgs()
# Year
year <- Args[6] # 6th argument is the first custom argument
numdays <- numOfYear(as.numeric(year))
inpath.cm <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine', as.character(year))

## ---------- Without AOD ---------- ##
inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF', as.character(year))
outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/WithoutAOD/PM25_FIT_RFMODEL', as.character(year))
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}
RFModelAOD(fm.no.aod, inpath.cm, inpath.rf, outpath, year, start.date = 1, end.date = numdays)

## ---------- Original AOD ---------- ##
inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF', as.character(year))
outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/Original/PM25_FIT_RFMODEL', as.character(year))
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}
RFModelAOD(fm, inpath.cm, inpath.rf, outpath, year, start.date = 1, end.date = numdays, 
               filter = 'Gapfill_tag_AAOT550 == 0 & Gapfill_tag_TAOT550 == 0')

## ---------- Gapfilled AOD (Cloud + Snow) ---------- ##
inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF', as.character(year))
outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/Gapfilled/PM25_FIT_RFMODEL', as.character(year))
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}
RFModelAOD(fm, inpath.cm, inpath.rf, outpath, year, start.date = 1, end.date = numdays, 
           filter = 'Gapfill_tag_AAOT550 == 1 & Gapfill_tag_TAOT550 == 1')

## ---------- Cloud Only Gapfilled AOD ---------- ##
inpath.rf <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/RF_CloudOnly', as.character(year))
outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/MODEL_AOD/CloudOnly/PM25_FIT_RFMODEL', as.character(year))
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}
RFModelAOD(fm, inpath.cm, inpath.rf, outpath, year, start.date = 1, end.date = numdays)

