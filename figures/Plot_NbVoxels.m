clc; clear;

close all

StartDir = fullfile(pwd, '..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'profiles');
[~,~,~] = mkdir(ResultsDir);

FigureFolder = fullfile(StartDir, 'figures');

SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

load( fullfile(ResultsDir, strcat('NbVoxels_l-', num2str(NbLayers), '.mat')) )

% Color for Subjects
COLOR_Subject= [
    31,120,180;
    178,223,138;
    51,160,44;
    251,154,153;
    227,26,28;
    253,191,111;
    255,127,0;
    202,178,214;
    106,61,154;
    0,0,130];
COLOR_Subject=COLOR_Subject/255;


% ToPLot= {...
%     {'A1_L','PT_L'};...
%     {'V1_L_thres','V2_L_thres','V3_L_thres','V4_L_thres','V5_L_thres'};...
%     {'S1_L_cyt', 'S1_L_aal'} };

ToPLot= {...
    {'A1_L','PT_L'};...
    {'V1_L_thres','V2_L_thres','V3_L_thres','V4_L_thres','V5_L_thres'};...
    {'S1_L_cyt'} };

FigDim = [100 100 1500 1000];
Visible = 'on';

Scatter = linspace(1.1,1.5,NbSub);

SubjectList = char({SubLs.name}');
SubjectList(:,1:4) = [];


%%
figure('position', FigDim, 'name', 'ROI size', 'Color', [1 1 1], 'visible', Visible)

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

iSubPlot = 1;

for iToPlot = 1:size(ToPLot,1)
    
    for iROI = 1:numel(ToPLot{iToPlot,1})
        
        
        Idx = find(strcmp({AllSubjects_Data.name}',ToPLot{iToPlot,1}{iROI}));
        
        subplot(size(ToPLot,1),2,iSubPlot)
        hold on
        errorbar(iROI,AllSubjects_Data(Idx).size.MEAN(1,1), AllSubjects_Data(Idx).size.STD(1,1), '.k')
        for iSubj=1:NbSub
            plot((iROI-1)*1+Scatter(iSubj),AllSubjects_Data(Idx).size.data(iSubj,1), 'marker', '.', 'markersize', 30, ....
                'color', COLOR_Subject(iSubj,:))
        end
        XtickLabel1{iROI}=strrep(AllSubjects_Data(Idx).name,'_',' ');
        set(gca,'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot,1}), 'xticklabel', XtickLabel1)
        axis([0.9 numel(ToPLot{iToPlot,1})+.6 0 160000])
        
        
        
        Idx2 = find(strcmp({AllSubjects_Data.name}',strrep(AllSubjects_Data(Idx).name, 'L', 'R')));
        
        subplot(size(ToPLot,1),2,iSubPlot+1)
        hold on
        errorbar(iROI,AllSubjects_Data(Idx2).size.MEAN(1,1), AllSubjects_Data(Idx2).size.STD(1,1), '.k')
        for iSubj=1:NbSub
            plot((iROI-1)*1+Scatter(iSubj),AllSubjects_Data(Idx2).size.data(iSubj,1), 'marker', '.', 'markersize', 30, ....
                'color', COLOR_Subject(iSubj,:))
        end
        XtickLabel2{iROI}=strrep(AllSubjects_Data(Idx2).name,'_',' ');
        set(gca,'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot,1}), 'xticklabel', XtickLabel2)
        axis([0.9 numel(ToPLot{iToPlot,1})+.6 0 160000])

    end
    
    clear XtickLabel1 XtickLabel2
    
    iSubPlot = iSubPlot + 2;
    
end

subplot(size(ToPLot,1),2,1)
title('LEFT')
subplot(size(ToPLot,1),2,2)
title('RIGHT')

mtit('ROI size', 'xoff',0,'yoff',.025)

print(gcf, fullfile(FigureFolder, 'NbVoxelLeftRightROI_vol.tif'), '-dtiff')



%%
figure('position', FigDim, 'name', 'ROI coverage', 'Color', [1 1 1], 'visible', Visible)

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

iSubPlot = 1;

for iToPlot = 1:size(ToPLot,1)
    
    for iROI = 1:numel(ToPLot{iToPlot,1})
        
        
        Idx = find(strcmp({AllSubjects_Data.name}',ToPLot{iToPlot,1}{iROI}));
        
        subplot(size(ToPLot,1),2,iSubPlot)
        hold on
        errorbar(iROI,...
            mean(AllSubjects_Data(Idx).size.data(:,1)./AllSubjects_Data(Idx).size.data(:,2)),...
            std(AllSubjects_Data(Idx).size.data(:,1)./AllSubjects_Data(Idx).size.data(:,2)), '.k')
        for iSubj=1:NbSub
            plot((iROI-1)*1+Scatter(iSubj),AllSubjects_Data(Idx).size.data(iSubj,1)/AllSubjects_Data(Idx).size.data(iSubj,2), 'marker', '.', 'markersize', 30, ....
                'color', COLOR_Subject(iSubj,:))
        end
        XtickLabel1{iROI}=strrep(AllSubjects_Data(Idx).name,'_',' ');
        set(gca,'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot,1}), 'xticklabel', XtickLabel1)
        axis([0.9 numel(ToPLot{iToPlot,1})+.6 0 1])
        
        
        
        Idx2 = find(strcmp({AllSubjects_Data.name}',strrep(AllSubjects_Data(Idx).name, 'L', 'R')));
        
        subplot(size(ToPLot,1),2,iSubPlot+1)
        hold on
        errorbar(iROI,...
            mean(AllSubjects_Data(Idx2).size.data(:,1)./AllSubjects_Data(Idx2).size.data(:,2)),...
            std(AllSubjects_Data(Idx2).size.data(:,1)./AllSubjects_Data(Idx2).size.data(:,2)), '.k')
        for iSubj=1:NbSub
            plot((iROI-1)*1+Scatter(iSubj),AllSubjects_Data(Idx2).size.data(iSubj,1)/AllSubjects_Data(Idx2).size.data(iSubj,2), 'marker', '.', 'markersize', 30, ....
                'color', COLOR_Subject(iSubj,:))
        end
        XtickLabel2{iROI}=strrep(AllSubjects_Data(Idx2).name,'_',' ');
        set(gca,'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot,1}), 'xticklabel', XtickLabel2)
        axis([0.9 numel(ToPLot{iToPlot,1})+.6 0 1])

    end
    
    clear XtickLabel1 XtickLabel2
    
    iSubPlot = iSubPlot + 2;
    
end

subplot(size(ToPLot,1),2,1)
title('LEFT')
subplot(size(ToPLot,1),2,2)
title('RIGHT')

mtit('ROI size', 'xoff',0,'yoff',.025)
print(gcf, fullfile(FigureFolder, 'CoverageLeftRightROI_vol.tif'), '-dtiff')




