library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)

setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/PLOT2D/')
source('../../src/fun.R')
source('src/plot_fun.R')

for (year in 2015 : 2015) {
  
  
  ## ---------- Shp & Colorbar ---------- ##
  
  # Read shp
  myshp <- readShapePoly('../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
  myshp <- subset(myshp, NAME == 'New York') # Select NYS shp
  myshp <- fortify(myshp)
  
  # colorbar
  # define jet colormap
  jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
  
  # ---------- PLOT PM2.5 ---------- #
  
  # Creating folders
  dir.create(file.path('img/columbia/', as.character(year)), recursive = T)
  
  # All year 
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_spring.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_summer.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_fall.RData', sep = ''))
  load(paste('data/PLOTPM25/', as.character(year), '/pm25_combine_plot_winter.RData', sep = ''))
  
  pm25_combine_plot <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot)
  pm25_combine_plot_spring <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_spring)
  pm25_combine_plot_summer <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_summer)
  pm25_combine_plot_fall <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_fall)
  pm25_combine_plot_winter <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pm25_combine_plot_winter)
  
  gg_pm25 <- plot2d(data = pm25_combine_plot, fill = pm25_combine_plot$PM25_Pred, 
                    colorbar = jet.colors, colorbar_limits = c(3, 12),
                    shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'),
                    xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
  gg_pm25
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'PM2.5', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_spring <- plot2d(data = pm25_combine_plot_spring, fill = pm25_combine_plot_spring$PM25_Pred,
                           colorbar = jet.colors, colorbar_limits = c(3, 12),
                           shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Spring PM2.5'),
                           xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
  gg_pm25_spring
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'Spring PM2.5', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_summer <- plot2d(data = pm25_combine_plot_summer, fill = pm25_combine_plot_summer$PM25_Pred,
                           colorbar = jet.colors, colorbar_limits = c(3, 12),
                           shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Summer PM2.5'),
                           xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
  gg_pm25_summer
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'SummerPM2.5', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_fall <- plot2d(data = pm25_combine_plot_fall, fill = pm25_combine_plot_fall$PM25_Pred,
                         colorbar = jet.colors, colorbar_limits = c(3, 12),
                         shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Fall PM2.5'),
                         xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
  gg_pm25_fall
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'FallPM2.5', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  gg_pm25_winter <- plot2d(data = pm25_combine_plot_winter, fill = pm25_combine_plot_winter$PM25_Pred,
                           colorbar = jet.colors, colorbar_limits = c(3, 12),
                           shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Winter PM2.5'),
                           xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
  gg_pm25_winter
  #ggsave(filename = file.path('img/columbia/', as.character(year), paste(as.character(year), 'WinterPM2.5', '.png', sep = '')), width = 30, height = 30, units = 'cm')
  
  
  
  # # ----------- Plot Combine ---------- #
  # load('~/Downloads/2012032_combine.RData')
  # combine$wind <- sqrt(combine$UWND_NARR^2 + combine$VWND_NARR^2) # Wind speed
  # combine.plot <- plot2d(data = combine, fill = combine$MajorDist, 
  #                        colorbar = jet.colors, colorbar_limits = c(0, 120000),
  #                        shp = myshp, legend_name = '', title = '')
  
}