#-------------------------
# MODIS Cloud Functions
# Jianzhao Bi
# 9/23/2017
#-------------------------
# Functions used in MODIS Cloud convertion

modis.cloud <- function(inpath, outpath, new.loc, datset, doys) {
  
  # Creating Output Path
  if (!file.exists(outpath)) {
    dir.create(outpath, recursive = T)
  }
  
  ###---------- Daily Output Generation ----------###
  
  for (day_i in doys) {
    
    print(day_i)
    
    ## Step 1: Select csv files
    file.modis.d <- dir(inpath, pattern = day_i)
    
    if (length(file.modis.d) > 0) {
      
      ## Step 2: Idw -> MAIAC Grid
      cf.df <- list()
      cfd.df <- list()
      
      for (i in 1 : length(file.modis.d)) { ## For each hour
        
        print(file.modis.d[i])
        
        ## Read one time's csv file
        dat.tmp <- read.csv(file.path(inpath, file.modis.d[i]), stringsAsFactors = F, na.strings = "NaN")
        
        ## IDW
        
        # Do the idw interpolation
        idx.na1 <- is.na(dat.tmp$Cloud_Frac) | dat.tmp$Lon == -999 | dat.tmp$Lat == -999 # Remove NAs
        if (sum(as.integer(!idx.na1)) > 1) { # idw should receive at least 2 points
          dat.new.tmp.cf <- idw.interp(dat.tmp$Lon[!idx.na1], dat.tmp$Lat[!idx.na1], dat.tmp$Cloud_Frac[!idx.na1],
                                       new.loc$Lon, new.loc$Lat, nmax = 7, maxdist = 0.2) # For Cloud Fraction  
        } else {
          dat.new.tmp.cf <- data.frame(lon = new.loc$Lon, lat = new.loc$Lat, Cloud_Frac = rep(NA, nrow(new.loc)))
        }
        idx.na2 <- is.na(dat.tmp$Cloud_Frac_Day) | dat.tmp$Lon == -999 | dat.tmp$Lat == -999 # Remove NAs
        if (sum(as.integer(!idx.na2)) > 1) { # idw should receive at least 2 points
          dat.new.tmp.cfd <- idw.interp(dat.tmp$Lon[!idx.na2], dat.tmp$Lat[!idx.na2], dat.tmp$Cloud_Frac_Day[!idx.na2],
                                        new.loc$Lon, new.loc$Lat, nmax = 7, maxdist = 0.2) # For Cloud Fraction Day  
        } else {
          dat.new.tmp.cfd <- data.frame(lon = new.loc$Lon, lat = new.loc$Lat, Cloud_Frac_Day = rep(NA, nrow(new.loc)))
        }
        
        # Change the name of the variable
        names(dat.new.tmp.cf)[1] <- 'lon'
        names(dat.new.tmp.cf)[2] <- 'lat'
        names(dat.new.tmp.cf)[3] <- 'Cloud_Frac'
        names(dat.new.tmp.cfd)[1] <- 'lon'
        names(dat.new.tmp.cfd)[2] <- 'lat'
        names(dat.new.tmp.cfd)[3] <- 'Cloud_Frac_Day'
        
        ## Save the idw results in a temporal list
        
        cf.df[[i]] <- dat.new.tmp.cf$Cloud_Frac
        cfd.df[[i]] <- dat.new.tmp.cfd$Cloud_Frac_Day
        
      }
      
      ## Step 3: average calculation for the temporal list
      
      cf.df <- as.data.frame(cf.df)
      cfd.df <- as.data.frame(cfd.df)
      
      cf.mean <- rowMeans(cf.df, na.rm = T)
      cfd.mean <- rowMeans(cfd.df, na.rm = T)
      
      ## Step 4: Save the data
      dat.new <- data.frame(Lat = new.loc$Lat, Lon = new.loc$Lon, Cloud_Frac = cf.mean, Cloud_Frac_Day = cfd.mean)
      write.csv(x = dat.new, file = paste(outpath, day_i, '_', datset, '.csv', sep = ''), row.names = F)
      
      ## Step 5 Remove variables to save memory
      gc()
      
    } else {
      print(paste('No this day\'s data: ', day_i))
    }
  }
}

