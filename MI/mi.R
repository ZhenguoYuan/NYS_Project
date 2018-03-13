library(Hmisc)
library(pls)

source('src/fun.R')

inpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine/'
outpath <- '/home/jbi6/terra/MAIAC_GRID_OUTPUT/MI'
if(!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

file<-sort(list.files(inpath))
r2.all<-c()

#Varnames
varname.lst <- list(AOD = 'AOD550_TAOT', CF = 'Cloud_Frac_Day_Terra', Snow = 'Snow_Cover_Terra') # For terra 550nm

for (i in 250 : length(file)){
  
  print(file[i])
  
  dat.lst <- dat.create(inpath, file, varname.lst, i)
  result.lst <- do.MI(dat.lst, varname.lst, r2.all)
  mi.result <- result.lst$result
  r2.all <- result.lst$r2.all
  
  print(r2.all$R2[i])
  
  #write.csv(result,paste(outpath,substr(file[i],1,7),'_MI.csv',sep=''),row.names=F)
  save(mi.result, file = file.path(outpath, paste(substr(file[i], 1, 7), '_MI.RData', sep='')))
  
  gc()
}

write.csv(r2.all, file.path(outpath, 'MI_R2.csv'), row.names = F)