setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/SummaryStat/Missing_AOD/')

library(ggplot2)
library(maptools)

source('~/Google Drive/Projects/Codes/NYS_Project/Validations/PLOT2D/src/plot_fun.R')

dat <- read.csv(file = 'data/missing/MAIACAAOT.h04v03.20152451655.csv', stringsAsFactors = F)
dat.copy <- dat

# Remove cloud missing
missing.cloud.tag <- is.na(dat.copy$AOT_055) & (dat.copy$QA_cloudmask == "'011" | dat.copy$QA_cloudmask == "'010" |  # Cloud Mask
                                                  dat.copy$QA_cloudmask == "'101" | dat.copy$QA_cloudmask == "'110" | 
                                               dat.copy$QA_cloudmask == "'111" | dat.copy$QA_adjmask == "'001" |
                                               dat.copy$QA_adjmask == "'010" | dat.copy$QA_adjmask == "'011" |
                                                 dat.copy$QA_aotqualityflag == "'1")

# Remove snow missing
missing.snow.tag <- is.na(dat.copy$AOT_055) & (dat.copy$QA_landmask == "'10" | dat.copy$QA_adjmask == "'100" | dat.copy$QA_adjmask == "'101") # Snow Mask

# Remove non-missing data
nonmissing.tag <- !is.na(dat.copy$AOT_055)

# Combine tags
tag <- missing.cloud.tag | missing.snow.tag | nonmissing.tag

dat.new <- dat.copy[!tag, ]

# Test the levels of QA flags for these missing data
dat.new2 <- dat.new
dat.new2$AOT_QA <- as.factor(dat.new2$AOT_QA)
levels(dat.new2$AOT_QA)
dat.new2$QA_cloudmask <- as.factor(dat.new2$QA_cloudmask)
levels(dat.new2$QA_cloudmask)
dat.new2$QA_landmask <- as.factor(dat.new2$QA_landmask)
levels(dat.new2$QA_landmask)
dat.new2$QA_adjmask <- as.factor(dat.new2$QA_adjmask)
levels(dat.new2$QA_adjmask)
dat.new2$QA_cloudtest <- as.factor(dat.new2$QA_cloudtest)
levels(dat.new2$QA_cloudtest)
dat.new2$QA_glintmask <- as.factor(dat.new2$QA_glintmask)
levels(dat.new2$QA_glintmask)
dat.new2$QA_aerosolmodel <- as.factor(dat.new2$QA_aerosolmodel)
levels(dat.new2$QA_aerosolmodel)
dat.new2$QA_aotqualityflag <- as.factor(dat.new2$QA_aotqualityflag)
levels(dat.new2$QA_aotqualityflag)

# If you see cloud mask gives “000 --- missing data”, 
# that means these pixels located in the area outside the sensor scan. 
# Since MAIAC data is gridded, those areas will be filled with fillvalue.

# ----- Plot ----- #

myshp <- readShapePoly('~/Google Drive/Projects/Codes/Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

plotna <- plot2d(data = dat.new, fill = dat.new$AOT_055, colorbar = jet.colors, colorbar_limits = c(), shp = myshp, legend_name = 'legend', title = 'title')
