% (C) Copyright 2020 Remi Gau
%
% plots the PCM models

clc;
clear;
close all;

% '3X3', '6X6', 'subset6X6'
ModelType = 'subset6X6';

Space = 'surf';

MVNN = true;

Dirs = SetDir(Space, MVNN);

IsAuditoryRoi = true;
[~, Models] = BuildModels(ModelType, IsAuditoryRoi);

FigureDir = fullfile(Dirs.PCM, ModelType, 'figures', 'models');
spm_mkdir(FigureDir);

fig_h = PlotPcmModels(Models);

for iFig = 1:numel(fig_h)

    FigureName = ['Model-' num2str(iFig), '-' fig_h(iFig).Name '.tif'];
    FigureName = strrep(FigureName, ',', '');

    figure(fig_h(iFig));
    PrintFigure(FigureDir);

end
