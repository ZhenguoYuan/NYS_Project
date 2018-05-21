#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: Plotting PM2.5 distribution (Original, Gap-filled, Cloud-only)
# Notice: the size of saved image is 535 * 502
#
# May 6, 2018
#----------------------------------------------------------------------

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

xlim <- c(-79.8, -72)
ylim <- c(40.5, 45)


## ---------- Shp & Colorbar ---------- ##

# Read shp
shp.name <- '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp'
myshp <- readShapePoly(shp.name)
myshp <- subset(myshp, NAME == 'New York') # Select NYS shp
myshp <- fortify(myshp)

# colorbar
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
rainbow.colors <- colorRampPalette(c('#0000ff', '#0054ff', '#00abff', '#00ffff', '#54ffab', '#abff53', '#ffff00', '#ffaa00', '#ff5400', '#ff0000'))
diff.colors.nobias <- colorRampPalette(c('#7f7fff', 'white', '#EF4566'))
diff.colors.bias <- colorRampPalette(c('#7f7fff', 'white', '#EF4566'), bias = 0.36)

# ---------- Difference (Full (Cloud+Snow) - Without AOD) (Snow Season) ---------- #
# Snow Season
# Full
load(paste('data/Gapfilled/pm25_combine_plot_snow.RData', sep = ''))
full.snow <- pm25_combine_plot_snow
full.snow <- cutByShp(shp.name = shp.name, full.snow)
# Without AOD
load(paste('data/WithoutAOD/pm25_combine_plot_snow.RData', sep = ''))
noaod.snow <- pm25_combine_plot_snow
noaod.snow <- cutByShp(shp.name = shp.name, noaod.snow)

diff.noaod.df <- data.frame(Lat = full.snow$Lat, Lon = full.snow$Lon, diff = full.snow$PM25_Pred_Avg - noaod.snow$PM25_Pred_Avg)

gg.diff.noaod <- plot2d(data = diff.noaod.df, fill = diff.noaod.df$diff,
                       colorbar = diff.colors.nobias, colorbar_limits = c(-0.3, 0.3),
                       shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(c) Full - Without AOD PM2.5',
                       xlim = xlim, ylim = ylim, hjust = 0.15)

# Stat (no ABS)
diff.noaod.stat <- full.snow$PM25_Pred_Avg - noaod.snow$PM25_Pred_Avg
mean(diff.noaod.stat, na.rm = T)
quantile(diff.noaod.stat, 0.25, na.rm = T)
quantile(diff.noaod.stat, 0.75, na.rm = T)
max(diff.noaod.stat)
min(diff.noaod.stat)

# Stat (ABS)
diff.noaod.stat.abs <- abs(diff.noaod.stat)
mean(diff.noaod.stat.abs, na.rm = T)
quantile(diff.noaod.stat.abs, 0.25, na.rm = T)
quantile(diff.noaod.stat.abs, 0.75, na.rm = T)
max(diff.noaod.stat.abs)


# ---------- Difference (Cloud+Snow - Cloud Only) (Snow Season) ---------- #

# Cloud-Only (Snow Season)
load(paste('data/CloudOnly/pm25_combine_plot_snow.RData', sep = ''))
cld.snow <- pm25_combine_plot_snow
cld.snow <- cutByShp(shp.name = shp.name, cld.snow)

diff.snow.df <- data.frame(Lat = full.snow$Lat, Lon = full.snow$Lon, diff = full.snow$PM25_Pred_Avg - cld.snow$PM25_Pred_Avg)

gg.diff.snow <- plot2d(data = diff.snow.df, fill = diff.snow.df$diff, 
                            colorbar = diff.colors.nobias, colorbar_limits = c(-0.3, 0.3),
                            shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '(d) Full - Cloud Only PM2.5',
                            xlim = xlim, ylim = ylim, hjust = 0.15)

# Stat (Cloud+Snow - Cloud Only) (no ABS)
diff.snow.stat <- full.snow$PM25_Pred_Avg - cld.snow$PM25_Pred_Avg
mean(diff.snow.stat)
quantile(diff.snow.stat, 0.25)
quantile(diff.snow.stat, 0.75)
max(diff.snow.stat)
min(diff.snow.stat)

# Stat (Cloud+Snow - Cloud Only) (ABS)
diff.snow.stat.abs <- abs(diff.snow.stat)
mean(diff.snow.stat.abs)
quantile(diff.snow.stat.abs, 0.25)
quantile(diff.snow.stat.abs, 0.75)
max(diff.snow.stat.abs)

# ---------- Difference (Full - Original AOD) ---------- #
# Snow Season
# Full
load(paste('data/Gapfilled/pm25_combine_plot.RData', sep = ''))
full <- pm25_combine_plot
full <- cutByShp(shp.name = shp.name, full)
# Original AOD
load(paste('data/Original/pm25_combine_plot.RData', sep = ''))
original <- pm25_combine_plot
original <- cutByShp(shp.name = shp.name, original)

diff.ori.df <- data.frame(Lat = full$Lat, Lon = full$Lon, diff = full$PM25_Pred_Avg - original$PM25_Pred_Avg)

gg.diff.ori <- plot2d(data = diff.ori.df, fill = diff.ori.df$diff,
                        colorbar = diff.colors.bias, colorbar_limits = c(-1.5, 0.5),
                        shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = 'Full - Original PM2.5',
                        xlim = xlim, ylim = ylim, hjust = 0.20)

# Stat (Cloud+Snow - Cloud Only) (no ABS)
diff.ori.stat <- full$PM25_Pred_Avg - original$PM25_Pred_Avg
mean(diff.ori.stat)
quantile(diff.ori.stat, 0.25)
quantile(diff.ori.stat, 0.75)
max(diff.ori.stat)
min(diff.ori.stat)

# Stat (Cloud+Snow - Cloud Only) (ABS)
diff.ori.stat.abs <- abs(diff.ori.stat)
mean(diff.ori.stat.abs)
quantile(diff.ori.stat.abs, 0.25)
quantile(diff.ori.stat.abs, 0.75)
max(diff.ori.stat.abs)


# # ---------- Population Weighted Difference (Cloud+Snow - Cloud Only) ---------- #
#
# pop <- read.csv(file = 'data/lspop2015.csv')
# 
# # pop * Cloud+Snow PM2.5
# pm25.pop.gap.snow <- merge(pm25.gap.snow, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
# pm25.pop.gap.snow <- cutByShp(shp.name = shp.name, pm25.pop.gap.snow)
# 
# pm25.pop.gap.snow$PM25.POP <- pm25.pop.gap.snow$PM25_Pred_Avg * pm25.pop.gap.snow$pop
# pm25.pop.gap.snow$log.PM25.POP <- log(pm25.pop.gap.snow$PM25.POP)
# gg.pm25.pop.gap.snow <- plot2d(data = pm25.pop.gap.snow, fill = pm25.pop.gap.snow$log.PM25.POP, 
#                                colorbar = jet.colors, colorbar_limits = c(0, 10),
#                                shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP) Snow Season'),
#                                xlim = xlim, ylim = ylim)
# 
# 
# # pop * Cloud Only PM2.5
# pm25.pop.cld.snow <- merge(pm25.cld.snow, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
# pm25.pop.cld.snow <- cutByShp(shp.name = shp.name, pm25.pop.cld.snow)
# 
# pm25.pop.cld.snow$PM25.POP <- pm25.pop.cld.snow$PM25_Pred_Avg * pm25.pop.cld.snow$pop
# pm25.pop.cld.snow$log.PM25.POP <- log(pm25.pop.cld.snow$PM25.POP)
# gg.pm25.pop.cld.snow <- plot2d(data = pm25.pop.cld.snow, fill = pm25.pop.cld.snow$log.PM25.POP, 
#                                colorbar = jet.colors, colorbar_limits = c(0, 10),
#                                shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP) Snow Season'),
#                                xlim = xlim, ylim = ylim)
# 
# # Log difference plot (full pm25-pop / original pm25-pop)
# ratio.snow <- data.frame(Lat = pm25.pop.gap.snow$Lat, Lon = pm25.pop.gap.snow$Lon, r = pm25.pop.gap.snow$log.PM25.POP/pm25.pop.cld.snow$log.PM25.POP)
# gg.ratio.snow <- plot2d(data = ratio.snow, fill = ratio.snow$r, 
#                         colorbar = diff.colors.nobias, colorbar_limits = c(0.98, 1.02),
#                         shp = myshp, legend_name = 'log ratio', title = paste(as.character(year), 'log ratio Snow Season'),
#                         xlim = xlim, ylim = ylim)
# 
# # Population weighted PM2.5 difference
# diff.snow <- pm25.pop.gap.snow$PM25.POP - pm25.pop.cld.snow$PM25.POP
# mean(diff.snow, na.rm = T)
# quantile(diff.snow, 0.25, na.rm = T)
# quantile(diff.snow, 0.75, na.rm = T)
# max(diff.snow, na.rm = T)
