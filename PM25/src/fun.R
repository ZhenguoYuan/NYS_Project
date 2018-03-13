#-----------------------------
# Functions in PM2.5 Ground
# Jianzhao Bi
# 11/12/2017
#-----------------------------
# Functions needed in generating files of ground PM2.5 observations

library(gdata)
library(lubridate)

## Loading NAPS old format
load.naps.old <- function(year, site.info, inputpath, method, method_short) {
  
  # Read files
  files <- dir(file.path(inputpath, as.character(year), method), pattern = paste('*_', method_short, '.XLS', sep = ''))
  if (length(files) == 0) {
    print('File number is 0!')
    return(NULL)
  }
  dat.final <- data.frame()
  
  for (i in 1 : length(files)) { # For each site
    
    print(files[i])
    
    # Site Name
    site.id <- strsplit(files[i], '_')[[1]][1]
    site.id <- as.integer(strsplit(site.id, 'S')[[1]][2])
    # Lat & Lon
    lat <- site.info[site.info$NAPS_ID == site.id, ]$Lat_Decimal
    lon <- site.info[site.info$NAPS_ID == site.id, ]$Long_Decimal
    
    if ((lat >= min(lat.range)) & (lat <= max(lat.range)) & 
        (lon >= min(lon.range)) & (lon <= max(lon.range))) {
      
      if (year < 2009) {
        dat <- read.xls(file.path(inputpath, as.character(year), method, files[i]), stringsAsFactors = F, skip = 1)
        names(dat) <- toupper(names(dat)) # Change all the headers to the upper case
      } else {
        dat <- read.xls(file.path(inputpath, as.character(year), method, files[i]), stringsAsFactors = F, skip = 2)
        names(dat) <- toupper(names(dat)) # Change all the headers to the upper case
        if (names(dat)[1] != 'DATE' & nrow(dat) > 1) {
          dat <- read.xls(file.path(inputpath, as.character(year), method, files[i]), stringsAsFactors = F, skip = 3)
          names(dat) <- toupper(names(dat)) # Change all the headers to the upper case
        }
      }
      
      # Change the MASS name for SPECIATION
      if (method == 'SPECIATION') {
        names(dat)[which(names(dat) == toupper('Speciation.Mass..ug.m3.'))] <- 'MASS'
      }
      
      if (!is.null(dat$MASS) & nrow(dat) > 1) { # Skip the files without MASS information
        
        # Remove PM10 observations for DICHOT
        if (method == 'DICHOT') {
          dat <- subset(dat, C.F == 'F')
        }
        
        # Time 
        dat.tmp <- data.frame(year = substring(dat$DATE, 1, 4)) # year
        dat.tmp$date <- as.Date(dat$DATE, format = '%Y-%m-%d') # Date
        # DOY
        dat.tmp$doy <- yday(dat.tmp$date)
        # Site info
        dat.tmp$site.id <- site.id
        dat.tmp$lon <- lon
        dat.tmp$lat <- lat
        # PM2.5
        dat.tmp$pm25 <- dat$MASS
        # Unit
        dat.tmp$unit <- 'ug/m3'
        # aqs.code
        dat.tmp$aqs.code <- NA
        # Method
        dat.tmp$method <- method
        
        # Combine the data set
        dat.final <- rbind(dat.final, dat.tmp)
      }
    }
  }
  
  # Ordering the data
  if (nrow(dat.final) > 1) {
    dat.final <- dat.final[order(dat.final$year, dat.final$doy), ]
  }
  
  return(dat.final)
  
}

## Combining three observations
combine.naps <- function(dat) {
  
  dichot <- subset(dat, method == 'DICHOT')
  part25 <- subset(dat, method == 'PART25')
  spec <- subset(dat, method == 'SPECIATION')
  
  value <- mean(c(dichot$pm25, part25$pm25), na.rm = T) # Considering DICHOT and PART25 first
  
  ### DON'T CONSIDER SPEC
  # if (is.na(value)) {# Considering SPEC
  #   value <- spec$pm25
  # }
  
  # Creating new data
  dat.new <- dat[1, ]
  dat.new$pm25 <- value
  dat.new$method <- 'COMBINE'
  
  return(dat.new)
}

naps.old <- function(year, site.info, inputpath) {
  
  ## ----- Loading PM2.5 ----- ##
  # DICHOT
  dat.dich <- load.naps.old(year, site.info, inputpath, 'DICHOT', 'DICH')
  # PART25
  dat.part25 <- load.naps.old(year, site.info, inputpath, 'PART25', 'PART25')
  # SPECIATION
  dat.spec <- load.naps.old(year, site.info, inputpath, 'SPECIATION', 'SPEC')
  
  ## ----- Combining three observations ----- ##
  dat.naps <- rbind(dat.dich, dat.part25, dat.spec)
  dat.naps <- dat.naps[order(dat.naps$year, dat.naps$doy, dat.naps$site.id), ]
  # Creating a combining factor
  dat.naps$combine <- paste(as.character(dat.naps$year), as.character(dat.naps$doy), as.character(dat.naps$site.id), sep = '.')
  dat.naps$combine <- as.factor(dat.naps$combine)
  # Combining
  dat.naps.final <- data.frame()
  for (i in levels(dat.naps$combine)){
    dat.tmp <- subset(dat.naps, combine == i)
    if (nrow(dat.tmp) == 1) {
      dat.naps.final <- rbind(dat.naps.final, dat.tmp)
    } else {
      dat.tmp <- combine.naps(dat.tmp)
      dat.naps.final <- rbind(dat.naps.final, dat.tmp)
    }
  }
  dat.naps.final$combine <- NULL
  # Removing NAs in PM2.5
  dat.naps.final <- subset(dat.naps.final, !is.na(dat.naps.final$pm25))
  
  
  return(dat.naps.final)
}

## Loading NAPS new format (integrated PM2.5)
naps.new <- function(year, site.info, inputpath) {
  
  files <- dir(file.path(inputpath, as.character(year)), pattern = '*.xlsx')
  dat.final <- data.frame()
  
  for (i in 1 : length(files)) { # For each site
    
    print(files[i])
    
    # Site Name
    site.id <- strsplit(files[i], '_')[[1]][1]
    site.id <- as.integer(strsplit(site.id, 'S')[[1]][2])
    # Lat & Lon
    lat <- site.info[site.info$NAPS_ID == site.id, ]$Lat_Decimal
    lon <- site.info[site.info$NAPS_ID == site.id, ]$Long_Decimal
    
    if ((lat >= min(lat.range)) & (lat <= max(lat.range)) & 
        (lon >= min(lon.range)) & (lon <= max(lon.range))) {
      
      dat <- read.xls(file.path(inputpath, as.character(year), files[i]), sheet = 'PM2.5', stringsAsFactors = F, skip = 8, na.strings = '-999.000')
      
      # Time 
      dat.tmp <- data.frame(year = substring(dat$Sampling.Date, 1, 4)) # year
      dat.tmp$date <- as.Date(dat$Sampling.Date, format = '%Y/%m/%d') # Date
      # DOY
      dat.tmp$doy <- yday(dat.tmp$date)
      # Site info
      dat.tmp$site.id <- site.id
      dat.tmp$lon <- lon
      dat.tmp$lat <- lat
      # PM2.5
      dat.tmp$pm25 <- dat$PM2.5
      # Unit
      dat.tmp$unit <- 'ug/m3'
      # aqs.code
      dat.tmp$aqs.code <- NA
      # Method
      dat.tmp$method <- 'DICHOT/PART25'
      
      ### DON'T CONSIDER SPEC
      # # Combining two PM2.5 observations
      # if (!is.null(dat$PM2.5.1)) {
      #   
      #   dat.tmp$pm251 <- dat$PM2.5.1
      #   
      #   idx <- is.na(dat.tmp$pm25)
      #   dat.tmp$pm25[idx] <- dat.tmp$pm251[idx]
      #   dat.tmp$method[idx] <- 'SPECIATION'
      #   
      #   dat.tmp$pm251 <- NULL
      #   
      # }
      
      # Removing NAs in PM2.5
      dat.tmp <- subset(dat.tmp, !is.na(dat.tmp$pm25))
      
      # Combine the data set
      dat.final <- rbind(dat.final, dat.tmp)
      
    }
  }
  
  # Ordering the data
  if (nrow(dat.final) > 1) {
    dat.final <- dat.final[order(dat.final$year, dat.final$doy), ]
  }
  
  return(dat.final)
  
}

## Loading EPA AQS PM2.5

epa.aqs <- function(year, inputpath) {
  
  ## ----- EPA AQS ----- #
  files <- dir(inputpath, pattern = paste('*_', as.character(year), '.csv', sep = ''))
  
  # Final data set
  dat.final <- data.frame()
  for (i in 1 : length(files)) {
    
    # Read AQS CSV
    dat <- read.csv(file.path(inputpath, files[i]), stringsAsFactors = F)
    # Remove the pixels outside the domain
    idx <- (dat$SITE_LATITUDE >= min(lat.range)) & (dat$SITE_LATITUDE <= max(lat.range)) & 
      (dat$SITE_LONGITUDE >= min(lon.range)) & (dat$SITE_LONGITUDE <= max(lon.range))
    dat <- dat[idx, ]
    # Creating a new data set
    # Time {---
    dat.tmp <- data.frame(year = substring(dat$Date, 7, 10)) # year
    dat.tmp$date <- as.Date(dat$Date, format = '%m/%d/%Y') # Date
    dat.tmp$doy <- yday(dat.tmp$date) # DOY
    # ---}
    dat.tmp$site.id <- dat$AQS_SITE_ID
    dat.tmp$lon <- dat$SITE_LONGITUDE
    dat.tmp$lat <- dat$SITE_LATITUDE
    dat.tmp$pm25 <- dat$Daily.Mean.PM2.5.Concentration
    dat.tmp$unit <- dat$UNITS
    dat.tmp$aqs.code <- dat$AQS_PARAMETER_CODE
    dat.tmp$method <- NA
    # Combining dat.tmp
    dat.final <- rbind(dat.final, dat.tmp)
    
  }
  
  # ----- Post-Processing ----- ##
  # Ordering the data
  dat.final <- dat.final[order(dat.final$year, dat.final$doy), ]
  
  return(dat.final)
}

