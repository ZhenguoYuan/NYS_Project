# Tools functions
# Jianzhao Bi
# 12/3/2017
#---------------------
## The tool functions

library(gstat)
library(sp)
library(akima)
library(maptools)

### -------------- TOOLS -------------- ###

## --------------------
# Converting lat/lon to km
xy.latlon <- function(Lat, Long){
  
  lon0 <- mean(range(Long))
  lat0 <- mean(range(Lat))
  
  rx <- 6371 * acos(sin(lat0 *pi/180)^2 + cos(lat0*pi/180)^2 * cos((lon0+.5)*pi/180 - (lon0-.5)*pi/180))
  ry <- 6371 * acos(sin((lat0 -.5)*pi/180) *  sin((lat0+.5)*pi/180) + cos((lat0-.5)*pi/180) * cos((lat0+.5)*pi/180))
  
  x.km <-(Long-lon0)*rx
  y.km <-(Lat-lat0)*ry
  
  return(data.frame(Y_Lat = y.km, X_Lon = x.km))
  
}

## --------------------
## Using NYS Shapefile to cut the data set
cutByShp <- function(shp.name, dat) {
  
  myshp <- readShapePoly(shp.name)
  myshp <- subset(myshp, NAME == 'New York')
  
  if ('Longitude' %in% names(dat)) {
    coordinates(dat) = ~ Longitude + Latitude
  } else if ('Lon' %in% names(dat)) {
    coordinates(dat) = ~ Lon + Lat
  } else if ('lon' %in% names(dat)) {
    coordinates(dat) = ~ lon + lat
  } else if ('long' %in% names(dat)) {
    coordinates(dat) = ~ long + lat
  }
  
  clip <- over(dat, myshp)
  idx_clip <- is.na(clip$STATEFP)
  dat <- as.data.frame(dat, stringsAsFactors = F)
  dat.sub <- dat[!idx_clip, ]
  
  return(dat.sub)
  
}

## --------------------
## Inverse distance weighted interpolation
idw.interp <- function(xo, yo, zo, xn, yn, nmax = 4, maxdist = Inf) {
  
  old <- data.frame(x = xo, y = yo, z = zo, stringsAsFactors = F)
  old <- na.omit(old)
  new <- data.frame(x = xn, y = yn, stringsAsFactors = F)
  
  # Produce the coordinates
  coordinates(old) <- ~x + y
  coordinates(new) <- ~x + y
  #gridded(new) <- T
  
  # Do the inverse distance weighted interpolation
  zn <- idw(formula = z ~ 1, locations = old, newdata = new, nmax = nmax, maxdist = maxdist)
  zn <- as.data.frame(zn)
  
  # Post-processing of idw
  zn$var1.var <- NULL
  
  return(zn)
  
}

## --------------------
## Inverse distance weighted interpolation with changing the column's name
idw.interp.final <- function(dat, new.loc, i, nmax = 5, maxdist = 0.15){
  # parameters 
  lon <- dat$lon
  lat <- dat$lat
  var <- dat[[i]]
  name <- colnames(dat)[i]
  
  # IDW
  idx.na <- is.na(var) # Check NAs
  if (sum(as.integer(!idx.na)) > 1) { # idw should receive at least 2 points
    df.tmp <- idw.interp(lon[!idx.na], lat[!idx.na], var[!idx.na], 
                         new.loc$Lon, new.loc$Lat, nmax = nmax, maxdist = maxdist)
  } else {
    df.tmp <- data.frame(lon = new.loc$Lon, lat = new.loc$Lat, var = rep(NA, nrow(new.loc)))
  }
  colnames(df.tmp) <- c('lon', 'lat', name)
  
  return(df.tmp)
  
}


## --------------------
## Akima interpolation
akima.interpp <- function(x, y, z, x0, y0, linear = T) {
  
  zo <- interpp(x = x, y = y, z = z, xo = x0, yo = y0, linear = linear)
  zo <- as.data.frame(zo)
  
  return(zo)
  
}

##-------------------------------------
# Reshaping matrix into vector
to.vec <- function(arr){
  vec <- matrix(arr, nrow = dim(arr)[1] * dim(arr)[2])
}

## --------------------
## Calculating how many days in a year
numOfYear <- function(year) {
  num <- as.double(as.Date(paste(as.character(year),'-12-31', sep = '')) - 
                     as.Date(paste(as.character(year),'-1-1', sep = '')) + 1)
  num <- as.numeric(num)
  return(num)
}

## --------------------
## Split one year into several doy groups for parallel computing
split.doy <- function(cluster.idx, cluster.num, year, start.date, end.date) {
  # Parallel parameters
  # cluster.idx - This cluster's number
  # cluster.num - Total number of clusters
  
  options(warn = -1)
  jobs <- split(start.date : end.date, 1 : cluster.num) # Job list of DOY
  options(warn = 0)
  this.jobs <- jobs[[cluster.idx]] # DOY indecies in this job
  this.doys <- sprintf(paste(year, '%03d', sep = ''), this.jobs) # DOYs
  
  return(this.doys)
}