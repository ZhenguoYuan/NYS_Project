clear
clc

% Paths
inpath = '/home/jbi6/terra/POP/nc/';
outpath = '/home/jbi6/terra/POP/';
if ~exist(outpath, 'dir')
    eval(['mkdir ', outpath]);
end

% For each year
for i = 2002 : 2016
    
    year = num2str(i);
    
    % Load parameters
    lat_old = ncread([inpath, 'lspop', year, '.nc'], 'lat');
    lon_old = ncread([inpath, 'lspop', year, '.nc'], 'lon');
    pop_old = ncread([inpath, 'lspop', year, '.nc'], ['lspop', year]);
    pop = pop_old';
    
    if i <= 2004
        pop(pop == 65535) = 0;
    else
        pop(pop < 0) = 0;
    end
    
    % Reshape parameters
    lat = repmat(lat_old, 1, size(lon_old, 1));
    lon = repmat(lon_old, 1, size(lat_old, 1));
    lon = lon';
    
    lat = reshape(lat, size(lat, 1)*size(lat, 2), 1);
    lon = reshape(lon, size(lon, 1)*size(lon, 2), 1);
    pop = reshape(pop, size(pop, 1)*size(pop, 2), 1);
    
    % Output data as a csv file
    dat = table(lon, lat, pop);
    
    writetable(dat, [outpath, 'lspop', year, '.csv']);
    
    disp([outpath, 'lspop', year, '.csv']);
    
end

% pcolor(lon, lat, pop);
% shading flat