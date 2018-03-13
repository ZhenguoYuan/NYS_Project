RFModelAOD <- function (inpath.cm, inpath.rf, outpath, year, start.date, end.date, filter = NULL) {
  
  ## -------------------------------------- ##
  ## -------------- Modeling -------------- ##
  ## -------------------------------------- ##
  
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
        
        # Filter the AOD
        if (!is.null(filter)) {
          dat.tmp <- subset(dat.tmp, subset = eval(parse(text = filter)))
        }
        
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
  
}

RFPredAOD <- function(inpath, inpath.rf, inpath.cm, outpath, year, start.date, end.date, tag) {
  
  ## ---------- RUN ---------- ##
  
  for (i in start.date : end.date) {
    
    print(paste(Sys.time(), tag, " :----processing doy " ,i, sep = ''))
    
    ## ---------- Input ---------- ##
    # File paths
    file.rf.aqua <- file.path(inpath.rf, 'aqua550', paste(year, sprintf('%03d', i), '_RF.RData', sep = ''))
    file.rf.terra <- file.path(inpath.rf, 'terra550', paste(year, sprintf('%03d', i), '_RF.RData', sep = ''))
    file.cm <- file.path(inpath.cm, paste(year, sprintf('%03d', i), '_combine.RData', sep = ''))
    
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
          #print(names(RF_Pred_Raw))
          PM25_Pred <- predict(rf.fit, RF_Pred_Raw)
          RF_Pred_Raw$PM25_Pred <- PM25_Pred
          Pred <- subset(RF_Pred_Raw, select = c(ID, Lat, Lon, PM25_Pred))
          
          ## ---------- Output ---------- ##
          write.csv(x = Pred, file = file.path(outpath, paste(year, sprintf('%03d', i), '_PM25PRED_RF.csv', sep = '')), row.names = F)
          
          print(paste(Sys.time(), tag, ": ----completed doy ", i, sep = ''))
          
        } else {
          print(paste(Sys.time(), tag, ": ----skipped doy ", i, sep = ''))
        }
        
      } else {
        print(paste(Sys.time(), tag, ": ----skipped doy ", i, sep = ''))
      }
    }
    
    gc()
    
  }
}

