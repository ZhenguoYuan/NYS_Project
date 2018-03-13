#-------------------------------------
# Model Performance of AOD Gap-filling
# 
# Jianzhao Bi
# 3/7/2018
#-------------------------------------

setwd('/home/jbi6/NYS_Project/CaseStudies/CloudOnlyAOD/')

source('../../src/fun.R') # Load basic functions

year <- 2015

inpath <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/RF_CloudOnly/', as.character(year), sep = '')
outpath <- paste('/home/jbi6/terra/MAIAC_GRID_OUTPUT/CaseStudies/CloudOnlyAOD/RF_CloudOnly/Model_Perform/', as.character(year), sep = '')
if (!file.exists(outpath)) {
  dir.create(outpath, recursive = T)
}

# AAOT

rsq.aaot <- c()
mse.aaot <- c()
snow.im1.aaot <- data.frame()
snow.im2.aaot <- data.frame()
cloud.im1.aaot <- data.frame()
cloud.im2.aaot <- data.frame()


for (i in 1 : numOfYear(year)) {
  
  print(i)
  
  load(file.path(inpath, 'aqua550', paste(as.character(year), sprintf('%03d', i), '_RF_MODELPERF.RData', sep = '')))
  rsq.aaot[i] <- model.perform$rsq
  mse.aaot[i] <- model.perform$mse
  cloud.im1.aaot <- rbind(cloud.im1.aaot, data.frame(rank = which(names(model.perform$importance1) == 'Cloud_Frac_Day_New'),
                                                     value = model.perform$importance1['Cloud_Frac_Day_New']))
  cloud.im2.aaot <- rbind(cloud.im2.aaot, data.frame(rank = which(names(model.perform$importance2) == 'Cloud_Frac_Day_New'),
                                                     value = model.perform$importance2['Cloud_Frac_Day_New']))
}

model.perform.aaot <- list(rsq = rsq.aaot, mse = mse.aaot, 
                           cloud.im1 = cloud.im1.aaot, cloud.im2 = cloud.im2.aaot)

# TAOT

rsq.taot <- c()
mse.taot <- c()
snow.im1.taot <- data.frame()
snow.im2.taot <- data.frame()
cloud.im1.taot <- data.frame()
cloud.im2.taot <- data.frame()


for (i in 1 : numOfYear(year)) {
  
  print(i)
  
  load(file.path(inpath, 'terra550', paste(as.character(year), sprintf('%03d', i), '_RF_MODELPERF.RData', sep = '')))
  rsq.taot[i] <- model.perform$rsq
  mse.taot[i] <- model.perform$mse
  cloud.im1.taot <- rbind(cloud.im1.taot, data.frame(rank = which(names(model.perform$importance1) == 'Cloud_Frac_Day_New'),
                                                     value = model.perform$importance1['Cloud_Frac_Day_New']))
  cloud.im2.taot <- rbind(cloud.im2.taot, data.frame(rank = which(names(model.perform$importance2) == 'Cloud_Frac_Day_New'),
                                                     value = model.perform$importance2['Cloud_Frac_Day_New']))
}

model.perform.taot <- list(rsq = rsq.taot, mse = mse.taot, 
                           cloud.im1 = cloud.im1.taot, cloud.im2 = cloud.im2.taot)

# Output
save(model.perform.aaot, model.perform.taot, file = file.path(outpath, 'model_perform.RData'))

