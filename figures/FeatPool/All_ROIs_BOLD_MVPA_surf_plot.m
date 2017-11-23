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

IsStim = 1;

SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers=6;

ROIs = {
    'A1'
    'PT'
    'V1'
    'V2'
    'V3'
    'V4'
    'V5'};
NbROI = numel(ROIs);
ROI_order_BOLD = [1 NbROI 2:NbROI-1];
ROI_order_MVPA = [NbROI-1 NbROI 1:NbROI-2];

TitSuf = {
    'Contra_vs_Ipsi';...
    'Between_Senses_Ipsi';...
    'Between_Senses_Contra'};


SubSVM = [1:3;4:6;7:9];

opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;

opt.scaling.img.eucledian = 0;
opt.scaling.img.zscore = 1;
opt.scaling.feat.mean = 1;
opt.scaling.feat.range = 0;
opt.scaling.feat.sessmean = 0;

SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);

% load BOLD and MVPA
if IsStim
    Stim_prefix = 'Stimuli';
    load(fullfile(BOLD_resultsDir, strcat('ResultsSurfPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
    File2Load = fullfile(MVPA_resultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
else
    Stim_prefix = 'Target';
    load(fullfile(BOLD_resultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
    File2Load = fullfile(MVPA_resultsDir, strcat('GrpTargetsPoolQuadGLM', SaveSufix)); %#ok<*UNRCH>
end

AllSubjects_Data_BOLD = AllSubjects_Data;
clear AllSubjects_Data

if exist(File2Load, 'file')
    load(File2Load, 'SVM', 'opt')
else
    warning('This file %s does not exist', File2Load)
end

close all

for iSubSVM=1:numel(TitSuf)
    
    clear ToPlot
    ToPlot.TitSuf = TitSuf{iSubSVM};
    ToPlot.ROIs_name = ROIs;
    ToPlot.Visible= 'on';
    ToPlot.FigureFolder=FigureFolder;
    ToPlot.OneSideTTest = {'both' 'both'};
    
    
    %% Get BOLD
    switch iSubSVM
        case 1
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
        case 2
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModIpsi);
        case 3
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModContra);
    end
    ToPlot = Get_data_BOLD(ToPlot,Data,ROI_order_BOLD);
    
    
    %% Get MVPA
    for iROI = 1:numel(ROIs)
        
        tmp = {SVM.name}';
        Legend = cell(3,1);
        
        for iSVM = SubSVM(iSubSVM,:)
            
            Legend{iSVM+1-SubSVM(iSubSVM,1)} = tmp{iSVM};

            AllSubjects_Data(iROI).whole_roi_grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp;
            
            AllSubjects_Data(iROI).MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.MEAN(1:end)');
            AllSubjects_Data(iROI).SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.SEM(1:end)');
            AllSubjects_Data(iROI).Beta.DATA(:,iSVM+1-SubSVM(iSubSVM,1),:) = ...
                reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA, [3,1,size(SVM(iSVM).ROI(iROI).layers.Beta.DATA,2)]);
            
        end
        
    end
    ToPlot = Get_data_MVPA(ToPlot,AllSubjects_Data,ROI_order_MVPA);
    

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
        
        ToPlot.Legend = Legend;
        ToPlot.ToPermute = ToPermute;
        ToPlot.Name = ['BOLD-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
        
        Plot_BOLD_MVPA_all_ROIs(ToPlot)

    end
    
end

cd(StartDir)

end



function ToPlot = Get_data_BOLD(ToPlot,Data,ROI_order)
ROI_idx = 1;
for iROI = ROI_order
    ToPlot.profile.MEAN(:,ROI_idx,:) = Data(iROI).MEAN; %#ok<*SAGROW>
    ToPlot.profile.SEM(:,ROI_idx,:) = Data(iROI).SEM;
    % Do not plot quadratic
    % 1rst dimension: subject
    % 2nd dimension: ROI
    % 3rd dimension: Cst, Lin
    % 4th dimension : different conditions (e.g A, V, T)
    ToPlot.profile.beta(:,ROI_idx,:,:) = shiftdim(Data(iROI).Beta.DATA(1:2,:,:),2);
    ToPlot.ROI.grp(:,ROI_idx,:) = Data(iROI).whole_roi_grp;
    ROI_idx = ROI_idx + 1;
end
end


function ToPlot = Get_data_MVPA(ToPlot,Data,ROI_order)
ROI_idx = 1;
for iROI = ROI_order
    ToPlot.MVPA.MEAN(:,ROI_idx,:) = Data(iROI).MEAN; %#ok<*SAGROW>
    ToPlot.MVPA.SEM(:,ROI_idx,:) = Data(iROI).SEM;
    % Do not plot quadratic
    % 1rst dimension: subject
    % 2nd dimension: ROI
    % 3rd dimension: Cst, Lin
    % 4th dimension : different conditions (e.g A, V, T)
    ToPlot.MVPA.beta(:,ROI_idx,:,:) = shiftdim(Data(iROI).Beta.DATA(1:2,:,:),2);
    ToPlot.MVPA.grp(:,ROI_idx,:) = Data(iROI).whole_roi_grp;
    ROI_idx = ROI_idx + 1;
end
end
