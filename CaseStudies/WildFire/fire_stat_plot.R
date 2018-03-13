library(ggplot2)
library(maptools)

setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/WildFire/')

source('../../Validations/PLOT2D/src/plot_fun.R')

load('data/pm25_fire.RData')
load('data/aaot_fire.RData')
load('data/taot_fire.RData')

start.date.temp <- 93
end.date.temp <- 155

lat.range.spatial <- c(41.45, 41.9)
lon.range.spatial <- c(-74.7, -74.0)

myshp = readShapePoly('~/Google Drive/Projects/Codes/Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
myshp <- fortify(myshp)
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

# ----- PM2.5 ----- #
# Temporal
plot(start.date.temp: end.date.temp, pm25.fire$pm25.temp)
lines(start.date.temp: end.date.temp, pm25.fire$pm25.temp)
# Spatial
gg.pm25.spatial <- plot2d(data = pm25.fire$pm25.spatial, fill = pm25.fire$pm25.spatial$PM25_Mean, colorbar = jet.colors, 
                     colorbar_limits = c(10, 15), shp = myshp, legend_name = 'PM2.5', title = 'Wild Fire', xlim = lon.range.spatial, ylim = lat.range.spatial)

# ----- AAOT ----- #
# Temporal
plot(start.date.temp: end.date.temp, aaot.fire$aaot.temp)
lines(start.date.temp: end.date.temp, aaot.fire$aaot.temp)
# Spatial
gg.aaot.spatial <- plot2d(data = aaot.fire$aaot.spatial, fill = aaot.fire$aaot.spatial$AAOT550_Mean, colorbar = jet.colors, 
                     colorbar_limits = c(0.2, 0.5), shp = myshp, legend_name = 'AAOT', title = 'Wild Fire', xlim = lon.range.spatial, ylim = lat.range.spatial)

# ----- TAOT ----- #
# Temporal
plot(start.date.temp: end.date.temp, taot.fire$taot.temp)
lines(start.date.temp: end.date.temp, taot.fire$taot.temp)
# Spatial
gg.taot.spatial <- plot2d(data = taot.fire$taot.spatial, fill = taot.fire$taot.spatial$TAOT550_Mean, colorbar = jet.colors, 
                          colorbar_limits = c(0.2, 0.5), shp = myshp, legend_name = 'TAOT', title = 'Wild Fire', xlim = lon.range.spatial, ylim = lat.range.spatial)
