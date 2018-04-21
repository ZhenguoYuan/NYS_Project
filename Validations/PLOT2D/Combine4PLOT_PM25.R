setwd('/home/jbi6/NYS_Project/Validations/PLOT2D/')

source('../../src/fun.R')
source('src/fun.R')


# Arguments for R script
Args <- commandArgs()
# Year
year <- Args[6] # 6th argument is the first custom argument
# DOY
numdays <- numOfYear(as.numeric(year))
# Paths
inpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_PRED_RFMODEL', as.character(year))
outpath <- file.path('/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/PLOT2D/PLOTPM25', as.character(year))
if (!file.exists(outpath)){
  dir.create(outpath, recursive = T)
}

## ---------- Combining ---------- ##
pm25_combine_plot <- combine4pm25(c(1 : numdays), year, inpath) # All year
pm25_combine_plot_snow <- combine4pm25(c(1 : 105), year, inpath) # Snow Season
pm25_combine_plot_spring <- combine4pm25(c(61 : 152), year, inpath) # Spring
pm25_combine_plot_summer <- combine4pm25(c(153 : 244), year, inpath) # Summer
pm25_combine_plot_fall <- combine4pm25(c(245 : 336), year, inpath) # Fall
pm25_combine_plot_winter <- combine4pm25(c(c(1 : 60), c(337 : numdays)), year, inpath) # Winter
  
## ---------- Output ---------- ##
save(pm25_combine_plot, file = file.path(outpath, 'pm25_combine_plot.RData'))
save(pm25_combine_plot_snow, file = file.path(outpath, 'pm25_combine_plot_snow.RData'))
save(pm25_combine_plot_spring, file = file.path(outpath, 'pm25_combine_plot_spring.RData'))
save(pm25_combine_plot_summer, file = file.path(outpath, 'pm25_combine_plot_summer.RData'))
save(pm25_combine_plot_fall, file = file.path(outpath, 'pm25_combine_plot_fall.RData'))
save(pm25_combine_plot_winter, file = file.path(outpath, 'pm25_combine_plot_winter.RData'))
