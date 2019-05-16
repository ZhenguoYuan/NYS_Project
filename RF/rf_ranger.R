#-------------------------------------
# Random Forest for AOD Gap-filling
# 
# Jianzhao Bi
# 3/6/2018
#-------------------------------------

library(ranger)

setwd('/home/jbi6/NYS_Project/RF/')

source('../src/fun.R') # Load interp functions
source('src/fun.R') # Load RF's function

# Year
year <- 2002

inpath <- paste('/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/Combine/', as.character(year), sep = '')
outpath <- paste('/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/RF/', as.character(year), sep = '')

# Formula
fm <- AOT550_New ~ Cloud_Frac_Day_New + Snow_Cover_New + DEM +
  RHUM_NARR + spec_humi_2m_NLDAS + temp_2m_NLDAS + total_prec_NLDAS +
  Y_Lat + X_Lon

## ---------- Parallel ---------- ##

this.doys <- split.doy(cluster.idx = 1,
                       cluster.num = 1, 
                       year = year, start.date = 1, 
                       end.date = numOfYear(as.numeric(year))) 

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
