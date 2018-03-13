#----------------------------
# Functions used in NLDAS
# Jianzhao Bi
# 2/12/2017
#----------------------------

##-------------------------------------
# Load file a of NLDAS
load.file.a <- function(nc_a){
  
  # Load parameters
  lon_1d <- ncvar_get(nc_a, varid = 'lon')
  lat_1d <- ncvar_get(nc_a, varid = 'lat')
  temp_2m <- ncvar_get(nc_a, varid = 'var11') # 2m Temp
  spec_humi_2m <- ncvar_get(nc_a, varid = 'var51') # 2m Specific Humidity
  surf_pres <- ncvar_get(nc_a, varid = 'var1') # Surface pressure
  zonal_wind_10m <- ncvar_get(nc_a, varid = 'var33') # 10 m Zonal wind speed
  merid_wind_10m <- ncvar_get(nc_a, varid = 'var34') # 10 m Meridional wind speed
  long_radi_surf <- ncvar_get(nc_a, varid = 'var205') # Longwave radiation downwards at surface
  conv_prec <- ncvar_get(nc_a, varid = 'var153') # Convective precipitation
  cape <- ncvar_get(nc_a, varid = 'var157') # CAPE
  pot_evap <- ncvar_get(nc_a, varid = 'var228') # Potential evaporation
  total_prec <- ncvar_get(nc_a, varid = 'var61') # precipitaiton total
  short_radi_surf <- ncvar_get(nc_a, varid = 'var204') # Shortwave radiation downwards at surface
  
  
  # Reshape Lat/Lon
  lon <- matrix(rep(lon_1d, length(lat_1d)), nrow = length(lon_1d), byrow = F)
  lat <- matrix(rep(lat_1d, length(lon_1d)), nrow = length(lon_1d), byrow = T)
  
  # Reshape all parameters
  lon <- to.vec(lon)
  lat <- to.vec(lat)
  temp_2m <- to.vec(temp_2m)
  spec_humi_2m <- to.vec(spec_humi_2m)
  surf_pres <- to.vec(surf_pres)
  zonal_wind_10m <- to.vec(zonal_wind_10m)
  merid_wind_10m <- to.vec(merid_wind_10m)
  long_radi_surf <- to.vec(long_radi_surf)
  conv_prec <- to.vec(conv_prec)
  cape <- to.vec(cape)
  pot_evap <- to.vec(pot_evap)
  total_prec <- to.vec(total_prec)
  short_radi_surf <- to.vec(short_radi_surf)
  
  # Creating a data frame
  nldas.a.df <- data.frame(lon, lat, temp_2m, spec_humi_2m, surf_pres,
                           zonal_wind_10m, merid_wind_10m, long_radi_surf,
                           conv_prec, cape, pot_evap, total_prec, short_radi_surf)
  
  return(nldas.a.df)
}

##-------------------------------------
# Load file b of NLDAS
load.file.b <- function(nc_b){
  
  # Load parameters
  lon_1d <- ncvar_get(nc_b, varid = 'lon')
  lat_1d <- ncvar_get(nc_b, varid = 'lat')
  short_flux_surf <- ncvar_get(nc_b, varid = 'var204') # shortwave radiation flux downwards at surface
  total_prec_b <- ncvar_get(nc_b, varid = 'var61') # precipitation total
  conv_prec_b <- ncvar_get(nc_b, varid = 'var63') # convective precipitation
  aero_cond <- ncvar_get(nc_b, varid = 'var179') # aerodynamic conductance
  narr_temp <- ncvar_get(nc_b, varid = 'var11') # NARR temperature
  narr_spec_humi <- ncvar_get(nc_b, varid = 'var51') # NARR specific humidity 
  narr_pres <- ncvar_get(nc_b, varid = 'var1') # NARR pressure 
  narr_zonal_wind <- ncvar_get(nc_b, varid = 'var33') # NARR zonal wind
  narr_merid_wind <- ncvar_get(nc_b, varid = 'var34') # NARR meridional wind
  narr_geopot_ht <- ncvar_get(nc_b, varid = 'var7') # NARR geopotential height
  
  # Reshape Lat/Lon
  lon <- matrix(rep(lon_1d, length(lat_1d)), nrow = length(lon_1d), byrow = F)
  lat <- matrix(rep(lat_1d, length(lon_1d)), nrow = length(lon_1d), byrow = T)
  
  # Reshape all parameters
  lon <- to.vec(lon)
  lat <- to.vec(lat)
  short_flux_surf <- to.vec(short_flux_surf)
  total_prec_b <- to.vec(total_prec_b)
  conv_prec_b <- to.vec(conv_prec_b)
  aero_cond <- to.vec(aero_cond)
  narr_temp <- to.vec(narr_temp)
  narr_spec_humi <- to.vec(narr_spec_humi)
  narr_pres <- to.vec(narr_pres)
  narr_zonal_wind <- to.vec(narr_zonal_wind)
  narr_merid_wind <- to.vec(narr_merid_wind)
  narr_geopot_ht <- to.vec(narr_geopot_ht)
  
  # Creating a data frame
  nldas.b.df <- data.frame(lon, lat, short_flux_surf, total_prec_b, 
                           conv_prec_b, aero_cond, narr_temp, narr_spec_humi,
                           narr_pres, narr_zonal_wind, narr_merid_wind, narr_geopot_ht)
  
  return(nldas.b.df)
}

##-------------------------------------
# Combining hourly data into daily data
hourly.to.daily <- function(time.range = 1 : 24, inpath_a, files.daily.a, inpath_b, files.daily.b){
  # Time range is a specific time period the meteorological data will be chosen; default is whole hours 0000 - 2300
  
  ## For each hour
  for (i in 1 : length(files.daily.a)) {
    # Read NC file
    nc_a <- nc_open(file.path(inpath_a, files.daily.a[i]))
    nc_b <- nc_open(file.path(inpath_b, files.daily.b[i]))
    
    # Load file a & b as data frames
    nldas.a.df <- load.file.a(nc_a)
    nldas.b.df <- load.file.b(nc_b)
    
    # Combine two dfs
    nldas.b.df$lon <- NULL
    nldas.b.df$lat <- NULL
    nldas.df <- cbind(nldas.a.df, nldas.b.df)
    
    # Combine hourly data into a 3-D array
    if (i == 1){
      final.array <- array(dim = c(dim(nldas.df), length(files.daily.a)))
      col.names <- colnames(nldas.df)
    } else {
      final.array[, , i] <- as.matrix(nldas.df)
      col.names <- colnames(nldas.df)
    }
    
    # Close NC files
    nc_close(nc_a)
    nc_close(nc_b)
    
  }
  
  # Calculating the average of each column
  final.array <- apply(final.array[ , , time.range], c(1,2), mean, na.rm = T)
  final.array[final.array == 'NaN'] <- NA
  final.df <- as.data.frame(final.array)
  colnames(final.df) <- col.names
  
  return(final.df)
}

