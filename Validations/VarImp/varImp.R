#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: Variable Importance Plot
# Notice: the size of saved image is 600 * 600
#
# Apr 20, 2018
#----------------------------------------------------------------------

setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/VarImp/')

load('data/2015_RFMODEL_RF.RData')

library(randomForest)

# Variable Importance Plot
var.labels <- c('Month','Visibility','Downward Shortwave Radiation','Julian Day','Specific Humidity','Wind Speed','CAPE','Terra AOD','Dew Point Temperature','Air Temperature','Potential Evaporation','Aqua AOD','Planetary Boundary Layer','Surface Pressure','Highway Distance','Major Road Distance','NDVI','Elevation','Population','PM2.5 Convolutional Layer')
varImpPlot(rf.fit, type = 1, main = '', n.var = 20, labels = var.labels)
varImpPlot(rf.fit, type = 1, main = '', n.var = 20)

# Scatter Plot
plot(rf.fit$predicted, rf.fit$y)
cor(rf.fit$predicted, rf.fit$y)
