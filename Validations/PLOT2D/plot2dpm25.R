#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: Plotting PM2.5 distribution (Annual and 4 seasons)
# Notice: the size of saved image is 535 * 502
#
# Apr 6, 2018
#----------------------------------------------------------------------

library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)

setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/PLOT2D/')
source('../../src/fun.R')
source('src/plot_fun.R')

xlim <- c(-79.8, -72)
ylim <- c(40.5, 45)

for (year in 2015 : 2015) {
  
  
  ## ---------- Shp & Colorbar ---------- ##
  
  # Read shp
  myshp <- readShapePoly('../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
  myshp <- subset(myshp, NAME == 'New York') # Select NYS shp
  myshp <- fortify(myshp)
  
  # colorbar
  # define jet colormap
  jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
  rainbow.colors <- colorRampPalette(c('#0000ff', '#0054ff', '#00abff', '#00ffff', '#54ffab', '#abff53', '#ffff00', '#ffaa00', '#ff5400', '#ff0000'))
  
  # ---------- PLOT PM2.5 ---------- #
  
  # # Creating folders
  # dir.create(file.path('img/columbia/', as.character(year)), recursive = T)
  
  # All year 
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_snow.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_spring.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_summer.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_fall.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_winter.RData', sep = ''))
  
  pm25_combine_plot <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot)
  pm25_combine_plot_snow <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_snow)
  pm25_combine_plot_spring <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_spring)
  pm25_combine_plot_summer <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_summer)
  pm25_combine_plot_fall <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_fall)
  pm25_combine_plot_winter <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_winter)
  
  gg_pm25 <- plot2d(data = pm25_combine_plot, fill = pm25_combine_plot$PM25_Pred, 
                    colorbar = rainbow.colors, colorbar_limits = c(3, 10),
                    shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(a) PM2.5 Annual Distribution',
                    xlim = xlim, ylim = ylim, breaks = c(3, 4, 5, 6, 7, 8, 9, 10))
  #gg_pm25
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'PM2.5', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  mean(pm25_combine_plot$PM25_Pred)
  quantile(pm25_combine_plot$PM25_Pred, 0.25)
  quantile(pm25_combine_plot$PM25_Pred, 0.75)
  
  gg_pm25_snow <- plot2d(data = pm25_combine_plot_snow, fill = pm25_combine_plot_snow$PM25_Pred,
                           colorbar = rainbow.colors, colorbar_limits = c(3, 10),
                           shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(e) PM2.5 Snow Season Distribution',
                           xlim = xlim, ylim = ylim, hjust = 0, breaks = c(3, 4, 5, 6, 7, 8, 9, 10))
  
  #gg_pm25_snow
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'Snow_PM25', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_spring <- plot2d(data = pm25_combine_plot_spring, fill = pm25_combine_plot_spring$PM25_Pred,
                           colorbar = rainbow.colors, colorbar_limits = c(3, 10),
                           shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(a) PM2.5 Spring Distribution',
                           xlim = xlim, ylim = ylim, breaks = c(3, 4, 5, 6, 7, 8, 9, 10))
  #gg_pm25_spring
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'Spring_PM25', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_summer <- plot2d(data = pm25_combine_plot_summer, fill = pm25_combine_plot_summer$PM25_Pred,
                           colorbar = rainbow.colors, colorbar_limits = c(3, 10),
                           shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(b) PM2.5 Summer Distribution',
                           xlim = xlim, ylim = ylim, breaks = c(3, 4, 5, 6, 7, 8, 9, 10))
  #gg_pm25_summer
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'Summer_PM25', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_fall <- plot2d(data = pm25_combine_plot_fall, fill = pm25_combine_plot_fall$PM25_Pred,
                         colorbar = rainbow.colors, colorbar_limits = c(3, 10),
                         shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(c) PM2.5 Fall Distribution',
                         xlim = xlim, ylim = ylim, breaks = c(3, 4, 5, 6, 7, 8, 9, 10))
  #gg_pm25_fall
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'Fall_PM25', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_winter <- plot2d(data = pm25_combine_plot_winter, fill = pm25_combine_plot_winter$PM25_Pred,
                           colorbar = rainbow.colors, colorbar_limits = c(3, 10),
                           shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(d) PM2.5 Winter Distribution',
                           xlim = xlim, ylim = ylim, breaks = c(3, 4, 5, 6, 7, 8, 9, 10))
  #gg_pm25_winter
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'Winter_PM25', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  
  
  # # ----------- Plot Combine ---------- #
  # load('~/Downloads/2012032_combine.RData')
  # combine$wind <- sqrt(combine$UWND_NARR^2 + combine$VWND_NARR^2) # Wind speed
  # combine.plot <- plot2d(data = combine, fill = combine$MajorDist, 
  #                        colorbar = jet.colors, colorbar_limits = c(0, 120000),
  #                        shp = myshp, legend_name = '', title = '')
  
}