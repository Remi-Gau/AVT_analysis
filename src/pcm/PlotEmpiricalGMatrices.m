% (C) Copyright 2020 Remi Gau
%
%  Plots the empirical G matrix

clc;
clear;
close all;

%% Main parameters

ModelType = '6X6';

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

PlotSubject = false;

% This needs to be adapted or even saved with the PCM results
[~, CondNames] = GetConditionList();
switch lower(ModelType)
    case '3x3'

        %% Analysis name condition to use for it

        Analysis(1).name = 'Ipsi';
        Analysis(1).CdtToSelect = 1:2:5;
        Analysis(1).CondNames = CondNames(1:2:5);

        Analysis(2).name = 'Contra';
        Analysis(2).CdtToSelect = 2:2:6;
        Analysis(2).CondNames = CondNames(2:2:6);

        Analysis(3).name = 'ContraIpsi';
        Analysis(3).CondNames = {'A', 'V', 'T'};

    case '6x6'

        Analysis(1).name = 'AllConditions';
        Analysis(1).CdtToSelect = 1:6;
        Analysis(1).CondNames = CondNames(1:6);

end

FigDim = [50, 50, 750, 750];
FONTSIZE = 12;

ColorMap = SeismicColourMap(1000);
% ColorMap = BrainColourMaps('hot_increasing');

%% Other parameters
% Unlikely to change

IsTarget = false;

Space = 'surf';

%% Will not change

MVNN = true;

ConditionType = 'stim';
if IsTarget
    ConditionType = 'target';
end

Dirs = SetDir(Space, MVNN);

InputDir = fullfile(Dirs.PCM, ModelType);

FigureDir = fullfile(InputDir, 'figures');
mkdir(FigureDir);

for iROI = 1:numel(ROIs)

    for iAnalysis = 1:numel(Analysis)

        filename = ['pcm_results', ...
                    '_roi-', ROIs{iROI}, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '.mat'];
        filename = fullfile(InputDir, filename);

        disp(filename);
        load(filename, 'Models', 'G_hat', 'G_pred_grp', 'G_pred_cr');

        %% Plot G matrices
        FigureFilename = ['empirical_G_matrix', ...
                          '_roi-', ROIs{iROI}, ...
                          '_cdt-', ConditionType, ...
                          '_param-', lower(InputType), ...
                          '_analysis-', Analysis(iAnalysis).name];

        figure( ...
               'name', strrep(FigureFilename, '_', ' '), ...
               'Position', FigDim);

        SetFigureDefaults();

        Title = strrep(FigureFilename, '_', ' ');

        PlotGMatrixAndSetAxis(mean(G_hat, 3), Analysis(iAnalysis).CondNames, Title, FONTSIZE, false);

        NewColorMap = NonCenteredDivergingColourmap(mean(G_hat, 3), ColorMap);
        colormap(NewColorMap);

        axis square;
        axis (repmat([0.5, size(G_hat, 1) + 0.5], 1, 2));

        hold on;

        AddWhiteLines(size(G_hat, 1));

        AddBlackBorder(size(G_hat, 1));

        FigureFilename = fullfile(FigureDir, [FigureFilename '.tif']);
        disp(FigureFilename);
        print(gcf, FigureFilename, '-dtiff');

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
        plot([ThisPos, ThisPos] + 0.51, [0.51 Width + 0.51], 'color', COLOR, 'linewidth', LINE_WIDTH);
        plot([0.51 Width + 0.51], [ThisPos ThisPos] + 0.51,  'color', COLOR, 'linewidth', LINE_WIDTH);
    end

end
