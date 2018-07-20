function All_ROIs_BOLD_MVPA_surf_plot
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

FigureFolder = fullfile(StartDir, 'figures');

MVPA_resultsDir = fullfile(StartDir, 'results', 'SVM');
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
% ROI_order_MVPA = [NbROI-1 NbROI 1:NbROI-2];

ROIs = {
    'A1'
    'PT'
    'V1'
    'V2'
    'V3'};
ROI_order_BOLD = [1 7 2:4];
ROI_order_MVPA = [6 7 1:3];

ROIs_to_get = 1:7;

TitSuf = {
    'Contra_vs_Ipsi';...
    'Between_Senses';...
    'Contra_&_Ipsi'};

SubSVM = [1:3;4:6;7:9];


opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;
opt.session.loro = 0;
opt.MVNN = 1;
opt.vol = 0;

if opt.MVNN
    ParamToPlot={'Cst','Lin','Avg','ROI'};
    opt.toplot = ParamToPlot{4};
    ROI_order_MVPA = 1:5;
    ROIs_to_get = 1:5;
    SubSVM = [1:3;4:6;7:9;10:12;13:15;16:18];
    suffix = 'Wht_Betas';
end

if opt.vol
    BOLD_resultsDir = fullfile(StartDir, 'results', 'profiles');
end

opt.scaling.img.eucledian = 0;
opt.scaling.img.zscore = 1;
opt.scaling.feat.mean = 1;
opt.scaling.feat.range = 0;
opt.scaling.feat.sessmean = 0;

SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);

% load BOLD and MVPA
if IsStim
    Stim_prefix = 'Stimuli';
    if opt.MVNN
        if opt.vol
            load( fullfile(BOLD_resultsDir, strcat('ResultsVolWhtBetasPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data' )
        else
            load( fullfile(BOLD_resultsDir, strcat('ResultsSurfPoolQuadGLM',suffix,'_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data' )
        end
    else
        load( fullfile(BOLD_resultsDir, strcat('ResultsSurfPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data' )
    end
    File2Load = fullfile(MVPA_resultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
else
    Stim_prefix = 'Target';
    load(fullfile(BOLD_resultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
    File2Load = fullfile(MVPA_resultsDir, strcat('GrpTargetsPoolQuadGLM', SaveSufix)); %#ok<*UNRCH>
end

AllSubjects_Data_BOLD = AllSubjects_Data;
clear AllSubjects_Data

if exist(File2Load, 'file')
    load(File2Load, 'SVM')
else
    warning('This file %s does not exist', File2Load)
end

close all

for iAnalysis= 1:numel(TitSuf)
    
    clear ToPlot ToPlot2
    ToPlot.TitSuf = TitSuf{iAnalysis};
    ToPlot.ROIs_name = ROIs;
    ToPlot.Visible= 'on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.OneSideTTest = {'both' 'both'};
    
    ToPlot.profile.MEAN=[];
    ToPlot.profile.SEM=[];
    ToPlot.profile.beta=[];
    ToPlot.ROI.grp=[];
    
    ToPlot.MVPA.MEAN=[];
    ToPlot.MVPA.SEM=[];
    ToPlot.MVPA.beta=[];
    ToPlot.MVPA.grp=[];
    
    
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
            
            % Same for the MVPA data
            ToPlot.Row = 2; % a new row means a new figure
            Data = Get_data_MVPA(ROIs_to_get,SubSVM,iAnalysis,SVM);
            ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
            
            % To know which type of data we are plotting every time
            ToPlot.IsMVPA = [...
                0 0 0; ...
                1 1 1];
            
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
            Legend{2,1} = 'Auditory';
            Legend{2,2} = 'Visual';
            Legend{2,3} = 'Tactile';
            
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
            
            % Same for the MVPA data (contra)
            ToPlot.Col = 1;
            ToPlot.Row = 3:4;
            Data = Get_data_MVPA(ROIs_to_get,SubSVM,3,SVM);
            ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
            
            % Same for the MVPA data (ipsi)
            ToPlot.Col = 2;
            ToPlot.Row = 3:4;
            Data = Get_data_MVPA(ROIs_to_get,SubSVM,2,SVM);
            ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
            
            % To know which type of data we are plotting every time
            ToPlot.IsMVPA = [...
                0 0; ...
                0 0; ...
                1 1; ...
                1 1];
            
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
            Legend{3,2} = 'ipsi';
            Legend{3,1} = 'contra';
            Legend{4,2} = 'ipsi';
            Legend{4,1} = 'contra';
            
            tmp={...
                [-0.3 4.5;-0.3 4.5] , [.42 1;.42 1];...
                [-1 4;-1 4] , [-.15 .62;-.15 .62];...
                [-0.2 1.3;-0.2 1.3] , [-.1 .2;-.1 .2];...
                };
            
            for i=1:2
                for j = 1:3
                    ToPlot.MinMax{j,i}=tmp{j,1};
                end
            end
            ToPlot.MinMax{1,2}=[-0.5 2.3;-0.5 2.3];
            ToPlot.MinMax{2,2}=[-.8 3.1;-.8 3.1];
            ToPlot.MinMax{3,2}=[-0.3 .8;-0.3 .8];
            for i=3:4
                for j = 1:3
                    ToPlot.MinMax{j,i}=tmp{j,2};
                end
            end
            
            if opt.MVNN
                ToPlot = rmfield(ToPlot,'MinMax');
            end
            
            ToPlot.Titles{1,1} = '[A - T]';
            ToPlot.Titles{2,1} = '[V - T]';
            ToPlot.Titles{3,1} = '[A VS T]';
            ToPlot.Titles{4,1} = '[V VS T]';
             
            
            
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
                repmat([-1 4.2],2,1) , repmat([-1.2 2.2],2,1) , repmat([-1.4 0.1],2,1);...
                repmat([-1.2 4],2,1) , repmat([-1.5 2.5],2,1) , repmat([-1.5 1],2,1);...
                repmat([-0.4 1.3],2,1) , repmat([-0.4 0.65],2,1) , repmat([-0.5 0.35],2,1);...
                };
            
            if opt.MVNN
                ToPlot = rmfield(ToPlot,'MinMax');
            end
            
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
            ToPlot.Name = ['BOLD_vol-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
        else
             ToPlot.Name = ['BOLD-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
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