function exeMain(path, year)

% I/O paths
inputpath = [path, num2str(year), '/hdf/'];
outputpath = [path, num2str(year), '/csv/'];

% Check if output folder exists
if ~exist(outputpath,'dir')
    eval(['mkdir ',outputpath]);
end

% Search the HDF files
flists=dir([inputpath, '*.hdf']);
fnums=length(flists);

% Convert HDF to CSV
for fi=1:fnums
    filename = flists(fi).name;
    toCSV(inputpath, filename, outputpath);
    disp([num2str(year), ': ', filename]);
end

end