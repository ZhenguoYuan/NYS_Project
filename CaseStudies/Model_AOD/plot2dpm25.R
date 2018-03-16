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
shp.name <- '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp'
myshp <- readShapePoly(shp.name)
myshp <- subset(myshp, NAME == 'New York') # Select NYS shp
myshp <- fortify(myshp)

# colorbar
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
diff.colors.nobias <- colorRampPalette(c('blue', 'white', 'red'))
diff.colors.bias <- colorRampPalette(c('blue', 'white', 'red'), bias = 0.3)

# ---------- Full ---------- #

# All Year
load(paste('../../Validations/PLOT2D/data/PLOTPM25/2015/pm25_combine_plot.RData', sep = ''))
pm25 <- pm25_combine_plot
pm25 <- cutByShp(shp.name = shp.name, pm25)

gg.pm25 <- plot2d(data = pm25, fill = pm25$PM25_Pred, 
                  colorbar = jet.colors, colorbar_limits = c(3, 12),
                  shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'), 
                  xlim = c(-80, -71.6), ylim = c(40.5, 45.25))


# ---------- Original ---------- #

# Snow Season
load(paste('data/Original/pm25_combine_plot_snow.RData', sep = ''))
pm25.ori.snow <- pm25_combine_plot_snow
pm25.ori.snow <- cutByShp(shp.name = shp.name, pm25.ori.snow)

gg.pm25.ori.snow <- plot2d(data = pm25.ori.snow, fill = pm25.ori.snow$PM25_Pred_Avg, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5 Snow Season'), 
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# ---------- Gapfilled (Cloud+Snow) ---------- #

# Snow Season
load(paste('data/Gapfilled/pm25_combine_plot_snow.RData', sep = ''))
pm25.gap.snow <- pm25_combine_plot_snow
pm25.gap.snow <- cutByShp(shp.name = shp.name, pm25.gap.snow)

gg.pm25.gap.snow <- plot2d(data = pm25.gap.snow, fill = pm25.gap.snow$PM25_Pred_Avg, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5 Snow Season'), 
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# ---------- Cloud Only ---------- #

# Snow Season
load(paste('data/CloudOnly/pm25_combine_plot_snow.RData', sep = ''))
pm25.cld.snow <- pm25_combine_plot_snow
pm25.cld.snow <- cutByShp(shp.name = shp.name, pm25.cld.snow)

gg.pm25.cld.snow <- plot2d(data = pm25.cld.snow, fill = pm25.cld.snow$PM25_Pred_Avg, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5 Snow Season'),
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# # ---------- Difference (Full - Original) ---------- #
# pm25.diff <- data.frame(Lat = pm25$Lat, Lon = pm25$Lon, diff = pm25$PM25_Pred - pm25_ori$PM25_Pred_Avg)
# 
# gg.pm25.diff <- plot2d(data = pm25.diff, fill = pm25.diff$diff, 
#                        colorbar = diff.colors, colorbar_limits = c(-2, 0.5),
#                        shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5 Diff'), 
#                        xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
# 
# # Stat
# pm25.diff.stat <- pm25$PM25_Pred - pm25_ori$PM25_Pred_Avg
# mean(pm25.diff.stat)
# quantile(pm25.diff.stat, 0.25)
# quantile(pm25.diff.stat, 0.75)

# ---------- Difference (Cloud+Snow - Cloud Only) ---------- #

# Stat (Cloud+Snow - Cloud Only)
pm25.diff.snow <- data.frame(Lat = pm25.gap.snow$Lat, Lon = pm25.gap.snow$Lon, diff = pm25.gap.snow$PM25_Pred_Avg - pm25.cld.snow$PM25_Pred_Avg)
mean(pm25.diff.snow$diff)
quantile(pm25.diff.snow$diff, 0.25)
quantile(pm25.diff.snow$diff, 0.75)
max(pm25.diff.snow$diff)

gg.pm25.diff.snow <- plot2d(data = pm25.diff.snow, fill = pm25.diff.snow$diff, 
                           colorbar = diff.colors.nobias, colorbar_limits = c(-0.5, 0.5),
                           shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5 Difference Snow Season'),
                           xlim = c(-80, -71.6), ylim = c(40.5, 45.25))



pop <- read.csv(file = 'data/lspop2015.csv')

# # ---------- Population Weighted Difference (Full - Original) ---------- #
# 
# # pop - full-model pm25
# pm25_pop <- merge(pm25, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
# pm25_pop <- cutByShp(shp.name = shp.name, pm25_pop)
# 
# pm25_pop$PM25.POP <- pm25_pop$PM25_Pred * pm25_pop$pop
# pm25_pop$log.PM25.POP <- log(pm25_pop$PM25.POP)
# gg_pm25_pop <- plot2d(data = pm25_pop, fill = pm25_pop$log.PM25.POP, 
#                       colorbar = jet.colors, colorbar_limits = c(0, 10),
#                       shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP)'),
#                       xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
# 
# 
# # pop - original-model pm25
# pm25_ori_pop <- merge(pm25_ori, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
# pm25_ori_pop <- cutByShp(shp.name = shp.name, pm25_ori_pop)
# 
# pm25_ori_pop$PM25.POP <- pm25_ori_pop$PM25_Pred_Avg * pm25_ori_pop$pop
# pm25_ori_pop$log.PM25.POP <- log(pm25_ori_pop$PM25.POP)
# gg_pm25_ori_pop <- plot2d(data = pm25_ori_pop, fill = pm25_ori_pop$log.PM25.POP, 
#                           colorbar = jet.colors, colorbar_limits = c(0, 10),
#                           shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP)'),
#                           xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
# 
# # Log difference plot (full pm25-pop / original pm25-pop)
# ratio <- data.frame(Lat = pm25_pop$Lat, Lon = pm25_pop$Lon, r = pm25_pop$log.PM25.POP/pm25_ori_pop$log.PM25.POP)
# ratio.colors <- colorRampPalette(c('blue', 'white', 'red'))
# gg_ratio <- plot2d(data = ratio, fill = ratio$r, 
#                    colorbar = ratio.colors, colorbar_limits = c(0.98, 1.02),
#                    shp = myshp, legend_name = 'log ratio', title = paste(as.character(year), 'log ratio'),
#                    xlim = c(-80, -71.6), ylim = c(40.5, 45.25))
# 
# # Population weighted PM2.5 difference
# diff <- pm25_pop$PM25.POP - pm25_ori_pop$PM25.POP
# mean(diff, na.rm = T)
# quantile(diff, 0.25, na.rm = T)
# quantile(diff, 0.75, na.rm = T)


# ---------- Population Weighted Difference (Cloud+Snow - Cloud Only) ---------- #

# pop * Cloud+Snow PM2.5
pm25.pop.gap.snow <- merge(pm25.gap.snow, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
pm25.pop.gap.snow <- cutByShp(shp.name = shp.name, pm25.pop.gap.snow)

pm25.pop.gap.snow$PM25.POP <- pm25.pop.gap.snow$PM25_Pred_Avg * pm25.pop.gap.snow$pop
pm25.pop.gap.snow$log.PM25.POP <- log(pm25.pop.gap.snow$PM25.POP)
gg.pm25.pop.gap.snow <- plot2d(data = pm25.pop.gap.snow, fill = pm25.pop.gap.snow$log.PM25.POP, 
                      colorbar = jet.colors, colorbar_limits = c(0, 10),
                      shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP) Snow Season'),
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))


# pop * Cloud Only PM2.5
pm25.pop.cld.snow <- merge(pm25.cld.snow, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
pm25.pop.cld.snow <- cutByShp(shp.name = shp.name, pm25.pop.cld.snow)

pm25.pop.cld.snow$PM25.POP <- pm25.pop.cld.snow$PM25_Pred_Avg * pm25.pop.cld.snow$pop
pm25.pop.cld.snow$log.PM25.POP <- log(pm25.pop.cld.snow$PM25.POP)
gg.pm25.pop.cld.snow <- plot2d(data = pm25.pop.cld.snow, fill = pm25.pop.cld.snow$log.PM25.POP, 
                          colorbar = jet.colors, colorbar_limits = c(0, 10),
                          shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP) Snow Season'),
                          xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# Log difference plot (full pm25-pop / original pm25-pop)
ratio.snow <- data.frame(Lat = pm25.pop.gap.snow$Lat, Lon = pm25.pop.gap.snow$Lon, r = pm25.pop.gap.snow$log.PM25.POP/pm25.pop.cld.snow$log.PM25.POP)
gg.ratio.snow <- plot2d(data = ratio.snow, fill = ratio.snow$r, 
                   colorbar = diff.colors.nobias, colorbar_limits = c(0.98, 1.02),
                   shp = myshp, legend_name = 'log ratio', title = paste(as.character(year), 'log ratio Snow Season'),
                   xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# Population weighted PM2.5 difference
diff.snow <- pm25.pop.gap.snow$PM25.POP - pm25.pop.cld.snow$PM25.POP
mean(diff.snow, na.rm = T)
quantile(diff.snow, 0.25, na.rm = T)
quantile(diff.snow, 0.75, na.rm = T)
max(diff.snow, na.rm = T)
