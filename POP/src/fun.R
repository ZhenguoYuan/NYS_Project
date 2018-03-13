load.pop <- function(inpath, file){
  
  # Read NC file
  nc <- nc_open(file.path(inpath, file))
  
  # Load parameters
  lat.old <- ncvar_get(nc, varid = 'lat')
  lon.old <- ncvar_get(nc, varid = 'lon')
  lspop.old <- ncvar_get(nc, varid = substring(file, first = 1, last = 9))
  
  # Reshape parameters
  lat <- rep(lat.old, each = length(lon.old))
  lon <- rep(lon.old, times = length(lat.old))
  lspop <- matrix(lspop.old, nrow = length(lat.old)*length(lon.old))
  
  # Remove NAs (change to 0s)
  idx <- is.na(lspop)
  lspop[idx, 1] <- 0
  
  # Output data frame
  dat <- data.frame(lat = lat, lon = lon, lspop = lspop)
  
  return(dat)
}

##--------------------
# Find the index of the nearest point
over.idx <- function(dat, new.loc) {
  len <- sqrt((new.loc$Lon - dat$lon)^2 + (new.loc$Lat - dat$lat)^2)
  idx <- which(len == min(len))
}
