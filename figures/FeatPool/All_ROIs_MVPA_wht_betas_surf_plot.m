function All_ROIs_MVPA_wht_betas_surf_plot
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

FigureFolder = fullfile(StartDir, 'figures');

MVPA_resultsDir = fullfile(StartDir, 'results', 'SVM');

IsStim = 1;

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
ROI_order_MVPA = 1:5;

TitSuf = {
    'Contra_vs_Ipsi';...
    'Between_Senses-IC';...
    'Left_vs_Right';...
    'Between_Senses-LR';...
    };

SubSVM = [1:3;4:6;7:9;10:12;13:15;16:18];

opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;
opt.session.loro = 0;
opt.MVNN = 1;

opt.scaling.img.eucledian = 0;
opt.scaling.img.zscore = 1;
opt.scaling.feat.mean = 1;
opt.scaling.feat.range = 0;
opt.scaling.feat.sessmean = 0;

ParamToPlot={'Cst','Lin','Avg','ROI'};

for iToPlot = 2
    
    opt.toplot = ParamToPlot{iToPlot};
    
    SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);
    
    % load MVPA
    if IsStim
        Stim_prefix = 'Stimuli';
        File2Load = fullfile(MVPA_resultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
    else
        Stim_prefix = 'Target';
        File2Load = fullfile(MVPA_resultsDir, strcat('GrpTargetsPoolQuadGLM', SaveSufix)); %#ok<*UNRCH>
    end
    
    if exist(File2Load, 'file')
        load(File2Load, 'SVM', 'opt')
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
                % which conditions goes into which column and row
                ToPlot.Col = [1 2 3];
                ToPlot.Row = 1;
                ToPlot.Cdt = 1:3;
                
                % Same for the MVPA data
                ToPlot.Row = 1; % a new row means a new figure
                Data = Get_data_MVPA(1:5,SubSVM,1,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                % Defines the number of subplots on each figure
                ToPlot.m=1;
                ToPlot.n=3;
                ToPlot.SubPlots = {1,2,3};
                
                Legend{1,1} = 'Auditory';
                Legend{1,2} = 'Visual';
                Legend{1,3} = 'Tactile';
                
                ToPlot.Titles{1,1} = '[Contra VS Ipsi]';
                
                
            case 2
                % Same for the MVPA data (contra)
                ToPlot.Col = 1;
                ToPlot.Row = 1:2;
                ToPlot.Cdt = [...
                    2 2;... % Skip 1 so to not plot the contrast and SVC for [A vs V]
                    3 3];
                Data = Get_data_MVPA(1:5,SubSVM,3,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                % Same for the MVPA data (ipsi)
                ToPlot.Col = 2;
                Data = Get_data_MVPA(1:5,SubSVM,2,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                
                % Defines the number of subplots on each figure
                ToPlot.m=1;
                ToPlot.n=2;
                ToPlot.SubPlots = {1,2};
                
                Legend{1,2} = 'ipsi';
                Legend{1,1} = 'contra';
                Legend{2,2} = 'ipsi';
                Legend{2,1} = 'contra';
                
                ToPlot.Titles{1,1} = '[A VS T]';
                ToPlot.Titles{2,1} = '[V VS T]';
                
                
            case 3
                % which conditions goes into which column and row
                ToPlot.Col = [1 2 3];
                ToPlot.Row = 1;
                ToPlot.Cdt = 1:3;
                
                % Same for the MVPA data
                ToPlot.Row = 1; % a new row means a new figure
                Data = Get_data_MVPA(1:5,SubSVM,4,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                % Defines the number of subplots on each figure
                ToPlot.m=1;
                ToPlot.n=3;
                ToPlot.SubPlots = {1,2,3};
                
                Legend{1,1} = 'Auditory';
                Legend{1,2} = 'Visual';
                Legend{1,3} = 'Tactile';
                
                ToPlot.Titles{1,1} = '[Left VS Right]';
                
                
            case 4
                % Same for the MVPA data (contra)
                ToPlot.Col = 1;
                ToPlot.Row = 1:2;
                ToPlot.Cdt = [...
                    2 2;... % Skip 1 so to not plot the contrast and SVC for [A vs V]
                    3 3];
                Data = Get_data_MVPA(1:5,SubSVM,6,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                % Same for the MVPA data (ipsi)
                ToPlot.Col = 2;
                Data = Get_data_MVPA(1:5,SubSVM,5,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                
                % Defines the number of subplots on each figure
                ToPlot.m=1;
                ToPlot.n=2;
                ToPlot.SubPlots = {1,2};
                
                Legend{1,2} = 'right';
                Legend{1,1} = 'left';
                Legend{2,2} = 'right';
                Legend{2,1} = 'left';
                
                ToPlot.Titles{1,1} = '[A VS T]';
                ToPlot.Titles{2,1} = '[V VS T]';
        end
        
        
        %% Plot
        sets = {};
        for iSub=1:10%NbSub
            sets{iSub} = [-1 1]; %#ok<*AGROW>
        end
        [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
        ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
        %     ToPermute = [];
        
        ToPlot.Legend = Legend; clear Legend
        ToPlot.ToPermute = ToPermute;
        ToPlot.Name = ['MVPA-wht_betas-' Stim_prefix '\n' SaveSufix(15:end-12)];
        
        Plot_MVPA_wht_betas_all_ROIs(ToPlot)
        
        
    end
    
    cd(StartDir)
    
end

end



function ToPlot = Get_data(ToPlot,Data,ROI_order)
ROI_idx = 1;
for iROI = ROI_order
    for iRow = 1:numel(ToPlot.Row)
        for iCol = 1:numel(ToPlot.Col)
            ToPlot.ROI(ToPlot.Row(iRow),ToPlot.Col(iCol)).grp(:,ROI_idx,:) = Data(iROI).whole_roi_grp(:,ToPlot.Cdt(iRow,iCol));
        end
    end
    ROI_idx = ROI_idx + 1;
end
end


function Data = Get_data_MVPA(ROIs,SubSVM,iSubSVM,SVM)
for iROI = 1:numel(ROIs)
    for iSVM = SubSVM(iSubSVM,:)
        Data(iROI).whole_roi_grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp;
    end
end
end