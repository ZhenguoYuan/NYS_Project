#---------------------
# ASTER GDEM
# Jianzhao Bi
# 9/28/2017
#---------------------
# Produce DEM data

# Time starting
ptm <- proc.time()

setwd('/home/jbi6/NYS_Project/ASTER_GDEM/')

# Load functions
source('src/fun.R')
source('../src/fun.R')

### ---------- RUN --------- ###
# MAIAC grid
new.loc <- read.csv('../MAIAC_GRID/output/maiac_grid.csv', stringsAsFactors = F)

# Input path
inpath <- '/home/jbi6/aura/NYS_DEM'
file.names <- dir(path = inpath, pattern = 'dem.tif$')
file.names <- file.path(inpath, file.names)

for (i in 1 : length(file.names)) {
  
  print(i)
  
  dem.tmp <- dem.tile(file.names[i], new.loc)
  
  if (i == 1) {
    dem.df <- data.frame(Lon = dem.tmp$Lon, Lat = dem.tmp$Lat)
    dem.df[, i + 2] <- dem.tmp$DEM
  } else {
    dem.df[, i + 2] <- dem.tmp$DEM
  }
  
}

dem <- rowMeans(dem.df[, 3 : ncol(dem.df)], na.rm = T)
dem[is.nan(dem)] <- NA
dem.df[, 3 : ncol(dem.df)] <- NULL
dem.df$DEM <- dem

# Fill the gap of the seam
options(warn = -1)
idx <- is.na(dem.df$DEM)
dem.df.new <- akima.interpp(dem.df$Lon[!idx], dem.df$Lat[!idx], dem.df$DEM[!idx], new.loc$Lon, new.loc$Lat)
options(warn = 0)
colnames(dem.df.new) <- c('Lon', 'Lat', 'DEM')

### ---------- SAVE FILE --------- ###

outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/ASTER_GDEM/'
if (!file.exists(outpath)) { # Creating Output Path
  dir.create(outpath, recursive = T)
}
write.csv(x = dem.df.new, file = paste(outpath, 'DEM.csv', sep = ''), row.names = F)

# Time ending
proc.time() - ptm

### ---------- PLOT --------- ###
# library(ggplot2)
# gg1 <- ggplot() + geom_tile(data = z, aes(x, y, fill = z, width = 0.017, height = 0.017), alpha = 1)
# gg2 <- ggplot() + geom_tile(data = dem.df, aes(Lon, Lat, fill = DEM, width = 0.017, height = 0.017), alpha = 1)
