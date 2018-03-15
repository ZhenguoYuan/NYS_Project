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

myshp <- readShapePoly('~/Google Drive/Projects/Codes/Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
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
# Load MODIS/VIIRS Fire Counts
firecount.shp <- readShapePoints('data/DL_FIRE_M6_5086/fire_archive_M6_5086.shp') # MODIS
# firecount.shp <- readShapePoints('data/DL_FIRE_V1_5087/fire_archive_V1_5087.shp') # VIIRS
firecount.dat <- as.data.frame(coordinates(firecount.shp))

# Spatial
gg.aaot.spatial <- plot2d(data = aaot.fire$aaot.spatial, fill = aaot.fire$aaot.spatial$AAOT550_Mean, colorbar = jet.colors, 
                     colorbar_limits = c(0.2, 0.5), shp = myshp, legend_name = 'AAOT', title = 'Wild Fire', xlim = lon.range.spatial, ylim = lat.range.spatial)
# Plot Fire Counts
gg.aaot.spatial + geom_point(data = firecount.dat, aes(x = coords.x1, y = coords.x2), shape = 3, color = 'red', size = 5) # d is '+'

# ----- TAOT ----- #
# Temporal
plot(start.date.temp: end.date.temp, taot.fire$taot.temp)
lines(start.date.temp: end.date.temp, taot.fire$taot.temp)
# Spatial
gg.taot.spatial <- plot2d(data = taot.fire$taot.spatial, fill = taot.fire$taot.spatial$TAOT550_Mean, colorbar = jet.colors, 
                          colorbar_limits = c(0.2, 0.5), shp = myshp, legend_name = 'TAOT', title = 'Wild Fire', xlim = lon.range.spatial, ylim = lat.range.spatial)
