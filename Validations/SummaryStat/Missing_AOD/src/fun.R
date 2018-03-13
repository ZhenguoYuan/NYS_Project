## Calculating the missing rates caused by cloud/snow
##################################
# -- Cloud Mask --
# 000 --- Undefined
# 001 --- Clear
# 010 --- Possible Cloudy
# 011 --- Cloudy
# 101 --- Cloud Shadow
# 110 --- Fire Hotspot
# 111 --- Water Sediments
# -- Land Water Snow/Ice Mask --
# 00 --- Land
# 01 --- Water
# 10 --- Snow
# 11 --- Ice
# -- Adjacency Mask --
# 000 --- Normal Condition
# 001 --- Adjacent to Cloud
# 010 --- Surrounded by more than 8 Cloudy Pixels
# 011 --- Single Cloudy Pixel
# 100 --- Adjacent to Snow
# 101 --- Snow was previously detected for this pixel
# -- AOT Quality FLAG --
# 0 --- Good
# 1 --- Possible Cloud Contamination
##################################
missingRate <- function(dat) {
  # --- Overall missing --- #
  missing.tag <- is.na(dat$AOT_055)
  overall.missing.rate <- sum(missing.tag) / nrow(dat) * 100
  
  # --- Cloud --- #
  missing.cloud.tag <- is.na(dat$AOT_055) & (dat$QA_cloudmask == "'011" | dat$QA_cloudmask == "'010" |  # Cloud Mask
                                               dat$QA_cloudmask == "'101" | dat$QA_cloudmask == "'110" | 
                                               dat$QA_cloudmask == "'111" | dat$QA_adjmask == "'001" |
                                               dat$QA_adjmask == "'010" | dat$QA_adjmask == "'011" | 
                                               dat$QA_aotqualityflag == "'1")
  cloud.missing.rate <- sum(missing.cloud.tag) / nrow(dat) * 100
  
  # --- Cloud & Snow --- #
  missing.cloudsnow.tag <- is.na(dat$AOT_055) & (dat$QA_landmask == "'10" | dat$QA_adjmask == "'100" | dat$QA_adjmask == "'101" ) & # Snow Mask
    (dat$QA_cloudmask == "'011" | dat$QA_cloudmask == "'010" | # Cloud Mask
       dat$QA_cloudmask == "'101" | dat$QA_cloudmask == "'110" | 
       dat$QA_cloudmask == "'111" | dat$QA_adjmask == "'001" | 
       dat$QA_adjmask == "'010" | dat$QA_adjmask == "'011" | 
       dat$QA_aotqualityflag == "'1")
  cloudsnow.missing.rate <- sum(missing.cloudsnow.tag) / nrow(dat) * 100
  
  # --- Only Snow (Cloud - Cloud & Snow) --- #
  missing.snow.tag <- is.na(dat$AOT_055) & (dat$QA_landmask == "'10" | dat$QA_adjmask == "'100" | dat$QA_adjmask == "'101") # Snow Mask
  snow.missing.rate <- sum(missing.snow.tag) / nrow(dat) * 100 - cloudsnow.missing.rate
  
  # --- Cloud & Water/Ice --- #
  missing.cloudwaterice.tag <- is.na(dat$AOT_055) & (dat$QA_landmask == "'01" | dat$QA_landmask == "'11") & # Water/Ice Mask
    (dat$QA_cloudmask == "'011" | dat$QA_cloudmask == "'010" | # Cloud Mask
       dat$QA_cloudmask == "'101" | dat$QA_cloudmask == "'110" | 
       dat$QA_cloudmask == "'111" | dat$QA_adjmask == "'001" | 
       dat$QA_adjmask == "'010" | dat$QA_adjmask == "'011" | 
       dat$QA_aotqualityflag == "'1")
  cloudwaterice.missing.rate <- sum(missing.cloudwaterice.tag) / nrow(dat) * 100
  
  # --- Only Water/Ice (Cloud - Cloud & Water/Ice) --- #
  missing.waterice.tag <- is.na(dat$AOT_055) & (dat$QA_landmask == "'01" | dat$QA_landmask == "'11") # Water/Ice Mask
  waterice.missing.rate <- sum(missing.waterice.tag) / nrow(dat) * 100 - cloudwaterice.missing.rate
  
  return(list(overall = overall.missing.rate, cloud = cloud.missing.rate, snow = snow.missing.rate, waterice = waterice.missing.rate))
}

## Calculate daily missing rates for AAOT or TAOT
calDailyMissingRate <- function(inpath, aottype, year, doy, shp.path) {
  
  # Displaying the file names
  files.v03 <- dir(path = file.path(inpath, 'h04v03/', as.character(year), aottype), full.names = T, pattern = 
                     paste('MAIAC', aottype, '.h04v03.', as.character(year), sprintf('%03d', doy), sep = ''))
  files.v04 <- dir(path = file.path(inpath, 'h04v04/', as.character(year), aottype), full.names = T, pattern = 
                     paste('MAIAC', aottype, '.h04v04.', as.character(year), sprintf('%03d', doy), sep = ''))
  files <- c(files.v03, files.v04)
  
  if (length(files) != 0) {
    
    # Combining CSV files, and using shp to cut
    dat.final <- data.frame()
    for (file.i in 1 : length(files)) {
      
      print(files[file.i])
      
      dat <- read.csv(file = files[file.i], as.is = T, stringsAsFactors = F, na.strings = 'NaN')
      dat.sub <- cutByShp(shp.path, dat)
      dat.final <- rbind(dat.final, dat.sub)
      
    }
    
    # Missing rates
    rates.daily <- missingRate(dat.final)
    rates.daily <- c(rates.daily, list(year = year, doy = doy))
    
  } else { # If there is no data
    
    rates.daily <- NULL
    
  }
  
  
  return(rates.daily)
  
}