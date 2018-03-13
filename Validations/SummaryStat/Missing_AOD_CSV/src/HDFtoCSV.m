function HDFtoCSV(inputpath,outputpath,latlonName,aottype,year,LatRange,LonRange)

import matlab.io.hdf4.*

%% Files and datasets' names
inputpath=[inputpath,num2str(year),'/'];
outputpath=[outputpath,num2str(year),'/',aottype,'/'];
if ~exist(outputpath,'dir')
    eval(['mkdir ',outputpath]);
end

%% Process HDF files 

% Search the file list
flists=dir([inputpath,'MAIAC',aottype,'.*.hdf']);
fnums=length(flists);

for fi=1:fnums
    
    %Determine the file name
    dataName=flists(fi).name;
    
    %Read HDF files
    [AOT047,AOT055,AOT_Uncertainty,AOT_QA,RelAZ_1km,Lat,Lon,QA_Struct,Year,Doy,Hour,Minute]=loadHDF(inputpath,dataName,latlonName);
    
    %Write into a *.csv file
    saveCSV(AOT047,AOT055,AOT_Uncertainty,AOT_QA,Lat,Lon,LatRange,LonRange,QA_Struct,Year,Doy,Hour,Minute,outputpath,dataName);
    
    % Disply the progress of the program
    disp(dataName);
    
end

end
