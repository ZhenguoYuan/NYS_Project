# NDVI conversion
#
# Author: Jianzhao Bi
# Date: Mar 4, 2018

library(lubridate)
library(ggplot2)
library(ggmap)
library(maptools)
library(RColorBrewer)

setwd('/home/jbi6/NYS_Project/NDVI/')

source('../src/latlon.R')
source('../src/fun.R')

for (year in 2002 : 2012) {
  
  ndays <- numOfYear(year)
  
  # MAIAC grid
  new.loc <- read.csv('../MAIAC_GRID/output/maiac_grid.csv', stringsAsFactors = F)
  # Paths
  in.path <- file.path('/home/jbi6/envi/NYS_Output/NDVI_ORI', as.character(year))
  out.path <- file.path('/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/NDVI', as.character(year))
  if (!file.exists(out.path)) {
    dir.create(out.path, recursive = T)
  }
  
  # Initialization
  ndvi.name.pre <- ''
  ndvi.sub.new <- NULL
  
  # For each day
  for (i in 1 : ndays) {
    
    # Determine the file name
    month <- month(as.Date(i - 1, origin = paste(as.character(year), '-01-01', sep = ''))) # Corresponding month of the day
    first.day <- yday(as.Date(paste(as.character(year), sprintf('%02d', month), '01', sep = '-'))) # The first day of that month
    ndvi.name <- sprintf('NewYork_1km_monthly_VI_%4d_%03d.csv', year, first.day)
    
    if (ndvi.name != ndvi.name.pre) {
      
      # Read the NDVI file
      ndvi <- read.csv(file = file.path(in.path, ndvi.name), stringsAsFactors = F, as.is = T)
      ndvi$X_Lon <- as.numeric(ndvi$X_Lon)
      # Subset the NDVI
      ndvi.sub <- subset(ndvi, Y_Lat >= min(lat.range) & Y_Lat <= max(lat.range) & X_Lon >= min(lon.range) & X_Lon <= max(lon.range))
      
      #IDW
      ndvi.sub.new <- idw.interp(ndvi.sub$X_Lon, ndvi.sub$Y_Lat, ndvi.sub$NDVI,
                                 new.loc$Lon, new.loc$Lat, nmax = 3) # For Cloud Fraction 
      names(ndvi.sub.new)[1] <- 'lon'
      names(ndvi.sub.new)[2] <- 'lat'
      names(ndvi.sub.new)[3] <- 'NDVI'
      
    }
    
    # Save file
    out.file.name <- sprintf('%d%03d_NDVI.RData', year, i)
    save(ndvi.sub.new, file = file.path(out.path, out.file.name))
    
    # Update ndvi input file name
    ndvi.name.pre <- ndvi.name
    
    print(out.file.name)
    
  }
  
}





# ----- PLOT ----- #
# # Read shp
# myshp = readShapePoly('../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
# myshp <- fortify(myshp)
# 
# # colorbar
# # define jet colormap
# jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
# 
# gg.old <- ggplot() + 
#   geom_tile(data = ndvi.sub, aes(X_Lon, Y_Lat, fill = NDVI, width = 0.014, height = 0.014), alpha = 1) + 
#   scale_fill_gradientn(colours = jet.colors(100), limits = c(-1, 1), oob = scales::squish) + # scales::squish is forcing all color display for points outside the legend range
#   geom_polygon(data = myshp, aes(x = long, y = lat, group = group), color = "black", fill = NA) +
#   labs(fill = 'NDVI') + ggtitle('NDVI') + coord_fixed(xlim = c(-81, -70.5),  ylim = c(39.5, 46), ratio = 1) # Using coord_fixed to realize the true zoom in!
# 
# gg.new <- ggplot() + 
#   geom_tile(data = ndvi.sub.new, aes(lon, lat, fill = NDVI, width = 0.014, height = 0.014), alpha = 1) + 
#   scale_fill_gradientn(colours = jet.colors(100), limits = c(-1, 1), oob = scales::squish) + # scales::squish is forcing all color display for points outside the legend range
#   geom_polygon(data = myshp, aes(x = long, y = lat, group = group), color = "black", fill = NA) +
#   labs(fill = 'NDVI') + ggtitle('NDVI') + coord_fixed(xlim = c(-81, -70.5),  ylim = c(39.5, 46), ratio = 1) # Using coord_fixed to realize the true zoom in!

