setwd('~/Downloads/')

source('~/Google Drive/Projects/Codes/NYS_Project/src/fun.R')

xy <- xy.latlon(rf.result$Lat, rf.result$Lon)

dat <- cbind(rf.result, xy)
idx <- sample(1 : nrow(dat), 0.1*nrow(dat))
idx <- sample(1 : nrow(dat), 0*nrow(dat))
dat.red <- dat[idx, ]

x.tmp <- dat$X_Lon[100]
y.tmp <- dat$Y_Lat[100]
buffer <- 100

start.time <- Sys.time()
for (i in 1 : 470000) {
  dat.tmp <- subset(dat.red, sqrt((X_Lon - x.tmp)^2 + (Y_Lat - y.tmp)^2) <= buffer)
  DailyMean.tmp <- mean(dat.tmp$AAOT550_New, na.rm = T)
}
print(Sys.time() - start.time)



