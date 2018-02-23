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

set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')

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
    'Between_Senses_Contra';
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

for iSubSVM= 1:numel(TitSuf)
    
    clear ToPlot ToPlot2
    ToPlot.TitSuf = TitSuf{iSubSVM};
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
    switch iSubSVM
        case 1
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
            Legend{1,1} = 'BOLD - [Contra-Ipsi]_A';
            Legend{2,1} = 'BOLD - [Contra-Ipsi]_V'; 
            Legend{3,1} = 'BOLD - [Contra-Ipsi]_T'; 
            Legend{1,2} = 'MVPA - [Contra VS Ipsi]_A';
            Legend{2,2} = 'MVPA - [Contra VS Ipsi]_V';
            Legend{3,2} = 'MVPA - [Contra VS Ipsi]_T'; 
            
            ToPlot.Titles{1,1} = '[Contra-Ipsi]_A';
            ToPlot.Titles{2,1} = '[Contra-Ipsi]_V';
            ToPlot.Titles{3,1} = '[Contra-Ipsi]_T';
                      
        case 2
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModIpsi);
            Legend{1,1} = 'BOLD - [A-T]_{ipsi}';
            Legend{2,1} = 'BOLD - [V-T]_{ipsi}';
            Legend{1,2} = 'MVPA - [A VS T]_{ipsi}';
            Legend{2,2} = 'MVPA - [V VS T]_{ipsi}';
            
            ToPlot.Titles{1,1} = '[A-T]';
            ToPlot.Titles{2,1} = '[V-T]';
            
            ToPlot.MinMax={...
                [-0.3 4.5;.42 1] , [-.5 3;.42 1];...
                [-1 4;-.15 .62] , [-1 4;-.15 .62];...
                [-0.2 1.3;-.1 .2] , [-0.2 1.3;-.1 .2];...
                };
            
        case 3
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModContra);
            Legend{1,1} = 'BOLD - [A-T]_{contra}'; 
            Legend{2,1} = 'BOLD - [V-T]_{contra}'; 
            Legend{1,2} = 'MVPA - [A VS T]_{contra}'; 
            Legend{2,2} = 'MVPA - [V VS T]_{contra}'; 
            
            ToPlot.Titles{1,1} = '[A-T]';
            ToPlot.Titles{2,1} = '[V-T]';
            
            ToPlot.MinMax={...
                [-0.3 4.5;.42 1] , [-.5 3;.42 1];...
                [-1 4;-.15 .62] , [-1 4;-.15 .62];...
                [-0.2 1.3;-.1 .2] , [-0.2 1.3;-.1 .2];...
                };
            
        case 4
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra);
            Legend{1,1} = 'BOLD - [A-Fix]_{contra}'; 
            Legend{2,1} = 'BOLD - [V-Fix]_{contra}'; 
            Legend{3,1} = 'BOLD - [T-Fix]_{contra}'; 
            Legend{1,2} = 'BOLD - [A-Fix]_{ipsi}'; 
            Legend{2,2} = 'BOLD - [V-Fix]_{ipsi}'; 
            Legend{3,2} = 'BOLD - [T-Fix]_{ipsi}'; 
            
            ToPlot.Titles{1,1} = '[A-Fix]';
            ToPlot.Titles{2,1} = '[V-Fix]';
            ToPlot.Titles{3,1} = '[T-Fix]';
            
            ToPlot.MinMax={...
                repmat([-1 4.2],2,1) , repmat([-1.2 2.2],2,1) , repmat([-1.4 0.1],2,1);...
                repmat([-1.2 4],2,1) , repmat([-1.5 2.5],2,1) , repmat([-1.5 1],2,1);...
                repmat([-0.4 1.3],2,1) , repmat([-0.4 0.65],2,1) , repmat([-0.5 0.35],2,1);...
                };
            
    end
    ToPlot = Get_data_BOLD(ToPlot,Data,ROI_order_BOLD);
    
    ToPlot.IsMVPA = [0 1;0 1;0 1];
    
    % Big ugly rearrangement of data to plot ispi and contra versus
    % baseline on the same figure... Yuck
    if iSubSVM==4
        ToPlot2.TitSuf = TitSuf{iSubSVM};
        Data = cat(1,AllSubjects_Data_BOLD(:).Ispi);
        ToPlot2 = Get_data_BOLD(ToPlot2,Data,ROI_order_BOLD);
        
        ToPlot.IsMVPA = [0 0;0 0;0 0];

        % Pass BOLD data as MVPA data but whatever...
        ToPlot.MVPA.MEAN=ToPlot2.profile.MEAN;
        ToPlot.MVPA.SEM=ToPlot2.profile.SEM;
        ToPlot.MVPA.beta=ToPlot2.profile.beta;
        ToPlot.MVPA.beta(:,:,2,:)=ToPlot.MVPA.beta(:,:,2,:)*-1;
        ToPlot.MVPA.grp=ToPlot2.ROI.grp;
    end
    
    %% Get MVPA
    if iSubSVM<4
        for iROI = 1:numel(ROIs)

            for iSVM = SubSVM(iSubSVM,:)

                AllSubjects_Data(iROI).whole_roi_grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp;
                
                AllSubjects_Data(iROI).MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.MEAN(1:end)');
                AllSubjects_Data(iROI).SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.SEM(1:end)');
                AllSubjects_Data(iROI).Beta.DATA(:,iSVM+1-SubSVM(iSubSVM,1),:) = ...
                    reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA, [3,1,size(SVM(iSVM).ROI(iROI).layers.Beta.DATA,2)]);
                
            end
            
        end
        ToPlot = Get_data_MVPA(ToPlot,AllSubjects_Data,ROI_order_MVPA);
        clear tmp
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
        ToPlot.Name = ['BOLD-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
        
        % Do not plot the contrast and SVC or [A vs V] and recombine ispi
        % and contra on the same figure.
        if iSubSVM==2 || iSubSVM==3
            ToPlot.ROI.grp(:,:,1)=[];
            ToPlot.profile.MEAN(:,:,1)=[];
            ToPlot.profile.SEM(:,:,1)=[];
            ToPlot.profile.beta(:,:,:,1)=[];
            ToPlot.MVPA.MEAN(:,:,1)=[];
            ToPlot.MVPA.SEM(:,:,1)=[];
            ToPlot.MVPA.beta(:,:,:,1)=[];
            ToPlot.MVPA.grp(:,:,1)=[];
        end
        
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
