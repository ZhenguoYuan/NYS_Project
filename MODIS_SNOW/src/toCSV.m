function toCSV(inpath, filename, outpath)

import matlab.io.hdf4.*

%% Time info

year = filename(10:13);
doy = filename(14:16);

%% Lat/Lon
Lon = (-180 + 0.025) : 0.05 : (180 - 0.025);
Lat = (90 - 0.025) : -0.05 : (-90 + 0.025);
Lon = repmat(Lon, 3600, 1);
Lat = repmat(Lat', 1, 7200);


%% Read HDF
% Start HDF Process
sdID = sd.start([inpath,filename], 'read');
% Snow_Cover
Snow_Cover = readHDF(sdID, 'Day_CMG_Snow_Cover', 0);
Snow_Cover = Snow_Cover';
% Clear_Index
Clear_Index = readHDF(sdID, 'Day_CMG_Clear_Index', 0);
Clear_Index = Clear_Index';
% Cloud_Obscured
Cloud_Obscured = readHDF(sdID, 'Day_CMG_Cloud_Obscured', 0);
Cloud_Obscured = Cloud_Obscured';
% Snow_Spatial_QA
Snow_Spatial_QA = readHDF(sdID, 'Snow_Spatial_QA', 0);
Snow_Spatial_QA = Snow_Spatial_QA';
% End HDF Process
sd.close(sdID);

%% Removing missing data
Snow_Cover = double(Snow_Cover);
Snow_Cover(Snow_Cover > 100 | Snow_Cover < 0) = nan; 
Clear_Index = double(Clear_Index);
Clear_Index(Clear_Index > 100 | Clear_Index < 0) = nan; 
Cloud_Obscured = double(Cloud_Obscured);
Cloud_Obscured(Cloud_Obscured > 100 | Cloud_Obscured < 0) = nan; 

%% Write CSV

% Reshape the 2d arraies into 1d vectors
len = size(Lat, 1) * size(Lat, 2);

Lat_1d = reshape(Lat, len, 1);
Lon_1d = reshape(Lon, len, 1);
Snow_Cover_1d = reshape(Snow_Cover, len, 1);
Clear_Index_1d = reshape(Clear_Index, len, 1);
Cloud_Obscured_1d = reshape(Cloud_Obscured, len, 1);
Snow_Spatial_QA_1d = reshape(Snow_Spatial_QA, len, 1);

% Cutting the data by lat/lon ranges
idx = (Lat_1d >= 39) & (Lat_1d <= 47) & (Lon_1d >= -82) & (Lon_1d <= -70);
Lat_1d = Lat_1d(idx);
Lon_1d = Lon_1d(idx);
Snow_Cover_1d = Snow_Cover_1d(idx);
Clear_Index_1d = Clear_Index_1d(idx);
Cloud_Obscured_1d = Cloud_Obscured_1d(idx);
Snow_Spatial_QA_1d = Snow_Spatial_QA_1d(idx);

% Create data table
dat = table(Lat_1d, Lon_1d, Snow_Cover_1d, Clear_Index_1d, Cloud_Obscured_1d, Snow_Spatial_QA_1d, ...
    'VariableNames', {'Lat', 'Lon', 'Snow_Cover', 'Clear_Index', 'Cloud_Obscured', 'Snow_Spatial_QA'});

% Output file name
csvname = [year, doy, '_MODIS_Snow.csv'];

% Write into a csv file
writetable(dat, [outpath, '/', csvname], 'Delimiter', ',', 'QuoteStrings', true);

end