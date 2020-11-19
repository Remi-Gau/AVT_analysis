clc;
clear;

close all;

CodeDir = '/home/remi/github/AVT_analysis';
StartDir = '/home/remi/Dropbox/PhD/Experiments/AVT/derivatives';

FigureFolder = fullfile(StartDir, 'figures');
addpath(genpath(fullfile(CodeDir, 'subfun')));
Get_dependencies('/home/remi/');

NbLayers = 6;
WithQuad = 1;
WithPerm = 1;

Visible = 'on';

CondNames = { ...
             'AStimL', 'AStimR'; ...
             'VStimL', 'VStimR'; ...
             'TStimL', 'TStimR'
             %         'ATargL','ATargR';...
             %         'VTargL','VTargR';...
             %         'TTargL','TTargR';...
            };

% ContSensMod
% Col2Sel = {...
%     [1 4], [2 5];
%     [1 4], [3 6];
%     [2 5], [3 6]};

% ContSensModIpsi
% Col2Sel = {...
%     [1 4], [2 5];
%     [1 4], [3 6];
%     [2 5], [3 6]};

% ContSensModContra
% Col2Sel = {...
%     [4 1], [5 2];
%     [4 1], [6 3];
%     [5 2], [6 3]};

%% Visual areas - A vs T

ROIs = { ...
        'V1', ...
        'V2', ...
        'V3', ...
        'TE', ...
        'PT', ...
        'S1_cyt', ...
        'S1_aal'};

BOLD_Cdt = [ ...
            2
            2
            2
            3
            3
            3
            1
            1];

SVM = [ ...
       'A VS T'; ...
       'A VS T'; ...
       'A VS T'; ...
       'V VS T'; ...
       'V VS T'; ...
       'V VS T'; ...
       'A VS V'; ...
       'A VS V' ...
      ];

for iROI = 1:numel(ROIs)

  fprintf([ROIs{iROI} '\n']);

  Name = [strrep(ROIs{iROI}, '_', '-') '-' strrep(SVM(iROI, :), ' ', '-')];

  % Open figure
  fig = figure('Name', Name, 'Position', [100, 100, 1500, 1000], ...
               'Color', [1 1 1], 'Visible', Visible);

  box off;

  set(gca, 'units', 'centimeters');
  pos = get(gca, 'Position');
  ti = get(gca, 'TightInset');

  set(fig, 'PaperUnits', 'centimeters');
  set(fig, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
  set(fig, 'PaperPositionMode', 'manual');
  set(fig, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

  set(fig, 'Visible', Visible);

  %% Get BOLD Data

  ResultsDir = fullfile(StartDir, 'results', 'profiles');

  % Contrasts against sensory modalities pooled over the whole ROI
  if WithQuad
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, ...
                                     '_VolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  else
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, ...
                                     '_VolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results'); %#ok<*UNRCH>
  end

  ToPlot.Data.MEAN(:, 1) = Results.ContSensMod.MEAN(:, BOLD_Cdt(iROI));
  ToPlot.Data.SEM(:, 1) = Results.ContSensMod.SEM(:, BOLD_Cdt(iROI));
  ToPlot.Data.grp(:, 1, :) = Results.ContSensMod.grp(:, BOLD_Cdt(iROI), :);
  ToPlot.Data.Beta.DATA(:, 1, :) = Results.ContSensMod.Beta.DATA(:, BOLD_Cdt(iROI), :);

  clear Results;

  % Contrasts against sensory modalities pooled for ipsi and contra
  if WithQuad
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, ...
                                     '_VolPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  else
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, ...
                                     '_VolPoolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  end

  ToPlot.Data.MEAN(:, 2) = Results.ContSensModIpsi.MEAN(:, BOLD_Cdt(iROI));
  ToPlot.Data.SEM(:, 2) = Results.ContSensModIpsi.SEM(:, BOLD_Cdt(iROI));
  ToPlot.Data.grp(:, 2, :) = Results.ContSensModIpsi.grp(:, BOLD_Cdt(iROI), :);
  ToPlot.Data.Beta.DATA(:, 2, :) = Results.ContSensModIpsi.Beta.DATA(:, BOLD_Cdt(iROI), :);

  ToPlot.Data.MEAN(:, 3) = Results.ContSensModContra.MEAN(:, BOLD_Cdt(iROI));
  ToPlot.Data.SEM(:, 3) = Results.ContSensModContra.SEM(:, BOLD_Cdt(iROI));
  ToPlot.Data.grp(:, 3, :) = Results.ContSensModContra.grp(:, BOLD_Cdt(iROI), :);
  ToPlot.Data.Beta.DATA(:, 3, :) = Results.ContSensModContra.Beta.DATA(:, BOLD_Cdt(iROI), :);

  clear Results;

  %% Plot BOLD DATA

  ToPlot.SubPlotOrder = [1 2 3];
  ToPlot.PlotSub = 1;
  ToPlot.WithQuad = WithQuad;
  ToPlot.SubplotGroup = [ ...
                         1 3; ...
                         7 9; ...
                         13 15];
  ToPlot.mn = [9 2];
  ToPlot.XYs = [ ...
                0.13 0.65; ...
                0.13 0.37; ...
                0.13 0.09 ...
               ];
  ToPlot.Legend = { ...
                   {'Whole', 'BOLD'}; ...
                   {'Ipsi', ''}; ...
                   {'Contra', ''} ...
                  };
  ToPlot.MVPA = 0;

  Plot_BOLD_MVPA(ToPlot);

  clear ToPlot;

  %% Get MVPA Data

  ResultsDir = fullfile(StartDir, 'results', 'SVM');

  % Contrasts against sensory modalities pooled over the whole ROI
  if WithQuad
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI},  '_', strrep(SVM(iROI, :), ' ', '-'), ...
                                     '_VolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  else
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, strrep(SVM(iROI, :), ' ', '-'), ...
                                     '_VolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  end

  ToPlot.Data.MEAN(:, 1) = Results.MEAN(2:end);
  ToPlot.Data.SEM(:, 1) = Results.SEM(2:end);
  ToPlot.Data.grp(:, 1, :) = Results.grp(:, 2:end)';
  ToPlot.Data.Beta.DATA(:, 1, :) = Results.Beta.DATA;

  clear Results;

  % Contrasts against sensory modalities pooled for ipsi
  if WithQuad
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, '_', strrep(SVM(iROI, :), ' ', '-'), '-Ipsi', ...
                                     '_VolPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  else
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, '_', strrep(SVM(iROI, :), ' ', '-'), '-Ipsi', ...
                                     '_VolPoolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  end

  ToPlot.Data.MEAN(:, 2) = Results.MEAN(2:end);
  ToPlot.Data.SEM(:, 2) = Results.SEM(2:end);
  ToPlot.Data.grp(:, 2, :) = Results.grp(:, 2:end)';
  ToPlot.Data.Beta.DATA(:, 2, :) = Results.Beta.DATA;

  clear Results;

  % Contrasts against sensory modalities pooled for ipsi
  if WithQuad
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, '_', strrep(SVM(iROI, :), ' ', '-'), '-Contra', ...
                                     '_VolPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  else
    load(fullfile(ResultsDir, strcat('Results_', ROIs{iROI}, '_', strrep(SVM(iROI, :), ' ', '-'), '-Contra', ...
                                     '_VolPoolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results');
  end

  ToPlot.Data.MEAN(:, 3) = Results.MEAN(2:end);
  ToPlot.Data.SEM(:, 3) = Results.SEM(2:end);
  ToPlot.Data.grp(:, 3, :) = Results.grp(:, 2:end)';
  ToPlot.Data.Beta.DATA(:, 3, :) = Results.Beta.DATA;

  clear Results;

  %% Plot BOLD DATA

  ToPlot.SubPlotOrder = [1 2 3];
  ToPlot.PlotSub = 1;
  ToPlot.WithQuad = WithQuad;
  ToPlot.SubplotGroup = [ ...
                         2 4; ...
                         8 10; ...
                         14 16];
  ToPlot.mn = [9 2];
  ToPlot.XYs = [ ...
                0.57 0.65; ...
                0.57 0.37; ...
                0.57 0.09 ...
               ];
  ToPlot.Legend = { ...
                   {'', 'MVPA'}; ...
                   {'', ''}; ...
                   {'', ''} ...
                  };
  ToPlot.MVPA = 1;

  Plot_BOLD_MVPA(ToPlot);

  %%
  mtit(Name, 'xoff', 0, 'yoff', +0.03, 'fontsize', 16);
  set(fig, 'Visible', Visible);

  %     print(fig, fullfile(FigureFolder, strcat(Name, '_', num2str(NbLayers), 'Layers.pdf')), '-dpdf')
  print(fig, fullfile(FigureFolder, strcat(Name, '_', num2str(NbLayers), 'Layers.tif')), '-dtiff');

  clear ToPlot;

end
