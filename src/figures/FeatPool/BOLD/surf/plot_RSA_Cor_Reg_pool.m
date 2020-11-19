close all;
clear;
clc;

% ToPlot={'Cst','Lin','Quad'};
ToPlot = {'Cst', 'Lin'};

StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
Get_dependencies('/home/rxg243/Dropbox/');

RSA_dir = fullfile(StartDir, 'figures', 'RSA');
mkdir(RSA_dir, 'Cdt');
mkdir(fullfile(RSA_dir, 'Cdt', 'Subjects'));
mkdir(RSA_dir, 'Sens');
mkdir(fullfile(RSA_dir, 'Sens', 'Subjects'));
mkdir(RSA_dir, 'Side');
mkdir(fullfile(RSA_dir, 'Side', 'Subjects'));
Reg_dir = fullfile(StartDir, 'figures', 'Regression');
mkdir(Reg_dir, 'Cdt');
mkdir(fullfile(Reg_dir, 'Cdt', 'Subjects'));
mkdir(Reg_dir, 'Sens');
mkdir(fullfile(Reg_dir, 'Sens', 'Subjects'));
mkdir(Reg_dir, 'Side');
mkdir(fullfile(Reg_dir, 'Side', 'Subjects'));
Cor_dir = fullfile(StartDir, 'figures', 'Correlation');
mkdir(Cor_dir, 'Cdt');
mkdir(fullfile(Cor_dir, 'Cdt', 'Subjects'));
mkdir(Cor_dir, 'Sens');
mkdir(fullfile(Cor_dir, 'Sens', 'Subjects'));
mkdir(Cor_dir, 'Side');
mkdir(fullfile(Cor_dir, 'Side', 'Subjects'));

cd (StartDir);
SubLs = dir('sub*');

for ranktrans = 0:1
  for isplotranktrans = 0:1
    plot_RSA_Cor_Reg_surf_pool_hs(StartDir, SubLs, ToPlot, ranktrans, isplotranktrans);
  end
end
