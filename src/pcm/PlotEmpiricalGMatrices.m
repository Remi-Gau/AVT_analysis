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
        
        m = 3;
        n = 5;
        
    case '6x6'
        
        Analysis(1).name = 'AllConditions';
        Analysis(1).CdtToSelect = 1:6;
        Analysis(1).CondNames = CondNames(1:6);
        
end
        
FigDim = [50, 50, 750, 750];
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
        
        PlotGMatrixAndSetAxis(mean(G_hat, 3), Analysis.CondNames, Title, FONTSIZE, false);
        
        NewColorMap = NonCenteredDivergingColourmap(mean(G_hat, 3), ColorMap);
        colormap(NewColorMap);

        axis square;
        axis ([.5 6.5 .5 6.5]);
        
        FigureFilename = fullfile(FigureDir, [FigureFilename '.tif']);
        disp(FigureFilename);
%         print(gcf, FigureFilename, '-dtiff');
        
    end
    
end


% 
% 
%         % Add white lines
%         if all(ConditionOrder == [2 4 6 1 3 5])
%             plot([3.5 3.5], [0.52 6.52], 'color', [.8 .8 .8], 'linewidth', 3);
%             plot([0.52 6.52], [3.5 3.5], 'color', [.8 .8 .8], 'linewidth', 3);
%         else
%             Pos = 2.5;
%             for  i = 1:2
%                 plot([Pos Pos], [0.52 6.52], 'w', 'linewidth', 3);
%                 plot([0.52 6.52], [Pos Pos], 'w', 'linewidth', 3);
%                 Pos = Pos + 2;
%             end
%         end
%         
%         % add black line contours
%         plot([0.5 0.5], [0.51 6.51], 'k', 'linewidth', 3);
%         plot([6.5 6.5], [0.51 6.51], 'k', 'linewidth', 3);
%         plot([0.51 6.51], [0.5 0.5], 'k', 'linewidth', 3);
%         plot([0.51 6.51], [6.5 6.5], 'k', 'linewidth', 3);
%         
%         
%         
%                 %% Print log and non-log scale together
%         if iScale == 2
%             % Create a scale with the original values
%             fig = figure('name', ['Scale-G-matrix-' Scaling opt.FigName], ...
%                 'Position', [50, 50, 700, 600], 'Color', [1 1 1]);
%             
%             colormap(NewColorMap);
%             
%             imagesc(repmat(linspace(MAX, MIN, 1000)', 1, 100));
%             
%             NbYtick = 10;
%             set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
%                 'ytick', linspace(1, 1000, NbYtick), ...
%                 'yticklabel', floor(linspace(MAX, MIN, NbYtick) * 10^3) / 10^3, ...
%                 'ticklength', [0.01 0.01], 'fontsize', 12);
%             
%             ax = gca;
%             axPos = ax.Position;
%             axes('Position', axPos);
%             
%             imagesc(repmat(linspace(MAX, MIN, 1000)', 1, 100));
%             
%             % get the Y scale unnormalized
%             %                     linspace(MAX,MIN,NbYtick)
%             %                     abs(linspace(MAX,MIN,NbYtick))
%             %                     10.^abs(linspace(MAX,MIN,NbYtick))
%             %                     10.^abs(linspace(MAX,MIN,NbYtick))*Min2Keep
%             %                     10.^abs(linspace(MAX,MIN,NbYtick))*Min2Keep.*sign(linspace(MAX,MIN,NbYtick))
%             YTickLabel = linspace(MAX, MIN, NbYtick);
%             YTickLabel = 10.^(abs(linspace(MAX, MIN, NbYtick))) * Min2Keep .* sign(YTickLabel);
%             YTickLabel = floor(YTickLabel * 10^4) / 10^4;
%             
%             set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
%                 'ytick', linspace(1, 1000, NbYtick), ...
%                 'yticklabel', YTickLabel, ...
%                 'YAxisLocation', 'right', ...
%                 'ticklength', [0.01 0.01], 'fontsize', 14);
%             
%             %                                         print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif']  ), '-dtiff')
%             %                     print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.svg']  ), '-dsvg')
%             
%         end