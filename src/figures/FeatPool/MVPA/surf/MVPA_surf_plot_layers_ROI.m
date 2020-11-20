clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
cd (StartDir);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('/home/rxg243/Dropbox/');

ResultsDir = fullfile(StartDir, 'results', 'SVM');
FigureFolder = fullfile(StartDir, 'figures', 'SVM', 'surf');
[~, ~, ~] = mkdir(FigureFolder);

% SVM(1) = struct('name', 'A Ipsi VS Contra', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'V Ipsi VS Contra', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'T Ipsi VS Contra', 'ROI', 1:length(ROIs));
%
% SVM(end+1) = struct('name', 'A VS V Ipsi', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'A VS T Ipsi', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'V VS T Ipsi', 'ROI', 1:length(ROIs));
%
% SVM(end+1) = struct('name', 'A VS V Contra', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'A VS T Contra', 'ROI', 1:length(ROIs));
% SVM(end+1) = struct('name', 'V VS T Contra', 'ROI', 1:length(ROIs));

TitSuf = {
          'Contra_vs_Ipsi'; ...
          'Between_Senses_Ipsi'; ...
          'Between_Senses_Contra'};

SubSVM = [1:3; 4:6; 7:9];

SubLs = dir('sub*');
NbSub = numel(SubLs);

% Options for the SVM
[opt, ~] = get_mvpa_options();

for NbLayers = 6
    for WithQuad = 1
        for WithPerm = 0:1

            for iSub = 1:size(SubLs, 1)
                sets{iSub} = [-1 1];
            end
            [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
            ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
            clear sets;

            if ~WithPerm
                ToPermute = [];
            end

            for Norm = 5:8

                [opt] = ChooseNorm(Norm, opt);

                SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);

                if WithQuad
                    File2Load = fullfile(ResultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
                else
                    File2Load = fullfile(ResultsDir, strcat('GrpPoolNoQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
                end

                if exist(File2Load, 'file')
                    load(File2Load, 'SVM', 'opt');
                else
                    warning('This file %s does not exist', File2Load);
                end

                for iROI = 1:numel(SVM(1).ROI)

                    fprintf('\n Running ROI:  %s\n', SVM(1).ROI(iROI).name);

                    for iSubSVM = 1:numel(TitSuf)

                        % Reorganize the data
                        AllSubjects_Data(iROI).name = SVM(1).ROI(iROI).name;

                        tmp = {SVM.name}';
                        Legend = cell(3, 1);

                        for iSVM = SubSVM(iSubSVM, :)

                            Legend{iSVM + 1 - SubSVM(iSubSVM, 1)} = {'Decoding accuracy', tmp{iSVM}};

                            AllSubjects_Data(iROI).whole_roi.MEAN(:, iSVM + 1 - SubSVM(iSubSVM, 1)) = SVM(iSVM).ROI(iROI).MEAN;
                            AllSubjects_Data(iROI).whole_roi.SEM(:, iSVM + 1 - SubSVM(iSubSVM, 1)) = SVM(iSVM).ROI(iROI).SEM;
                            AllSubjects_Data(iROI).whole_roi.grp(:, iSVM + 1 - SubSVM(iSubSVM, 1)) = SVM(iSVM).ROI(iROI).grp;

                            for iSubj = 1:size(SVM(iSVM).ROI(iROI).layers.grp, 3)
                                tmp2(:, iSubj) = diag(SVM(iSVM).ROI(iROI).layers.grp(:, :, iSubj));
                            end

                            AllSubjects_Data(iROI).MVPA.grp(:, iSVM + 1 - SubSVM(iSubSVM, 1), :) = flipud(tmp2); %#ok<*SAGROW>

                            AllSubjects_Data(iROI).MVPA.MEAN(:, iSVM + 1 - SubSVM(iSubSVM, 1)) = flipud(SVM(iSVM).ROI(iROI).layers.MEAN(1:end)');
                            AllSubjects_Data(iROI).MVPA.SEM(:, iSVM + 1 - SubSVM(iSubSVM, 1)) = flipud(SVM(iSVM).ROI(iROI).layers.SEM(1:end)');
                            AllSubjects_Data(iROI).MVPA.Beta(:, iSVM + 1 - SubSVM(iSubSVM, 1), :) = ...
                                reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA, [3, 1, size(SVM(iSVM).ROI(iROI).layers.Beta.DATA, 2)]);
                        end

                        % plot
                        close all;

                        Name = AllSubjects_Data(iROI).name;
                        if WithQuad
                            Name = [Name '-' TitSuf{iSubSVM}];
                        else
                            Name = [Name '-' TitSuf{iSubSVM}];
                        end

                        %% Layers
                        ToPlot.Name = [Name '\n' SaveSufix(9:end - 4)];
                        ToPlot.Data = AllSubjects_Data(iROI).MVPA;
                        ToPlot.PlotSub = 1;
                        ToPlot.WithQuad = WithQuad;
                        ToPlot.SubPlotOrder = [1 2 3];
                        ToPlot.Legend = Legend;
                        ToPlot.Visible = 'on';
                        ToPlot.FigureFolder = FigureFolder;
                        ToPlot.MVPA = 1;
                        ToPlot.ToPermute = ToPermute;
                        ToPlot.OneSideTTest = {'both' 'both' 'both'};

                        if ~any(isnan(AllSubjects_Data(iROI).MVPA.MEAN(:)))
                            PlotLayersForFig(ToPlot);
                        end

                        clear ToPlot;

                        %% Whole ROI
                        ToPlot.Name = [Name '\n' SaveSufix(9:end - 4)];
                        ToPlot.Data.whole_roi_MEAN = AllSubjects_Data(iROI).whole_roi.MEAN;
                        ToPlot.Data.whole_roi_SEM = AllSubjects_Data(iROI).whole_roi.SEM;
                        ToPlot.Data.whole_roi_grp = AllSubjects_Data(iROI).whole_roi.grp;
                        ToPlot.PlotSub = 1;
                        ToPlot.SubPlotOrder = [1 2 3];
                        ToPlot.Legend = Legend;
                        ToPlot.Visible = 'on';
                        ToPlot.FigureFolder = FigureFolder;
                        ToPlot.MVPA = 1;
                        ToPlot.ToPermute = ToPermute;
                        ToPlot.OneSideTTest = {'both'};

                        PlotROIForFig(ToPlot);

                        clear ToPlot;

                    end

                end

                cd(StartDir);

            end
        end
    end
end
