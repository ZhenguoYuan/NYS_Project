#------------------------------
# Functions used in combine
# Jianzhao Bi
# 11/13/2017
#------------------------------

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

# Loading csv files
load.csv <- function(filepath, pattern, year, doy, tag){
  
  var.dir <- filepath
  var.file <- dir(path = var.dir, pattern = paste('*', doy, pattern, sep = ''))
  
  if (length(var.file) == 0) {
    var <- NULL
  } else {
    var <- read.csv(file.path(var.dir, var.file), stringsAsFactors = F)
    # Ordering dataframe
    if ("Lat" %in% colnames(var)) {
      var <- var[order(var$Lat, var$Lon), ]
    } else if ("lat" %in% colnames(var)) {
      var <- var[order(var$lat, var$lon), ]
    } else {
      stop(paste(tag, 'There is not Lat/Lon data in data frame!', sep = ':'))
    }
  }
  
  return(var)
}

# Checking whether lat/lon match the referecen (new.loc) lat/lon
check.latlon <- function(lat, lon, ref.lat, ref.lon){
  flag.lat <- all(lat == ref.lat)
  flag.lon <- all(lon == ref.lon)
  
  if (flag.lat & flag.lon){
    return(T)
  } else {
    return(F)
  }
}

# Loading parameters from input files
load.var <- function(var, ref.lat, ref.lon, dat.final, var.names, var.cols, tag){
  
  if (is.null(var)){ # If there is no data at that day, output NAs
    print(paste(tag, 'NULL', sep = ':'))
    # Outputting into the final dataframe
    for (i in 1 : length(var.names)){
      dat.tmp <- data.frame(rep(NA, length(ref.lat)))
      names(dat.tmp)[1] <- var.names[i]
      dat.final <- cbind(dat.final, dat.tmp)
    }
  } else {
    # Checking Lat/Lon
    flag <- check.latlon(var$lat, var$lon, ref.lat, ref.lon)
    if (flag == T) {
      print(paste(tag, 'Pass Lat/Lon Checking!', sep = ':'))
    } else {
      stop(paste(tag, 'Fail to match Lat/Lon!', sep = ':'))
    }
    # Outputting into the final dataframe
    for (i in 1 : length(var.names)){
      dat.tmp <- data.frame(var[, var.cols[i]])
      names(dat.tmp)[1] <- var.names[i]
      dat.final <- cbind(dat.final, dat.tmp)
    }
  }
  
  
  return(dat.final)
}