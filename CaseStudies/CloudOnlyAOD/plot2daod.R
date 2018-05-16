library(ggplot2)
library(ggmap)
library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)

setwd('~/Google Drive/Projects/Codes/NYS_Project/CaseStudies/CloudOnlyAOD/')
source('../../src/fun.R')
source('../../Validations/PLOT2D/src/plot_fun.R')
source('../../Validations/SummaryStat/Missing_AOD/src/fun.R')

# Read shp
shp.name <- '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp'
myshp <- readShapePoly(shp.name)
myshp <- subset(myshp, NAME == 'New York') # Select NYS shp
myshp <- fortify(myshp)

# colorbar
# define jet colormap
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
diff.colors <- colorRampPalette(c('blue', 'white', 'red'))

## ---------- PLOT AOD ---------- ##
## AAOT Cloud Only
# Load data
load('data/PLOT2D/PLOTAOD/aaot550_combine_cloudonly.RData')
# Cut by NYS shp
aaot550.combine.cldonly <- cutByShp(shp.name = shp.name, dat = aaot550.combine.cldonly)
# Plot 2D
gg.aaot.cldonly <- plot2d(data = aaot550.combine.cldonly, fill = aaot550.combine.cldonly$AAOT550_Mean, 
                      colorbar = jet.colors, colorbar_limits = c(0.2, 0.28), 
                      shp = myshp, legend_name = 'AOD', title = '2015 001-112 AQUA AOD (Cloud Only)',
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

## AAOT Cloud Snow
# Load data
load('data/PLOT2D/PLOTAOD/aaot550_combine_cloudsnow.RData')
# Cut by NYS shp
aaot550.combine.cldsnw <- cutByShp(shp.name = shp.name, dat = aaot550.combine.cldsnw)
# Plot 2D
gg.aaot.cldsnw <- plot2d(data = aaot550.combine.cldsnw, fill = aaot550.combine.cldsnw$AAOT550_Mean, 
                  colorbar = jet.colors, colorbar_limits = c(0.2, 0.28), 
                  shp = myshp, legend_name = 'AOD', title = '2015 001-112 AQUA AOD (Cloud & Snow)',
                  xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

## TAOT Cloud Only
# Load data
load('data/PLOT2D/PLOTAOD/taot550_combine_cloudonly.RData')
# Cut by NYS shp
taot550.combine.cldonly <- cutByShp(shp.name = shp.name, dat = taot550.combine.cldonly)
# Plot 2D
gg.taot.cldonly <- plot2d(data = taot550.combine.cldonly, fill = taot550.combine.cldonly$TAOT550_Mean, 
                          colorbar = jet.colors, colorbar_limits = c(0.2, 0.25), 
                          shp = myshp, legend_name = 'AOD', title = '2015 001-112 TERRA AOD (Cloud Only)',
                          xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

## TAOT Cloud Snow
# Load data
load('data/PLOT2D/PLOTAOD/taot550_combine_cloudsnow.RData')
# Cut by NYS shp
taot550.combine.cldsnw <- cutByShp(shp.name = shp.name, dat = taot550.combine.cldsnw)
# Plot 2D
gg.taot.cldsnw <- plot2d(data = taot550.combine.cldsnw, fill = taot550.combine.cldsnw$TAOT550_Mean, 
                         colorbar = jet.colors, colorbar_limits = c(0.2, 0.25), 
                         shp = myshp, legend_name = 'AOD', title = '2015 001-112 TERRA AOD (Cloud & Snow)',
                         xlim = c(-80, -71.6), ylim = c(40.5, 45.25))



## ---------- PLOT DIFF AOD ---------- ##

## Difference (Gap - Ori) AAOT
df.aaot.diff <- data.frame(Lat = aaot550.combine.cldonly$Lat, Lon = aaot550.combine.cldonly$Lon, Diff = aaot550.combine.cldsnw$AAOT550_Mean - aaot550.combine.cldonly$AAOT550_Mean)
gg.aaot.diff <- plot2d(data = df.aaot.diff, fill = df.aaot.diff$Diff, 
                      colorbar = diff.colors, colorbar_limits = c(-0.01, 0.01), 
                      shp = myshp, legend_name = 'AOD', title = '2015 001-112 AQUA AOD (CldSnw - CldOnly)',
                      xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

## Difference (Gap - Ori) TAOT
df.taot.diff <- data.frame(Lat = taot550.combine.cldonly$Lat, Lon = taot550.combine.cldonly$Lon, Diff = taot550.combine.cldsnw$TAOT550_Mean - taot550.combine.cldonly$TAOT550_Mean)
gg.taot.diff <- plot2d(data = df.taot.diff, fill = df.taot.diff$Diff, 
                       colorbar = diff.colors, colorbar_limits = c(-0.03, 0.03), 
                       shp = myshp, legend_name = 'AOD', title = '2015 001-112 TERRA AOD (CldSnw - CldOnly)',
                       xlim = c(-80, -71.6), ylim = c(40.5, 45.25))

## Difference (CldSnw - CldOnly) AAOT
mean(abs(aaot550.combine.cldsnw$AAOT550_Mean - aaot550.combine.cldonly$AAOT550_Mean), na.rm = T)
quantile(abs(aaot550.combine.cldsnw$AAOT550_Mean - aaot550.combine.cldonly$AAOT550_Mean), 0.25, na.rm = T)
quantile(abs(aaot550.combine.cldsnw$AAOT550_Mean - aaot550.combine.cldonly$AAOT550_Mean), 0.75, na.rm = T)
max(abs(aaot550.combine.cldsnw$AAOT550_Mean - aaot550.combine.cldonly$AAOT550_Mean))
mean(abs(aaot550.combine.cldsnw$AAOT550_Mean))

## Difference (CldSnw - CldOnly) TAOT
mean(abs(taot550.combine.cldsnw$TAOT550_Mean - taot550.combine.cldonly$TAOT550_Mean), na.rm = T)
quantile(abs(taot550.combine.cldsnw$TAOT550_Mean - taot550.combine.cldonly$TAOT550_Mean), 0.25, na.rm = T)
quantile(abs(taot550.combine.cldsnw$TAOT550_Mean - taot550.combine.cldonly$TAOT550_Mean), 0.75, na.rm = T)
max(abs(taot550.combine.cldsnw$TAOT550_Mean - taot550.combine.cldonly$TAOT550_Mean))
mean(abs(taot550.combine.cldsnw$TAOT550_Mean))

## ---------- Summary Stats & T-Test ---------- ##
mean(aaot550.combine.cldonly$AAOT550_Mean, na.rm = T)
quantile(aaot550.combine.cldonly$AAOT550_Mean, 0.25, na.rm = T)
quantile(aaot550.combine.cldonly$AAOT550_Mean, 0.75, na.rm = T)

mean(aaot550.combine.cldsnw$AAOT550_Mean)
quantile(aaot550.combine.cldsnw$AAOT550_Mean, 0.25)
quantile(aaot550.combine.cldsnw$AAOT550_Mean, 0.75)

mean(taot550.combine.cldonly$TAOT550_Mean, na.rm = T)
quantile(taot550.combine.cldonly$TAOT550_Mean, 0.25, na.rm = T)
quantile(taot550.combine.cldonly$TAOT550_Mean, 0.75, na.rm = T)

mean(taot550.combine.cldsnw$TAOT550_Mean)
quantile(taot550.combine.cldsnw$TAOT550_Mean, 0.25)
quantile(taot550.combine.cldsnw$TAOT550_Mean, 0.75)

hist(aaot550.combine.cldonly$AAOT550_Mean)
hist(aaot550.combine.cldsnw$AAOT550_Mean)
hist(taot550.combine.cldonly$TAOT550_Mean)
hist(taot550.combine.cldsnw$TAOT550_Mean)

# Paired T Test
t.test(aaot550.combine.cldonly$AAOT550_Mean, aaot550.combine.cldsnw$AAOT550_Mean, paired = T)
t.test(taot550.combine.cldonly$TAOT550_Mean, taot550.combine.cldsnw$TAOT550_Mean, paired = T)

## ---------- Scatters ---------- ##
# AAOT
df.aaot.point <- data.frame(CldOnly = aaot550.combine.cldonly$AAOT550_Mean, CldSnw = aaot550.combine.cldsnw$AAOT550_Mean)
gg.aaot.point <- ggplot(data = df.aaot.point, aes(x = CldOnly, y = CldSnw)) + geom_point(alpha = .05) + 
  geom_smooth(method = 'lm') + 
  coord_fixed(xlim = c(0, 1), ylim = c(0, 1), ratio = 1)
fit.aaot.point <- lm(formula = CldSnw ~ CldOnly, data = df.aaot.point)
summary(fit.aaot.point)

# TAOT
df.taot.point <- data.frame(CldOnly = taot550.combine.cldonly$TAOT550_Mean, CldSnw = taot550.combine.cldsnw$TAOT550_Mean)
gg.taot.point <- ggplot(data = df.taot.point, aes(x = CldOnly, y = CldSnw)) + geom_point(alpha = .05) + 
  geom_smooth(method = 'lm') + 
  coord_fixed(xlim = c(0, 1), ylim = c(0, 1), ratio = 1)
fit.taot.point <- lm(formula = CldSnw ~ CldOnly, data = df.taot.point)
summary(fit.taot.point)
