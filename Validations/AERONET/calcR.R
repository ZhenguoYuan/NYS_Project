setwd('~/Google Drive/Projects/Codes/NYS_Project/Validations/AERONET/')
library(ggplot2)

load('data/mi_combine_aero.RData')
load('data/rf_combine_aero.RData')

## Check whether the correlation of gap-filled AOD is close to the correlation of original AOD !!!

## ---------- MI ---------- ##
mi_tag <- mi.combine.aero$mi_tag
mi.combine.aero$AOT550_MI <- rowMeans(cbind(mi.combine.aero$AOT550_1, mi.combine.aero$AOT550_2, mi.combine.aero$AOT550_3,
                                      mi.combine.aero$AOT550_4, mi.combine.aero$AOT550_5)) # Mean of MI AODs

## AERONET vs MI (Gap-filled)
plot(mi.combine.aero$AERONET_AOD550[mi_tag == 1], mi.combine.aero$AOT550_MI[mi_tag == 1], xlab = 'AERONET AOD', ylab = 'MI AOD')
cor(mi.combine.aero$AERONET_AOD550[mi_tag == 1], mi.combine.aero$AOT550_MI[mi_tag == 1])

## AERONET vs MI (Original)
plot(mi.combine.aero$AERONET_AOD550[mi_tag == 0], mi.combine.aero$AOT550_MI[mi_tag == 0], xlab = 'AERONET AOD', ylab = 'MAIAC AOD')
cor(mi.combine.aero$AERONET_AOD550[mi_tag == 0], mi.combine.aero$AOT550_MI[mi_tag == 0])

## ggplot
ggplot(mi.combine.aero, aes(AERONET_AOD550, AOT550_MI)) + 
  geom_point(aes(colour = factor(mi_tag))) + 
  scale_colour_discrete(name = 'Types', labels = c('Original', 'Gap-filled')) + 
  labs(x = 'AERONET AOD', y = 'MI AOD')

## ---------- RF ---------- ##
rf_tag <- rf.combine.aero$rf_tag

## AERONET vs RF (Gap-filled)
plot(rf.combine.aero$AERONET_AOD550[rf_tag == 1], rf.combine.aero$AOD550TAOT_RF[rf_tag == 1])
cor(rf.combine.aero$AERONET_AOD550[rf_tag == 1], rf.combine.aero$AOD550TAOT_RF[rf_tag == 1])


## AERONET vs RF (Original)
plot(rf.combine.aero$AERONET_AOD550[rf_tag == 0], rf.combine.aero$AOD550TAOT_RF[rf_tag == 0])
cor(rf.combine.aero$AERONET_AOD550[rf_tag == 0], rf.combine.aero$AOD550TAOT_RF[rf_tag == 0])

## ggplot
ggplot(rf.combine.aero, aes(AERONET_AOD550, AOD550TAOT_RF)) + 
  geom_point(aes(colour = factor(rf_tag))) + 
  scale_colour_discrete(name = 'Types', labels = c('Original', 'Gap-filled')) + 
  labs(x = 'AERONET AOD', y = 'RF AOD')
