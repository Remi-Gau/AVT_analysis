function All_ROIs_BOLD_targets_surf_plot
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'AVT-7T-code', 'subfun')))
Get_dependencies('D:\Dropbox/', 'D:\github/')

FigureFolder = fullfile(StartDir, 'figures');

BOLD_resultsDir = fullfile(StartDir, 'results', 'profiles','surf');

set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')

SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers=6;

% ROIs = {
%     'A1'
%     'PT'
%     'V1'
%     'V2'
%     'V3'
%     'V4'
%     'V5'};
% NbROI = numel(ROIs);
% ROI_order_BOLD = [1 NbROI 2:NbROI-1];

ROIs = {
    'A1'
    'PT'
    'V1'
    'V2'};
ROI_order_BOLD = [1 7 2:3];

ROIs_to_get = 1:7;

TitSuf = {
    'Contra_vs_Ipsi';...
    'Between_Senses';...
    'Contra_&_Ipsi';...
    'Targets-Stim'};

Test_side = [];

opt.vol = 0;


if opt.vol
    BOLD_resultsDir = fullfile(StartDir, 'results', 'profiles');
end

% load BOLD
Stim_prefix = 'Target';
load(fullfile(BOLD_resultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
AllSubjects_Data_BOLD = AllSubjects_Data;
clear AllSubjects_Data

load(fullfile(BOLD_resultsDir, strcat('ResultsSurfStimsTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
AllSubjects_Data_BOLD_StimTarget = AllSubjects_Data;
clear AllSubjects_Data

close all

for iAnalysis= 1:numel(TitSuf)
    
    clear ToPlot ToPlot2
    ToPlot.TitSuf = TitSuf{iAnalysis};
    ToPlot.ROIs_name = ROIs;
    ToPlot.Visible= 'on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.OneSideTTest = Test_side;
    
    ToPlot.profile.MEAN=[];
    ToPlot.profile.SEM=[];
    ToPlot.profile.beta=[];
    ToPlot.ROI.grp=[];
    
    
    %% Get BOLD
    switch iAnalysis
        case 1
            % Get BOLD data for Contra - Ipsi
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
            
            % which conditions goes into which column and row
            ToPlot.Col = [1 2 3];
            ToPlot.Row = 1;
            ToPlot.Cdt = 1:3;
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            % To know which type of data we are plotting every time
            ToPlot.IsMVPA = [...
                0 0 0];
            
            % Defines the number of subplots on each figure
            ToPlot.m=4;
            ToPlot.n=3;
            ToPlot.SubPlots = {... %Each column of this cell is a new condition
                [1 4] [2 5] [3 6];...
                7, 8, 9;...
                10, 11, 12;...
                13, 14, 15;... %The fourth row is for the plotting of the whole ROI
                };
            
            Legend{1,1} = 'Auditory';
            Legend{1,2} = 'Visual';
            Legend{1,3} = 'Tactile';
            
            ToPlot.Titles{1,1} = '[Contra - Ipsi]';
            ToPlot.Titles{2,1} = '[Contra VS Ipsi]';
            
            
            
        case 2
            % Get BOLD data for between senses contrasts (contra)
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModContra);
            ToPlot.Col = 1;
            ToPlot.Row = 1:2;
            ToPlot.Cdt = [...
                2 2;... % Skip 1 so to not plot the contrast and SVC or [A vs V]
                3 3;...
                2 2;...
                3 3];
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            % Get BOLD data for between senses contrasts (ipsi)
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModIpsi);
            ToPlot.Col = 2;
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            % To know which type of data we are plotting every time
            ToPlot.IsMVPA = [...
                0 0; ...
                0 0];
            
            % Defines the number of subplots on each figure
            ToPlot.m=4;
            ToPlot.n=2;
            ToPlot.SubPlots = {...
                [1 3] [2 4];...
                5, 6;...
                7, 8;...
                9, 10;...
                };
            
            Legend{1,2} = 'ipsi';
            Legend{1,1} = 'contra';
            Legend{2,2} = 'ipsi';
            Legend{2,1} = 'contra';
            
            
            ToPlot.MinMax{1,1} = [-0.3 8;-0.3 8];
            ToPlot.MinMax{2,1} = [-2 7;-2 7];
            ToPlot.MinMax{3,1} = [-0.5 2;-0.5 2];
            
            ToPlot.MinMax{1,2}=[-1.5 3.5;-1.5 3.5];
            ToPlot.MinMax{2,2}=[-2 3.5;-2 3.5];
            ToPlot.MinMax{3,2}=[-1 1.5;-1 1.5];
            
            
            ToPlot.Titles{1,1} = '[A - T]';
            ToPlot.Titles{2,1} = '[V - T]';
            
            
            
            
        case 3
            % Get BOLD data for Cdt-Fix Contra
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra);
            ToPlot.Col = 1;
            ToPlot.Row = 1:3;
            ToPlot.Cdt = [1;2;3];
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            Data = cat(1,AllSubjects_Data_BOLD(:).Ispi);
            ToPlot.Col = 2;
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            ToPlot.IsMVPA = [...
                0 0;...
                0 0;...
                0 0];
            
            ToPlot.OneSideTTest = ...
                cat(3, ...
                [3 3 2 2;
                2 2 3 3;
                3 3 2 2],...
                2*ones(3,4),...
                [3 3 2 2;
                1 1 3 3;
                3 3 2 2]);
            
            ToPlot.m=4;
            ToPlot.n=2;
            ToPlot.SubPlots = {...
                [1 3] [2 4];...
                5, 6;...
                7, 8;...
                9, 10;...
                };
            
            Legend{1,1} = 'contra';
            Legend{2,1} = 'contra';
            Legend{3,1} = 'contra';
            Legend{1,2} = 'ipsi';
            Legend{2,2} = 'ipsi';
            Legend{3,2} = 'ipsi';
            
            ToPlot.Titles{1,1} = '[A - Fix]';
            ToPlot.Titles{2,1} = '[V - Fix]';
            ToPlot.Titles{3,1} = '[T - Fix]';
            
            % set maximum and minimum for B parameters profiles (row 1) and
            % for S param (row 2: Cst; row 3: Lin)
            ToPlot.MinMax={...
                repmat([-.1 9.5],2,1) , repmat([-1 4.5],2,1) , repmat([-.4 3],2,1);...
                repmat([-1 7.5],2,1) , repmat([-2 5],2,1) , repmat([-2 4],2,1);...
                repmat([-0.8 2.4],2,1) , repmat([-.8 1.6],2,1) , repmat([-.75 1.3],2,1);...
                };
            
            
        case 4
            % Get BOLD data for Target-Stim Contra
            Data = cat(1,AllSubjects_Data_BOLD_StimTarget(:).StimTargContra);
            ToPlot.Col = 1;
            ToPlot.Row = 1:3;
            ToPlot.Cdt = [1;2;3];
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            % Get BOLD data for Target-Stim Ipsi
            Data = cat(1,AllSubjects_Data_BOLD_StimTarget(:).StimTargIpsi);
            ToPlot.Col = 2;
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            % Switch sign as it was originally computed as Stim-Targets
            for i=1:numel(ToPlot.profile)
                ToPlot.profile(i).MEAN = ToPlot.profile(i).MEAN*-1;
                ToPlot.profile(i).beta = ToPlot.profile(i).beta*-1;
            end
            
            ToPlot.IsMVPA = [...
                0 0;...
                0 0;...
                0 0];
            
            ToPlot.m=4;
            ToPlot.n=2;
            ToPlot.SubPlots = {...
                [1 3] [2 4];...
                5, 6;...
                7, 8;...
                9, 10;...
                };
            
            Legend{1,1} = 'contra';
            Legend{2,1} = 'contra';
            Legend{3,1} = 'contra';
            Legend{1,2} = 'ipsi';
            Legend{2,2} = 'ipsi';
            Legend{3,2} = 'ipsi';
            
            ToPlot.Titles{1,1} = '[Targets - Stimuli]_A';
            ToPlot.Titles{2,1} = '[Targets - Stimuli]_V';
            ToPlot.Titles{3,1} = '[Targets - Stimuli]_T';
            
            % set maximum and minimum for B parameters profiles (row 1) and
            % for S param (row 2: Cst; row 3: Lin)
            ToPlot.MinMax={...
                repmat([-.1 5.5],2,1) , repmat([-.5 3.5],2,1) , repmat([-.4 3.25],2,1);...
                repmat([-.5 4],2,1) , repmat([-1.5 4.4],2,1) , repmat([-1.8 4.2],2,1);...
                repmat([-0.5 1.5],2,1) , repmat([-.5 1.8],2,1) , repmat([-.7 1.8],2,1);...
                };
            
    end
    
    
    %% Plot
    for WithPerm = 1
        
        sets = {};
        for iSub=1:NbSub
            sets{iSub} = [-1 1]; %#ok<*AGROW>
        end
        [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
        ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
        
        if ~WithPerm
            ToPermute = [];
        end
        
        ToPlot.Legend = Legend; clear Legend
        ToPlot.ToPermute = ToPermute;
        if opt.vol
            %             ToPlot.Name = ['BOLD_vol-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
        else
            %              ToPlot.Name = ['BOLD-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
            ToPlot.Name = ['BOLD-' Stim_prefix];
        end
        
        
        Plot_BOLD_MVPA_all_ROIs(ToPlot)
        
        
    end
    
end

cd(StartDir)

end



function ToPlot = Get_data(ToPlot,Data,ROI_order)
ROI_idx = 1;
for iROI = ROI_order
    for iRow = 1:numel(ToPlot.Row)
        for iCol = 1:numel(ToPlot.Col)
            
            ToPlot.profile(ToPlot.Row(iRow),ToPlot.Col(iCol)).MEAN(:,ROI_idx) = Data(iROI).MEAN(:,ToPlot.Cdt(iRow,iCol));
            ToPlot.profile(ToPlot.Row(iRow),ToPlot.Col(iCol)).SEM(:,ROI_idx) = Data(iROI).SEM(:,ToPlot.Cdt(iRow,iCol));
            
            if isfield(Data, 'whole_roi_grp')
                ToPlot.ROI(ToPlot.Row(iRow),ToPlot.Col(iCol)).grp(:,ROI_idx,:) = Data(iROI).whole_roi_grp(:,ToPlot.Cdt(iRow,iCol));
            end
            
            % Do not plot quadratic
            % 1rst dimension: subject
            % 2nd dimension: ROI
            % 3rd dimension: Cst, Lin
            % 4th dimension : different conditions (e.g A, V, T)
            ToPlot.profile(ToPlot.Row(iRow),ToPlot.Col(iCol)).beta(:,ROI_idx,:,:) = shiftdim(Data(iROI).Beta.DATA(1:2,ToPlot.Cdt(iRow,iCol),:),2);
        end
    end
    ROI_idx = ROI_idx + 1;
end
end


function Data = Get_data_MVPA(ROIs,SubSVM,iSubSVM,SVM)
for iROI = 1:numel(ROIs)
    
    for iSVM = SubSVM(iSubSVM,:)
        
        Data(iROI).whole_roi_grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp;
        
        Data(iROI).MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = ...
            flipud(SVM(iSVM).ROI(iROI).layers.MEAN(1:end)');
        Data(iROI).SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = ...
            flipud(SVM(iSVM).ROI(iROI).layers.SEM(1:end)');
        Data(iROI).Beta.DATA(:,iSVM+1-SubSVM(iSubSVM,1),:) = ...
            reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA, [3,1,size(SVM(iSVM).ROI(iROI).layers.Beta.DATA,2)]);
        
    end
    
end
end