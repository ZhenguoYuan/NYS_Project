library(ggplot2)
library(ggmap)
library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)

setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/Model_AOD/')
source('../../src/fun.R')
source('../../Validations/PLOT2D/src/plot_fun.R')

year <- 2015


## ---------- Shp & Colorbar ---------- ##

# Read shp
myshp <- readShapePoly('../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
myshp <- fortify(myshp)

# colorbar
# define jet colormap
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

# ---------- Original ---------- #

# All year 
load(paste('data/Original/pm25_combine_plot.RData', sep = ''))
load(paste('data/Original/pm25_combine_plot_spring.RData', sep = ''))
load(paste('data/Original/pm25_combine_plot_summer.RData', sep = ''))
load(paste('data/Original/pm25_combine_plot_fall.RData', sep = ''))
load(paste('data/Original/pm25_combine_plot_winter.RData', sep = ''))

gg_pm25_ori <- plot2d(data = pm25_combine_plot, fill = pm25_combine_plot$PM25_Pred, 
                  colorbar = jet.colors, colorbar_limits = c(3, 12),
                  shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'))

gg_pm25_spring_ori <- plot2d(data = pm25_combine_plot_spring, fill = pm25_combine_plot_spring$PM25_Pred,
                         colorbar = jet.colors, colorbar_limits = c(3, 12),
                         shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'SpringPM2.5'))

gg_pm25_summer_ori <- plot2d(data = pm25_combine_plot_summer, fill = pm25_combine_plot_summer$PM25_Pred,
                         colorbar = jet.colors, colorbar_limits = c(3, 12),
                         shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Summer PM2.5'))

gg_pm25_fall_ori <- plot2d(data = pm25_combine_plot_fall, fill = pm25_combine_plot_fall$PM25_Pred,
                       colorbar = jet.colors, colorbar_limits = c(3, 12),
                       shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Fall PM2.5'))

gg_pm25_winter_ori <- plot2d(data = pm25_combine_plot_winter, fill = pm25_combine_plot_winter$PM25_Pred,
                         colorbar = jet.colors, colorbar_limits = c(4, 17),
                         shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Winter PM2.5'))

# ---------- Gapfilled ---------- #

# All year 
load(paste('data/Gapfilled/pm25_combine_plot.RData', sep = ''))
load(paste('data/Gapfilled/pm25_combine_plot_spring.RData', sep = ''))
load(paste('data/Gapfilled/pm25_combine_plot_summer.RData', sep = ''))
load(paste('data/Gapfilled/pm25_combine_plot_fall.RData', sep = ''))
load(paste('data/Gapfilled/pm25_combine_plot_winter.RData', sep = ''))

gg_pm25_gap <- plot2d(data = pm25_combine_plot, fill = pm25_combine_plot$PM25_Pred, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'))

gg_pm25_spring_gap <- plot2d(data = pm25_combine_plot_spring, fill = pm25_combine_plot_spring$PM25_Pred,
                             colorbar = jet.colors, colorbar_limits = c(3, 12),
                             shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'SpringPM2.5'))

gg_pm25_summer_gap <- plot2d(data = pm25_combine_plot_summer, fill = pm25_combine_plot_summer$PM25_Pred,
                             colorbar = jet.colors, colorbar_limits = c(3, 12),
                             shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Summer PM2.5'))

gg_pm25_fall_gap <- plot2d(data = pm25_combine_plot_fall, fill = pm25_combine_plot_fall$PM25_Pred,
                           colorbar = jet.colors, colorbar_limits = c(3, 12),
                           shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Fall PM2.5'))

gg_pm25_winter_gap <- plot2d(data = pm25_combine_plot_winter, fill = pm25_combine_plot_winter$PM25_Pred,
                             colorbar = jet.colors, colorbar_limits = c(4, 17),
                             shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Winter PM2.5'))

# ---------- Cloud Only ---------- #

# All year 
load(paste('data/CloudOnly/pm25_combine_plot.RData', sep = ''))
load(paste('data/CloudOnly/pm25_combine_plot_spring.RData', sep = ''))
load(paste('data/CloudOnly/pm25_combine_plot_summer.RData', sep = ''))
load(paste('data/CloudOnly/pm25_combine_plot_fall.RData', sep = ''))
load(paste('data/CloudOnly/pm25_combine_plot_winter.RData', sep = ''))

gg_pm25_cld <- plot2d(data = pm25_combine_plot, fill = pm25_combine_plot$PM25_Pred, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'))

gg_pm25_spring_cld <- plot2d(data = pm25_combine_plot_spring, fill = pm25_combine_plot_spring$PM25_Pred,
                             colorbar = jet.colors, colorbar_limits = c(3, 12),
                             shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'SpringPM2.5'))

gg_pm25_summer_cld <- plot2d(data = pm25_combine_plot_summer, fill = pm25_combine_plot_summer$PM25_Pred,
                             colorbar = jet.colors, colorbar_limits = c(3, 12),
                             shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Summer PM2.5'))

gg_pm25_fall_cld <- plot2d(data = pm25_combine_plot_fall, fill = pm25_combine_plot_fall$PM25_Pred,
                           colorbar = jet.colors, colorbar_limits = c(3, 12),
                           shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Fall PM2.5'))

gg_pm25_winter_cld <- plot2d(data = pm25_combine_plot_winter, fill = pm25_combine_plot_winter$PM25_Pred,
                             colorbar = jet.colors, colorbar_limits = c(4, 17),
                             shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'Winter PM2.5'))
