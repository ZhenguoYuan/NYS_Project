%----------------------------
% MODIS Cloud HDF to CSV
%
% Jianzhao Bi
% 9/19/2017
%----------------------------

clear
clc

addpath('src/');
addpath('../src/');

p = parpool(12);

path = '/home/jbi6/terra/MODIS_Cloud/MOD06_L2/';

parfor year = 2002 : 2016
    
    exeMain(path, year);
    
end

delete(p)