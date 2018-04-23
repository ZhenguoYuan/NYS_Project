#----------------------------------------------------------------------
# Author: Jianzhao Bi
#
# Description: Plotting AOD distribution; Conducting statistical analysis
# Notice: the size of saved image is 535 * 502
#
# Apr 6, 2018
#----------------------------------------------------------------------

library(ggplot2)
library(ggmap)
library(viridis)
library(RColorBrewer)
library(maptools)
library(directlabels)

setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/PLOT2D/')
source('../../src/fun.R')
source('src/plot_fun.R')
source('../SummaryStat/Missing_AOD/src/fun.R')

xlim <- c(-79.8, -72)
ylim <- c(40.5, 45)

# Read shp
shp.name <- '../../../Public/shp/cb_2016_us_state_20m/cb_2016_us_state_20m.shp'
myshp <- readShapePoly(shp.name)
myshp <- subset(myshp, NAME == 'New York') # Select NYS shp
myshp <- fortify(myshp)

# colorbar
# define jet colormap
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
rainbow.colors <- colorRampPalette(c('#0000ff', '#0054ff', '#00abff', '#00ffff', '#54ffab', '#abff53', '#ffff00', '#ffaa00', '#ff5400', '#ff0000'))
diff.colors <- colorRampPalette(c('#7f7fff', 'white', '#EF4566'))

## ---------- PLOT AOD ---------- ##
## AAOT Overall
# Load data
load('data/PLOTAOD/aaot550_combine.RData')
# Cut by NYS shp
aaot550.combine <- cutByShp(shp.name = shp.name, dat = aaot550.combine)
# Plot 2D
gg.aaot <- plot2d(data = aaot550.combine, fill = aaot550.combine$AAOT550_Mean, 
                      colorbar = rainbow.colors, colorbar_limits = c(0.20, 0.27), 
                      shp = myshp, legend_name = 'AOD', title = '(a) Aqua Overall AOD',
                      xlim = xlim, ylim = ylim)

## AAOT Original
# Load data
load('data/PLOTAOD/aaot550_combine_ori.RData')
# Cut by NYS shp
aaot550.combine.ori <- cutByShp(shp.name = shp.name, dat = aaot550.combine.ori)
# Plot 2D
gg.aaot.ori <- plot2d(data = aaot550.combine.ori, fill = aaot550.combine.ori$AAOT550_Mean, 
                colorbar = jet.colors, colorbar_limits = c(0.0, 0.3), 
                shp = myshp, legend_name = 'AOD', title = '2015 Aqua Original AOD',
                xlim = xlim, ylim = ylim)

## AAOT Gapfill
# Load data
load('data/PLOTAOD/aaot550_combine_gap.RData')
# Cut by NYS shp
aaot550.combine.gap <- cutByShp(shp.name = shp.name, dat = aaot550.combine.gap)
# Plot 2D
gg.aaot.gap <- plot2d(data = aaot550.combine.gap, fill = aaot550.combine.gap$AAOT550_Mean, 
                  colorbar = rainbow.colors, colorbar_limits = c(0.20, 0.27), 
                  shp = myshp, legend_name = 'AOD', title = '(b) Aqua Gap-filled AOD',
                  xlim = xlim, ylim = ylim)

## TAOT Overall
# Load data
load('data/PLOTAOD/taot550_combine.RData')
# Cut by NYS shp
taot550.combine <- cutByShp(shp.name = shp.name, dat = taot550.combine)
# Plot 2D
gg.taot <- plot2d(data = taot550.combine, fill = taot550.combine$TAOT550_Mean, 
                  colorbar = rainbow.colors, colorbar_limits = c(0.20, 0.27), 
                  shp = myshp, legend_name = 'AOD', title = '(c) Terra Overall AOD',
                  xlim = xlim, ylim = ylim)

## TAOT Original
# Load data
load('data/PLOTAOD/taot550_combine_ori.RData')
# Cut by NYS shp
taot550.combine.ori <- cutByShp(shp.name = shp.name, dat = taot550.combine.ori)
# Plot 2D
gg.taot.ori <- plot2d(data = taot550.combine.ori, fill = taot550.combine.ori$TAOT550_Mean, 
                      colorbar = jet.colors, colorbar_limits = c(0.05, 0.15), 
                      shp = myshp, legend_name = 'AOD', title = '2015 TERRA AOD ORIGINAL',
                      xlim = xlim, ylim = ylim)

## TAOT Gapfill
# Load data
load('data/PLOTAOD/taot550_combine_gap.RData')
# Cut by NYS shp
taot550.combine.gap <- cutByShp(shp.name = shp.name, dat = taot550.combine.gap)
# Plot 2D
gg.taot.gap <- plot2d(data = taot550.combine.gap, fill = taot550.combine.gap$TAOT550_Mean, 
                      colorbar = rainbow.colors, colorbar_limits = c(0.20, 0.27), 
                      shp = myshp, legend_name = 'AOD', title = '(d) Terra Gap-filled AOD',
                      xlim = xlim, ylim = ylim)

## ---------- PLOT DIFF AOD ---------- ##

## Difference (Gap - Ori) AAOT
df.aaot.diff <- data.frame(Lat = aaot550.combine.gap$Lat, Lon = aaot550.combine.gap$Lon, Diff = aaot550.combine.gap$AAOT550_Mean_Gap - aaot550.combine.ori$AAOT550_Mean_Ori)
gg.aaot.diff <- plot2d(data = df.aaot.diff, fill = df.aaot.diff$Diff, 
                      colorbar = diff.colors, colorbar_limits = c(-0.2, 0.2), 
                      shp = myshp, legend_name = 'AOD', title = '(e) Aqua AOD Differences',
                      xlim = xlim, ylim = ylim)

## Difference (Gap - Ori) TAOT
df.taot.diff <- data.frame(Lat = taot550.combine.gap$Lat, Lon = taot550.combine.gap$Lon, Diff = taot550.combine.gap$TAOT550_Mean_Gap - taot550.combine.ori$TAOT550_Mean_Ori)
gg.taot.diff <- plot2d(data = df.taot.diff, fill = df.taot.diff$Diff, 
                       colorbar = diff.colors, colorbar_limits = c(-0.2, 0.2), 
                       shp = myshp, legend_name = 'AOD', title = '(f) Terra AOD Differences',
                       xlim = xlim, ylim = ylim)

## ---------- Summary Stats & T-Test ---------- ##
mean(aaot550.combine.ori$AAOT550_Mean_Ori, na.rm = T)
quantile(aaot550.combine.ori$AAOT550_Mean_Ori, 0.25, na.rm = T)
quantile(aaot550.combine.ori$AAOT550_Mean_Ori, 0.75, na.rm = T)

mean(aaot550.combine.gap$AAOT550_Mean_Gap)
quantile(aaot550.combine.gap$AAOT550_Mean_Gap, 0.25)
quantile(aaot550.combine.gap$AAOT550_Mean_Gap, 0.75)

mean(taot550.combine.ori$TAOT550_Mean_Ori, na.rm = T)
quantile(taot550.combine.ori$TAOT550_Mean_Ori, 0.25, na.rm = T)
quantile(taot550.combine.ori$TAOT550_Mean_Ori, 0.75, na.rm = T)

mean(taot550.combine.gap$TAOT550_Mean_Gap)
quantile(taot550.combine.gap$TAOT550_Mean_Gap, 0.25)
quantile(taot550.combine.gap$TAOT550_Mean_Gap, 0.75)

hist(aaot550.combine.ori$AAOT550_Mean_Ori)
hist(aaot550.combine.gap$AAOT550_Mean_Gap)
hist(taot550.combine.ori$TAOT550_Mean_Ori)
hist(taot550.combine.gap$TAOT550_Mean_Gap)

# Paired T Test
t.test(aaot550.combine.gap$AAOT550_Mean_Gap, aaot550.combine.ori$AAOT550_Mean_Ori, paired = T)
t.test(taot550.combine.gap$TAOT550_Mean_Gap, taot550.combine.ori$TAOT550_Mean_Ori, paired = T)

## ---------- Scatters ---------- ##
# AAOT
df.aaot.point <- data.frame(Gap = aaot550.combine.gap$AAOT550_Mean_Gap, Ori = aaot550.combine.ori$AAOT550_Mean_Ori)
gg.aaot.point <- ggplot(data = df.aaot.point, aes(x = Ori, y = Gap)) + geom_point(alpha = .05) + 
  geom_smooth(method = 'lm') + 
  coord_fixed(xlim = c(0, 1), ylim = c(0, 1), ratio = 1)
fit.aaot.point <- lm(formula = Gap ~ Ori, data = df.aaot.point)
summary(fit.aaot.point)

# TAOT
df.taot.point <- data.frame(Gap = taot550.combine.gap$TAOT550_Mean_Gap, Ori = taot550.combine.ori$TAOT550_Mean_Ori)
gg.taot.point <- ggplot(data = df.taot.point, aes(x = Ori, y = Gap)) + geom_point(alpha = .05) + 
  geom_smooth(method = 'lm') + 
  coord_fixed(xlim = c(0, 1), ylim = c(0, 1), ratio = 1)
fit.taot.point <- lm(formula = Gap ~ Ori, data = df.taot.point)
summary(fit.taot.point)
