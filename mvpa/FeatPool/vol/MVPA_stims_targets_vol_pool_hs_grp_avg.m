function MVPA_stims_targets_vol_pool_hs_grp_avg
clc; clear;

StartDir = fullfile(pwd, '..','..');
cd (StartDir)

ResultsDir = fullfile(StartDir, 'results', 'SVM');
[~,~,~] = mkdir(ResultsDir);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))



NbLayers = 6;

FWHM = 0;

% Options
opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.layersubsample.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;

opt.scaling.img.eucledian = 0;
opt.scaling.img.zscore = 1;
opt.scaling.feat.mean = 1;
opt.scaling.feat.range = 0;
opt.scaling.feat.sessmean = 0;


% ROI
ROIs(1) = struct('name', 'V1_thres');
ROIs(end+1) = struct('name', 'V2_thres');
ROIs(end+1) = struct('name', 'V3_thres');
ROIs(end+1) = struct('name', 'V4_thres');
ROIs(end+1) = struct('name', 'V5_thres');

ROIs(end+1) = struct('name', 'A1');
ROIs(end+1) = struct('name', 'PT');


% Analysis
SVM(1) = struct('name', 'A - Targets VS Stim - Ipsi', 'ROI', 1:length(ROIs));
SVM(end+1) = struct('name', 'V - Targets VS Stim - Ipsi', 'ROI', 1:length(ROIs));
SVM(end+1) = struct('name', 'T - Targets VS Stim - Ipsi', 'ROI', 1:length(ROIs));

SVM(end+1) = struct('name', 'A - Targets VS Stim - Contra', 'ROI', 1:length(ROIs));
SVM(end+1) = struct('name', 'V - Targets VS Stim - Contra', 'ROI', 1:length(ROIs));
SVM(end+1) = struct('name', 'T - Targets VS Stim - Contra', 'ROI', 1:length(ROIs));

for i=1:numel(SVM)
    SVM(i).ROI = struct('name', {ROIs(SVM(i).ROI).name});
end

SaveSufix = CreateSaveSufix(opt, FWHM, NbLayers);

SubLs = dir('sub*');
NbSub = numel(SubLs);



%% Gets data for each subject
for iSub = 1:NbSub
    fprintf('\n\nProcessing %s', SubLs(iSub).name)
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    SaveDir = fullfile(SubDir, 'results', 'SVM');
    
    for iSVM = 1:numel(SVM)
        fprintf('\n Running SVM:  %s', SVM(iSVM).name)
        
        for iROI=1:numel(ROIs)
            
            File2Load = fullfile(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]));
            
            if exist(File2Load,'file')
                
                load(File2Load, 'Results', 'Class_Acc')
                
                SVM(iSVM).ROI(iROI).grp(iSub,1:NbLayers+1) = squeeze(Class_Acc.TotAcc(end,:,:,:));
                
                for iLayer = 2:(NbLayers+1)

                    NbCV = size(Results.session(end).rand(1).perm(1).SubSamp{1,1}.CV,1);
                    
                    for iCV=1:NbCV
                        pred = Results.session(end).rand(1).perm(1).SubSamp{1,1}.CV(iCV,iLayer).pred;
                        label = Results.session(end).rand(1).perm(1).SubSamp{1,1}.CV(iCV,iLayer).label;
                        SVM(iSVM).ROI(iROI).DATA{iSub}(iLayer-1,iCV) = mean(pred==label);
                        clear pred label
                    end

                end

            else
                warning('\nThe file %s was not found.', File2Load)
                
                SVM(iSVM).ROI(iROI).grp(iSub,1:NbLayers+1) = nan(1, NbLayers+1);
                SVM(iSVM).ROI(iROI).DATA{iSub} = [];
                
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
        
    end
end



%% Betas from profile fits
fprintf('\n\n GETTING BETA VALUES FOR PROFILE FITS')

DesMat = (1:NbLayers)-mean(1:NbLayers);

DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
DesMat = spm_orth(DesMat);

% DesMat = [DesMat' ones(NbLayers,1)];

for iSVM = 1:numel(SVM)
    fprintf('\n Running SVM:  %s', SVM(iSVM).name)
    
    for iROI=1:numel(ROIs)
        
        %% Actually compute betas
        for iSub = 1:NbSub
            
            Blocks = SVM(iSVM).ROI(iROI).DATA{iSub};
            
            if ~all(isnan(Blocks(:))) || ~isempty(Blocks)
                
                Y = flipud(Blocks-.5);
                [B] = ProfileGLM(DesMat, Y);
                
                SVM(iSVM).ROI(iROI).Beta.DATA(:,iSub)=B;
                
                clear Y B
                
            else
                SVM(iSVM).ROI(iROI).Beta.DATA(:,iSub)=nan(size(DesMat,2),1);
                
            end
            
        end
        
        %% Group stat on betas
        tmp = SVM(iSVM).ROI(iROI).Beta.DATA;
        SVM(iSVM).ROI(iROI).Beta.MEAN=nanmean(tmp, 2);
        SVM(iSVM).ROI(iROI).Beta.Beta.STD=nanstd(tmp, 2);
        SVM(iSVM).ROI(iROI).Beta.Beta.SEM=nansem(tmp, 2);
        
        % T-Test
        [~,P] = ttest(tmp');
        SVM(iSVM).ROI(iROI).Beta.P=P;

        
        clear tmp P
        
    end
end


%% Saves
fprintf('\nSaving\n')

for iSVM = 1:numel(SVM)
    for iROI=1:numel(ROIs)
        Results = SVM(iSVM).ROI(iROI);
        save( fullfile(ResultsDir, strcat('Results_', SVM(iSVM).ROI(iROI).name, '_', strrep(SVM(iSVM).name,' ','-'),...
            '_VolPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results')
    end
end

save( fullfile(ResultsDir, strcat('ResultsStimsTargetsPoolVolQuadGLM_l-', num2str(NbLayers), '.mat')) )

cd(StartDir)

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