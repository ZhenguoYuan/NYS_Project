library(ggplot2)
setwd('~/Google Drive/Projects/Codes/NYS_Project/POP/')

source('../src/latlon.R')

dat <- read.csv(file = '~/Downloads/lspop2012.csv', stringsAsFactors = F, as.is = T)
sum(dat$pop)
dat2 <- read.csv(file = '~/Downloads/lspop2012_ori.csv', stringsAsFactors = F, as.is = T)
dat2 <- subset(dat2, lon >= min(lon.range) & lon <= max(lon.range) & lat >= min(lat.range) & lat <= max(lat.range))
sum(dat2$pop)



plot_new <- ggplot() + geom_tile(data = dat, aes(lon, lat, fill = pop, width = 0.014, height = 0.014), alpha = 1.0) + scale_fill_continuous(limits=c(0, 1000), oob = scales::squish)
plot_ori <- ggplot() + geom_tile(data = dat2, aes(lon, lat, fill = pop, width = 0.009, height = 0.009), alpha = 1.0) + scale_fill_continuous(limits=c(0, 1000), oob = scales::squish)
#ggplot() + geom_point(data = dat, aes(lon, lat), colour = "red", alpha = 0.7) + geom_point(data = dat2, aes(lon, lat), colour = "green", alpha = 0.7)
