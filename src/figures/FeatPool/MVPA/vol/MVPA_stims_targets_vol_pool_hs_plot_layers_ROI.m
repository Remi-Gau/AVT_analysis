clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..', '..');
cd (StartDir);

NbLayers = 6;

SubLs = dir('sub*');
NbSub = numel(SubLs);
for iSub = 1:size(SubLs, 1)
  sets{iSub} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
% ToPermute = [];

addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

ResultsDir = fullfile(StartDir, 'results', 'SVM');
FigureFolder = fullfile(StartDir, 'figures', 'SVM', 'vol');
[~, ~, ~] = mkdir(FigureFolder);

% Analysis
% SVM(1) = struct('name', 'A - Targets VS Stim - Ipsi', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'V - Targets VS Stim - Ipsi', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'T - Targets VS Stim - Ipsi', 'ROI', 1:length(ROIs));
%
% SVM(end+1) = struct('name', 'A - Targets VS Stim - Contra', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'V - Targets VS Stim - Contra', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'T - Targets VS Stim - Contra', 'ROI', 1:length(ROIs));

% Options for the SVM
[opt, ~] = get_mvpa_options();

SaveSufix = CreateSaveSufix(opt, [], NbLayers);

for NbLayers = 6
  for WithQuad = 1
    for WithPerm = 0

      if WithQuad
        load(fullfile(ResultsDir, strcat('ResultsStimsTargetsPoolVolQuadGLM_l-', num2str(NbLayers), '.mat')), 'SVM', 'opt'); %#ok<*UNRCH>
      else
        load(fullfile(ResultsDir, strcat('ResultsStimsTargetsPoolVolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'SVM', 'opt'); %#ok<*UNRCH>
      end

      %% Targets VS Stim - Ipsi

      for i = 1:2

        switch i
          case 1
            SVM_1 = 1;
            SVM_last = 3;
            SVM_name = 'Targets_VS_Stim-Ipsi';
          case 2
            SVM_1 = 4;
            SVM_last = 6;
            SVM_name = 'Targets_VS_Stim-Contra';
        end

        % Reorganize the data
        tmp = {SVM.name}';
        Legend = cell(3, 1);

        for iSVM = SVM_1:SVM_last
          Legend{iSVM - SVM_1 + 1} = {'Percent correct', tmp{iSVM}};
        end

        for iROI = 1:numel(SVM(1).ROI)

          AllSubjects_Data(iROI).name = SVM(1).ROI(iROI).name;

          for iSVM = SVM_1:SVM_last
            % layers
            AllSubjects_Data(iROI).MVPA.grp(:, iSVM - SVM_1 + 1, :) = ...
                reshape(SVM(iSVM).ROI(iROI).grp(:, 2:NbLayers + 1)', [NbLayers, 1, size(SVM(iSVM).ROI(iROI).grp, 1)]); %#ok<*SAGROW>
            AllSubjects_Data(iROI).MVPA.MEAN(:, iSVM - SVM_1 + 1) = SVM(iSVM).ROI(iROI).MEAN(2:end)';
            AllSubjects_Data(iROI).MVPA.SEM(:, iSVM - SVM_1 + 1) = SVM(iSVM).ROI(iROI).SEM(2:end)';
            AllSubjects_Data(iROI).MVPA.Beta(:, iSVM - SVM_1 + 1, :) = ...
                reshape(SVM(iSVM).ROI(iROI).Beta.DATA, [3, 1, size(SVM(iSVM).ROI(iROI).Beta.DATA, 2)]);

            % whole ROI
            AllSubjects_Data(iROI).MVPA.whole_roi_grp(:, iSVM - SVM_1 + 1, :) = SVM(iSVM).ROI(iROI).grp(:, 1); %#ok<*SAGROW>
            AllSubjects_Data(iROI).MVPA.whole_roi_MEAN(:, iSVM - SVM_1 + 1) = nanmean(SVM(iSVM).ROI(iROI).grp(:, 1));
            AllSubjects_Data(iROI).MVPA.whole_roi_SEM(:, iSVM - SVM_1 + 1) = nanstd(SVM(iSVM).ROI(iROI).grp(:, 1));

          end

        end

        % Plots
        for iROI = 1:numel(SVM(iSVM).ROI)

          close all;

          Name = [AllSubjects_Data(iROI).name '-' SVM_name];
          if WithQuad
          else
            Name = [Name '-NoQuad-ALL'];
          end

          % Layers
          ToPlot.Name = [Name '\n' SaveSufix(9:end - 4)];
          ToPlot.Data = AllSubjects_Data(iROI).MVPA;
          ToPlot.PlotSub = 1;
          ToPlot.WithQuad = WithQuad;
          ToPlot.SubPlotOrder = 1:3;
          ToPlot.Legend = Legend;
          ToPlot.Visible = 'on';
          ToPlot.FigureFolder = FigureFolder;
          ToPlot.ToPermute = ToPermute;
          ToPlot.MVPA = 1;

          PlotLayersForFig(ToPlot);

          % Whole ROI
          Name = [AllSubjects_Data(iROI).name '-' SVM_name '-WholeROI\n' SaveSufix(9:end - 4)];

          ToPlot.Name = Name;
          ToPlot.Data = AllSubjects_Data(iROI).MVPA;

          PlotROIForFig(ToPlot);

          clear ToPlot;
        end

      end

      cd(StartDir);

    end
  end
end
