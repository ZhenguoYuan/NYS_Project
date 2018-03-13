library(ggplot2)

dat <- read.csv(file = '~/Downloads/lspop2002.csv', stringsAsFactors = F, as.is = T)
sum(dat$pop)

dat.sub <- dat[dat$lon >= -80.5 & dat$lon <= -71 & dat$lat >= 40.1 & dat$lat <= 45.6, ]

ggplot() + geom_tile(data = dat, aes(lon, lat, fill = pop, width = 0.047, height = 0.047), alpha = 1.0) + scale_fill_continuous(limits=c(0, 10000))
