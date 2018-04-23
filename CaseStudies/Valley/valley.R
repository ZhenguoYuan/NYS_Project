#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: PM2.5 Valley Accumulation
# Notice: the size of saved image is 535 * 502
#
# Apr 6, 2018
#----------------------------------------------------------------------

setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/Valley/')
source('../../src/fun.R')
source('../../Validations/PLOT2D/src/plot_fun.R')

library(RColorBrewer)
library(ggmap)
library(ggsn)

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
    geom_tile(data = data, aes(Lon, Lat, fill = PM25_Pred_Avg, width = 0.014, height = 0.014), alpha = 1) +
    scale_fill_gradientn(colours = colorbar, limits = colorbar_limits, oob = scales::squish) + # scales::squish is forcing all color display for points outside the legend range
    geom_polygon(data = shp, aes(x = long, y = lat, group = group), color = "black", fill = NA) +
    labs(fill = legend_name) + ggtitle(title) + coord_fixed(xlim = xlim,  ylim = ylim, ratio = 1) + # Using coord_fixed to realize true zoom in!
    xlab('Longitude (degree)') + ylab('Latitude (degree)') + 
    scalebar(x.min = min(xlim), x.max = max(xlim), y.min = min(ylim), y.max = max(ylim), dist = 3, dd2km = TRUE, st.size = 4, model = 'WGS84', location = 'bottomleft') +
    theme(legend.key.height=unit(2.5, "line"), legend.title = element_text(size = rel(1.2)),
          legend.text = element_text(size = rel(1)), axis.title = element_text(size = rel(1.2)), axis.text = element_text(size = rel(1)))
  
  #gg <- gg + geom_contour(data = dem, aes(x = x, y = y, z = var1.pred, colour = ..level..), bin = 8)#, size = 0.2, alpha = 0.7)
  gg <- gg + geom_contour(data = dem, aes(x = x, y = y, z = var1.pred), binwidth = 140, colour = 'black')
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
#dem.color <- rev(brewer.pal(n = 9, name = "YlGnBu"))
dem.color <- brewer.pal(n = 9, name = "YlGnBu")
gg.list <- plot2d.dem(data = pm25_combine_plot_winter,
                      colorbar = dem.color, colorbar_limits = c(5.5, 8),
                      shp = myshp, legend_name = expression(paste(mu, g/m^3)), title = '', dem.reg,
                      xlim = c(-75.5, -75.15), ylim = c(42.375, 42.75))

# PM2.5 concentration with contours
gg.list$gg
# Google map with contours
gg.list$gg.map

# ---------- PLOT Population Density ---------- #

## --- LandScan --- ##
# Plot population density
pop <- read.csv('../../CaseStudies/Model_AOD/data/lspop2015.csv')
pop <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', pop)
gg.pop <- plot2d(data = pop, fill = pop$pop, colorbar = jet.colors, colorbar_limits = c(0, 100), 
                 shp = myshp, legend_name = 'POP', title = 'POP', xlim = c(-75.5, -75.15), ylim = c(42.375, 42.75))
gg.pop + geom_contour(data = dem.reg, aes(x = x, y = y, z = var1.pred), binwidth = 140, colour = 'white')

# Mean pop density
pop.sub <- subset(pop, lat >= 42.375 & lat <= 42.75 & lon >= -75.5 & lon <= -75.15)
mean(pop.sub$pop, na.rm = T)

## --- Census --- ##
## Save the shapefile as a RData
#pop.cen <- readShapePoly('~/Downloads/pop-census/PopCen_plgon_land_albers_pop.shp')
#pop.cen <- subset(pop.cen, LATITUDE >= 42 & LATITUDE <= 43 & LONGITUDE >= -76 & LONGITUDE <= -75)
#save(pop.cen, file = 'census.RData')
load('data/census.RData')
# Read the shape file
proj <- '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs' # NAD83 projection
pop.cen@proj4string <- CRS(proj)
pop.cen <- spTransform(pop.cen, "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") # WGS84 projection
pop.cen.df <- fortify(pop.cen) # Convert to data frame
# Read the data
pop.cen.dat <- pop.cen@data
pop.cen.dat$id <- rownames(pop.cen.dat)
# Merge the shapefile and the data set
pop.cen.df.new <- merge(pop.cen.df, pop.cen.dat, by = c('id'), all = T)

ggplot() + geom_polygon(data = pop.cen.df.new, aes(x = long, y = lat, group = group, fill = POPULATION), color = "black") + 
  coord_fixed(xlim = c(-75.5, -75.15),  ylim = c(42.375, 42.75), ratio = 1) +
  geom_contour(data = dem.reg, aes(x = x, y = y, z = var1.pred), binwidth = 140, colour = 'white') + # DEM contour
  labs(fill = 'POP') + ggtitle('Census Bureau 2010')

