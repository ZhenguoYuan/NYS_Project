# #with CMAQ/GEOS-Chem AOD
# MI<-function(dat){
#   tryCatch(aregImpute(~AOT550 + Y_Lat + X_Lon+I(aod)+X2+Y2+XY+I(CF)+I(Air_Temp_PBLH)+I(RH_PBLH)+I(Specific_humidity_PBLH)+I(di)+I(Elev),
#                       type='regression',n.impute=5, nk=10, curtail=F,tlinear=T,data=dat),
#            error=function(e) {print('remove di');aregImpute(~AOT550 + Y_Lat + X_Lon+I(aod)+X2+Y2+XY+I(CF)+I(Air_Temp_PBLH)+I(RH_PBLH)+
#                                                               I(Specific_humidity_PBLH)+I(Elev),
#                                                             type='regression',n.impute=5, nk=10, curtail=F,tlinear=T,data=dat)}
#   )
#   
# }

# #Without CMAQ/GEOS-Chem AOD
# MI<-function(dat){
#   tryCatch(aregImpute(~AOT550 + Y_Lat + X_Lon+X2+Y2+XY+I(CF)+I(Air_Temp_PBLH)+I(RH_PBLH)+I(Specific_humidity_PBLH)+I(di)+I(Elev),
#                       type='regression',n.impute=5, nk=10, curtail=F,tlinear=T,data=dat),
#            error=function(e) {print('remove di');aregImpute(~AOT550 + Y_Lat + X_Lon+X2+Y2+XY+I(CF)+I(Air_Temp_PBLH)+I(RH_PBLH)+
#                                                               I(Specific_humidity_PBLH)+I(Elev),
#                                                             type='regression',n.impute=5, nk=10, curtail=F,tlinear=T,data=dat)}
#   )
#   
# }

MI<-function(dat){
  
  tryCatch(
    aregImpute(~AOT550 + Y_Lat + X_Lon + X2 + Y2 + XY + I(CF) + I(temp_2m_NLDAS) + I(RH_3h_NARR) + I(spec_humi_2m_NLDAS) + I(total_prec_NLDAS) + I(DEM) + I(di),
               type='regression', n.impute=5, nk=10, curtail=F, tlinear=T, data=dat),
    error = function(e) {
      print('remove di'); aregImpute(~AOT550 + Y_Lat + X_Lon + X2 + Y2 + XY + I(CF) + I(temp_2m_NLDAS) + I(RH_3h_NARR) + I(spec_humi_2m_NLDAS) + I(total_prec_NLDAS) + I(DEM),
                                     type='regression', n.impute=5, nk=10, curtail=F, tlinear=T, data=dat)
    }
  )
  
}


dat.create <- function(dir, file, varname.lst, i){
  
  if (i==1){
    dat1<-c()
    dat2<-c()
  } else if (i==2){
    dat1<-c()
    #dat2<-read.csv(paste(dir,file[1],sep=''),header=T,as.is=T)
    load(paste(dir,file[1],sep=''))
    dat2 <- combine
    dat2<-dat2[!is.na(unlist(with(dat2, mget(varname.lst$AOD)))),]
    if (nrow(dat2)>0) {dat2$di<-2}
  } else {
    #dat1<-read.csv(paste(dir,file[i-2],sep=''),header=T,as.is=T)
    load(paste(dir,file[i-2],sep=''))
    dat1 <- combine
    dat1<-dat1[!is.na(unlist(with(dat1, mget(varname.lst$AOD)))),]
    if (nrow(dat1)>0) {dat1$di<-1}
    #dat2<-read.csv(paste(dir,file[i-1],sep=''),header=T,as.is=T)
    load(paste(dir,file[i-1],sep=''))
    dat2 <- combine
    dat2<-dat2[!is.na(unlist(with(dat2, mget(varname.lst$AOD)))),]
    if (nrow(dat2)>0) {dat2$di<-2}
  }
  #dat3<-read.csv(paste(dir,file[i],sep=''),header=T,as.is=T)
  load(paste(dir,file[i],sep=''))
  dat3 <- combine
  if (nrow(dat3)>0) {dat3$di<-3}
  if (i==(length(file)-1)){
    #dat4<-read.csv(paste(dir,file[i+1],sep=''),header=T,as.is=T)
    load(paste(dir,file[i+1],sep=''))
    dat4 <- combine
    dat4<-dat4[!is.na(unlist(with(dat4, mget(varname.lst$AOD)))),]
    if (nrow(dat4)>0) {dat4$di<-4}
    dat5<-c()
  } else if (i==length(file)){
    dat4<-c()
    dat5<-c()
  } else {
    #dat4<-read.csv(paste(dir,file[i+1],sep=''),header=T,as.is=T)
    load(paste(dir,file[i+1],sep=''))
    dat4 <- combine
    dat4<-dat4[!is.na(unlist(with(dat4, mget(varname.lst$AOD)))),]
    if (nrow(dat4)>0) {dat4$di<-4}
    #dat5<-read.csv(paste(dir,file[i+2],sep=''),header=T,as.is=T)
    load(paste(dir,file[i+2],sep=''))
    dat5 <- combine
    dat5<-dat5[!is.na(unlist(with(dat5, mget(varname.lst$AOD)))),]
    if (nrow(dat5)>0) {dat5$di<-5}
  }
  
  dat<-rbind(dat1, dat2, dat3, dat4, dat5)
  dat<-dat[!is.na(dat$DEM),]
  #dat<-merge(dat,elev,by='GridID')
  
  ## AOT550
  AOT550 <- unlist(with(dat, mget(varname.lst$AOD)))
  AOT550[AOT550<(-0.1)]<-(-0.1)
  AOT550[AOT550>5]<- 5
  dat$AOT550 <- AOT550
  
  dat$X2<-dat$X_Lon^2
  dat$Y2<-dat$Y_Lat^2
  dat$XY<-dat$X_Lon*dat$Y_Lat
  dat$di<-factor(dat$di)
  dat$CF <- unlist(with(dat, mget(varname.lst$CF)))
  dat$Snow <- unlist(with(dat, mget(varname.lst$Snow)))
  
  dat.lst <- list(dat = dat, dat3 = dat3)
  
  return(dat.lst)
  
}

do.MI <- function(dat.lst, varname.lst, r2.all){
  
  dat <- dat.lst$dat
  dat3 <- dat.lst$dat3
  dat3$AOT550 <- unlist(with(dat3, mget(varname.lst$AOD)))
  
  fit <- MI(dat)
  r2.all$R2[i] <- fit$rsq
  
  a.tmp<-data.frame(fit$imputed$AOT550)
  a.tmp[a.tmp<(-0.1)]<-(-0.1)
  a.tmp[a.tmp>5]<-5
  
  b.tmp<-dat[is.na(dat$AOT550),]
  c.tmp<-dat3[!is.na(dat3$AOT550),]
  c.tmp<-subset(c.tmp,select=c(year,doy,ID,AOT550))
  result<-cbind(a.tmp, subset(b.tmp,select=c(year,doy,ID)))
  colnames(result)[1:5]<-c('AOT550_1','AOT550_2','AOT550_3','AOT550_4','AOT550_5')
  c.tmp$AOT550_1<-c.tmp$AOT550
  c.tmp$AOT550_2<-c.tmp$AOT550
  c.tmp$AOT550_3<-c.tmp$AOT550
  c.tmp$AOT550_4<-c.tmp$AOT550
  c.tmp$AOT550_5<-c.tmp$AOT550
  result<-rbind(result,c.tmp[,-4])
  
  # Order the result
  result <- result[order(result$ID), ]
  
  return(list(result = result, r2.all = r2.all))
  
}