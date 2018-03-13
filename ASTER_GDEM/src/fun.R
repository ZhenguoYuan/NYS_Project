library(rgdal)
library(raster)

# Reduce resolution for DEM
reduce.res <- function(v, nrow, ncol, fact){
  ## Input v must be a vector
  
  # Convert vector to matrix and then to vector with geographical coordinates (useless)
  r <- raster(matrix(v, nrow = nrow, ncol = ncol, byrow = T))
  extent(r) <- extent(c(-180, 180, -90, 90))
  
  # Construct a new template raster
  s <- raster(nrow = round(nrow/fact), ncol = round(ncol/fact))
  
  # Resampling
  m.new <- resample(r, s)
  m.new <- as.matrix(m.new) # Raster -> Matrix
  v.new <- as.vector(t(m.new)) # Matrix -> Vector
  
  return(v.new)
}


## Lat/Lon (y/x)
tiff.latlon <- function(r) {
  
  bbox <- r@bbox
  
  x.min <- bbox['x', 'min']
  x.max <- bbox['x', 'max']
  y.min <- bbox['y', 'min']
  y.max <- bbox['y', 'max']
  
  x.cell.size <- r@grid@cellsize[1]
  y.cell.size <- r@grid@cellsize[2]
  
  x.cell.dim <- r@grid@cells.dim[1]
  y.cell.dim <- r@grid@cells.dim[2]
  
  x <- seq(from = x.min + (x.cell.size / 2), to = x.max - (x.cell.size / 2), length.out = x.cell.dim)
  y <- seq(from = y.max - (y.cell.size / 2), to = y.min + (y.cell.size / 2), length.out = y.cell.dim)
  
  x <- rep(x, times = y.cell.dim)
  y <- rep(y, each = x.cell.dim)
  
  coor.lst <- list(Lat = y, Lon = x)
  
  return(coor.lst)
} 


dem.tile <- function(filename, new.loc) {

  # Read the TIF file
  rg <- readGDAL(filename)
  
  # Get the DEM points
  dem <- rg@data$band1
  dem.nrow <- rg@grid@cells.dim[2] # Lat - Y
  dem.ncol <- rg@grid@cells.dim[1] # Lon - X
  # Get the coordinates of the DEM points
  coor <- tiff.latlon(rg)
  
  # Reduce resolution
  dem.small <- reduce.res(dem, dem.nrow, dem.ncol, 15)
  lat.small <- reduce.res(coor$Lat, dem.nrow, dem.ncol, 15)
  lon.small <- reduce.res(coor$Lon, dem.nrow, dem.ncol, 15)
  
  # Linear Interpolation
  options(warn = -1)
  z <- akima.interpp(lon.small, lat.small, dem.small, new.loc$Lon, new.loc$Lat)
  options(warn = 0)
  names(z)[1] <- 'Lon'
  names(z)[2] <- 'Lat'
  names(z)[3] <- 'DEM'
  
  return(z)
  
}