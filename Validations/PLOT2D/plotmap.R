#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: Plotting the study area with PM2.5 monitoring sites
# Notice: the size of saved image is 800 * 800
#
# Apr 6, 2018
#----------------------------------------------------------------------

library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)
library(ggplot2)
library(ggmap)
library(ggsn)

setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/PLOT2D/')

# ----- PM2.5 sites ----- #

sites <- read.csv('data/Sites/PM25_2015.csv')
sites.uni <- aggregate(sites, by = list(sites$site.id), FUN = mean)
sites.uni <- subset(sites.uni, select = c(site.id, lon, lat, aqs.code))
sites.uni$type <- 'AQS'
sites.uni$type[is.na(sites.uni$aqs.code)] <- 'NAPS'

# ----- Map ----- #

# Read shp
myshp <- readShapePoly('../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
myshp.ny <- subset(myshp, NAME == 'New York') # Select NYS shp
myshp <- fortify(myshp)
myshp.ny <- fortify(myshp.ny)

# Lat/Lon Ranges
xlim <- c(-81, -70.5)
ylim <- c(39.5, 46)

# Getting base map
map <- get_map(location = c(-81, 39.5, -70.5, 46), maptype = 'terrain', source = ('stamen'), zoom = 7)

# Plotting study region
gg <- ggmap(map, extent = "panel") + 
  geom_polygon(data = myshp.ny, aes(x = long, y = lat, group = group, fill = 'New York State'), color = 'black', alpha = 0.3) +
  geom_point(data = sites.uni, aes(x = lon, y = lat, colour = type, shape = type), size = 3, alpha = 0.8) + 
  geom_polygon(aes(x = c(-81, -70.5, -70.5, -81), y = c(39.5, 39.5, 46, 46)), color = 'black', fill = NA, size = 2) +
  theme(panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_blank(),
        axis.title = element_blank(), axis.ticks = element_blank(), axis.text = element_blank(),
        legend.position = 'bottom', legend.title = element_blank(), legend.box.spacing = unit(0, 'npc')) +
  scalebar(dist = 100, dd2km = TRUE, st.size = 4, model = 'WGS84', location = 'bottomright', 
           x.min = -80, x.max = -71, y.min = 40, y.max = 45) +
  scale_fill_manual(values = c("#ffffff")) +
  scale_color_manual(values = c("#d84951", "#4357a3")) +
  scale_shape_manual(values = c(18, 17))

# ----- Adding Noth Arrow ----- #
north2(gg, x = 0.89, y = 0.85, symbol = 1, scale = 0.13)




