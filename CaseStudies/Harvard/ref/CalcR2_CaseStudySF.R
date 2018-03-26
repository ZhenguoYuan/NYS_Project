## -------------
## Name: CalcR2_CaseStudy.R
## Program version: R 3.2.3
## Dependencies:
## Author: J.H. Belle
## Purpose: Run CV R2 analysis on no gap-filling, my gap-filling, and harvard gap-filling models relating AOD to PM
## -------------
library(plyr)

# Read in data
Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldRUC_10km.csv", stringsAsFactors = F)
#Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlG24_MAIACCldRUC.csv", stringsAsFactors = F)
Dat$Date <- as.Date(Dat$Date, "%Y-%m-%d")
G24 <- subset(Dat, Dat$Glint == 0)

# Remove regular AOD values less than 0 - these are missing
G24$AOD47 <- ifelse(G24$AOD47 < 0, NA, G24$AOD47)
G24$AOD55 <- ifelse(G24$AOD55 < 0 | G24$AOD55 > 0.5, NA, G24$AOD55)

# Classify observations into clear, glint, high cloud, medium cloud, low cloud, and thundercloud using MAIAC and RUC
G24$Month <- as.integer(as.character(G24$Date, "%m"))
G24$Year <- as.integer(as.character(G24$Date, "%Y"))
G24$OrigPM <- G24$X24hrPM
G24$X24hrPM <- ifelse(G24$X24hrPM <= 0, 0.01, G24$X24hrPM)
G24$LogPM <- log(G24$X24hrPM)
G24 <- subset(G24, G24$Dist < 1000)
# Remove duplicate MAIAC collocations
#takefirst <- function(datblock){ return(datblock[1,])}
#library(plyr)
#FirstCollocOnly <- ddply(G24, .(State, County, Site, Date, AquaTerraFlag), takefirst)
MissingMAIAC <- G24

#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_10km.csv", stringsAsFactors = F)
#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_Atl10km.csv", stringsAsFactors = F)
Clouds <- read.csv("E://CloudAgg_10km.csv")
Clouds$Date <- as.Date(Clouds$Date, "%Y-%m-%d")
Clouds$X <- NULL
MissingMAIAC <- merge(MissingMAIAC, Clouds, all.x=T)
# Filter 3: RUC -
MissingMAIAC$Raining <- ifelse(MissingMAIAC$prate_surface == 0, 0, 1)
# Will need to double-check this categorization for each dataset
MissingMAIAC$MAIACcat <- ifelse(MissingMAIAC$Cloud == 1 | MissingMAIAC$Partcloud == 1 | MissingMAIAC$CloudShadow == 1, "Cloud", ifelse(MissingMAIAC$Glint == 1 | MissingMAIAC$Clear == 1 | MissingMAIAC$Snow == 1, "Glint", NA))
MissingMAIAC$CloudAOD <- ifelse(is.na(MissingMAIAC$CloudAOD), 0, MissingMAIAC$CloudAOD)
MissingMAIAC$hpbl_surface <- ifelse(MissingMAIAC$hpbl_surface < 0, 0, MissingMAIAC$hpbl_surface)
MissingMAIAC$WindSpeed <- sqrt(MissingMAIAC$X10u_heightAboveGround^2 + MissingMAIAC$X10v_heightAboveGround^2)
MissingMAIAC$CloudPhase <- ifelse(is.na(MissingMAIAC$CloudPhase), 0, MissingMAIAC$CloudPhase)
MissingMAIAC$CloudEmmisivity <- ifelse(is.na(MissingMAIAC$CloudEmmisivity), 0, MissingMAIAC$CloudEmmisivity)
MissingMAIAC$CloudTopTemp <- ifelse(MissingMAIAC$CloudTopTemp < 0, NA, MissingMAIAC$CloudTopTemp - 15000)
MissingMAIAC$CloudWaterPath <- ifelse(is.na(MissingMAIAC$CloudWaterPath), 0, MissingMAIAC$CloudWaterPath)
MissingMAIAC$CloudRadius <- ifelse(is.na(MissingMAIAC$CloudRadius), 0, MissingMAIAC$CloudRadius)

MissingMAIAC$HasCldEmis <- ifelse(MissingMAIAC$CloudEmmisivity == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldRad <- ifelse(MissingMAIAC$CloudRadius == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldAOD <- ifelse(MissingMAIAC$CloudAOD == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldMODHgt <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "NoCld", "YesCld")
MissingMAIAC$MODCld <- ifelse(MissingMAIAC$HasCldEmis == "YesCld" & MissingMAIAC$HasCldRad == "YesCld" & MissingMAIAC$HasCldAOD == "YesCld" & MissingMAIAC$HasCldMODHgt == "YesCld", "YesCld", ifelse(MissingMAIAC$HasCldEmis == "NoCld" & MissingMAIAC$HasCldRad == "NoCld" & MissingMAIAC$HasCldAOD == "NoCld" & MissingMAIAC$HasCldMODHgt == "NoCld", "NoCld", "MaybeCld"))
MissingMAIAC$MODCld2 <- ifelse(MissingMAIAC$CloudPhase == 0 & MissingMAIAC$MODCld == "YesCld", "MaybeCld", MissingMAIAC$MODCld)
#xtabs(~ MODCld2 + Raining, MissingMAIAC)
MissingMAIAC$MODRUCCld <- ifelse(MissingMAIAC$MODCld2 == "NoCld" & MissingMAIAC$Raining == 1, "MaybeCld", MissingMAIAC$MODCld2)
#xtabs(~ MODRUCCld + MAIACcat, MissingMAIAC)
MissingMAIAC$MODMAIACRUCCld <- ifelse((MissingMAIAC$MODRUCCld == "NoCld" & MissingMAIAC$MAIACcat == "Cloud") | (MissingMAIAC$MODRUCCld == "YesCld" & MissingMAIAC$MAIACcat == "Glint"), "MaybeCld", MissingMAIAC$MODRUCCld)
MissingMAIAC$MODMAIACRUCCld <- ifelse((MissingMAIAC$MODRUCCld == "NoCld" & MissingMAIAC$MAIACcat == "Cloud"), "MaybeCld", MissingMAIAC$MODRUCCld)
#summary(as.factor(MissingMAIAC$MODMAIACRUCCld))
# NA's in MODMAIACRUCCld variable are missing RUC information - remove
MissingMAIAC <- subset(MissingMAIAC, !is.na(MissingMAIAC$MODMAIACRUCCld))
# Make a categorical variable that combines the Yes Clouds in MODMAIACRUCCld with Cloud Phase
MissingMAIAC$CloudCatFin <- ifelse(MissingMAIAC$MODMAIACRUCCld == "MaybeCld", "MaybeCld", ifelse(MissingMAIAC$MODMAIACRUCCld == "NoCld", "NoCld", ifelse(MissingMAIAC$CloudPhase == 1, "WaterCld", ifelse(MissingMAIAC$CloudPhase == 2, "IceCld", "UndetCld"))))
xtabs(~CloudCatFin + AquaTerraFlag, MissingMAIAC)
MissingMAIAC$CldHgtCat <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "None", ifelse(MissingMAIAC$CloudTopHgt < 5000, "Low", "High"))
MissingMAIAC$CloudCatFin2 <- ifelse(MissingMAIAC$MODMAIACRUCCld == "MaybeCld", "MaybeCld", ifelse(MissingMAIAC$MODMAIACRUCCld == "NoCld", "NoCld", MissingMAIAC$CldHgtCat))
MissingMAIAC$pblh = MissingMAIAC$hpbl_surface/1000
MissingMAIAC$prate <- MissingMAIAC$prate_surface*1000
MissingMAIAC$CenteredTemp = MissingMAIAC$X2t_heightAboveGround - 273.15
MissingMAIAC$cape2 = MissingMAIAC$cape_surface/1000
MissingMAIAC$DOY = as.integer(as.character(MissingMAIAC$Date, "%j"))
# Add station XY information
#Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlStationLocs_XY.csv", stringsAsFactors = F)
#CentroidX = 1076436.4 #Atl
#CentroidY = -544307.2 #Atl
Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifStationLocs_XY.csv", stringsAsFactors = F)
CentroidX = -2179644.1 #SF
CentroidY = 258174.0 #SF
StationLocs = Stationlocs[,c("State", "County", "Site", "POINT_X", "POINT_Y", "RASTERVALU")]
MissingMAIAC <- merge(MissingMAIAC, StationLocs)
MissingMAIAC$CenteredX = MissingMAIAC$POINT_X - CentroidX
MissingMAIAC$CenteredY = MissingMAIAC$POINT_Y - CentroidY
MissingMAIAC$Elev = MissingMAIAC$RASTERVALU/1000
SpatialVars = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/SFMAIACgrid_Pred/SFGridFin/FinGridJoined.csv", stringsAsFactors = F)[,c("InputFID", "PercForest", "PRoadLengt", "NEIPM", "Elev", "POINT_X", "POINT_Y")]
EPAtoMAIAC = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/SFMAIACgrid_Pred/SFGridFin/EPAtoMAIAC.csv", stringsAsFactors = F)[,c("State", "County", "Site", "Input_FID")]
SpatialVars = merge(SpatialVars, EPAtoMAIAC, by.x="InputFID", by.y="Input_FID")
MissingMAIAC = merge(MissingMAIAC, SpatialVars, by=c("State", "County", "Site"))
#MissingMAIAC$Elev.y= MissingMAIAC$Elev.y/1000
#MissingMAIAC$PRoadLengt = MissingMAIAC$PRoadLengt/1000

#SpatialVars = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/AtlMAIACgrid_Pred/FinalCopy_AtlPolys/FinGridJoined2.csv", stringsAsFactors = F)[,c("InputFID", "RdLen", "Elev", "PForst", "NEIPM")]
#EPAtoMAIAC = read.csv("T:/eohprojs/CDC_climatechange/Jess/Dissertation/AtlMAIACgrid_Pred/FinalCopy_AtlPolys/EPAtoMAIAC.csv", stringsAsFactors = F)[,c("State", "County", "Site", "Input_FID")]
#SpatialVars = merge(SpatialVars, EPAtoMAIAC, by.x="InputFID", by.y="Input_FID")
#MissingMAIAC = merge(MissingMAIAC, SpatialVars, by=c("State", "County", "Site"))
# Make Single observation for each date
MissingMAIAC = subset(MissingMAIAC, !is.na(MissingMAIAC$CenteredTemp))[,c("State", "County", "Site", "Date", "X24hrPM", "InputFID", "AquaTerraFlag", "AOD55", "r_heightAboveGround", "LogPM", "CloudAOD", "CloudRadius", "CloudEmmisivity", "Raining", "WindSpeed", "CloudCatFin", "pblh", "CenteredTemp", "cape2", "POINT_X.y", "POINT_Y.y", "Elev.y", "PercForest", "PRoadLengt", "NEIPM")]
#MissingMAIAC = subset(MissingMAIAC, !is.na(MissingMAIAC$CenteredTemp))[,c("State", "County", "Site", "InputFID", "Date", "Time", "X24hrPM", "AquaTerraFlag", "AOD55", "r_heightAboveGround", "LogPM", "CloudAOD", "CloudRadius", "CloudEmmisivity", "Raining", "WindSpeed", "CloudCatFin", "pblh", "CenteredTemp", "cape2", "POINT_X", "POINT_Y", "Elev.y", "PForst", "RdLen", "NEIPM")]
#colnames(MissingMAIAC) <- c("State", "County", "Site", "InputFID", "Date", "Time", "X24hrPM", "AquaTerraFlag", "AOD55", "r_heightAboveGround", "LogPM", "CloudAOD", "CloudRadius", "CloudEmmisivity", "Raining", "WindSpeed", "CloudCatFin", "pblh", "CenteredTemp", "cape2", "POINT_X.y", "POINT_Y.y", "Elev.y", "PercForest", "PRoadLengt", "NEIPM")
Terra = subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "T")
Aqua = subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "A")

takefirst <- function(datblock){
  TakeFirst = datblock[1,c("InputFID", "X24hrPM", "LogPM", "AquaTerraFlag", "r_heightAboveGround", "Raining", "WindSpeed", "pblh", "CenteredTemp", "cape2", "POINT_X.y", "POINT_Y.y", "Elev.y", "PercForest", "PRoadLengt", "NEIPM")]
  AOD55 = mean(datblock$AOD55, na.rm=T)
  #CloudAOD = mean(ifelse(datblock$CloudAOD==0, NA, datblock$CloudAOD), na.rm=T)
  CloudAOD = mean(datblock$CloudAOD, na.rm=T)
  #CloudRadius = mean(ifelse(datblock$CloudRadius==0, NA, datblock$CloudRadius), na.rm=T)
  CloudRadius = mean(datblock$CloudRadius, na.rm=T)
  #CloudEmmisivity = mean(ifelse(datblock$CloudEmmisivity==0, NA, datblock$CloudEmmisivity), na.rm=T)
  CloudEmmisivity = mean(datblock$CloudEmmisivity, na.rm=T)
  CloudCatFins = unique(datblock$CloudCatFin)
  CloudCatFin = ifelse(length(CloudCatFins)== 1, CloudCatFins, ifelse("WaterCld" %in% CloudCatFins, "WaterCld", ifelse("IceCld" %in% CloudCatFins, "IceCld", "MaybeCld")))
  return(cbind.data.frame(TakeFirst, AOD55, CloudAOD, CloudRadius, CloudEmmisivity, CloudCatFin))
}
Terra2  = ddply(Terra, .(State, County, Site, Date), takefirst)
Aqua2 = ddply(Aqua, .(State, County, Site, Date), takefirst)
CombTA = merge(Terra2, Aqua2, by=c("State", "County", "Site", "InputFID", "Date", "X24hrPM"))
CombTA$CrossValSetT = sample(1:10, length(CombTA$County), replace=T)
CombTA$CrossValSetA = sample(1:10, length(CombTA$County), replace=T)
CombTA$DOY = as.integer(as.character(CombTA$Date, "%j"))
CombTA$Year = as.integer(as.character(CombTA$Date, "%Y"))
CombTA = subset(CombTA, CombTA$Year == 2012 | CombTA$Year == 2013 | CombTA$Year == 2014)
CombTA = subset(CombTA, CombTA$X24hrPM > 2)
Rdlengths = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/SFMAIACgrid_Pred/SFGridFin/RdLengths_AllRds.csv")[,c("Input_FID", "Count_", "RdLenkm")]
CombTA = merge(CombTA, Rdlengths, by.x="InputFID", by.y="Input_FID")
CombTA$rownames = rownames(CombTA)

## --------
## No gap-filling model
## --------

library(MuMIn)
library(piecewiseSEM)
library(lme4)

# Fit models
for (i in seq(1,10)){
  mod = lmer(X24hrPM~AOD55.x + pblh.x + CenteredTemp.x + WindSpeed.x + r_heightAboveGround.x + Elev.y.x + NEIPM.x + PercForest.x + RdLenkm + (1+AOD55.x|DOY), CombTA[CombTA$CrossValSetT != i,])
  moda = lmer(X24hrPM~AOD55.y + pblh.y + CenteredTemp.y + WindSpeed.y + r_heightAboveGround.y + Elev.y.y + NEIPM.y + PercForest.y + RdLenkm + (1+AOD55.y|DOY), CombTA[CombTA$CrossValSetA != i,])
  predvalsT = predict(mod, CombTA[CombTA$CrossValSetT == i,], allow.new.levels=T)
  predvalsA = predict(moda, CombTA[CombTA$CrossValSetA == i,], allow.new.levels=T)
  if (exists("PredA")){ PredA = c(PredA, predvalsA) } else PredA = predvalsA
  if (exists("PredT")){ PredT = c(PredT, predvalsT) } else PredT = predvalsT
}

# Add predicted values into main dataset
PredA = cbind.data.frame(names(PredA), PredA)
colnames(PredA) <- c("rownames", "PredA")
PredA$rownames = as.character(PredA$rownames)
CombTA = merge(CombTA, PredA, all.x=T)
PredT = cbind.data.frame(names(PredT), PredT)
colnames(PredT) <- c("rownames", "PredT")
PredT$rownames = as.character(PredT$rownames)
CombTA = merge(CombTA, PredT, all.x=T)
# Average T + A
CombTA$CVPredNoGapFill = rowMeans(CombTA[,c("PredA", "PredT")], na.rm=T)
# Calculate R2
summary(lm(X24hrPM~CVPredNoGapFill, CombTA, na.action = "na.omit"))
summary(lm(X24hrPM~PredA, CombTA, na.action = "na.omit"))
summary(lm(X24hrPM~PredT, CombTA, na.action = "na.omit"))
rm(PredT, PredA)

## --------
# My gap fill
## --------

for (i in seq(1,10)){
  cloudt_w = lmer(LogPM.x ~ CenteredTemp.x + r_heightAboveGround.x + WindSpeed.x + cape2.x + pblh.x + Raining.x + CloudEmmisivity.x + CloudRadius.x + CloudAOD.x + (1|Date), CombTA[(CombTA$CrossValSetT != i & CombTA$CloudCatFin.x == "WaterCld"),], na.action="na.omit")
  cloudt_i = lmer(LogPM.x ~ CenteredTemp.x + r_heightAboveGround.x + WindSpeed.x + cape2.x + pblh.x + Raining.x + CloudEmmisivity.x + CloudRadius.x + CloudAOD.x + (1|Date), CombTA[CombTA$CrossValSetT != i & CombTA$CloudCatFin.x == "IceCld",])

  clouda_w = lmer(LogPM.y ~ CenteredTemp.y + r_heightAboveGround.y + WindSpeed.y + cape2.y + pblh.y + Raining.y + CloudEmmisivity.y + CloudRadius.y + CloudAOD.y + (1|Date), CombTA[CombTA$CrossValSetA != i & CombTA$CloudCatFin.y == "WaterCld",])
  clouda_i = lmer(LogPM.y ~ CenteredTemp.y + r_heightAboveGround.y + WindSpeed.y + cape2.y + pblh.y + Raining.y + CloudEmmisivity.y + CloudRadius.y + CloudAOD.y + (1|Date), CombTA[CombTA$CrossValSetA != i & CombTA$CloudCatFin.y == "IceCld",])

  predctw = predict(cloudt_w, CombTA[CombTA$CrossValSetT == i & CombTA$CloudCatFin.x == "WaterCld",], allow.new.levels=T)
  predcti = predict(cloudt_i, CombTA[CombTA$CrossValSetT == i & CombTA$CloudCatFin.x == "IceCld",], allow.new.levels=T)

  predcaw = predict(clouda_w, CombTA[CombTA$CrossValSetA == i & CombTA$CloudCatFin.y == "WaterCld",], allow.new.levels=T)
  predcai = predict(clouda_i, CombTA[CombTA$CrossValSetA == i & CombTA$CloudCatFin.y == "IceCld",], allow.new.levels=T)

  if (exists("PredTw")){ PredTw = c(PredTw, predctw) } else PredTw = predctw
  if (exists("PredTi")){ PredTi = c(PredTi, predcti) } else PredTi = predcti
  if (exists("PredAw")){ PredAw = c(PredAw, predcaw) } else PredAw = predcaw
  if (exists("PredAi")){ PredAi = c(PredAi, predcai) } else PredAi = predcai
}


PredTw = cbind.data.frame(names(PredTw), exp(PredTw))
colnames(PredTw) <- c("rownames", "PredTw")
PredTw$rownames = as.character(PredTw$rownames)
CombTA$rownames2 = as.numeric(rownames(CombTA))
CombTA = merge(CombTA, PredTw, all.x=T, by.x="rownames2", by.y="rownames")

PredTi = cbind.data.frame(names(PredTi), exp(PredTi))
colnames(PredTi) <- c("rownames", "PredTi")
PredTi$rownames = as.character(PredTi$rownames)
#CombTA = merge(CombTA, PredTi, all.x=T)
CombTA = merge(CombTA, PredTi, all.x=T, by.x="rownames2", by.y="rownames")

PredAw = cbind.data.frame(names(PredAw), exp(PredAw))
colnames(PredAw) <- c("rownames", "PredAw")
PredAw$rownames = as.character(PredAw$rownames)
#CombTA = merge(CombTA, PredAw, all.x=T)
CombTA = merge(CombTA, PredAw, all.x=T, by.x="rownames2", by.y="rownames")

PredAi = cbind.data.frame(names(PredAi), exp(PredAi))
colnames(PredAi) <- c("rownames", "PredAi")
PredAi$rownames = as.character(PredAi$rownames)
#CombTA = merge(CombTA, PredAi, all.x=T)
CombTA = merge(CombTA, PredAi, all.x=T, by.x="rownames2", by.y="rownames")

rm(PredTw, PredTi, PredTo, PredAw, PredAi, PredAo)

CombTA$PredCldA = rowSums(CombTA[,c("PredAw", "PredAi")], na.rm = T)
CombTA$PredCldA = ifelse(CombTA$PredCldA == 0, NA, CombTA$PredCldA)
CombTA$PredCldT = rowSums(CombTA[,c("PredTw", "PredTi")], na.rm = T)
CombTA$PredCldT = ifelse(CombTA$PredCldT == 0, NA, CombTA$PredCldT)

CombTA$PredWCld = rowMeans(CombTA[,c("PredCldA", "PredCldT", "PredT", "PredA")], na.rm=T)
CombTA$PredWCldA = rowMeans(CombTA[,c("PredCldA","PredA")], na.rm=T)
CombTA$PredWCldT = rowMeans(CombTA[,c("PredCldT","PredT")], na.rm=T)

summary(lm(X24hrPM~PredWCld, CombTA))
summary(lm(X24hrPM~PredWCldA, CombTA))
summary(lm(X24hrPM~PredWCldT, CombTA))

## -------
# Harvard gap fill
## -------
library(mgcv)
DailyMean = aggregate(X24hrPM~Date, CombTA, mean)
colnames(DailyMean) <- c("Date", "DailyMean")
DailyMean$DailyMean = sqrt(DailyMean$DailyMean)
CombTA = merge(CombTA, DailyMean, by="Date")
CombTA$sqrtPM = sqrt(CombTA$X24hrPM)
CombTA$rownames3 = rownames(CombTA)
CombTA$Month = as.numeric(as.character(CombTA$Date, "%m"))
rm(Pred)
for (i in seq(1,10)){
  for (m in seq(1,12)){
    harvt = gam(sqrtPM ~ DailyMean + s(POINT_X.y.y, POINT_Y.y.y, k=10), data=CombTA[CombTA$CrossValSetT != i & CombTA$Month == m,], method="REML")
    pred = predict(harvt, CombTA[CombTA$CrossValSetT == i & CombTA$Month == i,], type="respose")
    if (exists("Pred")){
      pred2 = as.data.frame(pred)
      pred2$rownames = dimnames(pred)[[1]]
      Pred = rbind.data.frame(Pred, pred2)
    } else {
      Pred = as.data.frame(pred)
      Pred$rownames = dimnames(pred)[[1]]
    }
  }
}


CombTA = merge(CombTA, Pred, all.x=T, by.x="rownames3", by.y="rownames")
CombTA$HarvPred = CombTA$DailyMean.y^2
CombTA$PredH = rowMeans(CombTA[,c("PredT", "PredA", "HarvPred")], na.rm=T)
summary(lm(X24hrPM~PredH, CombTA))

## ----------
# Fit final versions to transfer to cluster
## ----------

mainmoda = lmer(X24hrPM~AOD55.y + pblh.y + CenteredTemp.y + WindSpeed.y + r_heightAboveGround.y + Elev.y.y + PercForest.y + NEIPM.y + RdLenkm + (1+AOD55.y|DOY), CombTA)
mainmod = lmer(X24hrPM~AOD55.x + pblh.x + CenteredTemp.x + WindSpeed.x + r_heightAboveGround.x + Elev.y.y + NEIPM.x + PercForest.x + RdLenkm + (1+AOD55.x|DOY), CombTA)
summary(mainmod)
summary(mainmoda)
saveRDS(mainmod, "C:/Users/jhbelle/Documents/mainmodel.Rdata")
saveRDS(mainmoda, "C:/Users/jhbelle/Documents/mainmodela.Rdata")

for (m in seq(1,12)){
  harvmod = gam(sqrtPM~ DailyMean.x + s(POINT_X.y.y, POINT_Y.y.y, k=10), data=CombTA[CombTA$Month == m,])
  saveRDS(harvmod, sprintf("C://Users/jhbelle/Documents/harvmodel_%i.Rdata", m))
}

watcloud = lmer(LogPM.y ~ CenteredTemp.y + r_heightAboveGround.y + WindSpeed.y + cape2.y + pblh.y + Raining.y + CloudEmmisivity.y + CloudRadius.y + CloudAOD.y + (1|DOY), CombTA[(CombTA$CloudCatFin.x == "WaterCld"),], na.action="na.omit")
saveRDS(watcloud, "C:/Users/jhbelle/Documents/watercloudmodela.Rdata")

icecloud = lmer(LogPM.y ~ CenteredTemp.y + r_heightAboveGround.y + WindSpeed.y + cape2.y + pblh.y + Raining.y + CloudEmmisivity.y + CloudRadius.y + CloudAOD.y + (1|DOY), CombTA[(CombTA$CloudCatFin.x == "IceCld"),], na.action="na.omit")
saveRDS(icecloud, "C:/Users/jhbelle/Documents/icecloudmodela.Rdata")

watcloud = lmer(LogPM.x ~ CenteredTemp.x + r_heightAboveGround.x + WindSpeed.x + cape2.x + pblh.x + Raining.x + CloudEmmisivity.x + CloudRadius.x + CloudAOD.x + (1|DOY), CombTA[(CombTA$CloudCatFin.x == "WaterCld"),], na.action="na.omit")
saveRDS(watcloud, "C:/Users/jhbelle/Documents/watercloudmodel.Rdata")

icecloud = lmer(LogPM.x ~ CenteredTemp.x + r_heightAboveGround.x + WindSpeed.x + cape2.x + pblh.x + Raining.x + CloudEmmisivity.x + CloudRadius.x + CloudAOD.x + (1|DOY), CombTA[(CombTA$CloudCatFin.x == "IceCld"),], na.action="na.omit")
saveRDS(icecloud, "C:/Users/jhbelle/Documents/icecloudmodel.Rdata")
