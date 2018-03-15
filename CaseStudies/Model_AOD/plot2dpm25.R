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
# define jet colormap
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

# ---------- Full ---------- #

# All year 
load(paste('../../Validations/PLOT2D/data/PLOTPM25/2015/pm25_combine_plot.RData', sep = ''))
pm25 <- pm25_combine_plot
pm25 <- cutByShp(shp.name = shp.name, pm25)

gg_pm25 <- plot2d(data = pm25, fill = pm25$PM25_Pred, 
                  colorbar = jet.colors, colorbar_limits = c(3, 12),
                  shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'), 
                  xlim = c(-80, -71.6), ylim = c(40.5, 45.25))


# ---------- Original ---------- #

# All year 
load(paste('data/Original/pm25_combine_plot.RData', sep = ''))
pm25_ori <- pm25_combine_plot
pm25_ori <- cutByShp(shp.name = shp.name, pm25_ori)

gg_pm25_ori <- plot2d(data = pm25_ori, fill = pm25_ori$PM25_Pred_Avg, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'), 
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# ---------- Gapfilled ---------- #

# All year 
load(paste('data/Gapfilled/pm25_combine_plot.RData', sep = ''))
pm25_gap <- pm25_combine_plot
pm25_gap <- cutByShp(shp.name = shp.name, pm25_gap)

gg_pm25_gap <- plot2d(data = pm25_gap, fill = pm25_gap$PM25_Pred_Avg, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'), 
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# ---------- Cloud Only ---------- #

# All year 
load(paste('data/CloudOnly/pm25_combine_plot.RData', sep = ''))
pm25_cld <- pm25_combine_plot
pm25_cld <- cutByShp(shp.name = shp.name, pm25_cld)

gg_pm25_cld <- plot2d(data = pm25_cld, fill = pm25_cld$PM25_Pred_Avg, 
                      colorbar = jet.colors, colorbar_limits = c(3, 12),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5'),
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# ---------- Difference (Full - Original) ---------- #
pm25.diff <- data.frame(Lat = pm25$Lat, Lon = pm25$Lon, diff = pm25$PM25_Pred - pm25_ori$PM25_Pred_Avg)

diff.colors <- colorRampPalette(c('blue', 'white', 'red'), bias = 0.3)
gg.pm25.diff <- plot2d(data = pm25.diff, fill = pm25.diff$diff, 
                       colorbar = diff.colors, colorbar_limits = c(-2, 0.5),
                       shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5 Diff'), 
                       xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# Stat
pm25.diff.stat <- pm25$PM25_Pred - pm25_ori$PM25_Pred_Avg
mean(pm25.diff.stat)
quantile(pm25.diff.stat, 0.25)
quantile(pm25.diff.stat, 0.75)

# ---------- Difference (Full - Gapfilled) ---------- #

# Stat (Full - Gapfilled)
pm25.diff.stat.gap <- pm25$PM25_Pred - pm25_gap$PM25_Pred_Avg
mean(pm25.diff.stat.gap)
quantile(pm25.diff.stat.gap, 0.25)
quantile(pm25.diff.stat.gap, 0.75)

# Stat (Full - CldOnly)
pm25.diff.stat.cld <- pm25$PM25_Pred - pm25_cld$PM25_Pred_Avg
mean(pm25.diff.stat.cld)
quantile(pm25.diff.stat.cld, 0.25)
quantile(pm25.diff.stat.cld, 0.75)

# ---------- Population Weighted ---------- #

pop <- read.csv(file = 'data/lspop2015.csv')

# pop - full-model pm25
pm25_pop <- merge(pm25, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
pm25_pop <- cutByShp(shp.name = shp.name, pm25_pop)

pm25_pop$PM25.POP <- pm25_pop$PM25_Pred * pm25_pop$pop
pm25_pop$log.PM25.POP <- log(pm25_pop$PM25.POP)
gg_pm25_pop <- plot2d(data = pm25_pop, fill = pm25_pop$log.PM25.POP, 
                      colorbar = jet.colors, colorbar_limits = c(0, 10),
                      shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP)'),
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))


# pop - original-model pm25
pm25_ori_pop <- merge(pm25_ori, pop, by.x = c('Lat', 'Lon'), by.y = c('lat', 'lon'), all = F)
pm25_ori_pop <- cutByShp(shp.name = shp.name, pm25_ori_pop)

pm25_ori_pop$PM25.POP <- pm25_ori_pop$PM25_Pred_Avg * pm25_ori_pop$pop
pm25_ori_pop$log.PM25.POP <- log(pm25_ori_pop$PM25.POP)
gg_pm25_ori_pop <- plot2d(data = pm25_ori_pop, fill = pm25_ori_pop$log.PM25.POP, 
                          colorbar = jet.colors, colorbar_limits = c(0, 10),
                          shp = myshp, legend_name = 'log(PM2.5*POP)', title = paste(as.character(year), 'log(PM2.5*POP)'),
                          xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# Log difference plot (full pm25-pop / original pm25-pop)
ratio <- data.frame(Lat = pm25_pop$Lat, Lon = pm25_pop$Lon, r = pm25_pop$log.PM25.POP/pm25_ori_pop$log.PM25.POP)
ratio.colors <- colorRampPalette(c('blue', 'white', 'red'))
gg_ratio <- plot2d(data = ratio, fill = ratio$r, 
                   colorbar = ratio.colors, colorbar_limits = c(0.98, 1.02),
                   shp = myshp, legend_name = 'log ratio', title = paste(as.character(year), 'log ratio'),
                   xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

# Population weighted PM2.5 difference
diff <- pm25_pop$PM25.POP - pm25_ori_pop$PM25.POP
mean(diff, na.rm = T)
quantile(diff, 0.25, na.rm = T)
quantile(diff, 0.75, na.rm = T)
