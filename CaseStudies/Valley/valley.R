setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/Valley/')
source('../../src/fun.R')
source('../../Validations/PLOT2D/src/plot_fun.R')

## ---------- Data ---------- ##

year <- 2015

# Read shp
myshp <- readShapePoly('../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
myshp <- fortify(myshp)

# colorbar
# define jet colormap
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

# Winter PM2.5
load(paste('../../Validations/PLOT2D/data/PLOTPM25/', as.character(year), '/pm25_combine_plot_winter.RData', sep = ''))


## ---------- Function ---------- ## 
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
  gg <- gg + geom_contour(data = dem, aes(x = x, y = y, z = var1.pred), binwidth = 140, colour = 'white')
  #gg <- direct.label(gg, list("far.from.others.borders", "calc.boxes", "enlarge.box", hjust = 1, vjust = 1, box.color = NA, fill = "transparent", "draw.rects"))
  
  # colours = colorbar(100)
  
  gg.plot <- list(gg = gg, gg.map = gg.map)
  return(gg.plot)
  
}


# ---------- PLOT PM2.5 with contours ---------- #
# Convert DEM
# dem <- read.csv('data/DEM.csv', stringsAsFactors = F)
# # Resampling the DEM into a regular grid
# dem <- na.omit(dem)
# new.grid <- expand.grid(x = seq(min(dem$Lon), max(dem$Lon), 0.01), y = seq(min(dem$Lat), max(dem$Lat), 0.01))
# dem.reg <- idw.interp(xo = dem$Lon, yo = dem$Lat, zo = dem$DEM, xn = new.grid$x, yn = new.grid$y, nmax = 10, maxdist = 0.1)
# dem.reg <- na.omit(dem.reg)

# Read in dem data
load('data/dem.RData')

# Plot PM2.5 distribution with DEM
dem.color <- rev(brewer.pal(n = 9, name = "YlGnBu"))
gg.list <- plot2d.dem(data = pm25_combine_plot_winter,
                      colorbar = dem.color, colorbar_limits = c(5.5, 8),
                      shp = myshp, legend_name = 'PM2.5', title = paste(as.character(year), 'PM2.5 with DEM'), dem.reg,
                      xlim = c(-75.5, -75.15), ylim = c(42.375, 42.75))

# PM2.5 concentration with contours
gg.list$gg
# Google map with contours
gg.list$gg.map

# Plot population density
pop <- read.csv('../../CaseStudies/Model_AOD/data/lspop2015.csv')
pop <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pop)
gg.pop <- plot2d(data = pop, fill = pop$pop, colorbar = jet.colors, colorbar_limits = c(0, 100), shp = myshp, legend_name = 'POP', title = 'POP', xlim = c(-75.5, -75.15), ylim = c(42.375, 42.75))
gg.pop + geom_contour(data = dem.reg, aes(x = x, y = y, z = var1.pred), binwidth = 140, colour = 'white')

# Mean pop density
pop.sub <- subset(pop, lat >= 42.375 & lat <= 42.75 & lon >= -75.5 & lon <= -75.15)
mean(pop.sub$pop, na.rm = T)
