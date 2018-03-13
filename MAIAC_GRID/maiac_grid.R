#---------------------
# Create MAIAC Grid
# Jianzhao Bi
# 9/7/2017
#---------------------
## This script create the MAIAC grid used in following regression

# Set the current working path
script.dir <- dirname(sys.frame(1)$ofile)
setwd(script.dir)

# Read the latlon file of North America (h04v03 & h04v04)
if (!exists('grid.old')) {
  grid.old <- read.csv('input/NA_LatLon.csv', header = F, stringsAsFactors = F)
}
names(grid.old) <- c('Lat','Lon')

# Ranges of lat & lon
source('../src/latlon.R')

# Cut the original grid and create final grid
idx <- (grid.old$Lat >= min(lat.range)) & (grid.old$Lat <= max(lat.range)) & (grid.old$Lon >= min(lon.range)) & (grid.old$Lon <= max(lon.range))
grid.new <- grid.old[idx, ]
grid.new$ID <- seq(1, nrow(grid.new), 1)
grid.new <- grid.new[, c('ID', 'Lat', 'Lon')]

# Save the MAIAC grid data as a csv file
write.csv(x = grid.new, file = 'output/maiac_grid.csv', row.names = F)

