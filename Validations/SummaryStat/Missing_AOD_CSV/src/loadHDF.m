function [AOT047,AOT055,AOT_Uncertainty,AOT_QA,RelAZ_1km,Lat,Lon,QA_Struct,Year,Doy,Hour,Minute]=loadHDF(inputpath,dataName,latlonName)

import matlab.io.hdf4.*

%Start HDF Process
sdID=sd.start([inputpath,dataName],'read');
%AOT_047
AOT047=readHDF(sdID,'Optical_Depth_047',1);
%AOT_055
AOT055=readHDF(sdID,'Optical_Depth_055',1);
%AOT Uncertainty
AOT_Uncertainty=readHDF(sdID,'AOT_Uncertainty',1);
%AOT QA
AOT_QA=readHDF(sdID,'AOT_QA',0);
%RelAX
RelAZ_5km=readHDF(sdID,'RelAZ',1);
%End HDF Process
sd.close(sdID);

% Oversample the RelAZ
One5by5=ones(5);
RelAZ_1km=kron(RelAZ_5km,One5by5);

%Start Latlon HDF Process
sdID=sd.start(latlonName,'read');
%Lat
Lat=readHDF(sdID,'lat',0);
%Lon
Lon=readHDF(sdID,'lon',0);
%End HDF Process
sd.close(sdID);

%Quality flags
QA_Struct=QualityFlags(AOT_QA);

%Date and time
Year=str2double(dataName(18:21));
Doy=str2double(dataName(22:24));
Hour=str2double(dataName(25:26));
Minute=str2double(dataName(27:28));


end