#-------------------------
# MAIAC AOD Functions
# Jianzhao Bi
# 9/23/2017
#-------------------------
# Functions used in MAIAC AOD Matching

# ## Getting file names and doys of the data set
# doy.get <- function(inpath) {
#   
#   # Load AOD files
#   files <- dir(inpath, pattern = '*.csv')
#   
#   # Extract the date information
#   date <- lapply(files, FUN = substr, 18, 24)
#   date <- as.factor(as.character(date))
#   
#   # Get the DOYs
#   doys <- levels(date)
#   
#   out.lst <- list(files = files, doys = doys)
#   
#   return(out.lst)
#   
# }

## Output daily MAIAC AOD data
aod.daily <- function(inpath, aod.daily.files, new.loc.path) {
  
  ### ----- Step 1: Read MAIAC Grid ----- ###
  new.loc <- read.csv(new.loc.path, stringsAsFactors = F)
  
  ### ----- Step 2: IDW -> MAIAC Grid ----- ###
  
  # Temporary lists
  AOD470.df <- list()
  AOD550.df <- list()
  
  for (i in 1 : length(aod.daily.files)) {
    
    print(aod.daily.files[i])
    
    # Read csv file
    dat <- read.csv(file = file.path(inpath, aod.daily.files[i]), stringsAsFactors = F, na.strings = 'NaN')
    
    # Round the lat/lon to 3 digits
    dat$Latitude <- round(dat$Latitude, 3)
    dat$Longitude <- round(dat$Longitude, 3)
    
    # IDW for AOD 470nm
    idx.na1 <- is.na(dat$AOT_047) # Check NAs
    if (sum(as.integer(!idx.na1)) > 1) { # idw should receive at least 2 points
      dat.new.470 <- idw.interp(dat$Longitude[!idx.na1], dat$Latitude[!idx.na1], dat$AOT_047[!idx.na1], 
                                new.loc$Lon, new.loc$Lat, nmax = 1, maxdist = 0.005)
    } else {
      dat.new.470 <- data.frame(Lon = new.loc$Lon, Lat = new.loc$Lat, AOD470 = rep(NA, nrow(new.loc)))
    }
    
    names(dat.new.470)[1] <- 'Lon'
    names(dat.new.470)[2] <- 'Lat'
    names(dat.new.470)[3] <- 'AOD470'
    
    # IDW for AOD 550nm
    idx.na2 <- is.na(dat$AOT_055) # Check NAs
    if (sum(as.integer(!idx.na2)) > 1) { # idw should receive at least 2 points
      dat.new.550 <- idw.interp(dat$Longitude[!idx.na2], dat$Latitude[!idx.na2], dat$AOT_055[!idx.na2], 
                                new.loc$Lon, new.loc$Lat, nmax = 1, maxdist = 0.005)
    } else {
      dat.new.550 <- data.frame(Lon = new.loc$Lon, Lat = new.loc$Lat, AOD550 = rep(NA, nrow(new.loc)))
    }
    
    names(dat.new.550)[1] <- 'Lon'
    names(dat.new.550)[2] <- 'Lat'
    names(dat.new.550)[3] <- 'AOD550'
    
    # Save the idw results in a temporal list
    AOD470.df[[i]] <- dat.new.470$AOD470
    AOD550.df[[i]] <- dat.new.550$AOD550
    
  }
  
  ### ----- Step 3: Average calculation for the temporal list ----- ###
  
  AOD470.df <- as.data.frame(AOD470.df)
  AOD550.df <- as.data.frame(AOD550.df)
  
  AOD470.mean <- rowMeans(AOD470.df, na.rm = T)
  AOD550.mean <- rowMeans(AOD550.df, na.rm = T)
  
  ### ----- Step 4: Save the data ----- ###
  dat.new <- data.frame(Lat = new.loc$Lat, Lon = new.loc$Lon, AOD470 = AOD470.mean, AOD550 = AOD550.mean)
  
  return(dat.new)
  
}

## Produce daily data and combine h04v03 and h04v04
aod.combine <- function(di, inpath03, inpath04, outpath, new.loc.path, type) {
  
  ### ----- Find each days files for h04v03 ----- ###
  aod03.daily.files <- dir(inpath03, pattern = paste('.', di, sep = ''))
  if (length(aod03.daily.files) != 0) {
    aod03.out <- aod.daily(inpath03, aod03.daily.files, new.loc.path)
  } else {
    aod03.out <- read.csv(new.loc.path, stringsAsFactors = F)
    aod03.out$AOD470 <- rep(NA, nrow(aod03.out))
    aod03.out$AOD550 <- rep(NA, nrow(aod03.out))
    aod03.out$ID <- NULL
  }
  
  ### ----- Find each days files for h04v04 ----- ###
  aod04.daily.files <- dir(inpath04, pattern = paste('.', di, sep = ''))
  if (length(aod04.daily.files) != 0) {
    aod04.out <- aod.daily(inpath04, aod04.daily.files, new.loc.path)
  } else {
    aod04.out <- read.csv(new.loc.path, stringsAsFactors = F)
    aod04.out$AOD470 <- rep(NA, nrow(aod04.out))
    aod04.out$AOD550 <- rep(NA, nrow(aod04.out))
    aod04.out$ID <- NULL
  }
  
  ### ----- Combine h04v03 and h04v04 ----- ###
  library(abind)
  aod.out.tmp <- abind(aod03.out, aod04.out, along = 3)
  aod.out <- as.data.frame(rowMeans(aod.out.tmp, dims = 2, na.rm = T))
  
  ### ----- Output AOD files ----- ###
  if (!file.exists(outpath)) { # Creating Output Path
    dir.create(outpath, recursive = T)
  }
  filename <- paste(di, '_', type, '.csv', sep = '')
  write.csv(x = aod.out, file = paste(outpath, filename, sep = ''), row.names = F)
  
}