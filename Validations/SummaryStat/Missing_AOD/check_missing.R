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

# ----- Plot ----- #

myshp <- readShapePoly('~/Google Drive/Projects/Codes/Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

plotna <- plot2d(data = dat.new, fill = dat.new$AOT_055, colorbar = jet.colors, colorbar_limits = c(), shp = myshp, legend_name = 'legend', title = 'title')
