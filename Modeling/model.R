#----------------------------
# LME_GAM Fitting for RF
# 
# Jianzhao Bi
# 12/3/2017
#----------------------------

library(MASS)
library(mgcv)
library(pls)
library(lubridate)

setwd('/home/jbi6/NYS_Project/Modeling/')
source('../src/fun.R')
source('src/mi_fun.R')

# Arguments for R script
Args <- commandArgs()
# Parameters
year <- Args[6] # 6th argument is the first custom argument
numdays <- numOfYear(as.numeric(year))
inpath.rf <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF'
inpath.cm <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling'
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

## ---------- Input ---------- ##

if (!file.exists(file.path(outpath, paste(year, '_COMBINE_RF.RData')))) {
  
  all <- data.frame()
  for (i_day in 1 : numdays) {
    
    print(i_day)
    
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
      dat.tmp <- merge(combine, rf.result, by.x = c('ID'), by.y = c('ID'), all = T)

      # Removing missing AOD & PM2.5
      dat.tmp <- subset(dat.tmp, !is.na(AOD550_TAOT.y) & !is.na(PM25))
      
      # Combining daily data
      all <- rbind(all, dat.tmp)
      
    }
  }
  
  # Save 'all'
  save(all ,file = file.path(outpath, paste(year, '_COMBINE_RF.RData', sep = '')))
  
} else {
  
  # Load 'all'
  load(file = file.path(outpath, paste(year, '_COMBINE_RF.RData', sep = '')))
  
}

## ---------- Modeling ---------- ##

# Organizing
all <- LME_GAM_ORG(all, year)
# Modeling
LME_GAM_result <- LME_GAM(all, year)
# Output
save(LME_GAM_result ,file = file.path(outpath, paste(year, '_LMEGAM_RF.RData', sep = '')))


## ---------- Cross-Validation ---------- ##
cv.r2 <- c()
for (i_cv in 1 : 100) {
  
  ## ----- Split ----- ##
  ## 90% of the sample size
  smp_size <- floor(0.9 * nrow(all))
  
  ## set the seed to make your partition reproductible
  train_ind <- sample(seq_len(nrow(all)), size = smp_size)
  
  dat.fit.train <- all[train_ind, ]
  dat.fit.test <- all[-train_ind, ]
  
  y <- dat.fit.test$PM25
  dat.fit.test$PM25 <- NULL
  
  ## ----- CV ----- ##
  LME_GAM_result <- LME_GAM(dat.fit.train, year, if.print = F)
  Pred <- LME_GAM_PRED(dat.fit.test, LME_GAM_result, year)
  cv.r2[i_cv] <- cor(y, Pred$Pred_2s_1) * cor(y, Pred$Pred_2s_1)
  
  print(paste('CV R2 ', as.character(i_cv), ': ', as.character(cv.r2[i_cv]), sep = ''))
  
  gc()
  
}

print('-----------------------------')
print(paste('Mean CV R2:', as.character(mean(cv.r2))))



