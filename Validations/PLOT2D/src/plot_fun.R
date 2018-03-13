# Plot 2d distribution
plot2d <- function (data, fill, colorbar, colorbar_limits = NULL, shp, legend_name = '', title = '', xlim = c(-81, -70.5), ylim = c(39.5, 46)) {
  
  if ('Longitude' %in% names(data)) {
    data$Lon <- data$Longitude
    data$Lat <- data$Latitude
  }
  
  gg <- ggplot() + 
    geom_tile(data = data, aes(Lon, Lat, fill = fill, width = 0.014, height = 0.014), alpha = 1) + 
    scale_fill_gradientn(colours = colorbar(100), limits = colorbar_limits, oob = scales::squish) + # scales::squish is forcing all color display for points outside the legend range
    geom_polygon(data = shp, aes(x = long, y = lat, group = group), color = "black", fill = NA) +
    labs(fill = legend_name) + ggtitle(title) + coord_fixed(xlim = xlim, ylim = ylim, ratio = 1) # Using coord_fixed to realize the true zoom in!
  
  return(gg)
  
}

# Plot 2d distribution with contours
plot2d.dem <- function (data, colorbar, colorbar_limits = NULL, shp, legend_name, title, dem, xlim, ylim) {
  
  library(scales)
  
  
  
  map <- get_map(location = c(lon = mean(xlim), lat = mean(ylim)), maptype = 'satellite', zoom = 10)
  gg.map <-  ggmap(map, extent = 'panel') + coord_fixed(xlim = xlim,  ylim = ylim, ratio = 1) + geom_contour(data = dem, aes(x = x, y = y, z = var1.pred), binwidth = 140, , colour = 'white')
  
  gg <- ggplot() +
    geom_tile(data = data, aes(Lon, Lat, fill = PM25_Pred, width = 0.014, height = 0.014), alpha = 1) +
    scale_fill_gradientn(colours = colorbar, limits = colorbar_limits, oob = scales::squish) + # scales::squish is forcing all color display for points outside the legend range
    geom_polygon(data = shp, aes(x = long, y = lat, group = group), color = "black", fill = NA) +
    labs(fill = legend_name) + ggtitle(title) + coord_fixed(xlim = xlim,  ylim = ylim, ratio = 1) # Using coord_fixed to realize true zoom in!
  
  #gg <- gg + geom_contour(data = dem, aes(x = x, y = y, z = var1.pred, colour = ..level..), bin = 8)#, size = 0.2, alpha = 0.7)
  gg <- gg + geom_contour(data = dem, aes(x = x, y = y, z = var1.pred), binwidth = 140, , colour = 'white')
  #gg <- direct.label(gg, list("far.from.others.borders", "calc.boxes", "enlarge.box", hjust = 1, vjust = 1, box.color = NA, fill = "transparent", "draw.rects"))
  
  # colours = colorbar(100)
  
  gg.plot <- list(gg = gg, gg.map = gg.map)
  return(gg.plot)
  
}
