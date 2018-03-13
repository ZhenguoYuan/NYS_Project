setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/SnowMax/')

source('../../src/fun.R')
source('../../Validations/PLOT2D/src/plot_fun.R')

myshp <- readShapePoly('../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp')
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

# ----- Determine the max snow/cloud day ----- #
load('../../RF/data/model_perform.RData')
model.perform.aaot.cldsnw <- model.perform.aaot
load('../../CaseStudies/CloudOnlyAOD/data/Model_Perform/model_perform.RData')
model.perform.aaot.cldonly <- model.perform.aaot
rsq <- data.frame(rsq.cldsnw = model.perform.aaot.cldsnw$rsq, rsq.cldonly = model.perform.aaot.cldonly$rsq)
rsq$diff <- rsq$rsq.cldsnw - rsq$rsq.cldonly

idx <- which(rsq$diff == max(rsq$diff))
rsq$rsq.cldsnw[idx]
rsq$rsq.cldonly[idx]
rsq$diff[idx]

# ----- Daily missing causations ----- #
load('../../Validations/SummaryStat/Missing_AOD/data/2015_AAOT_Temporal.RData')
rates.aaot$cloud[idx]
rates.aaot$snow[idx]

# ----- Load the data of max snow/cloud day ----- #

load('data/2015039_RF_CldSnw.RData')
dat.cldsnw <- rf.result
dat.cldsnw <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', dat = dat.cldsnw)
load('data/2015039_RF_CldOnly.RData')
dat.cldonly <- rf.result
dat.cldonly <- cutByShp(shp.name = '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp', dat = dat.cldonly)

plot.cldsnw <- plot2d(data = dat.cldsnw, fill = dat.cldsnw$AAOT550_New, colorbar = jet.colors, 
                      colorbar_limits = c(0, 0.5), shp = myshp, legend_name = 'AOD', title = 'Cloud + Snow')

plot.cldonly <- plot2d(data = dat.cldonly, fill = dat.cldonly$AAOT550_New, colorbar = jet.colors, 
                      colorbar_limits = c(0, 0.5), shp = myshp, legend_name = 'AOD', title = 'Cloud Only')

dat.diff.aot <- data.frame(aot.cldsnw = dat.cldsnw$AAOT550_New, aot.cldonly = dat.cldonly$AAOT550_New)
dat.diff.aot$diff <- dat.diff.aot$aot.cldsnw - dat.diff.aot$aot.cldonly
max(dat.diff.aot$diff, na.rm = T) / mean(dat.diff.aot$aot.cldsnw, na.rm = T) * 100

# ----- Model Performance ----- #

load('data/2015039_RF_MODELPERF_CldOnly.RData')
model.perform.cldonly <- model.perform
load('data/2015039_RF_MODELPERF_CldSnw.RData')
model.perform.cldsnw <- model.perform

rsq.cldonly <- model.perform.cldonly$rsq
rsq.cldsnw <- model.perform.cldsnw$rsq

mse.cldonly <- model.perform.cldonly$mse
mse.cldsnw <- model.perform.cldsnw$mse

model.perform.cldonly$importance1
model.perform.cldsnw$importance1

# ----- Draw the snow & cloud distribution at that day ----- #

# Cloud Cover
dat.cldcover <- read.csv(file = 'data/2015039_MYD06_L2.csv')
plot.cldcover <- plot2d(data = dat.cldcover, fill = dat.cldcover$Cloud_Frac_Day, colorbar = jet.colors,
                        colorbar_limits = c(0, 1), shp = myshp, legend_name = 'Cloud Fraction', title = 'Cloud Fraction')
# Snow Cover
dat.snwcover <- read.csv(file = 'data/2015039_MYD10C1.csv')
plot.snwcover <- plot2d(data = dat.snwcover, fill = dat.snwcover$Snow_Cover, colorbar = jet.colors,
                        colorbar_limits = c(0, 100), shp = myshp, legend_name = 'Snow Fraction', title = 'Snow Fraction')
