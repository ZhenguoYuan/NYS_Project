#-------------------------
# MODIS Snow Functions
# Jianzhao Bi
# 10/26/2017
#-------------------------
# Functions used in MODIS Snow convertion

modis.snow <- function(inpath, outpath, new.loc, datset, doys) {
  
  # Creating Output Path
  if (!file.exists(outpath)) {
    dir.create(outpath, recursive = T)
  }
  
  ###---------- Daily Output Generation ----------###
  
  for (day_i in doys) {
    
    print(day_i)
    
    ## Step 1: Select csv files
    files <- dir(inpath, pattern = day_i)
    
    if (length(files) > 0) {
      
      ## Step 2: Idw -> MAIAC Grid
      dat.df <- list()
      
      for (i in 1 : length(files)) { ## For each hour
        
        print(files[i])
        
        ## Read one time's csv file
        dat.tmp <- read.csv(file.path(inpath, files[i]), stringsAsFactors = F, na.strings = "NaN")
        
        ## IDW
        
        # Do the idw interpolation
        idx.na <- is.na(dat.tmp$Snow_Cover) # Remove NAs
        if (sum(as.integer(!idx.na)) > 1) { # idw should receive at least 2 points
          dat.new.tmp <- idw.interp(dat.tmp$Lon[!idx.na], dat.tmp$Lat[!idx.na], dat.tmp$Snow_Cover[!idx.na],
                                       new.loc$Lon, new.loc$Lat, nmax = 7, maxdist = 0.5) # For Snow Cover  
        } else {
          dat.new.tmp <- data.frame(lon = new.loc$Lon, lat = new.loc$Lat, Snow_Cover = rep(NA, nrow(new.loc)))
        }
        
        # Change the name of the variable
        names(dat.new.tmp)[1] <- 'lon'
        names(dat.new.tmp)[2] <- 'lat'
        names(dat.new.tmp)[3] <- 'Snow_Cover'
        
        ## Save the idw results in a temporal list
        
        dat.df[[i]] <- dat.new.tmp$Snow_Cover
        
      }
      
      ## Step 3: average calculation for the temporal list
      
      dat.df <- as.data.frame(dat.df)
      
      dat.mean <- rowMeans(dat.df, na.rm = T)
      
      ## Step 4: Save the data
      dat.new <- data.frame(Lat = new.loc$Lat, Lon = new.loc$Lon, Snow_Cover = dat.mean)
      write.csv(x = dat.new, file = paste(outpath, day_i, '_', datset, '.csv', sep = ''), row.names = F)
      
      ## Step 5 Remove variables to save memory
      gc()
      
    } else {
      print(paste('No this day\'s data: ', day_i))
    }
  }
}
