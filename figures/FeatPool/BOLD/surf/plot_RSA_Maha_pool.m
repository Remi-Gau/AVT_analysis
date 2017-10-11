close all
clear
clc

% ToPlot={'Cst','Lin','Quad'};
ToPlot={'Cst','Lin'};


StartDir = fullfile(pwd, '..','..', '..','..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
Get_dependencies('/home/rxg243/Dropbox/')

RSA_dir = fullfile(StartDir, 'figures', 'RSA');
mkdir(RSA_dir, 'Cdt'); mkdir(fullfile(RSA_dir, 'Cdt', 'Subjects'));
mkdir(RSA_dir, 'Sens'); mkdir(fullfile(RSA_dir, 'Sens', 'Subjects'));
mkdir(RSA_dir, 'Side'); mkdir(fullfile(RSA_dir, 'Side', 'Subjects'));

cd (StartDir)
SubLs = dir('sub*');


for ranktrans=0:1
    for isplotranktrans=0:1
        plot_RSA_Mahalanobis_surf_pool_hs(StartDir, SubLs, ToPlot, ranktrans, isplotranktrans)
    end
end

