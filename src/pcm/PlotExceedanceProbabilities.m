% (C) Copyright 2020 Remi Gau

%
% plot the exceedance probabilities for all ROIs as a matrix
%

clc;
clear;
close all;

%% Other parameters

[ModelType, InputType, ROIs, ConditionType, Dirs] = SetPcm();

PlotSubject = 1;

InputDir = fullfile(Dirs.PCM, ModelType, 'model_comparison');
FigureDir = fullfile(Dirs.PCM, ModelType, 'figures', 'model_comparison');

Opt = SetDefaults();

NbROIs = numel(ROIs);

for iROI = 1:NbROIs

    fprintf(1, '%s\n', ROIs{iROI});

    filename = ['model_comparison', ...
                '_roi-', ROIs{iROI}, ...
                '_cdt-', ConditionType, ...
                '_param-', lower(InputType)];

    if PlotSubject
        filename = [filename '_withSubj-1'];
    end

    fprintf(1, 'loading:\n %s\n', fullfile(InputDir, [filename '.mat']));

    load(fullfile(InputDir, [filename '.mat']), ...
         'XP', 'Models_all', 'Families', 'Analysis');

    for i = 1:numel(XP)
        ExProba{i}(:, :, :, iROI) = XP{i};
    end

    clear XP;
end

CreateFigureExceedanceProba(ExProba, Families, Analysis, InputType, ModelType, FigureDir, ROIs, Dirs);
