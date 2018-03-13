# Plot
# Temporal
plot(start_date: end_date, pm25.temp)
lines(start_date: end_date, pm25.temp)
# Spatial
myshp = readShapePoly('~/Google Drive/Projects/Codes/Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
myshp <- fortify(myshp)
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
gg.spatial <- plot2d(data = pm25.fire$pm25.spatial, fill = pm25.fire$pm25.spatial$PM25_Mean, colorbar = jet.colors, 
                     colorbar_limits = c(0, 20), shp = myshp, legend_name = 'PM2.5', title = 'Wild Fire', xlim = lon.range.spatial, ylim = lat.range.spatial)


