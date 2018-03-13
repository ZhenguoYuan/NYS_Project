setwd('~/Google Drive/MAIAC Project/Codes/NYS_Project/RF/')

load('testdata/244_10000_TEST_RF.RData')
dat10000 <- dat.pred.test

load('testdata/244_30000_TEST_RF.RData')
dat30000 <- dat.pred.test

load('testdata/244_50000_TEST_RF.RData')
dat50000 <- dat.pred.test

load('testdata/244_100000_TEST_RF.RData')
dat100000 <- dat.pred.test

load('testdata/244_840000_TEST_RF.RData')
dat840000 <- dat.pred.test

# 10000 vs 840000
cor(dat10000$AOD550_TAOT, dat840000$AOD550_TAOT, use = "complete.obs")
#plot(dat10000$AOD550_TAOT, dat840000$AOD550_TAOT)
print(paste('RMSE:', sqrt(mean((dat10000$AOD550_TAOT - dat840000$AOD550_TAOT)^2, na.rm = T))))
summary(lm(dat840000$AOD550_TAOT ~ dat10000$AOD550_TAOT))

# 30000 vs 840000
cor(dat30000$AOD550_TAOT, dat840000$AOD550_TAOT, use = "complete.obs")
#plot(dat30000$AOD550_TAOT, dat840000$AOD550_TAOT)
print(paste('RMSE:', sqrt(mean((dat30000$AOD550_TAOT - dat840000$AOD550_TAOT)^2, na.rm = T))))
summary(lm(dat840000$AOD550_TAOT ~ dat30000$AOD550_TAOT))

# 50000 vs 840000
cor(dat50000$AOD550_TAOT, dat840000$AOD550_TAOT, use = "complete.obs")
#plot(dat50000$AOD550_TAOT, dat840000$AOD550_TAOT)
print(paste('RMSE:', sqrt(mean((dat50000$AOD550_TAOT - dat840000$AOD550_TAOT)^2, na.rm = T))))
summary(lm(dat840000$AOD550_TAOT ~ dat50000$AOD550_TAOT))

# 100000 vs 840000
cor(dat100000$AOD550_TAOT, dat840000$AOD550_TAOT, use = "complete.obs")
#plot(dat100000$AOD550_TAOT, dat840000$AOD550_TAOT)
print(paste('RMSE:', sqrt(mean((dat100000$AOD550_TAOT - dat840000$AOD550_TAOT)^2, na.rm = T))))
summary(lm(dat840000$AOD550_TAOT ~ dat100000$AOD550_TAOT))

