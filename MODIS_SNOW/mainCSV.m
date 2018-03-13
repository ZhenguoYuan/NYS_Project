%----------------------------
% MODIS Snow Cover HDF to CSV
%
% Jianzhao Bi
% 10/26/2017
%----------------------------

clear
clc

addpath('src/');
addpath('../src/');

p = parpool(12);

path1 = '/home/jbi6/aura/MODIS_SNOW_ORI/MOD10C1/data/'; % Terra
path2 = '/home/jbi6/aura/MODIS_SNOW_ORI/MYD10C1/data/'; % Aqua


parfor year = 2002 : 2016
    
    exeMain(path1, year);
    exeMain(path2, year);
    
end

delete(p)