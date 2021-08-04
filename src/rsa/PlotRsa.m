% (C) Copyright 2021 Remi Gau
%
%  Plots the empirical G matrix

clc;
clear;
close all;

%% Main parameters

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
        'V1'
        'V2'
        'A1'
        'PT'
       };

Opt = SetRasterPlotParameters();
ColorMap = Opt.Raster.ColorMap;

Opt.CombineHemisphere = true;

%% Other parameters

ConditionType = 'stim';
if Opt.Targets
    ConditionType = 'target'; %#ok<*UNRCH>
end

Space = 'surf';
MVNN = true;
Dirs = SetDir(Space, MVNN);

InputDir = fullfile(Dirs.PCM, ModelType);

FigureDir = fullfile(InputDir, 'figures', 'empirical_G_matrices');

for iROI = 1:numel(ROIs)

    for iAnalysis = 1:numel(Analysis)

        filename = ['pcm_results', ...
                    '_roi-', ROIs{iROI}, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '.mat'];

        if Opt.PerformDeconvolution
            filename = strrep(filename, '.mat', '_deconvolved-1.mat');
        end

        if strcmp(ModelType, 'subset6X6')
            filename = ['group_' filename];
        end

        filename = fullfile(InputDir, filename);

        fprintf(1, 'loading:\n %s\n', filename);
        load(filename, 'Models', 'G_hat', 'G_pred_grp', 'G_pred_cr');

        %% Plot G matrices
        FigureFilename = ['empirical_G_matrix', ...
                          '_roi-', ROIs{iROI}, ...
                          '_cdt-', ConditionType, ...
                          '_param-', lower(InputType), ...
                          '_analysis-', Analysis(iAnalysis).name];

        Opt.Title = strrep(FigureFilename, '_', ' ');

        Opt = OpenFigure(Opt);

    end
end
