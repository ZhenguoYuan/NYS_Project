#-------------------------------------
# Functions used in Random Forest 
# for AOD Gap-filling
# 
# Jianzhao Bi
# 3/6/2018
#-------------------------------------

### Gap-filling by Random Forest
RF_Gapfill <- function(dat.fit, dat.pred, type, outpath, formula) {
  ## type can be either "terra550" or "aqua550"
  
  # Choose the data according to the type
  if (type == 'terra550') {
    # Fitting data
    dat.fit$AOT550_New <- dat.fit$AOD550_TAOT
    dat.fit$Cloud_Frac_Day_New <- dat.fit$Cloud_Frac_Day_Terra
    dat.fit$Snow_Cover_New <- dat.fit$Snow_Cover_Terra
    # Predicting data
    dat.pred$AOT550_New <- dat.pred$AOD550_TAOT
    dat.pred$Cloud_Frac_Day_New <- dat.pred$Cloud_Frac_Day_Terra
    dat.pred$Snow_Cover_New <- dat.pred$Snow_Cover_Terra
  } else if (type == 'aqua550') {
    # Fitting data
    dat.fit$AOT550_New <- dat.fit$AOD550_AAOT
    dat.fit$Cloud_Frac_Day_New <- dat.fit$Cloud_Frac_Day_Aqua
    dat.fit$Snow_Cover_New <- dat.fit$Snow_Cover_Aqua
    # Predicting data
    dat.pred$AOT550_New <- dat.pred$AOD550_AAOT
    dat.pred$Cloud_Frac_Day_New <- dat.pred$Cloud_Frac_Day_Aqua
    dat.pred$Snow_Cover_New <- dat.pred$Snow_Cover_Aqua
  } else {
    stop('AOD type does not exist!')
  }
  
  if (!all(is.na(dat.fit$AOT550_New))) { # Check if the AOT is all missing
    
    # Remove rows with NAs
    idx <- rowMeans(dat.fit)
    dat.fit <- subset(dat.fit, subset = !is.na(idx)) # Keep the rows without NAs 
    
    if (nrow(dat.fit) != 0) { # Check if the data is all missing
      
      dat.fit$Gapfill_tag <- 0 # Gap-filling Tag
      
      ## ---- Reducing Sample Size ---- ##
      # Random choosing subset of the data
      if (nrow(dat.fit) > 100000) {
        idx_sub <- sample(seq_len(nrow(dat.fit)), size = 100000)
        dat.fit.sub <- dat.fit[idx_sub, ]
      } else {
        dat.fit.sub <- dat.fit
      }
      
      print(paste('Sample dimension:', nrow(dat.fit.sub)))
      
      ## ---- RF Fitting ---- ##
      ptm <- proc.time()
      
      rf.fit <- ranger(formula = formula, data = dat.fit.sub, num.trees = 100, importance = 'impurity', num.threads = 20, seed = 1118)
      
      print(proc.time() - ptm)
      
      ## ---- Model Performance ---- ##
      # Overall
      print(rf.fit)
      # Importance
      imp <- rf.fit$variable.importance # mean decrease in node impurity
      imp <- imp[order(imp, decreasing = T)]
      print('Mean decrease in node impurity')
      print(imp)
      # Save performance results
      model.perform <- list(rsq = rf.fit$r.squared, mse = rf.fit$prediction.error, importance = imp)
      
      
      ## ---------- Prediction ---------- ##
      dat.pred <- subset(dat.pred, subset = is.na(idx)) # Keep the rows with NAs 
      dat.pred$AOT550_New <- NULL
      dat.pred$Gapfill_tag <- 1 # Gap-filling Tag
      
      # Handle missing predictors 
      pred.miss.idx <- apply(X = is.na(subset(dat.pred, select = all.vars(formula)[2 : length(all.vars(formula))])), MARGIN = 1, FUN = any)
      dat.pred.miss <- dat.pred[pred.miss.idx, ]
      dat.pred.nomiss <- dat.pred[!pred.miss.idx, ]
      
      # Prediction
      AOD550_pred <- predict(rf.fit, dat.pred.nomiss, num.threads = 20)
      dat.pred.nomiss$AOT550_New <- AOD550_pred$predictions
      dat.pred.miss$AOT550_New <- NA
      dat.pred <- rbind(dat.pred.nomiss, dat.pred.miss)
      
      # Combination
      dat.new <- rbind(dat.fit, dat.pred)
      dat.new <- subset(dat.new, dat.new$Adj_tag == 0) # Keep this day's data
      dat.new <- dat.new[order(dat.new$Lat, dat.new$Lon), ]
      dat.new <- subset(dat.new, select = c(ID, Lat, Lon, AOT550_New, Gapfill_tag, Adj_tag))
      rf.result <- dat.new
      
      print(paste('Result dimension:', nrow(rf.result)))
      
      ## ---------- Data Clearance ---------- ##
      
      # Missing rate
      missing.rate <- sum(is.na(rf.result$AOT550_New)) / nrow(rf.result) * 100
      print(paste('Missing Rate: ', as.character(missing.rate), '%', sep = ''))
      
      # Changing AOD's name
      if (type == 'terra550') {
        rf.result$TAOT550_New <- rf.result$AOT550_New
        rf.result$Gapfill_tag_TAOT550 <- rf.result$Gapfill_tag
        rf.result <- subset(rf.result, select = c(ID, Lat, Lon, TAOT550_New, Gapfill_tag_TAOT550))
      } else if (type == 'aqua550') {
        rf.result$AAOT550_New <- rf.result$AOT550_New
        rf.result$Gapfill_tag_AAOT550 <- rf.result$Gapfill_tag
        rf.result <- subset(rf.result, select = c(ID, Lat, Lon, AAOT550_New, Gapfill_tag_AAOT550))
      }
      
      # Showing time
      Sys.time()
      
      ## ---------- Output ---------- ##
      
      # Save the RF results
      outpath.final <- file.path(outpath, type)
      if (!file.exists(outpath.final)) {
        dir.create(outpath.final, recursive = T)
      }
      save(rf.result, file = file.path(outpath.final, paste(this.doys[i_day], '_RF.RData', sep='')))
      save(model.perform, file = file.path(outpath.final, paste(this.doys[i_day], '_RF_MODELPERF.RData', sep='')))
      
    }
  }
  
  return()
  
}

