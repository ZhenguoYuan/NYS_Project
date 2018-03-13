#---------------------
# AERONET
# Jianzhao Bi
# 10/22/2017
#---------------------
# Generating files of AERONET observations


setwd('/Users/bjz91/Google Drive/MAIAC Project/Codes/NYS_Project/AERONET/')

source('../src/fun.R') # Load interp functions
source('src/fun.R')

# File Path
files <- dir('input/data/', pattern = '*.lev*')

# Site Information
site <- read.csv(file = 'input/site_info.csv', as.is = T, stringsAsFactors = F)

## For each station
dat.final <- data.frame()
for (i in 1 : length(files)) {
  
  # Read file
  dat <- read.csv(file = file.path('input/data', files[i]), as.is = T, stringsAsFactors = F, skip = 4, na.strings = 'N/A')
  
  # Parameters 
  dat.new <- data.frame(year = substring(dat$Date.dd.mm.yy., 7, 10))
  dat.new$doy <- dat$Julian_Day
  dat.new$lon <- rep(site$lon[i], nrow(dat.new))
  dat.new$lat <- rep(site$lat[i], nrow(dat.new))
  dat.new$name <- rep(site$name[i], nrow(dat.new))
  dat.new$AOT470 <- angstrom(470, site$band.1.470[i], unlist(with(dat, mget(paste('AOT_', site$band.1.470[i], sep = '')))), 
                             site$band.1.470[i], unlist(with(dat, mget(paste('AOT_', site$band.1.470[i], sep = '')))), 
                             site$band.2.470[i], unlist(with(dat, mget(paste('AOT_', site$band.2.470[i], sep = ''))))) # Angstrom
  dat.new$AOT550 <- angstrom(550, site$band.1.550[i], unlist(with(dat, mget(paste('AOT_', site$band.1.550[i], sep = '')))), 
                             site$band.1.550[i], unlist(with(dat, mget(paste('AOT_', site$band.1.550[i], sep = '')))), 
                             site$band.2.550[i], unlist(with(dat, mget(paste('AOT_', site$band.2.550[i], sep = ''))))) # Angstrom
  
  # Concatenating the df
  dat.final <- rbind(dat.final, dat.new)

}

# Ordering the data
dat.final <- subset(dat.final, !is.na(dat.final$AOT470) | !is.na(dat.final$AOT550))
dat.final <- dat.final[order(dat.final$year, dat.final$doy), ]

# Output
write.csv(x = dat.final, file = 'output/AERONET_NYS.csv', row.names = F)





