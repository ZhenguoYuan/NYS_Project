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
var.labels <- c('Month','Visibility','Downward Shortwave Radiation','Julian Day','Specific Humidity','Wind Speed','CAPE','Terra AOD','Dew Point Temperature','Air Temperature','Potential Evaporation','Aqua AOD','Planetary Boundary Layer','Surface Pressure','Highway Distance','Major Road Distance','NDVI','Elevation','Population','PM2.5 Convolutional Layer')
varImpPlot(rf.fit, type = 1, main = '', n.var = 20, labels = var.labels)
varImpPlot(rf.fit, type = 1, main = '', n.var = 20)

# Scatter Plot
library(ggplot2)
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
dat <- data.frame(y = rf.fit$y, y.pred = rf.fit$predicted)

y.list.all <- as.data.frame(y.list.all)

fit <- lm(data = y.list.all, y ~ y.pred)

text <- data.frame(xpos = c(-Inf, -Inf, Inf, Inf),
                   ypos =  c(-Inf, Inf, -Inf, Inf),
                   annotateText = c("Bottom Left (h0,v0)","Top Left (h0,v1)"
                                    ,"Bottom Right h1,v0","Top Right h1,v1"),
                   hjustvar = c(0,0,1,1) ,
                   vjustvar = c(0,1,0,1))

ggplot(y.list.all, aes(x = y.pred, y = y)) + geom_bin2d(binwidth = c(0.7, 0.7)) + 
  geom_abline(intercept = 0, slope = 1, color = 'gray', linetype = 2) + geom_abline(intercept = fit$coefficients[1], slope = fit$coefficients[2], color = 'blue') + 
  scale_fill_gradientn(colours = jet.colors(100), limits = c(0, 150), oob = scales::squish) +
  xlab(expression(paste('PM2.5 Predictions (', mu, g/m^3, ')'))) +
  ylab(expression(paste('PM2.5 Measurements (', mu, g/m^3, ')'))) +
  labs(fill = expression('Count of \nData Point')) +
  coord_fixed(ratio = 1, xlim = c(0, 50), ylim = c(0, 50)) +
  geom_text(data = text, aes(x = xpos, y = ypos, hjust = hjustvar, vjust = vjustvar, label = annotateText))


  annotate('text', x = 0, y = 0, hjust = 0, vjust = 0.5, label = 'Overall CV') +
  annotate('text', x = 40, y = 10, label = 'N=25,599') +
  annotate('text', x = 40, y = 8, label = 'R2=0.82') +
  annotate('text', x = 40, y = 6, label = 'RMSE=2.18')
