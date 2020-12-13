% (C) Copyright 2020 Remi Gau
%
%  First plots the G matrices:
%  - empirical,
%  - cross validated free model
%  - then that all the fitted of all the models

clc;
clear;
close all;

%% Main parameters

ModelType = '3X3';

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

FigDim = [50, 50, 1400, 750];
FONTSIZE = 8;

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
        FigureFilename = ['G_matrices', ...
            '_roi-', ROIs{iROI}, ...
            '_cdt-', ConditionType, ...
            '_param-', lower(InputType), ...
            '_analysis-', Analysis(iAnalysis).name];
        
        figure( ...
            'name', strrep(FigureFilename, '_', ' '), ...
            'Position', FigDim);
        
        SetFigureDefaults();
        
        colormap(ColorMap);
        
        [m, n] = OptimizeSubplotNumber(numel(Models)-1);
        
        Subplot = 1;
        
        % CVed G_{emp}
        subplot(m, n, Subplot);
        
        PlotGMatrixAndSetAxis(mean(G_hat, 3), Analysis(iAnalysis).CondNames, 'G_{emp} CV', FONTSIZE);
        
        Subplot = Subplot + 1;
        
        % CVed G_{pred} free model
        subplot(m, n, Subplot);
        
        PlotGMatrixAndSetAxis(mean(G_pred_cr{end}, 3), Analysis(iAnalysis).CondNames, 'G_{pred} free CV', FONTSIZE);
        
        Subplot = Subplot + 1;
        
        % plot pred G mat from each model
        for iModel = 2:(numel(Models)-1)
            
            subplot(m, n, Subplot);
            
            Title = [num2str(iModel - 1) ' - ' strrep(Models{iModel}.name, '_', ' ')];
            PlotGMatrixAndSetAxis(mean(G_pred_cr{iModel}, 3), Analysis(iAnalysis).CondNames, Title, FONTSIZE);
            
            Subplot = Subplot + 1;
            
        end
        
        mtit(get(gcf, 'name'), ...
            'fontsize', FONTSIZE, ...
            'xoff', 0, ...
            'yoff', .035);
        
        FigureFilename = fullfile(FigureDir, [FigureFilename '.tif']);
        disp(FigureFilename);
        print(gcf, FigureFilename, '-dtiff');
        
    end
    
end
