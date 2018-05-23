%--------------------------
% HDF to CSV
%
% Jianzhao Bi
% 9/20/2017
%--------------------------
% Convert HDF files to CSV files

clear
clc

p = parpool(12);

%% Load src files

addpath('../../Public/MATLAB/src/');
addpath('../../Lima_Project/MAIAC/src/');

%% Parameters

inpath_main = '/aura/MAIAC_NA/';
outpath_main = '/home/jbi6/aura/NYS_MAIAC_CSV/';

aerotype = {'AAOT', 'TAOT'};
tiles = {'h04v03', 'h04v04'};

LatRange = [40.1, 45.6];
LonRange = [-80.5, -71];

%% RUN

parfor year_i = 2002 : 2005
    for tile_j = 1 : 2 % Tiles
        for type_k = 1 : 2 % Aerosol Type (AAOT & TAOT)
            
            % Parameters
            inpath = [inpath_main, tiles{tile_j}, '/'];
            outpath = [outpath_main, tiles{tile_j}, '/'];
            latlon_hdf = [inpath_main, 'MAIACLatlon.', tiles{tile_j},'.hdf'];
            
            % HDF to CSV
            HDFtoCSV(inpath,...
                outpath,...
                latlon_hdf,...
                aerotype{type_k}, ...
                year_i, ...
                LatRange, ...
                LonRange);
        end
    end
end


delete(p);