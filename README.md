
# New York State PM2.5 Modeling Project

## Supporting Codes

### src
* **latlon.R**
	* Running this first (for some program, e.g. MAIAC_GRID)
	* This is the ranges of lat/lon
* **fun.R**
	* This includes functions used in all programs
* **readHDF.m**
	* Reading HDF4 in MATLAB

### MAIAC_GRID
* Creating a reference lat/lon grid for the whole project using MAIAC grid
* Main: `maiac_grid.R`
* Input: `input/NA_LatLon.csv` (This should be produced manually)
* Output: `output/maiac_grid.csv` (This grid file is used in all subsequent programs; this is the standard grid file)
* Run: running directly (Mac/Windows)

## Data Preparation
### MAIAC_AOD
#### main_AOD_CSV.m
* Converting original MAIAC HDF (HDF4) files to CSV files
* Input: `/aura/MAIAC_NA/`
* Output: `/home/jbi6/aura/NYS_MAIAC_CSV/`
* Run: `qsub script_csv` (Linux)
#### maiac.script.R
* Producing daily MAIAC AOD CSV files in standard grid (IDW Interp)
* Input: `/home/jbi6/aura/NYS_MAIAC_CSV/`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/MAIAC_AOD/`
* Run: `bash submit.sh` (rely on `qsub_script.pbs`) (Linux)
* Notice: the jobs are assigned as `year * AOD_type * cluster_num`

### NARR
* Producing daily NARR weather RData files from NARR monolevel NC files
* Main: `narr.R`
* Input: `/home/jbi6/terra/NARR_ORI/`
* Output
	* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/NARR/`
	* Organization: `yyyy/varname/yyyyddd_varname.RData`
* Run: `bash submit.sh` (Linux)

### MODIS_CLOUD (MOD06/MYD06)
#### mainCSV.m
* Converting original MODIS HDF (HDF4) files into CSV files
* Input: `/home/jbi6/terra/MODIS_Cloud/.../hdf/`
* Output: `/home/jbi6/terra/MODIS_Cloud/.../csv/`
* Run: `qsub script_csv.pbs` (Linux)
#### modis.script.R
* Producing daily MODIS Cloud CSV files in standard grid (IDW Interp)
* Input: `/home/jbi6/terra/MODIS_Cloud/.../csv/`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/MODIS_Cloud/`
* Run: `bash submit.sh` (rely on `qsub_script.pbs`) (Linux)
* Notice: the jobs are assigned as `year * cluster_num`

### ASTER_GDEM
* Generating DEM file (CSV format) for the research domain
* Main: `main.R`
* Input: `/home/jbi6/aura/NYS_DEM/`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/ASTER_GDEM/`
* Run: `qsub qsub_script`

### MODIS_SNOW (MOD10/MYD10)
#### Snow Testing
* Testing the pattern of snow in NYS
* Main: `snow.m`
* Input: 
	* Local: `test_data/`
* Output
	* Local: `img/` (image files)
	* Local: `video/` (animation)
#### mainCSV
* Converting original MODIS HDF (HDF4) files into CSV files
* Input: `/home/jbi6/aura/MODIS_SNOW_ORI/.../hdf/`
* Output: `/home/jbi6/aura/MODIS_SNOW_ORI/.../csv/`
* Run: `qsub script_csv.pbs` (Linux)
#### Modis.script.R
* Producing daily MODIS Snow CSV files in standard grid (IDW Interp)
* Input: `/home/jbi6/aura/MODIS_SNOW_ORI/.../csv/`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/MODIS_Snow/`
* Run: `bash submit.sh` (rely on `qsub_script.pbs`) (Linux)
* Notice: the jobs are assigned as `year * cluster_num`

### AERONET
* Generating a list of AERONET AOT observations (470/550) from difference AERONET site
* Main: `main.R`
* Input: 
	* Local: `input/`
* Output
	* Local: `output/`
	* Cluster: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/AERONET/`
* Run: in local folder (not cluster), run `main.R`
* Notice: `site_info.csv` should be manually made and checked before running `main.R`. This CSV file includes the information (i.e. lat/lon, band info, and site name) of each AERONET site, which have the same sequence as the sequence of LEV20 file names in R.

### PM25
* Generating a list of PM2.5 ground measurements from ground sites
* Main: `main.R`
* Input
	* EPA AQS (local): `data/AQS/`
	* NAPS (local): `data/NAPS/`
* Output
	* Local: `output/`
	* Cluster: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/PM25/`
* Run: in local folder (not cluster), run `main.R`

### POP
#### readnc.m
* Converting the input nc files into csv files (since there is no `ncdf4` package in cluster)
* Main: `readnc.m`
* Input: `/home/jbi6/terra/POP_ORI/nc/`
* Output: `/home/jbi6/terra/POP_ORI/`
* Run: `qsub script_readnc` (Linux)
#### pop.R
* Generating the LandScan population data
* Main: `pop.R`
* Input: `/home/jbi6/terra/POP_ORI/`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/POP/`
* Run: `bash submit.sh` (Linux)
#### pop_plot.R
* Plotting the population distribution and checking the population amount
* Input: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/POP/`

### NLDAS 
#### ReorgGRB.sh
* Reorganizing the NLDAS files and folders which are downloaded from GES DISC
* Location: `/home/jbi6/aura/NLDAS_ORI/`
#### ConvNC.sh
* Converting the original `*.grb` files into `*.nc` files
	* the bash codes are from Jess, which depends on `/home/jhbelle/.profile`
* Location: `/home/jbi6/aura/NLDAS_ORI/`
#### CountNum.sh
* Counting how many files are in each folder of NLDAS data
* Location: `/home/jbi6/aura/NLDAS_ORI/`
#### Download_scripts
* Scripts used to download NLDAS `*.grb` files from GES DISC
* Location: `/home/jbi6/aura/NLDAS_ORI/download_scripts/`
#### nldas.R
* Generating NLDAS meteorological data
* Main: `nldas.R`
* Input: `/home/jbi6/aura/NLDAS_ORI/data/`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/NLDAS/`
* Run: `bash submit.sh` (Linux)

### GLOBCOVER
* Calculating the mode of GRIDCODE for each grid and generating landuse data (csv)
* Main: `globcover.R`
* Input: `/home/jbi6/terra/GLOBCOVER_ORI/grid_land.csv`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/GLOBCOVER/globcover.csv`
* Run: `bash submit.sh` (Linux)

### NDVI
* Converting the original NDVI files (from Keyong Huang) to daily NDVI data within the MAIAC grid
* Main: `ndvi.R`
* Input: `/home/jbi6/terra/NDVI_ORI`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/NDVI/`
* Run: `bash submit.sh` (Linux)

### Combine
* Combining all parameters into a single (daily) csv file
* Main: `combine.R`
* Input: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine/yyyy/`
* Run: `bash submit.sh`

## AOD Gap-Filling
### MI
* Conduct the multiple imputation
### RF
#### rf.R
* Gap-filling AOD missing values by random forest
* Input: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine`
	* `YYYYDOY_combine.RData`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF`
	* aqua550 & terra550
	* `YYYYDOY_RF.RData`
	* `YYYYDOY_RF_MODELPERF.RData` (Model Performace: including rsq, mse, and variable importance measures)
* Run: `bash submit.sh`

#### push_time.sh
* Automatic submitting a new year's RF Gap-filling when last year's modeling is done
* Run: `bash push_time.sh` -> calling `submit_time.sh $year`

#### rf_testing.R
* Testing if the fitting ability of RF decreases as choosing less sample size, in order to choose a suitable sample size to speed up the RF fitting
* The sample sizes tested are 10000, 30000, 50000, and 100000. The prediction results from these sample sizes will be compared to which with complete sample
* Input: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine`
	* `YYYYDOY_combine.RData`
* Output: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF_TEST`
	* `DOY_SampleSize_TEST_RF.RData`
	* Each output is a result predicted by a certain sample size
* Run: `bash submit_test.sh`

#### rf_testing_plot.R
* To compare the prediction results from the fitting use different sample size (comparison standard is correlation r)
* Input: 
	* Cluster: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF_TEST`
		* `DOY_SampleSize_TEST_RF.RData`
	* Local: `testdata/`
		* `DOY_SampleSize_TEST_RF.RData`
* Output
	* correlation coefficients – R
	* Scatter plots
* Run: in local folder (not cluster), run `rf_testing_plot.R`

## PM2.5 Modeling
### Random Forest
#### RF_Modeling.R
* PM2.5 modeling using random forest
* Input
	* Gap-filled AOD: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/`
	* Combined data: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine/`
* Output
	* Combining gap-filled AOD and other parameters
		* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_FIT_RFMODEL/YYYY/`
		* `YYYY_COMBINE_RF.RData`
	* Random Forest model which will be used to predict PM2.5
		* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_FIT_RFMODEL/YYYY/`
		* `YYYY_RFMODEL_RF.RData`
	* The fitting results and CV results of RF model
		* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_FIT_RFMODEL/YYYY/`
		* `YYYY_RFModel.txt`
* Run: `bash submit_rf_model.sh` (Linux)

#### RF_Pred.R
* PM2.5 prediction using random forest
* Input
	* Gap-filled AOD: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/`
	* Combined data: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Combine/`
	* RF model
		* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_FIT_RFMODEL/YYYY/`
		* `YYYY_RFMODEL_RF.RData`
* Output
	* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_PRED_RFMODEL/YYYY/`
* Run: `bash submit_rf_pred.sh` (Linux)

## Validations
### AERONET
* Comparing gap-filled AOD (RF and MI) with AERONET AOD
* Main: `Combine4AERO.R`
	* Combining MI and RF daily results into single files with available AERONET AOD
	* Input
		* MI: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/MI/`
		* RF: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/`
	* Output
		* MI
			* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/AERONET/`
			* `mi_combine_aero.RData`
		* RF
			* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/AERONET/`
			* `rf_combine_aero.RData`
		* Run: `bash submit.sh` (Linux)

### PLOT2D
#### Combine4PLOT_AOD.R
* Combining MI and RF daily results to annual AOD averages
* Input
	* MI: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/MI/`
	* RF: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/RF/`
* Output
	* MI
		* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/PLOT2D/PLOTAOD/`
		* `mi_combine_plot.RData`
	* RF
			* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/PLOT2D/PLOTAOD/`
			* `xaotddd_combine_[ccc].RData` (X is AOT type; DDD is wavelength; CCC is original or gap-filled)
* Run: `bash submit_AOD.sh` (Linux)

#### plot2daod.R
* Plotting spatial distributions of overall, original, and gap-filled AOD; Do the summary statistics of original and gap-filled AOD
* Input: `data/PLOTAOD/`
	* `aaot550_combine.RData`
	* `aaot550_combine_ori.RData`
	* `aaot550_combine_gap.RData`
	* `taot550_combine.RData`
	* `taot550_combine_ori.RData`
	* `taot550_combine_gap.RData`
* Output: screen
* Run: in local folder, run `plot2daod.R`

#### Combine4PLOT_PM25.R
* Combining daily PM2.5 predictions into an annual average and 4 seasons’ averages 
* Input: `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Modeling/PM25_PRED_RFMODEL/YYYY/`
* Output
	* `/home/jbi6/terra/MAIAC_GRID_OUTPUT/Validations/PLOT2D/PLOTPM25/YYYY/`
		* `pm25_combine_plot.RData`
		* `pm25_combine_plot_spring.RData`
		* `pm25_combine_plot_summer.RData`
		* `pm25_combine_plot_fall.RData`
		* `pm25_combine_plot_winter.RData`
* Run: `bash submit_PM25.sh` (Linux)

#### plot2dpm25.R
* Plotting spatial distributions of gap-filled AOD (RF and MI) and modeled PM2.5 
* Input
	* AOD (copy to local)
		* `data/PLOTAOD/mi_combine_plot.RData`
		* `data/PLOTAOD/rf_combine_plot.RData` 
	* PM2.5 (copy to local)
		* `data/PLOTPM25/pm25_combine_plot.RData`
		* `data/PLOTPM25/pm25_combine_plot_spring.RData`
		* `data/PLOTPM25/pm25_combine_plot_summer.RData`
		* `data/PLOTPM25/pm25_combine_plot_fall.RData`
		* `data/PLOTPM25/pm25_combine_plot_winter.RData`













	
> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTYyMDczMjc4MCwyMDU3MjU5NDQ2XX0=
-->