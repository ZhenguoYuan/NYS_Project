function toCSV(inpath, filename, outpath)

import matlab.io.hdf4.*

%% Time info

year = filename(11:14);
doy = filename(15:17);
hour = filename(19:20);
min = filename(21:22);

%% Read HDF
% Start HDF Process
sdID = sd.start([inpath,filename], 'read');
% Latitude
Lat = readHDF(sdID, 'Latitude', 0);
% Longitude
Lon = readHDF(sdID, 'Longitude', 0);
% Cloud Fraction Day
Cloud_Frac = readHDF(sdID, 'Cloud_Fraction', 1);
% Cloud Fraction Day
Cloud_Frac_Day = readHDF(sdID, 'Cloud_Fraction_Day', 1);
% End HDF Process
sd.close(sdID);

%% Write CSV

% Reshape the 2d arraies into 1d vectors
len = size(Lat, 1) * size(Lat, 2);

Lat_1d = reshape(Lat, len, 1);
Lon_1d = reshape(Lon, len, 1);
Cloud_Frac_1d = reshape(Cloud_Frac, len, 1);
Cloud_Frac_Day_1d = reshape(Cloud_Frac_Day, len, 1);

% Create data table
dat = table(Lat_1d, Lon_1d, Cloud_Frac_1d, Cloud_Frac_Day_1d,...
    'VariableNames', {'Lat', 'Lon', 'Cloud_Frac', 'Cloud_Frac_Day'});

% Output file name
csvname = [year, doy, '_', hour, min, '_MODIS_Cloud.csv'];

% Write into a csv file
writetable(dat, [outpath, '/', csvname], 'Delimiter', ',', 'QuoteStrings', true);

end