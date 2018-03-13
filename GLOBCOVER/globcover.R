#----------------------------
# Processing Landuse Data
# Jianzhao Bi
# 11/12/2017
#----------------------------

setwd('/home/jbi6/NYS_Project/GLOBCOVER/')

## ---------- Func ---------- ##
# Getting the mode of the sequence
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

## ---------- RUN ---------- ##

inpath <- '/home/jbi6/terra/GLOBCOVER_ORI'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/GLOBCOVER'
if(!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

# Reading original landuse data
dat <- read.csv(file.path(inpath, 'grid_land.csv'), stringsAsFactors = F, as.is = T)

# # Creating interaction term for lat/lon (unique lat/lon grid)
# dat$UNI <- interaction(dat$Lat, dat$Lon)
# 
# # Creating final data set
# dat.final <- data.frame(lat = NULL, lon = NULL, gridcode = NULL)
# 
# # For each lat/lon grid
# for (i in levels(dat$UNI)){
#   print(i)
#   dat.tmp <- subset(dat, UNI == i)
#   gridcode <- getmode(dat.tmp$GRIDCODE)
#   dat.uni <- data.frame(lat = dat.tmp$Lat[1], lon = dat.tmp$Lon[1], gridcode = gridcode)
#   dat.final <- rbind(dat.final, dat.uni)
# }

# Aggregating data
dat.final <- aggregate(dat, by = list(dat$Lat, dat$Lon), FUN = getmode)
dat.final <- subset(dat.final, select = c(Lat, Lon, GRIDCODE))

# Outputing file
write.csv(file = file.path(outpath, 'globcover.csv'), x = dat.final, row.names = F)


