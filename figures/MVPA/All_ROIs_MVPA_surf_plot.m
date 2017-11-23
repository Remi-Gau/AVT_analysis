function All_ROIs_MVPA_surf_plot
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

ResultsDir = fullfile(StartDir, 'results', 'SVM');
FigureFolder = fullfile(StartDir, 'figures', 'SVM', 'surf');

SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers=6;


SubSVM = [1:3;4:6;7:9];

TitSuf = {
    'Contra_vs_Ipsi';...
    'Between_Senses_Ipsi';...
    'Between_Senses_Contra'};

opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;



for WithPerm = 1
    
    sets = {};
    for iSub=1:NbSub
        sets{iSub} = [-1 1];
    end
    [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
    ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
    
    if ~WithPerm
        ToPermute = [];
    end
    
    for Norm = 6
        
        switch Norm
            case 5
                opt.scaling.img.eucledian = 0;
                opt.scaling.img.zscore = 1;
                opt.scaling.feat.mean = 0;
                opt.scaling.feat.range = 1;
                opt.scaling.feat.sessmean = 0;
            case 6
                opt.scaling.img.eucledian = 0;
                opt.scaling.img.zscore = 1;
                opt.scaling.feat.mean = 1;
                opt.scaling.feat.range = 0;
                opt.scaling.feat.sessmean = 0;
            case 7
                opt.scaling.img.eucledian = 0;
                opt.scaling.img.zscore = 0;
                opt.scaling.feat.mean = 1;
                opt.scaling.feat.range = 0;
                opt.scaling.feat.sessmean = 0;
            case 8
                opt.scaling.img.eucledian = 0;
                opt.scaling.img.zscore = 0;
                opt.scaling.feat.mean = 0;
                opt.scaling.feat.range = 0;
                opt.scaling.feat.sessmean = 0;
        end
        
        SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);
        
        %% Plot Stim and targets alone
        close all
        
        for IsStim = 1
            
            if IsStim
                Stim_prefix = 'Stimuli-';
                File2Load = fullfile(ResultsDir, strcat('GrpNoPoolQuadGLM', SaveSufix)); %#ok<*UNRCH>
            else
                Stim_prefix = 'Target-';
                File2Load = fullfile(ResultsDir, strcat('GrpTargetsNoPoolQuadGLM', SaveSufix)); %#ok<*UNRCH>
            end
            
            if exist(File2Load, 'file')
                load(File2Load, 'SVM', 'opt')
            else
                warning('This file %s does not exist', File2Load)
            end
            
            %% Regorganize data
            
            for iSubSVM=1:numel(TitSuf)
                
                for iROI = 1:numel(SVM(1).ROI)
                    
                    AllSubjects_Data(iROI,1).name = SVM(1).ROI(iROI).name;
                    
                    tmp = {SVM.name}';
                    Legend = cell(3,1);
                    
                    for iSVM = SubSVM(iSubSVM,:)
                        
                        for ihs = 1:2
                            Legend{iSVM+1-SubSVM(iSubSVM,1)} = {tmp{iSVM}};
                            
                            AllSubjects_Data(iROI,ihs).whole_roi_grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp(:,ihs);
                            
                            AllSubjects_Data(iROI,ihs).MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.MEAN(ihs,1:end)');
                            AllSubjects_Data(iROI,ihs).SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.SEM(ihs,1:end)');
                            AllSubjects_Data(iROI,ihs).Beta.DATA(:,iSVM+1-SubSVM(iSubSVM,1),:) = ...
                                reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA(:,:,ihs), [3,1,size(SVM(iSVM).ROI(iROI).layers.Beta.DATA(:,:,ihs),2)]);
                        end
                    end
                    
                end
                
                
                %% Plot
                disp({AllSubjects_Data.name}')
                
                NbROI = length(AllSubjects_Data);
                ROI_order = [NbROI-1 NbROI 1:NbROI-2];
                
                ROI_idx = 1;
                for iROI = ROI_order
                    ToPlot.ROIs_name{ROI_idx} = AllSubjects_Data(iROI).name;
                    ROI_idx = ROI_idx + 1;
                end
                ToPlot.SubPlotOrder = [1 2 3];
                
                ToPlot.Legend = Legend;
                ToPlot.YLabel = 'Decoding accuracy';
                ToPlot.Visible= 'on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 1;
                ToPlot.ToPermute = ToPermute;
                ToPlot.OneSideTTest = {'both' 'both' 'both'};
                
                for ihs = 1:2
                    if ihs==1
                        ToPlot.Name = ['MVPA-LHS-' Stim_prefix TitSuf{iSubSVM} '\n' SaveSufix(15:end-12)];
                    else
                        ToPlot.Name = ['MVPA-RHS-' Stim_prefix TitSuf{iSubSVM} '\n' SaveSufix(15:end-12)];
                    end
                    ToPlot = GetData(ToPlot,AllSubjects_Data(:,ihs),ROI_order);
                    plot_all_ROIs(ToPlot)
                end
                
            end
            
        end
        
    end
    
end
cd(StartDir)

end

function ToPlot = GetData(ToPlot,Data,ROI_order)
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