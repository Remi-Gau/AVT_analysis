clc; clear;

StartDir = fullfile(pwd, '..','..', '..','..', '..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf');
[~,~,~] = mkdir(FigureFolder);

load(fullfile(ResultsDir, strcat('ResultsSurfBOLDPoolWholeROI.mat')) , 'AllSubjects_Data')

SubLs = dir('sub*');
NbSub = numel(SubLs);
for iSub=1:size(SubLs,1)
    sets{iSub} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
% ToPermute = [];

%% Plots
for iROI = 1:length(AllSubjects_Data)
    
    close all
    
    fprintf([AllSubjects_Data(iROI).name '\n'])
    
    Name = strrep(AllSubjects_Data(iROI).name, '_', ' ');
    
    %% Basic condition
    ToPlot.Name = [Name '-WholeROI-Ipsilateral'];
    ToPlot.Data = AllSubjects_Data(iROI).Ispi;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = [1 2 3];
    ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 0;
    ToPlot.ToPermute = ToPermute;
    ToPlot.OneSideTTest = {'both'};
    
    PlotROIForFig(ToPlot)
    
    pause(.2)
    
    clear ToPlot
    
    %% Sensory modalities
    ToPlot.Name = [Name '-WholeROI-Contralateral'];
    ToPlot.Data = AllSubjects_Data(iROI).Contra;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = [1 2 3];
    ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 0;
    ToPlot.ToPermute = ToPermute;
    ToPlot.OneSideTTest = {'both'};
    
    PlotROIForFig(ToPlot)
    
    pause(.2)
    
    clear ToPlot
    
    
    %% Left VS Right
    ToPlot.Name = [Name '-WholeROI-Ipsi-Contra'];
    ToPlot.Data = AllSubjects_Data(iROI).Contra_VS_Ipsi;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = [1 2 3];
    ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 0;
    ToPlot.ToPermute = ToPermute;
    ToPlot.OneSideTTest = {'both'};
    
    PlotROIForFig(ToPlot)
    
    pause(.2)
    
    clear ToPlot
    
    
    %% Contrast between sensory modalities Ispi
    ToPlot.Name = [Name '-WholeROI-SensModContrastsIpsi'];
    ToPlot.Data = AllSubjects_Data(iROI).ContSensModIpsi;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = [1 2 3];
    ToPlot.Legend = {{'','Audio-Visual'}, {'','Audio-Tactile'} {'','Visual-Tactile'}};
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 0;
    ToPlot.ToPermute = ToPermute;
    ToPlot.OneSideTTest = {'both'};
    
    PlotROIForFig(ToPlot)
    
    pause(.2)
    
    clear ToPlot
    
    
    %% Contrast between sensory modalities Contra
    ToPlot.Name = [Name '-WholeROI-SensModContrastsContra'];
    ToPlot.Data = AllSubjects_Data(iROI).ContSensModContra;
    ToPlot.PlotSub = 1;
    ToPlot.SubPlotOrder = [1 2 3];
    ToPlot.Legend = {{'','Audio-Visual'}, {'','Audio-Tactile'} {'','Visual-Tactile'}};
    ToPlot.Visible='on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.MVPA = 0;
    ToPlot.ToPermute = ToPermute;
    ToPlot.OneSideTTest = {'both'};
    
    PlotROIForFig(ToPlot)
    
    pause(.2)
    
    clear ToPlot
    
end
cd(StartDir)



