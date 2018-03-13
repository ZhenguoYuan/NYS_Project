#-------------------------------------
# Summary Statistic of Model Performance 
# of AOD Gap-filling
# 
# Jianzhao Bi
# 3/7/2018
#-------------------------------------

setwd('~/Google Drive/Projects/Codes/NYS_Project/RF/')

load('data/model_perform.RData')

# --- AAOT --- #
# OOB R2
mean(model.perform.aaot$rsq)
quantile(model.perform.aaot$rsq, 0.75)
quantile(model.perform.aaot$rsq, 0.25)

# MSE
mean(model.perform.aaot$mse)
quantile(model.perform.aaot$mse, 0.75)
quantile(model.perform.aaot$mse, 0.25)

# OOB R2
mean(model.perform.aaot$rsq[1 : 105])
quantile(model.perform.aaot$rsq[1 : 105], 0.75)
quantile(model.perform.aaot$rsq[1 : 105], 0.25)

# MSE
mean(model.perform.aaot$mse[1 : 105])
quantile(model.perform.aaot$mse[1 : 105], 0.75)
quantile(model.perform.aaot$mse[1 : 105], 0.25)

# Snow Cover
mean(model.perform.aaot$snow.im1$rank[1 : 105]) # Snow Cover Importance 1 for first 16 weeks
hist(model.perform.aaot$snow.im1$rank[1 : 105])
mean(model.perform.aaot$snow.im2$rank[1 : 105]) # Snow Cover Importance 2 for first 16 weeks
hist(model.perform.aaot$snow.im2$rank[1 : 105])

mean(model.perform.aaot$snow.im1$rank[106 : 365]) # Snow Cover Importance 1 for the rest weeks
hist(model.perform.aaot$snow.im1$rank[106 : 365])
mean(model.perform.aaot$snow.im2$rank[106 : 365]) # Snow Cover Importance 2 for the rest weeks
hist(model.perform.aaot$snow.im2$rank[106 : 365])

t.test(model.perform.aaot$snow.im1$rank[1 : 105], model.perform.aaot$snow.im1$rank[106 : 365]) # T-test for the rank before and after week 16
t.test(model.perform.aaot$snow.im2$rank[1 : 105], model.perform.aaot$snow.im2$rank[106 : 365])

# Cloud Cover
mean(model.perform.aaot$cloud.im1$rank[1 : 105]) # Cloud Cover Importance 1 for first 16 weeks
hist(model.perform.aaot$cloud.im1$rank[1 : 105])
mean(model.perform.aaot$cloud.im2$rank[1 : 105]) # Cloud Cover Importance 2 for first 16 weeks
hist(model.perform.aaot$cloud.im2$rank[1 : 105])

mean(model.perform.aaot$cloud.im1$rank[106 : 365]) # Cloud Cover Importance 1 for the rest weeks
hist(model.perform.aaot$cloud.im1$rank[106 : 365])
mean(model.perform.aaot$cloud.im2$rank[106 : 365]) # Cloud Cover Importance 2 for the rest weeks
hist(model.perform.aaot$cloud.im2$rank[106 : 365])

t.test(model.perform.aaot$cloud.im1$rank[1 : 105], model.perform.aaot$cloud.im1$rank[106 : 365]) # T-test for the rank before and after week 16
t.test(model.perform.aaot$cloud.im2$rank[1 : 105], model.perform.aaot$cloud.im2$rank[106 : 365])

# --- TAOT --- #
# OOB R2
mean(model.perform.taot$rsq)
quantile(model.perform.taot$rsq, 0.75)
quantile(model.perform.taot$rsq, 0.25)

# MSE
mean(model.perform.taot$mse)
quantile(model.perform.taot$mse, 0.75)
quantile(model.perform.taot$mse, 0.25)

# OOB R2
mean(model.perform.taot$rsq[1 : 105])
quantile(model.perform.taot$rsq[1 : 105], 0.75)
quantile(model.perform.taot$rsq[1 : 105], 0.25)

# MSE
mean(model.perform.taot$mse[1 : 105])
quantile(model.perform.taot$mse[1 : 105], 0.75)
quantile(model.perform.taot$mse[1 : 105], 0.25)

# Snow Cover
mean(model.perform.taot$snow.im1$rank[1 : 105]) # Snow Cover Importance 1 for first 16 weeks
hist(model.perform.taot$snow.im1$rank[1 : 105])
mean(model.perform.taot$snow.im2$rank[1 : 105]) # Snow Cover Importance 2 for first 16 weeks
hist(model.perform.taot$snow.im2$rank[1 : 105])

mean(model.perform.taot$snow.im1$rank[106 : 365]) # Snow Cover Importance 1 for the rest weeks
hist(model.perform.taot$snow.im1$rank[106 : 365])
mean(model.perform.taot$snow.im2$rank[106 : 365]) # Snow Cover Importance 2 for the rest weeks
hist(model.perform.taot$snow.im2$rank[106 : 365])

t.test(model.perform.taot$snow.im1$rank[1 : 105], model.perform.taot$snow.im1$rank[106 : 365]) # T-test for the rank before and after week 16
t.test(model.perform.taot$snow.im2$rank[1 : 105], model.perform.taot$snow.im2$rank[106 : 365])

# Cloud Cover
mean(model.perform.taot$cloud.im1$rank[1 : 105]) # Cloud Cover Importance 1 for first 16 weeks
hist(model.perform.taot$cloud.im1$rank[1 : 105])
mean(model.perform.taot$cloud.im2$rank[1 : 105]) # Cloud Cover Importance 2 for first 16 weeks
hist(model.perform.taot$cloud.im2$rank[1 : 105])

mean(model.perform.taot$cloud.im1$rank[106 : 365]) # Cloud Cover Importance 1 for the rest weeks
hist(model.perform.taot$cloud.im1$rank[106 : 365])
mean(model.perform.taot$cloud.im2$rank[106 : 365]) # Cloud Cover Importance 2 for the rest weeks
hist(model.perform.taot$cloud.im2$rank[106 : 365])

t.test(model.perform.taot$cloud.im1$rank[1 : 105], model.perform.taot$cloud.im1$rank[106 : 365]) # T-test for the rank before and after week 16
t.test(model.perform.taot$cloud.im2$rank[1 : 105], model.perform.taot$cloud.im2$rank[106 : 365])
