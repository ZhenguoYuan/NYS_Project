#------------------------------
# Combining all parameters 
# Jianzhao Bi
# 3/4/2018
#------------------------------

setwd('/home/jbi6/NYS_Project/Combine')

source('src/fun.R')
source('../src/fun.R')

## Input/Output
inpath <- '/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT'
outpath <- '/home/jbi6/envi/NYS_Output/MAIAC_GRID_OUTPUT/Combine/'

# Arguments for R script
Args <- commandArgs()
# Year
YEAR <- as.numeric(Args[6]) # 6th argument is the first custom argument

## ---------- PARALLEL ---------- ##

this.doys <- split.doy(cluster.idx = as.numeric(Args[7]),
                       cluster.num = as.numeric(Args[8]), 
                       year = YEAR, start.date = 1, 
                       end.date = numOfYear(as.numeric(YEAR))) 

## ---------- RUN ---------- ##

for(i.this.doy.char in 1 : length(this.doys)) { # For each day
  
  # This is the actually DOY!!!!!
  DOY <- substring(this.doys[i.this.doy.char], 5, 7)
  print(DOY) 
  
  ## ---------- Lat/Lon and Time ---------- ##
  print('Lat/Lon')
  corr <- read.csv(file = '../MAIAC_GRID/output/maiac_grid.csv', stringsAsFactors = F)
  corr <- corr[order(corr$Lat, corr$Lon), ]
  corr$ID <- seq(1, nrow(corr))
  corr$year <- rep(as.numeric(YEAR), nrow(corr))
  corr$doy <- rep(as.numeric(DOY), nrow(corr))
  dat.final <- corr
  # Reference Lat/Lon
  ref.lat <- corr$Lat
  ref.lon <- corr$Lon
  
  ## ---------- X/Y ---------- ##
  corr.xy <- xy.latlon(ref.lat, ref.lon)
  dat.final <- cbind(dat.final, corr.xy)
  
  ## ---------- MAIAC AOD ---------- ##
  print('MAIAC AOD')
  ## MAIAC TAOT
  taot <- load.csv(file.path(inpath, 'MAIAC_AOD', as.character(YEAR), 'TAOT'), '_TAOT.csv', YEAR, DOY, 'MAIAC TAOT')
  dat.final <- load.var(taot, ref.lat, ref.lon, dat.final,
                        var.names = c('AOD470_TAOT', 'AOD550_TAOT'), 
                        var.cols = c(3, 4), 'MAIAC TAOT')
  ## MAIAC AAOT
  aaot <- load.csv(file.path(inpath, 'MAIAC_AOD', as.character(YEAR), 'AAOT'), '_AAOT.csv', YEAR, DOY, 'MAIAC AAOT')
  dat.final <- load.var(aaot, ref.lat, ref.lon, dat.final,
                        var.names = c('AOD470_AAOT', 'AOD550_AAOT'), 
                        var.cols = c(3, 4), 'MAIAC AAOT')
  
  
  ## ---------- MODIS Cloud ---------- ##
  print('MODIS Cloud')
  ## MODIS Cloud Terra
  cloud_terra <- load.csv(file.path(inpath, 'MODIS_Cloud', as.character(YEAR), 'MOD06_L2'), '_MOD06_L2.csv', YEAR, DOY, 'MODIS Cloud Terra')
  dat.final <- load.var(cloud_terra, ref.lat, ref.lon, dat.final,
                        var.names = c('Cloud_Frac_Terra', 'Cloud_Frac_Day_Terra'), 
                        var.cols = c(3, 4), 'MODIS Cloud Terra')
  ## MODIS Cloud Aqua
  cloud_aqua <- load.csv(file.path(inpath, 'MODIS_Cloud', as.character(YEAR), 'MYD06_L2'), '_MYD06_L2.csv', YEAR, DOY, 'MODIS Cloud Aqua')
  dat.final <- load.var(cloud_aqua, ref.lat, ref.lon, dat.final,
                        var.names = c('Cloud_Frac_Aqua', 'Cloud_Frac_Day_Aqua'), 
                        var.cols = c(3, 4), 'MODIS Cloud Aqua')
  
  
  ## ---------- MODIS Snow ---------- ##
  print('MODIS Snow')
  ## MODIS Snow Terra
  snow_terra <- load.csv(file.path(inpath, 'MODIS_Snow', as.character(YEAR), 'MOD10C1'), '_MOD10C1.csv', YEAR, DOY, 'MODIS Snow Terra')
  dat.final <- load.var(snow_terra, ref.lat, ref.lon, dat.final,
                        var.names = c('Snow_Cover_Terra'),
                        var.cols = c(3), 'MODIS Snow Terra')
  ## MODIS Snow Aqua
  snow_aqua <- load.csv(file.path(inpath, 'MODIS_Snow', as.character(YEAR), 'MYD10C1'), '_MYD10C1.csv', YEAR, DOY, 'MODIS Snow Aqua')
  dat.final <- load.var(snow_aqua, ref.lat, ref.lon, dat.final,
                        var.names = c('Snow_Cover_Aqua'),
                        var.cols = c(3), 'MODIS Snow Aqua')
  
  
  ## ---------- ASTER GDEM ---------- ##
  print('ASTER GDEM')
  dem <- read.csv(file = file.path(inpath, 'ASTER_GDEM', 'DEM.csv'), stringsAsFactors = F)
  # Ordering dataframe
  if ('Lat' %in% colnames(dem)) {
    dem <- dem[order(dem$Lat, dem$Lon), ]
  } else if ('lat' %in% colnames(dem)) {
    dem <- dem[order(dem$lat, dem$lon), ]
  } 
  dat.final <- load.var(dem, ref.lat, ref.lon, dat.final,
                        var.names = c('DEM'),
                        var.cols = c(3), 'ASTER GDEM')
  
  ## ---------- GLOBCOVER ---------- ##
  print('GLOBCOVER')
  landuse <- read.csv(file = file.path(inpath, 'GLOBCOVER', 'globcover.csv'), stringsAsFactors = F)
  # Ordering dataframe
  if ('Lat' %in% colnames(landuse)) {
    landuse <- landuse[order(landuse$Lat, landuse$Lon), ]
  } else if ('lat' %in% colnames(landuse)) {
    landuse <- landuse[order(landuse$lat, landuse$lon), ]
  } 
  dat.final <- load.var(landuse, ref.lat, ref.lon, dat.final,
                        var.names = c('GRIDCODE'),
                        var.cols = c(3), 'GLOBCOVER')
  
  ## ---------- NDVI ---------- ##
  print('NDVI')
  load(file.path(inpath, 'NDVI', as.character(YEAR), paste(YEAR, DOY, '_NDVI.RData', sep = '')))
  # Ordering dataframe
  if ('Lat' %in% colnames(ndvi.sub.new)) {
    ndvi.sub.new <- ndvi.sub.new[order(ndvi.sub.new$Lat, ndvi.sub.new$Lon), ]
  } else if ('lat' %in% colnames(ndvi.sub.new)) {
    ndvi.sub.new <- ndvi.sub.new[order(ndvi.sub.new$lat, ndvi.sub.new$lon), ]
  } 
  dat.final <- load.var(ndvi.sub.new, ref.lat, ref.lon, dat.final,
                        var.names = c('NDVI'),
                        var.cols = c(3), 'NDVI')
  
  ## ---------- POP ----------##
  print('Population')
  pop <- read.csv(file = file.path(inpath, 'POP', paste('lspop', as.character(YEAR), '.csv', sep = '')), stringsAsFactors = F)
  # Ordering dataframe
  if ('Lat' %in% colnames(pop)) {
    pop <- pop[order(pop$Lat, pop$Lon), ]
  } else if ('lat' %in% colnames(pop)) {
    pop <- pop[order(pop$lat, pop$lon), ]
  } 
  dat.final <- load.var(pop, ref.lat, ref.lon, dat.final,
                        var.names = c('pop'),
                        var.cols = c(4), 'POP')
  
  ## ---------- ROAD NETWORK ----------##
  print('Highway')
  highway <- read.csv(file = file.path(inpath, 'ROAD_NETWORK', 'highwaydist.csv'), stringsAsFactors = F)
  # Ordering dataframe
  if ('Lat' %in% colnames(highway)) {
    highway <- highway[order(highway$Lat, highway$Lon), ]
  } else if ('lat' %in% colnames(highway)) {
    highway <- highway[order(highway$lat, highway$lon), ]
  }
  dat.final <- load.var(highway, ref.lat, ref.lon, dat.final,
                        var.names = c('HighwayDist'),
                        var.cols = c(16), 'HIGHWAY')
  
  print('Major')
  major <- read.csv(file = file.path(inpath, 'ROAD_NETWORK', 'majordist.csv'), stringsAsFactors = F)
  # Ordering dataframe
  if ('Lat' %in% colnames(major)) {
    major <- major[order(major$Lat, major$Lon), ]
  } else if ('lat' %in% colnames(major)) {
    major <- major[order(major$lat, major$lon), ]
  }
  dat.final <- load.var(major, ref.lat, ref.lon, dat.final,
                        var.names = c('MajorDist'),
                        var.cols = c(17), 'MAJOR')
  
  
  ## ---------- NARR ---------- ##
  print('NARR')
  narr.var.name <- c('dlwrf', 'dpt', 'dswrf', 'hpbl', 'pres', 'rhum', 'air', 'uwnd', 'vis', 'vwnd')
  for (i.narr in 1 : length(narr.var.name)) {
    narr.file.name <- file.path(inpath, 'NARR', as.character(YEAR), narr.var.name[i.narr], # File path
                                paste(as.character(YEAR), sprintf("%03d", as.numeric(DOY)), '_', narr.var.name[i.narr], '.RData', sep = '')) # File name
    load(narr.file.name)
    narr.daily <- get(narr.var.name[i.narr])
    # Ordering dataframe
    if ('Lat' %in% colnames(narr.daily)) {
      narr.daily <- narr.daily[order(narr.daily$Lat, narr.daily$Lon), ]
    } else if ('lat' %in% colnames(narr.daily)) {
      narr.daily <- narr.daily[order(narr.daily$lat, narr.daily$lon), ]
    }
    dat.final <- load.var(narr.daily, ref.lat, ref.lon, dat.final,
                          var.names = c(paste(toupper(narr.var.name[i.narr]), 'NARR', sep = '_')),
                          var.cols = c(3), narr.var.name[i.narr])
  }
  
  ## ---------- NLDAS ---------- ##
  print('NLDAS')
  
  ### Paths ###
  # This day's file
  nldas.file.name <- file.path(inpath, 'NLDAS', as.character(YEAR), # File path
                               paste(as.character(YEAR), sprintf("%03d", as.numeric(DOY)), '_NLDAS.RData', sep = '')) # File name
  # Previous day's file
  if (DOY != 1) {
    nldas.file.name.pre <- file.path(inpath, 'NLDAS', as.character(YEAR), # File path
                                     paste(as.character(YEAR), sprintf("%03d", as.numeric(DOY) - 1), '_NLDAS.RData', sep = '')) # File name
  } else {
    # Previous year - The last day of last year
    nldas.file.name.pre <- file.path(inpath, 'NLDAS', as.character(YEAR - 1), # File path
                                     paste(as.character(YEAR - 1), sprintf("%03d", numOfYear(YEAR - 1)), '_NLDAS.RData', sep = '')) # File name
  }
  
  ### Load files ###
  if (file.exists(nldas.file.name.pre)){ # If there is previous day
    # Previous day
    load(nldas.file.name.pre)
    nldas.daily.new.pre <- nldas.daily.new
    # This day
    load(nldas.file.name)
  } else { # If not
    load(nldas.file.name)
    nldas.daily.new.pre <- nldas.daily.new
  }
  
  ### Ordering dataframe ###
  # This day
  if ('Lat' %in% colnames(nldas.daily.new)) {
    nldas.daily.new <- nldas.daily.new[order(nldas.daily.new$Lat, nldas.daily.new$Lon), ]
  } else if ('lat' %in% colnames(nldas.daily.new)) {
    nldas.daily.new <- nldas.daily.new[order(nldas.daily.new$lat, nldas.daily.new$lon), ]
  }
  # Previous day
  if ('Lat' %in% colnames(nldas.daily.new.pre)) {
    nldas.daily.new.pre <- nldas.daily.new.pre[order(nldas.daily.new.pre$Lat, nldas.daily.new.pre$Lon), ]
  } else if ('lat' %in% colnames(nldas.daily.new.pre)) {
    nldas.daily.new.pre <- nldas.daily.new.pre[order(nldas.daily.new.pre$lat, nldas.daily.new.pre$lon), ]
  }

  ### Load vars ###
  # Other parameters
  dat.final <- load.var(nldas.daily.new, ref.lat, ref.lon, dat.final,
                        var.names = c('temp_2m_NLDAS','spec_humi_2m_NLDAS',
                                      'surf_pres_NLDAS','zonal_wind_10m_NLDAS','merid_wind_10m_NLDAS',
                                      'long_radi_surf_NLDAS','conv_prec_NLDAS','cape_NLDAS','pot_evap_NLDAS',
                                      'short_radi_surf_NLDAS','short_flux_surf_NLDAS',
                                      'total_prec_b_NLDAS','conv_prec_b_NLDAS','aero_cond_NLDAS','narr_temp_NLDAS',
                                      'narr_spec_humi_NLDAS','narr_pres_NLDAS','narr_zonal_wind_NLDAS',
                                      'narr_merid_wind_NLDAS','narr_geopot_ht_NLDAS'), 
                        var.cols = c(3 : 11, 13 : 23), 'NLDAS')
  # Previous day's precipitation
  dat.final <- load.var(nldas.daily.new.pre, ref.lat, ref.lon, dat.final,
                        var.names = c('total_prec_NLDAS'), 
                        var.cols = c(12), 'NLDAS_PREC')
  
  
  ## ---------- AERONET ---------- ##
  print('AERONET')
  aeronet <- read.csv(file = file.path(inpath, 'AERONET', 'AERONET_NYS.csv'), stringsAsFactors = F)
  # Find year and doy
  aeronet.doy <- subset(aeronet, year == YEAR & doy == as.numeric(DOY))
  ## idw
  # 470 nm
  if (nrow(aeronet.doy) != 0){
    if (!all(is.na(aeronet.doy$AOT470))) {
      aeronet470.idw <- idw.interp(aeronet.doy$lon, aeronet.doy$lat, aeronet.doy$AOT470, ref.lon, ref.lat, nmax = 100, maxdist = 0.005)
      aeronet470.idw <- aeronet470.idw[, 3]
    } else {
      aeronet470.idw <- rep(NA, length(ref.lat))
    }
  } else {
    aeronet470.idw <- rep(NA, length(ref.lat))
  }
  # 550 nm
  if (nrow(aeronet.doy) != 0){
    if (!all(is.na(aeronet.doy$AOT550))) {
      aeronet550.idw <- idw.interp(aeronet.doy$lon, aeronet.doy$lat, aeronet.doy$AOT550, ref.lon, ref.lat, nmax = 100, maxdist = 0.005)
      aeronet550.idw <- aeronet550.idw[, 3]
    } else {
      aeronet550.idw <- rep(NA, length(ref.lat))
    }
  } else {
    aeronet550.idw <- rep(NA, length(ref.lat))
  }
  
  dat.final <- cbind(dat.final, data.frame(AERONET_AOD470 = aeronet470.idw, AERONET_AOD550 = aeronet550.idw))
  
  ## ---------- PM2.5 ---------- ##
  print('PM2.5')
  pm25 <- read.csv(file = file.path(inpath, 'PM25', paste('PM25_', as.character(YEAR), '.csv', sep = '')), stringsAsFactors = F)
  # Find year and doy
  pm25.doy <- subset(pm25, year == YEAR & doy == as.numeric(DOY))
  # idw
  if (nrow(pm25.doy) != 0){
    pm25.idw <- idw.interp(pm25.doy$lon, pm25.doy$lat, pm25.doy$pm25, ref.lon, ref.lat, nmax = 100, maxdist = 0.005)
    pm25.idw <- pm25.idw[, 3]
  } else {
    pm25.idw <- rep(NA, length(ref.lat))
  }
  dat.final <- cbind(dat.final, data.frame(PM25 = pm25.idw))

  ## ---------- Output ---------- ##
  output.year <- file.path(outpath, as.character(YEAR))
  if (!file.exists(output.year)) {
    dir.create(output.year, recursive = T)
  }
  #write.csv(x = dat.final, file = file.path(outpath, paste(as.character(YEAR), DOY, '_combine.csv', sep = '')), row.names = F)
  combine <- dat.final
  save(combine, file = file.path(output.year, paste(as.character(YEAR), DOY, '_combine.RData', sep = '')))
  
  gc()
  
}


