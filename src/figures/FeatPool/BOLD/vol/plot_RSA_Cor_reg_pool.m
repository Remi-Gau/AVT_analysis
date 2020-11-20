close all;
clear;
clc;

StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
Get_dependencies('/home/rxg243/Dropbox/');

cd (StartDir);
SubLs = dir('sub*');

addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

for beta_type = 0:2
    for ranktrans = 0:1
        for isplotranktrans = 0:1
            plot_RSA_Maha_Cor_Reg_vol_pool_hs(StartDir, SubLs, beta_type, ranktrans, isplotranktrans);
        end
    end
end
