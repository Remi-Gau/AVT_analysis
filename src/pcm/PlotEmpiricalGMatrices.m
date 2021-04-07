% (C) Copyright 2020 Remi Gau
%
%  Plots the empirical G matrix

clc;
clear;
close all;

%% Main parameters

% '3X3', '6X6', 'subset6X6'
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
        'V1'
        'V2'
        'A1'
        'PT'
       };

Analysis = BuildModels(ModelType);

Opt = SetRasterPlotParameters();
ColorMap = Opt.Raster.ColorMap;

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

        PlotGMatrixAndSetAxis(mean(G_hat, 3), ...
                              Analysis(iAnalysis).CondNames, ...
                              Opt.Title, ...
                              Opt.Fontsize, ...
                              false);

        NewColorMap = NonCenteredDivergingColorMap(mean(G_hat, 3), ColorMap);
        colormap(NewColorMap);

        axis square;
        axis (repmat([0.5, size(G_hat, 1) + 0.5], 1, 2));

        hold on;

        AddWhiteLines(size(G_hat, 1));

        AddBlackBorder(size(G_hat, 1));

        PrintFigure(FigureDir);

        Clim = ComputeClimMatrix(mean(G_hat, 3), false);
        CreateFigureColorBar('Scale-G-matrix-', Clim(1), Clim(2), NewColorMap);

    end

end

function AddBlackBorder(Width)

    Width = Width + 0.5;

    LINE_WIDTH = 3;

    plot([0.5 0.5],         [0.51 Width + 0.01], 'k', 'linewidth', LINE_WIDTH);
    plot([Width Width],     [0.51 Width + 0.01], 'k', 'linewidth', LINE_WIDTH);
    plot([0.51 Width + 0.01], [0.5 0.5],         'k', 'linewidth', LINE_WIDTH);
    plot([0.51 Width + 0.01], [Width Width],     'k', 'linewidth', LINE_WIDTH);

end

function AddWhiteLines(Width)

    LINE_WIDTH = 3;
    COLOR = [.8 .8 .8];

    if Width == 3
        Pos = [1 2];
    elseif Width == 6
        Pos = [2 4];
    end

    for  i = 1:numel(Pos)
        ThisPos = Pos(i);
        plot([ThisPos, ThisPos] + 0.51, [0.51 Width + 0.51], ...
             'color', COLOR, 'linewidth', LINE_WIDTH);
        plot([0.51 Width + 0.51], [ThisPos ThisPos] + 0.51,  ...
             'color', COLOR, 'linewidth', LINE_WIDTH);
    end

end
