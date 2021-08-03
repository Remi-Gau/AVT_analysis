% (C) Copyright 2020 Remi Gau

%
% plot the exceedance probabilities for all ROIs as a matrix
%

clc;
clear;
close all;

%% Main parameters

% '3X3', 'subset6X6'
ModelType = 'subset6X6';

% Choose on what type of data the analysis will be run
%
% b-parameters
%
% 'ROI'
%
% s-parameters
%
% 'Cst', 'Lin', 'Quad'
%

InputType = 'Cst';

% Region of interest:
%  possible choices: A1, PT, V1-5

ROIs = { ...
        'A1'
        'PT'
        'V1'
        'V2'
       };

%% Other parameters

MVNN = true;
Space = 'surf';

PlotSubject = 1;

Dirs = SetDir(Space, MVNN);
InputDir = fullfile(Dirs.PCM, ModelType, 'model_comparison');
FigureDir = fullfile(Dirs.PCM, ModelType, 'figures', 'model_comparison');

Opt = SetDefaults();
ConditionType = 'stim';
if Opt.Targets
    ConditionType = 'target'; %#ok<*UNRCH>
end

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

