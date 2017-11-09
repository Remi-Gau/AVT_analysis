clc; clear;

StartDir = fullfile(pwd, '..','..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'SVM');
FigureFolder = fullfile(StartDir, 'figures', 'SVM');
[~,~,~] = mkdir(FigureFolder);

NbLayers = 6;

load(fullfile(ResultsDir, strcat('ResultsPoolVolQuadGLM_l-', num2str(NbLayers), '.mat')), 'SVM', 'opt') %#ok<*UNRCH>

%% Ipsi VS contra
% Reorganize the data
tmp = {SVM.name}';
Legend = cell(3,1);
for iSVM = 1:3
    Legend{iSVM} = {'Percent correct',tmp{iSVM}};
end

for iROI = 1:numel(SVM(1).ROI)
    AllSubjects_Data(iROI).name = SVM(1).ROI(iROI).name;
    for iSVM = 1:3
        AllSubjects_Data(iROI).MVPA.grp(:,iSVM,:) = SVM(iSVM).ROI(iROI).grp(:,1); %#ok<*SAGROW>
        AllSubjects_Data(iROI).MVPA.MEAN(:,iSVM) = nanmean(SVM(iSVM).ROI(iROI).grp(:,1));
        AllSubjects_Data(iROI).MVPA.SEM(:,iSVM) = nanstd(SVM(iSVM).ROI(iROI).grp(:,1));
    end
end



% Plots
for iROI = 1:numel(SVM(iSVM).ROI)
    
    close all
    
    Name = [AllSubjects_Data(iROI).name '-WholeROI-ipsiVScontra'];
    
    %% Basic condition
    ToPlot.Name = Name;
    ToPlot.Data = AllSubjects_Data(iROI).MVPA;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = 1:3;
    ToPlot.Legend = Legend;
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 1;
    
    PlotROIForFig(ToPlot)
    
    clear ToPlot
    
end


%% Between conditions Ipsi
clear AllSubjects_Data
% Reorganize the data
tmp = {SVM.name}';
Legend = cell(3,1);
for iSVM = 4:6
    Legend{iSVM-3} = {'Percent correct',tmp{iSVM}};
end

for iROI = 1:numel(SVM(1).ROI)
    AllSubjects_Data(iROI).name = SVM(1).ROI(iROI).name;
    for iSVM = 4:6
        AllSubjects_Data(iROI).MVPA.grp(:,iSVM-3,:) = SVM(iSVM).ROI(iROI).grp(:,1); %#ok<*SAGROW>
        AllSubjects_Data(iROI).MVPA.MEAN(:,iSVM-3) = nanmean(SVM(iSVM).ROI(iROI).grp(:,1));
        AllSubjects_Data(iROI).MVPA.SEM(:,iSVM-3) = nanstd(SVM(iSVM).ROI(iROI).grp(:,1));
    end
end



% Plots
for iROI = 1:numel(SVM(iSVM).ROI)
    
    close all
    
    Name = [AllSubjects_Data(iROI).name  '-WholeROI-BetweenSensesIpsi'];
    
    %% Basic condition
    ToPlot.Name = Name;
    ToPlot.Data = AllSubjects_Data(iROI).MVPA;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = 1:3;
    ToPlot.Legend = Legend;
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 1;
    
    PlotROIForFig(ToPlot)
    
    clear ToPlot
    
end


%% Between conditions contra
clear AllSubjects_Data
% Reorganize the data
tmp = {SVM.name}';
Legend = cell(3,1);
for iSVM = 7:9
    Legend{iSVM-6} = {'Percent correct',tmp{iSVM}};
end

for iROI = 1:numel(SVM(1).ROI)
    AllSubjects_Data(iROI).name = SVM(1).ROI(iROI).name;
    for iSVM = 7:9
        AllSubjects_Data(iROI).MVPA.grp(:,iSVM-6,:) = SVM(iSVM).ROI(iROI).grp(:,1); %#ok<*SAGROW>
        AllSubjects_Data(iROI).MVPA.MEAN(:,iSVM-6) = nanmean(SVM(iSVM).ROI(iROI).grp(:,1));
        AllSubjects_Data(iROI).MVPA.SEM(:,iSVM-6) = nanstd(SVM(iSVM).ROI(iROI).grp(:,1));
    end
end



% Plots
for iROI = 1:numel(SVM(iSVM).ROI)
    
    close all
    
    Name = [AllSubjects_Data(iROI).name   '-WholeROI-BetweenSensesContra'];
    
    %% Basic condition
    ToPlot.Name = Name;
    ToPlot.Data = AllSubjects_Data(iROI).MVPA;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = 1:3;
    ToPlot.Legend = Legend;
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 1;
    
    PlotROIForFig(ToPlot)
    
    clear ToPlot
    
end

cd(StartDir)

