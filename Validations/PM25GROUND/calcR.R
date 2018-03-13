setwd('~/Google Drive/MAIAC Project/Codes/NYS_Project/Validations/PM25GROUND/')
library(ggplot2)

load('data/combine_PM25.RData')

## Check whether the correlation of gap-filled PM2.5 is close to the correlation of original PM2.5 !!!

gapfill_tag <- combine.pm25$Gapfill_tag

## Ground PM2.5 vs Predicted PM2.5 (Gap-filled)
plot(combine.pm25$PM25[gapfill_tag == 1], combine.pm25$PM25_Pred[gapfill_tag == 1])
cor(combine.pm25$PM25[gapfill_tag == 1], combine.pm25$PM25_Pred[gapfill_tag == 1])


## Ground PM2.5 vs Predicted PM2.5 (Original)
plot(combine.pm25$PM25[gapfill_tag == 0], combine.pm25$PM25_Pred[gapfill_tag == 0])
cor(combine.pm25$PM25[gapfill_tag == 0], combine.pm25$PM25_Pred[gapfill_tag == 0])

## Scatter plot
ggplot(combine.pm25, aes(PM25, PM25_Pred)) + 
  geom_point(aes(colour = factor(gapfill_tag))) + 
  scale_colour_discrete(name = 'Types', labels = c('Original', 'Gap-filled')) + 
  labs(x = 'Ground PM2.5', y = 'Predicted PM2.5')
