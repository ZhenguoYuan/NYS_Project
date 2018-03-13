library(ncdf4)
library(ggplot2)

setwd('~/Downloads/')

nc <- nc_open('cmaq_amad_conus_pm25_pm25_2002.nc')

time <- ncvar_get(nc, varid = 'TFLAG')
time <- time[ , 1, ] # Remove the redundant time information (keep the first row of the second dimension)

elev <- ncvar_get(nc, varid = 'ELEVATION')
pm25 <- ncvar_get(nc, varid = 'PM25')

lon <- ncvar_get(nc, varid = 'LONGITUDE')
lon <- lon[ , , 1] # Remove the redundant lon information (keep the first array of 8760 arraies)
lat <- ncvar_get(nc, varid = 'LATITUDE')
lat <- lat[ , , 1] # Remove the redundant lat information (keep the first array of 8760 arraies)