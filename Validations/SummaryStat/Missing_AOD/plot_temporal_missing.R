# Plot trends of temporal missing rate of AOD
#
# Author: Jianzhao Bi
# Date: Mar 6, 2018

library(ggplot2)
library(ggmap)
library(viridis)
library(RColorBrewer)
library(maptools)

setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/SummaryStat/Missing_AOD/')

load('data/2015_AAOT_Temporal.RData')
load('data/2015_TAOT_Temporal.RData')
load('data/Daily_Missing.RData')

trendInPeriod <- function(dat, cycle) {
  
  period <- rep(1 : 365, each = cycle)
  period <- period[1 : 365]
  dat$period <- period
  dat.period <- aggregate(dat, by = list(period), FUN = 'mean', na.rm = T)
  
  trend.plot <- ggplot(data = dat.period, aes(x = period)) +
    geom_point(aes(y = cloud, colour = "darkblue")) + 
    geom_line(aes(y = cloud, colour = "darkblue")) + 
    geom_point(aes(y = snow, colour = "red")) +
    geom_line(aes(y = snow, colour = "red")) +
    scale_color_discrete(name = "Causations", labels = c("Cloud", "Snow")) +
    ylab('Missing Rate (%)')
  
  return(trend.plot)
}


# --- Daily Missing Check --- # 
# This is only for the validation of following missing analyses
mean(daily.missing$aaot.daily.missing, na.rm = T)
quantile(daily.missing$aaot.daily.missing, 0.25, na.rm = T)
quantile(daily.missing$aaot.daily.missing, 0.75, na.rm = T)

mean(daily.missing$taot.daily.missing, na.rm = T)
quantile(daily.missing$taot.daily.missing, 0.25, na.rm = T)
quantile(daily.missing$taot.daily.missing, 0.75, na.rm = T)

# --- AAOT --- #
# Weekly trends
week.trend.aaot <- trendInPeriod(dat = rates.aaot, cycle = 7)
# Monthly trends
month.trend.aaot <- trendInPeriod(dat = rates.aaot, cycle = 30)

# --- TAOT --- #
# Weekly trends
week.trend.taot <- trendInPeriod(dat = rates.taot, cycle = 7)
# Monthly trends
month.trend.taot <- trendInPeriod(dat = rates.taot, cycle = 30)

# --- Missing Rate --- #

## AAOT
mean(rates.aaot$overall)
quantile(rates.aaot$overall, 0.25, na.rm = T)
quantile(rates.aaot$overall, 0.75, na.rm = T)

mean(rates.aaot$cloud)
quantile(rates.aaot$cloud, 0.25, na.rm = T)
quantile(rates.aaot$cloud, 0.75, na.rm = T)

mean(rates.aaot$snow)
quantile(rates.aaot$snow, 0.25, na.rm = T)
quantile(rates.aaot$snow, 0.75, na.rm = T)

mean(rates.aaot$snow[1 : 105]) # First 15 weeks
quantile(rates.aaot$snow[1 : 105], 0.25, na.rm = T)
quantile(rates.aaot$snow[1 : 105], 0.75, na.rm = T)

mean(rates.aaot$waterice)
quantile(rates.aaot$waterice, 0.25, na.rm = T)
quantile(rates.aaot$waterice, 0.75, na.rm = T)

## TAOT
mean(rates.taot$overall, na.rm = T)
quantile(rates.taot$overall, 0.25, na.rm = T)
quantile(rates.taot$overall, 0.75, na.rm = T)

mean(rates.taot$cloud, na.rm = T)
quantile(rates.taot$cloud, 0.25, na.rm = T)
quantile(rates.taot$cloud, 0.75, na.rm = T)

mean(rates.taot$snow, na.rm = T)
quantile(rates.taot$snow, 0.25, na.rm = T)
quantile(rates.taot$snow, 0.75, na.rm = T)

mean(rates.taot$snow[1 : 105], na.rm = T) # First 15 weeks
quantile(rates.taot$snow[1 : 105], 0.25, na.rm = T)
quantile(rates.taot$snow[1 : 105], 0.75, na.rm = T)

mean(rates.taot$waterice, na.rm = T)
quantile(rates.taot$waterice, 0.25, na.rm = T)
quantile(rates.taot$waterice, 0.75, na.rm = T)
