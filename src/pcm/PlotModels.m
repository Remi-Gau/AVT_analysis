% (C) Copyright 2020 Remi Gau
%
% plots the PCM models

clc;
clear;
close all;

[ModelType, InputType, ROIs, ConditionType, Dirs] = SetPcm();

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
