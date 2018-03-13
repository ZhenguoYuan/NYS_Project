#---------------------
# Functions used in NARR
#
# Jianzhao Bi
# 2/12/2018
#---------------------

#-----------------
## Generating daily RData files of NARR data
narr.daily <- function (file.prefix, var.name, year, inpath, outpath, new.loc, time.range) {
  # Time range is a specific time period the meteorological data will be chosen; default is whole hours 0000, 0300, ..., 2100
  
  ## ---------- Read NC files ---------- ##
  # NC file name
  file.name.nc <- file.path(inpath, paste(file.prefix, '.', as.character(year), '.nc', sep = ''))
  # Reading NC variables
  library(ncdf4)
  nc.file <- nc_open(file.name.nc)
  lon <- ncvar_get(nc.file, varid = 'lon')
  lat <- ncvar_get(nc.file, varid = 'lat')
  time <- ncvar_get(nc.file, varid = 'time')
  var <- ncvar_get(nc.file, varid = var.name)
  nc_close(nc.file)
  # Post-processing
  time <- as.POSIXlt(time * 3600, origin = '1800-01-01 00:00') # Converting "hours since date" to the date-time object
  lon.vec <- to.vec(lon) # To vector
  lat.vec <- to.vec(lat) # To vector
  doys <- time$yday + 1 # day of year
  
  ## ---------- Output RData files ---------- ##
  for (i in 1 : numOfYear(year)) {
    
    print(paste(var.name, as.character(i), sep = ': day '))
    
    # Selecting daily data
    var.daily <- var[ , , doys == i] # Choosing the data in Day i
    time.daily <- time[doys == i] # Choosing the data in Day i
    # Selecting certain hours' data
    time.idx <- which(time.daily$hour >= min(time.range) & time.daily$hour <= max(time.range))
    var.daily <- var.daily[, , time.idx]
    # Calculating the mean in each day
    var.daily <- apply(var.daily, c(1, 2), mean, na.rm = T)
    var.daily.vec <- to.vec(var.daily)
    # Resampling
    dat.ori <- data.frame(lon = lon.vec, lat = lat.vec, var.daily.vec) # Forming a data frame
    names(dat.ori)[3] <- var.name
    dat.ori <- subset(dat.ori, lon >= -81 & lon <= -70 & lat >= 39 & lat <= 47) # Cutting
    dat.new <- idw.interp.final(dat.ori, new.loc, i = 3, nmax = 5, maxdist = Inf) # Interpolation
    
    # Save files
    outpath.rdata <- file.path(outpath, as.character(year), var.name)
    if (file.exists(outpath.rdata) == F) {
      dir.create(outpath.rdata, recursive = T)
    }
    file.name.rdata <- paste(as.character(year), sprintf("%03d", as.numeric(i)), '_', var.name, '.RData', sep = '')
    assign(x = var.name, value = dat.new) # Assigning the data.frame to a variable named by the name of which in NARR dataset
    save(list = var.name, file = file.path(outpath.rdata, file.name.rdata))
    
  }
  
}

## --------------------
## Parallel Computing of NARR data set generation
pc.run <- function (ichunk, file.prefix, var.name, year, inpath, outpath, new.loc, time.range) {
  
  library(ncdf4)
  library(gstat)
  library(sp)
  library(akima)
  
  ## Parallel Computing
  for (i in ichunk) {
    narr.daily(file.prefix = file.prefix[i], var.name = var.name[i], year, inpath, outpath, new.loc, time.range)
  }
  
  return()
}

## --------------------
## Splitting the parallel jobs and sending them to the cluster
pc.split <- function(cls, file.prefix, var.name, year, inpath, outpath, new.loc, time.range) {
  
  n <- length(file.prefix) # Number of i in for loop
  nc <- length(cls) # Number of clusters
  
  # determine which worker gets which chunk of i
  options(warn = -1)
  ichunks <- split(1 : n, 1 : nc)
  options(warn = 0)
  
  # Apply the code to the cluster
  clusterApply(cls, ichunks, pc.run, file.prefix, var.name, year, inpath, outpath, new.loc, time.range)
  
}
