% (C) Copyright 2020 Remi Gau
%
% For 3X3 models
%
% - computes likelihood of each model
% - computes exceedance probabilities by performing 2 family comparison with spm_compare_families
%
%           a) Families.names{1}='Scaled';
%           b) Families.names{2}='Scaled+Idpdt and Idpdt';
%
% or
%           a) Families.names{1}='Scaled';
%           b) Families.names{2}='Scaled+Idpdt'
%           c) Families.names{3}='Idpdt'
%
% - plot the exceedance probabilities for both cases as a matrix
%

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


InputType = 'ROI';

% Region of interest:
%  possible choices: A1, PT, V1-5

ROIs = { ...
  'V1'
  'V2'
  'A1'
  'PT'
  };

% This needs to be adapted or even saved with the PCM results
Analysis(1).name = 'Ipsi';
Analysis(2).name = 'Contra';
Analysis(3).name = 'ContraIpsi';

%% Figure parameters
set(0, 'defaultAxesFontName', 'Arial');
set(0, 'defaultTextFontName', 'Arial');

FigDim = [50, 50, 480, 600];
Visible = 'on';

%% Other parameters
% Unlikely to change

IsTarget = false;

DoFeaturePooling = true;

Space = 'surf';

%% Will not change

MVNN = true;

ConditionType = 'stim';
if IsTarget
  ConditionType = 'target';
end

Dirs = SetDir(Space, MVNN);
InputDir = fullfile(Dirs.PCM, '3X3');

FigureDir = fullfile(InputDir, 'figures');
mkdir(FigureDir);

[Families, Families2] = SetPcm3X3modelsFamily();

NbROIs = numel(ROIs);

for iROI = 1:NbROIs
  
  for iAnalysis = 1:numel(Analysis)
    
    filename = ['pcm_results', ...
      '_roi-', ROIs{iROI}, ...
      '_cdt-', ConditionType, ...
      '_param-', lower(InputType), ...
      '_analysis-', Analysis(iAnalysis).name, ...
      '.mat'];
    filename = fullfile(InputDir, filename);
    
    disp(filename);
    load(filename, 'Models', 'T_grp', 'T_cr');
    
    Models_all{iAnalysis, 1} = Models; %#ok<*SAGROW>
    T_group_all{iAnalysis, 1} = T_grp;
    T_cross_all{iAnalysis, 1} = T_cr;
    
    clear Models T_grp T_cr filename
    
  end
  
  Normalize = 0;
  colors = {'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'; 'b'};
  
  for iAnalysis = 1:numel(Models_all)
    
    Upperceil = T_group_all{iAnalysis, 1}.likelihood(:, end);
    Data2Plot = T_cross_all{iAnalysis, 1};
    M = Models_all{iAnalysis, 1};
    
    T = pcm_plotModelLikelihood(...
      Data2Plot, M, ...
      'upperceil', Upperceil, ...
      'colors', colors, ...
      'normalize', Normalize);
    
    Likelihood{iROI}(:, :, iAnalysis) = T.likelihood;
    Likelihood_norm{iROI}(:, :, iAnalysis) = T.likelihood_norm;
    
  end
  
end

%% Do family comparison and plot
XP = [];
XP2 = [];

for iROI = 1:NbROIs
  
  close all;
  
  disp(ROIs{iROI})
  
  %% For ipsi and contra
  for iAnalysis = 1:numel(Models_all)
    
    %% RFX: perform bayesian model family comparison
    % Compute exceedance probabilities
    for iCdt = 1:3
      family = Families{iCdt};
      loglike = Likelihood{iROI}(:, family.modelorder + 1, iAnalysis);
      family = spm_compare_families(loglike, family);
      XP(iCdt, :, iROI, iAnalysis) = family.xp;
      
      family = Families2{iCdt};
      loglike = Likelihood{iROI}(:, family.modelorder + 1, iAnalysis);
      family = spm_compare_families(loglike, family);
      XP2(iCdt, :, iROI, iAnalysis) = family.xp;
    end
    
  end
end

%% Matrices plot for exceedance probability of I + (S & I)
close all;

for iFam = 1:2
  
  Struct2Save = struct( ...
    'comp', {...
    {...
    'Ai VS Vi', 'Ai VS Ti', 'Vi VS Ti', ...
    'Ac VS Vc', 'Ac VS Tc', 'Vc VS Tc'...
    }...
    }, ...
    'p_s', [], ...
    'p_si', [], ...
    'p_i', []);
  
  for iAnalysis = 1:size(XP, 4)
    
    if iFam == 1
      NbFam = '3';
      Mat2Plot = squeeze(XP(:, 3, :, iAnalysis) + XP(:, 1, :, iAnalysis));
      Struct2Save = cat(1, ...
        XP([2 1 3], :, :, iAnalysis), ...
        XP([2 1 3], :, :, iAnalysis));
      
    else
      NbFam = '2';
      Mat2Plot = squeeze(XP2(:, 1, :, iAnalysis));
      Struct2Save = zeros(6, 3, NbROI);
      
    end
    
    filename = ['ModelFamilyComparison', ...
      '_cdt-', ConditionType, ...
      '_param-', lower(InputType), ...
      '_analysis-', Analysis(iAnalysis).name];
    
    %     print_PCM_table(Struct2Save, Struct2Save, ROI, NbROI, FigureDir, opt);
    
    figure(...
      'name', strrep(filename, '_', ' '), ...
      'Position', FigDim, ...
      'Color', [1 1 1], ...
      'visible', Visible);
    
    colormap('gray');
    
    hold on;
    box off;
    
    imagesc(flipud(Mat2Plot), [0 1]);
    
    plot([.5 NbROIs + .5], [1.5 1.5], 'color', [.2 .2 .2], 'linewidth', 1);
    plot([.5 NbROIs + .5], [2.5 2.5], 'color', [.2 .2 .2], 'linewidth', 1);
    for i = 1:4
      plot([0.5 0.5] + i, [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1);
    end
    
    patch([2.44 2.56 2.56 2.44], [.5 .5 3.5 3.5], 'w', 'linewidth', 2);
    
    plot([.5 .5], [.5 3.5], 'k', 'linewidth', 2);
    plot([NbROIs + .5 NbROIs + .5], [.5 3.5], 'k', 'linewidth', 2);
    plot([.5 NbROIs + .5], [.5 .5], 'k', 'linewidth', 2);
    plot([.5 NbROIs + .5], [3.5 3.5], 'k', 'linewidth', 2);
    
    title(Analysis(iAnalysis).name);
    
    switch iAnalysis
      case 1
        yticklabel = ['V_i VS T_i'; 'A_i VS T_i'; 'A_i VS V_i'];
      case 2
        yticklabel = ['V_c VS T_c'; 'A_c VS T_c'; 'A_c VS V_c'];
      case 3
        yticklabel = ['V VS T'; 'A VS T'; 'A VS V'];
    end
    
    set(gca, 'fontsize', 10, ...
      'ytick', 1:3, ...
      'yticklabel', yticklabel, ...
      'xtick', 1:NbROIs, ...
      'xticklabel', ROIs(1:NbROIs), 'Xcolor', 'k');
    
    colorbar
    
    p=mtit(['Exc probability Idpt + Scaled & Idpdt - ' InputType],...
      'fontsize',14,...
      'xoff',0,'yoff',.025);
    
    axis([.5 NbROIs + .5 .5 3.5]);
    axis square;
    
    disp(filename)
    print(gcf, fullfile(FigureDir, [filename '.tif']), '-dtiff');
    pause(2);
    
    ColorMap = BrainColourMaps('hot_increasing');
    colormap(ColorMap);
    disp(filename)
    print(gcf, fullfile(FigureDir, [filename '_hot.tif']), '-dtiff');
    
  end
  
end
