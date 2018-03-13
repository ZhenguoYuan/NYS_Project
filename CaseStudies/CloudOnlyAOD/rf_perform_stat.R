#-------------------------------------
# Summary Statistic of Model Performance 
# of AOD Gap-filling of Cloud Only
# 
# Jianzhao Bi
# 3/8/2018
#-------------------------------------

setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/CloudOnlyAOD/')

load('data/Model_Perform/model_perform.RData')

# --- AAOT --- #
# OOB R2
mean(model.perform.aaot$rsq[1 : 105])
quantile(model.perform.aaot$rsq[1 : 105], 0.75)
quantile(model.perform.aaot$rsq[1 : 105], 0.25)

# MSE
mean(model.perform.aaot$mse[1 : 105])
quantile(model.perform.aaot$mse[1 : 105], 0.75)
quantile(model.perform.aaot$mse[1 : 105], 0.25)

# Cloud Cover
mean(model.perform.aaot$cloud.im1$rank[1 : 105]) # Cloud Cover Importance 1 for first 16 weeks
hist(model.perform.aaot$cloud.im1$rank[1 : 105])
mean(model.perform.aaot$cloud.im2$rank[1 : 105]) # Cloud Cover Importance 2 for first 16 weeks
hist(model.perform.aaot$cloud.im2$rank[1 : 105])

mean(model.perform.aaot$cloud.im1$rank[106 : 365]) # Cloud Cover Importance 1 for first 16 weeks
hist(model.perform.aaot$cloud.im1$rank[106 : 365])
mean(model.perform.aaot$cloud.im2$rank[106 : 365]) # Cloud Cover Importance 2 for first 16 weeks
hist(model.perform.aaot$cloud.im2$rank[106 : 365])

t.test(model.perform.aaot$cloud.im1$rank[1 : 105], model.perform.aaot$cloud.im1$rank[106 : 365]) # T-test for the rank before and after week 16
t.test(model.perform.aaot$cloud.im2$rank[1 : 105], model.perform.aaot$cloud.im2$rank[106 : 365])

# --- TAOT --- #
# OOB R2
mean(model.perform.taot$rsq[1 : 105])
quantile(model.perform.taot$rsq[1 : 105], 0.75)
quantile(model.perform.taot$rsq[1 : 105], 0.25)

# MSE
mean(model.perform.taot$mse[1 : 105])
quantile(model.perform.taot$mse[1 : 105], 0.75)
quantile(model.perform.taot$mse[1 : 105], 0.25)

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
