%--------------------------
% HDF to CSV
%
% Jianzhao Bi
% 3/4/2018
%--------------------------
% Convert HDF files to CSV files

clear
clc

p = parpool(5);

%% Load src files

addpath('src');

%% Parameters

inpath_main = '/home/jbi6/aura/NorthAmerica_2000-2016/';
outpath_main = '/home/jbi6/aura/NYS_MAIAC_CSV_Validation/';

types = {{'AAOT', 'h04v03'}, {'TAOT', 'h04v03'}, {'AAOT', 'h04v04'}, {'TAOT', 'h04v04'}};

LatRange = [40.1, 45.6];
LonRange = [-80.5, -71];

year = 2015;

%% RUN

parfor type_i = 1 : 4
    
    % Parameters
    inpath = [inpath_main, types{type_i}{2}, '/'];
    outpath = [outpath_main, types{type_i}{2}, '/'];
    latlon_hdf = [inpath_main, 'MAIACLatlon.', types{type_i}{2},'.hdf'];
    
    % HDF to CSV
    HDFtoCSV(inpath,...
        outpath,...
        latlon_hdf,...
        types{type_i}{1}, ...
        year, ...
        LatRange, ...
        LonRange);
end


delete(p);