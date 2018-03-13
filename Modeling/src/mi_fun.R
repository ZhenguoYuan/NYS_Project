#----------------------------
# Function used in 
# LME_GAM Fitting for RF
# 
# Jianzhao Bi
# 12/3/2017
#----------------------------

library(MASS)
library(mgcv)
library(pls)
library(lubridate)
library(randomForest)

## ------------------------
## Fitting by LME and GAM
LME_GAM <- function(all, year, if.print = T) {
  
  
  if (if.print) {
    print(paste(Sys.time(), '-- Modeling'))
  }
  
  ## ---------- LME ---------- ##
  LME_Control.obj <- lmeControl(returnObject = TRUE)
  
  summary(all)
  
  LME<- lme(fixed = PM25 ~ I(PBLH_3h_NARR - mean(PBLH_3h_NARR)) + I(short_flux_surf_NLDAS - mean(short_flux_surf_NLDAS)) + I(RH_3h_NARR - mean(RH_3h_NARR)) +
              I(AOD550_TAOT.y - mean(AOD550_TAOT.y)) + I(AOD550_TAOT.y - mean(AOD550_TAOT.y)) * I(PBLH_3h_NARR - mean(PBLH_3h_NARR)) + I(AOD550_TAOT.y2 - mean(AOD550_TAOT.y2))+
              I(wind - mean(wind)) + I(total_prec_NLDAS - mean(total_prec_NLDAS)) + I(short_flux_surf_NLDAS2 - mean(short_flux_surf_NLDAS2)) + I(TEMP_2m_3h_NARR - mean(TEMP_2m_3h_NARR)), 
            random = list(month = ~ I(RH_3h_NARR - mean(RH_3h_NARR)) + I(PBLH_3h_NARR - mean(PBLH_3h_NARR)), 
                          doy = ~ 1 + I(AOD550_TAOT.y - mean(AOD550_TAOT.y)) + I(AOD550_TAOT.y2 - mean(AOD550_TAOT.y2))), 
            data = all,  control = LME_Control.obj)
  
  LME_Pred_MF<- predict(LME, level = 0 : 2)
  fit<-lm(all$PM25 ~ LME_Pred_MF$predict.doy)
  summary(fit)
  
  ## ---------- GAM ---------- ##
  GAM_Raw<-cbind(LME_Pred_MF$predict.doy, all[,c("PM25","doy","year","month","ID","X_Lon", "Y_Lat", "pop", 'HighwayDist', 'MajorDist')]) # Second-level parameters
  colnames(GAM_Raw)[1]<-"Pred_1"
  GAM_Raw$Resid<-GAM_Raw$PM25-GAM_Raw$Pred_1
  avg<-aggregate(GAM_Raw[,-c(5:6)], by=list(GAM_Raw$month,GAM_Raw$ID), mean) # Monthly Average
  colnames(avg)[1:2]<-c("month","ID")
  Resid_Pred<-c()
  
  # # Process the GRIDCODE
  # avg$GRIDCODE <- as.factor(avg$GRIDCODE)
  
  # For each month
  for (i in 1 : 12){
    nam <- paste("GAM", i, sep = "")
    GAM <- gam(Resid ~ s(X_Lon, Y_Lat) + s(pop) + s(HighwayDist) + s(MajorDist), data = avg[avg$month==i,]) # k is effective degrees of freedom (BIOS526 Penalized Splines and GAM)
    Resid_Pred1 <- predict(GAM)
    Resid_Pred1<-data.frame(cbind(avg$ID[avg$month==i],Resid_Pred1))
    Resid_Pred1$month = i
    Resid_Pred<-rbind(Resid_Pred,Resid_Pred1)
    assign(nam,GAM)
  }
  colnames(Resid_Pred)[1:2]<-c("ID","Resid_Pred1")
  Overall<-merge(GAM_Raw,Resid_Pred,by.x=c("ID","month"), by.y=c("ID","month"), all = T)
  Overall$Pred_2s_MF1 <- Overall$Pred_1 + Overall$Resid_Pred1 # Predictions from LME and GAM
  
  fit<-lm(PM25 ~ Pred_2s_MF1,data = Overall)
  summary(fit)
  
  if (if.print) {
    print(paste(Sys.time(), '-- Complete'))
  }
  
  return(list(LME = LME, GAM = list(GAM1 = GAM1, GAM2 = GAM2, GAM3 = GAM3,
    GAM4 = GAM4, GAM5 = GAM5, GAM6 = GAM6, GAM7 = GAM7,
    GAM8 = GAM8, GAM9 = GAM9, GAM10 = GAM10, GAM11 = GAM11,
    GAM12 = GAM12)))
  
}

## ------------------------
## Prediction from LME and GAM
LME_GAM_PRED <- function(LME_Pred_Raw, LME_GAM_result, year) {
  
  # Predict LME
  LME_Pred <- predict(LME_GAM_result$LME, LME_Pred_Raw, level = 0 : 2) 
  # Predict GAM in this month
  Resid_Pred <- predict(LME_GAM_result$GAM[[LME_Pred_Raw$month[1]]], LME_Pred_Raw) 
  
  Pred<-cbind(LME_Pred_Raw[,c("ID","year","doy","Lon","Lat")], LME_Pred, Resid_Pred)
  Pred$LME_Pred_1 <- LME_Pred$predict.doy
  Pred$Pred_2s_1<-Pred$LME_Pred_1 + Pred$Resid_Pred
  Pred<-Pred[,c("ID","year","doy","Resid_Pred","LME_Pred_1","Pred_2s_1","Lon","Lat")]
  
  return(Pred)
}

## ------------------------
## Organizing data for LME and GAM
LME_GAM_ORG <- function(dat, year) {
  
  # Adding other necessary parameters
  dat$AOD550_TAOT.y2 <- dat$AOD550_TAOT.y^2 # AOD^2
  dat$short_flux_surf_NLDAS2 <- dat$short_flux_surf_NLDAS^2 # Surface Incident Shortwave Flux ^ 2
  dat$wind <- sqrt(dat$UWND_3h_NARR^2 + dat$VWND_3h_NARR^2) # Wind speed
  dat$month <- month(as.Date(dat$doy - 1, origin = paste(as.character(year), '-01-01', sep = '')))
  
  return(dat)
  
}



