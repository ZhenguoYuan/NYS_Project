#-------------------------------------
# Random Forest for AOD Gap-filling of 
# the CloudOnlyAOD case study
# 
# Jianzhao Bi
# 3/7/2018
#-------------------------------------

library(randomForest)
library(MASS)
library(foreach)
library(doSNOW)

setwd('/home/jbi6/NYS_Project/CaseStudies/CloudOnlyAOD/')

source('../../src/fun.R') # Load interp functions
source('../../RF/src/fun.R') # Load RF's function

# Arguments for R script
Args <- commandArgs()
# Year
year <- Args[6] # 6th argument is the first custom argument
start.date <- 1
end.date <- numOfYear(as.numeric(year))

inpath <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine/', as.character(year), sep = '')
outpath <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/RF_CloudOnly/', as.character(year), sep = '')

fm <- AOT550_New ~ Cloud_Frac_Day_New + DEM +
  RHUM_NARR + spec_humi_2m_NLDAS + temp_2m_NLDAS + total_prec_NLDAS +
  Y_Lat + X_Lon

## ---------- Parallel ---------- ##

this.doys <- split.doy(cluster.idx = as.numeric(Args[7]),
                       cluster.num = as.numeric(Args[8]), 
                       year = year, start.date = start.date, 
                       end.date = end.date)

## ---------- 3-Day Combination ---------- ##

for (i_day in 1 : length(this.doys)) {
  
  print(paste(this.doys[i_day], sep = ''))
  
  # Read adjacent days' data
  adj_factor <- 1 # 3 days
  dat <- data.frame()
  year_tmp <- as.numeric(substring(this.doys[i_day], 1, 4))
  doy_tmp <- as.numeric(substring(this.doys[i_day], 5, 7))
  for (j_adj in -adj_factor : adj_factor) { # Previous day, this day, and following day
    file.adj <- file.path(inpath, paste(year_tmp, sprintf('%03d', doy_tmp + j_adj), '_combine.RData', sep = ''))
    if (file.exists(file.adj)) {
      print(file.adj)
      load(file.adj)
      combine$Adj_tag <- j_adj
      dat <- rbind(dat, combine)
    }
  }
  
  ## ---------- Fitting ---------- ##
  ### TAOT550 nm ###
  print('-------- TAOT 550 --------')
  # Fitting data set
  dat.fit.TAOT550 <- subset(dat, select = c(ID, Lat, Lon, Y_Lat, X_Lon, AOD550_TAOT,
                                    Cloud_Frac_Day_Terra, Snow_Cover_Terra, DEM, 
                                    RHUM_NARR, spec_humi_2m_NLDAS, temp_2m_NLDAS, total_prec_NLDAS, Adj_tag))
  # Prediction data set
  dat.pred.TAOT550 <- dat.fit.TAOT550
  # Random Forest Gapfilling
  RF_Gapfill(dat.fit.TAOT550, dat.pred.TAOT550, type = 'terra550', outpath, fm)
  
  ### AAOT550 nm ###
  print('-------- AAOT 550 --------')
  # Fitting data set
  dat.fit.AAOT550 <- subset(dat, select = c(ID, Lat, Lon, Y_Lat, X_Lon, AOD550_AAOT,
                                            Cloud_Frac_Day_Aqua, Snow_Cover_Aqua, DEM, 
                                            RHUM_NARR, spec_humi_2m_NLDAS, temp_2m_NLDAS, total_prec_NLDAS, Adj_tag))
  # Prediction data set
  dat.pred.AAOT550 <- dat.fit.AAOT550
  # Random Forest Gapfilling
  RF_Gapfill(dat.fit.AAOT550, dat.pred.AAOT550, type = 'aqua550', outpath, fm)

  gc()
  
}
