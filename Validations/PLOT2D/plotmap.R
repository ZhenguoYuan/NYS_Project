library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)
library(ggplot2)
library(ggmap)
library(ggsn)

setwd('/Users/jbi6/Google Drive/Projects/Codes/NYS_Project/Validations/PLOT2D/')

# Read shp
myshp <- readShapePoly('../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
myshp.ny <- subset(myshp, NAME == 'New York') # Select NYS shp
myshp <- fortify(myshp)
myshp.ny <- fortify(myshp.ny)

xlim <- c(-81, -70.5)
ylim <- c(39.5, 46)

map <- get_map(location = c(-81, 39.5, -70.5, 46), maptype = 'toner-lite', zoom = 6, source = c('stamen'))
ggmap(map, extent = 'panel') + coord_fixed(xlim = xlim,  ylim = ylim, ratio = 1) +
  geom_polygon(aes(x = c(-81, -70.5, -70.5, -81), y = c(39.5, 39.5, 46, 46)), color = 'black', fill = NA, linetype = 1) + 
  theme(panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_blank(), 
        axis.title = element_blank(), axis.ticks = element_blank(), axis.text = element_blank())

gg <- ggplot() + 
  geom_polygon(data = myshp.ny, aes(x = long, y = lat, group = group), fill = 'gray') +
  geom_polygon(data = myshp, aes(x = long, y = lat, group = group), color = 'black', fill = NA) +
  geom_polygon(aes(x = c(-81, -70.5, -70.5, -81), y = c(39.5, 39.5, 46, 46)), color = 'black', fill = NA, linetype = 2) + 
  labs(fill = 'legend_name') + coord_fixed(xlim = xlim, ylim = ylim, ratio = 1) + # Using coord_fixed to realize the true zoom in!
  scalebar(myshp, dist = 30, dd2km = TRUE, st.size = 2, model = 'WGS84') + 
  theme(panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_blank(), 
        axis.title = element_blank(), axis.ticks = element_blank(), axis.text = element_blank())

