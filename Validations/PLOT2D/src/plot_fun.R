# Plot 2d distribution
plot2d <- function (data, fill, colorbar, colorbar_limits = NULL, shp, legend_name = '', title = '', xlim = c(-81, -70.5), ylim = c(39.5, 46)) {
  
  if ('Longitude' %in% names(data)) {
    data$Lon <- data$Longitude
    data$Lat <- data$Latitude
  } else if ('lat' %in% names(data)) {
    data$Lon <- data$lon
    data$Lat <- data$lat
  }
  
  gg <- ggplot() + 
    geom_tile(data = data, aes(Lon, Lat, fill = fill, width = 0.014, height = 0.014), alpha = 1) + 
    scale_fill_gradientn(colours = colorbar(100), limits = colorbar_limits, oob = scales::squish) + # scales::squish is forcing all color display for points outside the legend range
    geom_polygon(data = shp, aes(x = long, y = lat, group = group), color = "black", fill = NA) +
    labs(fill = legend_name) + ggtitle(title) + coord_fixed(xlim = xlim, ylim = ylim, ratio = 1) # Using coord_fixed to realize the true zoom in!
    # theme(legend.position = "bottom", legend.box = "horizontal", legend.key.width = unit(3, "line"))
  
  return(gg)
  
}