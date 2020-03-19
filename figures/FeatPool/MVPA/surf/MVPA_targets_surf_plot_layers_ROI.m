clc; clear;

StartDir = fullfile(pwd, '..','..','..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'SVM');
FigureFolder = fullfile(StartDir, 'figures', 'SVM', 'surf');
[~,~,~] = mkdir(FigureFolder);

%     SVM(1) = struct('name', 'A Ipsi VS Contra - Targets', 'ROI', 1:length(ROIs));
%     SVM(end+1) = struct('name', 'V Ipsi VS Contra - Targets', 'ROI', 1:length(ROIs));
%     SVM(end+1) = struct('name', 'T Ipsi VS Contra - Targets', 'ROI', 1:length(ROIs));
%     
%     SVM(end+1) = struct('name', 'A VS V Ipsi - Targets', 'ROI', 1:length(ROIs));
%     SVM(end+1) = struct('name', 'A VS T Ipsi - Targets', 'ROI', 1:length(ROIs));
%     SVM(end+1) = struct('name', 'V VS T Ipsi - Targets', 'ROI', 1:length(ROIs));
%     
%     SVM(end+1) = struct('name', 'A VS V Contra - Targets', 'ROI', 1:length(ROIs));
%     SVM(end+1) = struct('name', 'A VS T Contra - Targets', 'ROI', 1:length(ROIs));
%     SVM(end+1) = struct('name', 'V VS T Contra - Targets', 'ROI', 1:length(ROIs));

TitSuf = {
    'Targets-Contra_vs_Ipsi';...
    'Targets-Between_Senses_Ipsi';...
    'Targets-Between_Senses_Contra'};

SubSVM = [1:3;4:6;7:9];

SubLs = dir('sub*');
NbSub = numel(SubLs);
for iSub=1:size(SubLs,1)
    sets{iSub} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
% ToPermute = [];

opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;

for NbLayers=6
    for WithQuad= 1
        for WithPerm = 0
            
            for Norm = [6 8]
                
                [opt] = ChooseNorm(Norm, opt)
                
                SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);
                
                if WithQuad
                    File2Load = fullfile(ResultsDir, strcat('GrpTargetsPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
                else
                    File2Load = fullfile(ResultsDir, strcat('GrpTargetsPoolNoQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
                end
                
                if exist(File2Load, 'file')
                    load(File2Load, 'SVM', 'opt')
                else
                    warning('This file %s does not exist', File2Load)
                end
                
                for iROI = 1:numel(SVM(1).ROI)
                    
                    fprintf('\n Running ROI:  %s\n', SVM(1).ROI(iROI).name)
                    
                    for iSubSVM=1:numel(TitSuf)
                        
                        % Reorganize the data
                        AllSubjects_Data(iROI).name = SVM(1).ROI(iROI).name;
                        
                        tmp = {SVM.name}';
                        Legend = cell(3,1);
                        
                        for iSVM = SubSVM(iSubSVM,:)
                            
                            Legend{iSVM+1-SubSVM(iSubSVM,1)} = {'Decoding accuracy',tmp{iSVM}};
                            
                            AllSubjects_Data(iROI).whole_roi.MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).MEAN;
                            AllSubjects_Data(iROI).whole_roi.SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).SEM;
                            AllSubjects_Data(iROI).whole_roi.grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp;
                            
                            
                            for iSubj=1:size(SVM(iSVM).ROI(iROI).layers.grp,3)
                                tmp2(:,iSubj) = diag(SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj));
                            end
                            
                            
                            AllSubjects_Data(iROI).MVPA.grp(:,iSVM+1-SubSVM(iSubSVM,1),:) = flipud(tmp2); %#ok<*SAGROW>
                            
                            
                            AllSubjects_Data(iROI).MVPA.MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.MEAN(1:end)');
                            AllSubjects_Data(iROI).MVPA.SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.SEM(1:end)');
                            AllSubjects_Data(iROI).MVPA.Beta(:,iSVM+1-SubSVM(iSubSVM,1),:) = ...
                                reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA, [3,1,size(SVM(iSVM).ROI(iROI).layers.Beta.DATA,2)]);
                        end
                        
                        % plot
                        close all
                        
                        Name = AllSubjects_Data(iROI).name;
                        if WithQuad
                            Name = [Name '-' TitSuf{iSubSVM}];
                        else
                            Name = [Name '-' TitSuf{iSubSVM}];
                        end
                        
                        
                        %% Layers
                        ToPlot.Name = [Name '\n' SaveSufix(9:end-4)];
                        ToPlot.Data = AllSubjects_Data(iROI).MVPA;
                        ToPlot.PlotSub = 1;
                        ToPlot.WithQuad = WithQuad;
                        ToPlot.SubPlotOrder = [1 2 3];
                        ToPlot.Legend = Legend;
                        ToPlot.Visible= 'on';
                        ToPlot.FigureFolder=FigureFolder;
                        ToPlot.MVPA = 1;
                        ToPlot.ToPermute = ToPermute;
                        ToPlot.OneSideTTest = {'both' 'both' 'both'};
                        
                        if ~any(isnan(AllSubjects_Data(iROI).MVPA.MEAN(:)))
                            PlotLayersForFig(ToPlot)
                        end
                        
                        clear ToPlot
                        
                        
                        %% Whole ROI
                        ToPlot.Name = [Name '\n' SaveSufix(9:end-4)];
                        ToPlot.Data.whole_roi_MEAN = AllSubjects_Data(iROI).whole_roi.MEAN;
                        ToPlot.Data.whole_roi_SEM = AllSubjects_Data(iROI).whole_roi.SEM;
                        ToPlot.Data.whole_roi_grp = AllSubjects_Data(iROI).whole_roi.grp;
                        ToPlot.PlotSub = 1;
                        ToPlot.SubPlotOrder = [1 2 3];
                        ToPlot.Legend = Legend;
                        ToPlot.Visible='on';
                        ToPlot.FigureFolder=FigureFolder;
                        ToPlot.MVPA = 1;
                        ToPlot.ToPermute = ToPermute;
                        ToPlot.OneSideTTest = {'both'};
                        
                        PlotROIForFig(ToPlot)
                        
                        clear ToPlot
                        
                        
                    end
                    
                end
                
                cd(StartDir)
                
            end
        end
    end
end


