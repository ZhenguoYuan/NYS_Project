#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: Plotting PM2.5 distribution (Our Model and Harvard Model)
# Notice: the size of saved image is 535 * 502
#
# Apr 6, 2018
#----------------------------------------------------------------------

library(ggplot2)
library(ggmap)
library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)

setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/Harvard/')
source('../../src/fun.R')
source('../../Validations/PLOT2D/src/plot_fun.R')

year <- 2015

xlim <- c(-79.8, -72)
ylim <- c(40.5, 45)

## ---------- Shp & Colorbar ---------- ##

# Read shp
shp.name <- '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp'
myshp <- readShapePoly(shp.name)
myshp <- subset(myshp, NAME == 'New York') # Select NYS shp
myshp <- fortify(myshp)

# colorbar
# define jet colormap
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
rainbow.colors <- colorRampPalette(c('#0000ff', '#0054ff', '#00abff', '#00ffff', '#54ffab', '#abff53', '#ffff00', '#ffaa00', '#ff5400', '#ff0000'))

# ---------- Full ---------- #

# All year 
load(paste('../../Validations/PLOT2D/data/PLOTPM25/2015/pm25_combine_plot.RData', sep = ''))
pm25 <- pm25_combine_plot
pm25 <- cutByShp(shp.name = shp.name, pm25)

gg_pm25 <- plot2d(data = pm25, fill = pm25$PM25_Pred, 
                  colorbar = jet.colors, colorbar_limits = c(3, 10),
                  shp = myshp, legend_name = 'ug/m3', title = 'PM2.5 Annual Distribution',
                  xlim = xlim, ylim = ylim)


# ---------- Harvard ---------- #

# All year 
load(paste('data/pm25_combine_plot.RData', sep = ''))
pm25_harv <- pm25_combine_plot
pm25_harv <- cutByShp(shp.name = shp.name, pm25_harv)

gg_pm25_harv <- plot2d(data = pm25_harv, fill = pm25_harv$PM25_Pred_Avg, 
                       colorbar = rainbow.colors, colorbar_limits = c(3, 10),
                       shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(b) Gap-filled PM2.5 by Eq.3', 
                       xlim = xlim, ylim = ylim, breaks = c(3, 4, 5, 6, 7, 8, 9, 10))
