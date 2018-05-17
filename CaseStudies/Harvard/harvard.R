# ----------------
# Name: harvard.R
# Author: Jianzhao Bi
# Description: Harvard Gap-filling (Monthly, Parallel)
# Date: May 17, 2018
# ----------------

library(mgcv)
library(lubridate)

setwd('/home/jbi6/NYS_Project/CaseStudies/Harvard/')

source('../../src/fun.R')
source('src/harvard_fun.R')

# Arguments for R script
Args <- commandArgs()

# Time
year <- Args[6]

# -------------------- #
# ----- Parallel ----- #
# Parallel parameters
cluster.idx <- as.numeric(Args[7]) # This cluster's number
cluster.num <- as.numeric(Args[8]) # Total number of clusters
# Split tasks
options(warn = -1)
jobs <- split(1 : 12, 1 : cluster.num) # Job list of DOY
options(warn = 0)
this.jobs <- jobs[[cluster.idx]]
# ----- Parallel ----- #
# -------------------- #

# ----- Parameters ----- #
# 12 Months
month.start <- c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335)
month.end <- c(31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365)

# Paths
inpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_PRED_RFMODEL', as.character(year))
inpath.rf.aaot <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/', as.character(year), '/aqua550/', sep = '')
inpath.rf.taot <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/', as.character(year), '/terra550/', sep = '')
inpath.combine <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine/', as.character(year), sep = '')
outpath.fit <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/Harvard/PM25_FIT_HARVARD', as.character(year))
if (!file.exists(outpath.fit)) {
  dir.create(outpath.fit,recursive = T)
}
outpath.pred <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/Harvard/PM25_PRED_HARVARD', as.character(year))
if (!file.exists(outpath.pred)) {
  dir.create(outpath.pred,recursive = T)
}

# Buffer
buffer <- 100 # in km
is.buffer <- T # Whether use the buffer

# ----- Run ----- #

for (m in this.jobs) { # For a month
  
  dat.monthly.fit <- data.frame()
  dat.monthly.pred <- data.frame()
  
  # --- Combine Daily Data --- #
  
  for (i.doy in month.start[m] : month.end[m]) { 
    
    print(i.doy)
    print(Sys.time())
    
    # Load the PM2.5 data set
    pm25.filename <- file.path(inpath, paste(as.character(year), sprintf('%03d', i.doy), '_PM25PRED_RF.csv', sep = ''))
    
    if (file.exists(pm25.filename)) {
      
      # --- Load Data --- #
      
      dat <- read.csv(file = pm25.filename, stringsAsFactors = F)
      
      # Load the RF gap-filling data set to get the gap-filling tag
      load(file.path(inpath.rf.aaot, paste(as.character(year), sprintf('%03d', i.doy), '_RF.RData', sep = '')))
      aaot <- rf.result
      gapfill.tag.aaot <- aaot$Gapfill_tag_AAOT550
      load(file.path(inpath.rf.taot, paste(as.character(year), sprintf('%03d', i.doy), '_RF.RData', sep = '')))
      taot <- rf.result
      gapfill.tag.taot <- taot$Gapfill_tag_TAOT550
      gapfill.tag <- gapfill.tag.aaot | gapfill.tag.taot # Using "|" because the PM2.5 will be estimated by Harvard model as long as it predicted by gap-filled AAOT or TAOT
      dat.tag <- data.frame(ID = aaot$ID, gapfill.tag = gapfill.tag) # Indicating whether this PM2.5 is estimated from original AOD
      
      # Load the combined dataset
      load(file.path(inpath.combine, paste(as.character(year), sprintf('%03d', i.doy), '_combine.RData', sep = '')))
      combine <- subset(combine, select = c(ID, year, doy, Y_Lat, X_Lon, PM25))
      
      # merge PM2.5 prediction and the tag
      dat.daily <- merge(dat, dat.tag, by = c('ID'), all = F)
      dat.daily <- merge(dat.daily, combine, by = c('ID'), all.x = T)
      
      # Add month
      dat.daily$month <- m
      
      # --- Daily Mean --- #
      # Select EPA observations
      dat.daily.epa <- subset(dat.daily, !is.na(PM25)) # Select the PM2.5 values predicted by original AOD
      dat.daily.epa <- subset(dat.daily.epa, select = c(ID, X_Lon, Y_Lat, PM25))
      print(paste('nrow :', as.character(nrow(dat.daily.epa))))
      
      if (is.buffer) {
        # Calculate Daily EPA station mean within the buffer
        if (nrow(dat.daily.epa) != 0) {
          DailyEPAMean <- apply(dat.daily, 1, FUN = bufferMean, dat.daily.epa, buffer)
          dat.daily$DailyEPAMean <- DailyEPAMean
          dat.daily$sqrtDailyEPAMean <- sqrt(DailyEPAMean)
        } else {
          dat.daily$DailyEPAMean <- NA
          dat.daily$sqrtDailyEPAMean <- NA
        }
      } else {
        # Calculate Daily EPA station regional mean
        if (nrow(dat.daily.epa) != 0) {
          DailyEPAMean <- mean(dat.daily.epa$PM25, na.rm = T)
          dat.daily$DailyEPAMean <- DailyEPAMean
          dat.daily$sqrtDailyEPAMean <- sqrt(DailyEPAMean)
        } else {
          dat.daily$DailyEPAMean <- NA
          dat.daily$sqrtDailyEPAMean <- NA
        }
      }
      
      # Sqrt PM2.5
      dat.daily$sqrtPM25_Pred <- sqrt(dat.daily$PM25_Pred)
      
      # Fitting and predicting data sets
      dat.daily.fit <- dat.daily[dat.daily$gapfill.tag == F, ]
      dat.daily.pred <- dat.daily[dat.daily$gapfill.tag == T,]
      
      # Combine daily data sets
      dat.monthly.fit <- rbind(dat.monthly.fit, dat.daily.fit)
      dat.monthly.pred <- rbind(dat.monthly.pred, dat.daily.pred)
      
    }
    
  }
  
  # --- Harvard Gap-filling --- #
  
  harvmod <- gam(sqrtPM25_Pred ~ sqrtDailyEPAMean + s(X_Lon, Y_Lat), data = dat.monthly.fit)
  sqrtPred <- predict(harvmod, dat.monthly.pred)
  Pred <- sqrtPred * sqrtPred
  
  # Assign gap-filled values
  dat.monthly.pred$PM25_Pred_Harvard <- Pred
  dat.monthly.pred$harvard.fill.tag <- 1
  
  dat.monthly.fit$PM25_Pred_Harvard <- dat.monthly.fit$PM25_Pred
  dat.monthly.fit$harvard.fill.tag <- 0
  
  # Combining fit and pred data sets
  dat.monthly <- rbind(dat.monthly.fit, dat.monthly.pred)
  dat.monthly <- dat.monthly[order(dat.monthly$ID),]
  
  # --- Cross-validation --- #
  # Output screen contents to file
  sink(file = file.path(outpath.fit, paste(as.character(year), sprintf('%02d', m), 'HarvardModel.txt', sep = '_')))
  # Cross-validation
  harvardCV(dat.monthly.fit)
  # End the screen output
  sink()
  
  # --- Save Predicted Data --- #
  
  for (i.doy in month.start[m] : month.end[m]) {
    
    dat.daily.harvard <- subset(dat.monthly, month == m & doy == i.doy)
    if (nrow(dat.daily.harvard) > 0) {
      save(dat.daily.harvard, file = file.path(outpath.pred, paste(as.character(year), sprintf('%03d', i.doy), '_HARVARD.RData', sep = '')))
    }
  }
  
  gc()
  
  
}

# # ----- Plot ----- #
# library(ggplot2)
# 
# jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
# 
# gg <- ggplot() +
#   geom_tile(data = dat.monthly.fit, aes(Lon, Lat, fill = dat.monthly.fit$PM25_Pred, width = 0.014, height = 0.014), alpha = 1) +
#   scale_fill_gradientn(colours = jet.colors(100), limits = c(0,10), oob = scales::squish, na.value = NA)
# 
# gg.new <- ggplot() +
#   geom_tile(data = dat.monthly, aes(Lon, Lat, fill = PM25_Pred_Harvard, width = 0.014, height = 0.014), alpha = 1) +
#   scale_fill_gradientn(colours = jet.colors(100), limits = c(0,10), oob = scales::squish, na.value = 'white')


