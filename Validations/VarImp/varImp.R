#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: Variable Importance Plot
# Notice: the size of saved image is 600 * 600
#
# Apr 6, 2018
#----------------------------------------------------------------------

setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/VarImp/')

load('2015_RFMODEL_RF.RData')

library(randomForest)

varImpPlot(rf.fit, type = 1, main = 'Variable Importance')
