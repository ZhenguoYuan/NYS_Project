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
load('data/2015_CV_RF.RData')

library(randomForest)

# Variable Importance Plot
var.labels <- c('Month','Visibility','Dew Point Temperature','Julian Day','Downward Shortwave Radiation','Air Temperature','Terra AOD','CAPE','Potential Evaporation','Specific Humidity','Aqua AOD','Planetary Boundary Layer','Wind Speed','NDVI','Highway Distance','Surface Pressure','Elevation','Major Road Distance','Population','PM2.5 Convolutional Layer')
varImpPlot(rf.fit, type = 1, main = '', n.var = 20, labels = var.labels)
varImpPlot(rf.fit, type = 1, main = '', n.var = 20)

# Scatter Plot
library(ggplot2)
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

y.list.all <- as.data.frame(y.list.all)

fit <- lm(data = y.list.all, y ~ y.pred)
cor(y.list.all$y, y.list.all$y.pred)

ggplot(y.list.all, aes(x = y.pred, y = y)) + geom_bin2d(binwidth = c(0.7, 0.7)) + 
  geom_abline(intercept = 0, slope = 1, color = 'gray', linetype = 2) + geom_abline(intercept = fit$coefficients[1], slope = fit$coefficients[2], color = 'blue', size = 0.5, alpha = 0.5) + 
  scale_fill_gradientn(colours = jet.colors(100), limits = c(0, 150), oob = scales::squish) +
  xlab(expression(paste('PM2.5 Predictions (', mu, g/m^3, ')'))) +
  ylab(expression(paste('PM2.5 Measurements (', mu, g/m^3, ')'))) +
  labs(fill = expression('Count of \nData Point')) +
  coord_fixed(ratio = 1, xlim = c(0, 52), ylim = c(0, 52), expand = F) +
  theme(legend.key.height=unit(2.5, "line"), legend.text = element_text(size = rel(1)), 
        axis.text = element_text(size = rel(1)), axis.title = element_text(size = rel(1.2))) +
  annotate('text', x = 46, y = 9, label = 'N = 25,409', size = 4.1) +
  annotate('text', x = 45, y = 6.5, label = 'CV R2 = 0.82', size = 4.1) +
  annotate('text', x = 45, y = 4, label = 'RMSE = 2.16', size = 4.1) +
  annotate('text', x = 43.3, y = 1.5, label = 'Y = -0.42 + 1.05X', size = 4.1)

