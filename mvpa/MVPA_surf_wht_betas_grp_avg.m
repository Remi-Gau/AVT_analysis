function MVPA_surf_wht_betas_grp_avg

clc; clear;

StartDir = fullfile(pwd, '..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

ResultsDir = fullfile(StartDir, 'results', 'SVM');
[~,~,~] = mkdir(ResultsDir);

ToPlot={'Cst','Lin','Avg','ROI'};

NbLayers = 6;

% Options
opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;
opt.MVNN = 1;
opt.session.loro = 0;

SubLs = dir('sub*');
NbSub = numel(SubLs);

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [DesMat' ones(NbLayers,1)];
DesMat = spm_orth(DesMat);

for iToPlot = 4
    
    opt.toplot = ToPlot{iToPlot};
                 
    if iToPlot==4
        Do_layers = 1;
    else
        Do_layers = 0;
    end

for Norm = 6
    
    clear ROIs SVM
    
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
    
    
    % ROI
    ROIs(1) = struct('name', 'A1');
    ROIs(end+1) = struct('name', 'PT');
    
    ROIs(end+1) = struct('name', 'V1');
    ROIs(end+1) = struct('name', 'V2');
    ROIs(end+1) = struct('name', 'V3');
%     ROIs(end+1) = struct('name', 'V4');
%     ROIs(end+1) = struct('name', 'V5');
    

    % Analysis
    SVM(1) = struct('name', 'A Ipsi VS Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V Ipsi VS Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'T Ipsi VS Contra', 'ROI', 1:length(ROIs));
    
    SVM(end+1) = struct('name', 'A VS V Ipsi', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'A VS T Ipsi', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V VS T Ipsi', 'ROI', 1:length(ROIs));
    
    SVM(end+1) = struct('name', 'A VS V Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'A VS T Contra', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V VS T Contra', 'ROI', 1:length(ROIs));
    
    
    SVM(end+1) = struct('name', 'A_L VS A_R', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V_L VS V_R', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'T_L VS T_R', 'ROI', 1:length(ROIs));
    
    SVM(end+1) = struct('name', 'A_L VS V_L', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'A_L VS T_L', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V_L VS T_L', 'ROI', 1:length(ROIs));
    
    SVM(end+1) = struct('name', 'A_R VS V_R', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'A_R VS T_R', 'ROI', 1:length(ROIs));
    SVM(end+1) = struct('name', 'V_R VS T_R', 'ROI', 1:length(ROIs));


    for i=1:numel(SVM)
        SVM(i).ROI = struct('name', {ROIs(SVM(i).ROI).name}); %#ok<*AGROW>
    end
    
    %% Gets data for each subject
    for iSubj = 1:NbSub
        fprintf('\n\nProcessing %s', SubLs(iSubj).name)
        
        SubDir = fullfile(StartDir, SubLs(iSubj).name);
        SaveDir = fullfile(SubDir, 'results', 'SVM');
        
        for iSVM = 1:numel(SVM)
            fprintf('\n Running SVM:  %s', SVM(iSVM).name)
            
            for iROI=1:numel(ROIs)
                
                File2Load = fullfile(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]));
                
                if exist(File2Load,'file')
                    
                    load(File2Load, 'Results', 'Class_Acc', 'opt')

                    SVM(iSVM).ROI(iROI).grp(iSubj) = Class_Acc.TotAcc;
                    if Do_layers
                        SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj) = Class_Acc.TotAccLayers{1};
                    end
                    
                    % Extract results
                    CV = Results.session(end).rand.perm.CV;
                    NbCV = size(CV,1); %#ok<*NODEF>
                    
                    for iCV=1:NbCV
                        
                        % For the whole ROI
                        SVM(iSVM).ROI(iROI).DATA{iSubj}(iCV) = CV(iCV).acc;
                        
                        if Do_layers
                            for iLayer = 1:NbLayers
                                label = CV(iCV).layers.results{1}{iLayer}.label;
                                pred = CV(iCV).layers.results{1}{iLayer}.pred(:,iLayer);
                                
                                SVM(iSVM).ROI(iROI).layers.DATA{iSubj}(iLayer,iCV) = mean(pred==label);
                                clear pred label
                            end
                        end
                        
                    end
                    
                else
                    warning('\nThe file %s was not found.', File2Load)

                    SVM(iSVM).ROI(iROI).DATA{iSubj} = [];
                    SVM(iSVM).ROI(iROI).grp(iSubj) = NaN;
                    if Do_layers
                        SVM(iSVM).ROI(iROI).layers.DATA{iSubj} = [];
                        SVM(iSVM).ROI(iROI).layers.grp(:,:,iSubj) = nan(NbLayers);
                    end
                    
                end
                clear Results Class_Acc 
                
            end 
        end
    end
    
    %% Averages over subjects
    for iSVM = 1:numel(SVM)
        for iROI=1:numel(ROIs)
            
            SVM(iSVM).ROI(iROI).MEAN = nanmean(SVM(iSVM).ROI(iROI).grp); 
            SVM(iSVM).ROI(iROI).STD = nanstd(SVM(iSVM).ROI(iROI).grp);
            SVM(iSVM).ROI(iROI).SEM = nansem(SVM(iSVM).ROI(iROI).grp);
            
            if Do_layers
                for iSubj=1:numel(SVM(iSVM).ROI(iROI).layers.DATA)
                    tmp(iSubj,1:NbLayers) = mean(SVM(iSVM).ROI(iROI).layers.DATA{iSubj},2);
                end
                SVM(iSVM).ROI(iROI).layers.MEAN = mean(tmp);
                SVM(iSVM).ROI(iROI).layers.STD = std(tmp);
                SVM(iSVM).ROI(iROI).layers.SEM = nansem(tmp);
            end
            
        end
    end
    
    %% Betas from profile fits
    if Do_layers
        fprintf('\n\n GETTING BETA VALUES FOR PROFILE FITS')
        
        for iSVM = 1:numel(SVM)
            fprintf('\n Running SVM:  %s', SVM(iSVM).name)
            
            for iROI=1:numel(ROIs)
                
                %% Actually compute betas
                for iSub = 1:NbSub
                    
                    Blocks = SVM(iSVM).ROI(iROI).layers.DATA{iSub};
                    
                    if ~all(isnan(Blocks(:))) || ~isempty(Blocks)
                        
                        Y = flipud(Blocks-.5);
                        [B] = ProfileGLM(DesMat, Y);
                        
                        SVM(iSVM).ROI(iROI).layers.Beta.DATA(:,iSub)=B;
                        
                        clear Y B
                        
                    else
                        SVM(iSVM).ROI(iROI).layers.Beta.DATA(:,iSub)=nan(size(DesMat,2),1);
                        
                    end
                    
                end
                
                %% Group stat on betas
                tmp = SVM(iSVM).ROI(iROI).layers.Beta.DATA;
                SVM(iSVM).ROI(iROI).layers.Beta.MEAN=nanmean(tmp, 2);
                SVM(iSVM).ROI(iROI).layers.Beta.Beta.STD=nanstd(tmp, 2);
                SVM(iSVM).ROI(iROI).layers.Beta.Beta.SEM=nansem(tmp, 2);
                
                % T-Test
                [~,P] = ttest(tmp');
                SVM(iSVM).ROI(iROI).Beta.P=P;
                
                clear tmp P
                
            end
        end
        
    end
    
    %% Saves
    fprintf('\n\nSaving\n')
    
    for iSVM = 1:numel(SVM)
        for iROI=1:numel(ROIs)
            Results = SVM(iSVM).ROI(iROI);
            save( fullfile(ResultsDir, strcat('Grp_', SVM(iSVM).ROI(iROI).name, '_', strrep(SVM(iSVM).name,' ','-'),...
                '_PoolQuadGLM',  SaveSufix, '.mat')), 'Results')
        end
    end
    
    save( fullfile(ResultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')) )
    
    cd(StartDir)
    
end
end

end

function [B] = ProfileGLM(X, Y)

if any(isnan(Y(:)))
    [~,y]=find(isnan(Y));
    y=unique(y);
    Y(:,y)=[];
    clear y
end

if isempty(Y)
    B=nan(1,size(X,2));
else
    X=repmat(X,size(Y,2),1);
    Y=Y(:);
    [B,~,~] = glmfit(X, Y, 'normal', 'constant', 'off');
end

end