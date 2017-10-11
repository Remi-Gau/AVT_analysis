function MVPA_surf_pool_hs
clc; clear;

StartDir = fullfile(pwd, '..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;

NbWorkers = 8;


% Options for the SVM
opt.fs.do = 0; % feature selection
opt.rfe.do = 0; % recursive feature elimination
opt.scaling.idpdt = 1; % scale test and training sets independently
opt.permutation.test = 0;  % do permutation test
opt.session.curve = 0; % learning curves on a subsample of all the sessions
opt.session.proptest = 0.2; % proportion of all sessions to keep as a test set
opt.verbose = 0;


CondNames = {...
    'AStimL','AStimR';...
    'VStimL','VStimR';...
    'TStimL','TStimR';...
%     'ATargL','ATargR';...
%     'VTargL','VTargR';...
%     'TTargL','TTargR';...
    };

Cdt_ROI_lhs = 1:6;
Cdt_ROI_rhs = [2 1 4 3 6 5];


% --------------------------------------------------------- %
%              Classes and associated conditions            %
% --------------------------------------------------------- %
Class(1) = struct('name', 'A Stim - Left', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'AStimL'};

Class(2) = struct('name', 'A Stim - Right', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'AStimR'};


Class(3) = struct('name', 'V Stim - Left', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'VStimL'};

Class(4) = struct('name', 'V Stim - Right', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'VStimR'};


Class(5) = struct('name', 'T Stim - Left', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'TStimL'};

Class(6) = struct('name', 'T Stim - Right', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'TStimR'};

ROIs_ori = {
    'A1',...
    'PT',...
    'V1',...
    'V2',...
    'V3',...
    'V4',...
    'V5'};

% --------------------------------------------------------- %
%                     Analysis to perform                   %
% --------------------------------------------------------- %
SVM_Ori(1) = struct('name', 'A Ipsi VS Contra', 'class', [1 2], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'V Ipsi VS Contra', 'class', [3 4], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'T Ipsi VS Contra', 'class', [5 6], 'ROI_2_analyse', 1:numel(ROIs_ori));
%
SVM_Ori(end+1) = struct('name', 'A VS V Ipsi', 'class', [1 3], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'A VS T Ipsi', 'class', [1 6], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'V VS T Ipsi', 'class', [3 6], 'ROI_2_analyse', 1:numel(ROIs_ori));

SVM_Ori(end+1) = struct('name', 'A VS V Contra', 'class', [2 4], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'A VS T Contra', 'class', [2 6], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'V VS T Contra', 'class', [4 6], 'ROI_2_analyse', 1:numel(ROIs_ori));


% --------------------------------------------------------- %
%          Data pre-processing and SVM parameters           %
% --------------------------------------------------------- %
% Feature selection (FS)
opt.fs.threshold = 0.75;
opt.fs.type = 'ttest2';

% Recursive feature elminiation (RFE)
opt.rfe.threshold = 0.01;
opt.rfe.nreps = 20;

% SVM C/nu parameters and default arguments
opt.svm.machine = 'C-SVC';
if strcmp(opt.svm.machine, 'C-SVC')
    opt.svm.log2c = 1;
    opt.svm.dargs = '-s 0';
elseif strcmp(opt.svm.machine, 'nu-SVC')
    opt.svm.nu = [0.0001 0.001 0.01 0.1:0.1:1];
    opt.svm.dargs = '-s 1';
end

opt.svm.kernel = 0;
if opt.svm.kernel
    % should be implemented
else
    opt.svm.dargs = [opt.svm.dargs ' -t 0 -q']; % inherent linear kernel, quiet mode
end

% Randomization options
if opt.permutation.test;
    opt.permutation.nreps = 101; % #repetitions for permutation test
else
    opt.permutation.nreps = 1;
end

% Learning curve
% #repetitions for session subsampling if needed
opt.session.subsample.nreps = 30;

% Maximum numbers of CVs
opt.session.maxcv = [];


% -------------------------%
%          START           %
% -------------------------%
[KillGcpOnExit] = OpenParWorkersPool(NbWorkers);

SubLs = dir('sub*');
NbSub = numel(SubLs);


for iSub = 1:NbSub
    
    % --------------------------------------------------------- %
    %                        Subject data                       %
    % --------------------------------------------------------- %
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    
    Data_dir = fullfile(SubDir, 'ffx_nat', 'betas', '6_surf');
    
    SaveDir = fullfile(SubDir, 'results', 'SVM');
    [~,~,~] = mkdir(SaveDir);
    
    % Load Vertices of interest for each ROI;
    load(fullfile(SubDir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex')
    
    
    %% Gets the number of each beta images and the numbers of the beta of interest
    load(fullfile(SubDir, 'ffx_nat','SPM.mat'))
    RegNumbers = GetRegNb(SPM);
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    for i=1:size(BetaNames,1)
        if BetaNames(i,6)==' '
            tmp(i,1:6) = BetaNames(i,7:12); %#ok<*AGROW>
        else
            tmp(i,1:6) = BetaNames(i,8:13);
        end
    end
    BetaNames = tmp;
    
    % If we want to have a learning curve
    NbRuns = numel(SPM.Sess); clear SPM
    if opt.session.curve
        % #sessions over which to run the learning curve
        opt.session.nsamples = 10:2:NbRuns;
    else
        opt.session.nsamples = NbRuns;
    end
    
    
    %% Creates a dataset that lists for each beta of interest:
    %   - its corresponding class
    %   - the session in which it occurs
    CV_Mat_Orig = [zeros(NbRuns*sum([Class.nbetas]), 1) ...
        zeros(NbRuns*sum([Class.nbetas]), 1)] ;
    
    % For each condition of each class we figure out what is the associated
    % regressors and in which sessions they occur.
    irow = 1; 
    BetaList_lh = [];
    BetaList_rh = [];
    for iClass=1:numel(Class)

        tmp=BetaNames(BetaOfInterest,:);
        
        TEMP = BetaOfInterest(strcmp(Class(Cdt_ROI_lhs(iClass)).cond, cellstr(tmp)));
        BetaList_lh = [BetaList_lh ; TEMP];
        
        TEMP = BetaOfInterest(strcmp(Class(Cdt_ROI_rhs(iClass)).cond, cellstr(tmp)));
        BetaList_rh = [BetaList_rh ; TEMP];
        
        for i=1:length(TEMP)
            CV_Mat_Orig(irow,1) = iClass;
            
            [I,~] = find(TEMP(i)==RegNumbers);
            CV_Mat_Orig(irow,2) = I;
            
            irow = irow + 1;
        end
        clear TEMP I i tmp

    end
    clear irow iClass iCond BetaNames iFile RegNumbers
    
    
    %% Read features
    fprintf(' Reading features\n')    
    for hs = 1:2
        
        if hs==1
            fprintf('  Left hemipshere\n')
            HsSufix = 'l';
        else
            fprintf('  Right hemipshere\n')
            HsSufix = 'r';
        end
        
        FeatureSaveFile = fullfile(Data_dir,[SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
            num2str(NbLayers) '_surf.mat']);
        
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile, 'AllMapping', 'inf_vertex', 'VertexWithData')
            Mapping_both_hs{hs} = AllMapping;
            VertexWithDataHS{hs} = VertexWithData;
            NbVertex(hs)=size(inf_vertex,2);
        else
            error('The features have not been extracted from the VTK files.')
        end
        
    end
    
    %% Redistribute features into each ROI
    FeaturesAll = cell(numel(ROI),1); %#ok<*USENS>
    
    [~,LOCB_lh] = ismember(BetaList_lh,BetaOfInterest);
    [~,LOCB_rh] = ismember(BetaList_rh,BetaOfInterest);

    for iExemplar = 1:numel(LOCB_lh)
        
        Profiles_lh = nan(NbVertex(1),6);
        Profiles_rh = nan(NbVertex(2),6);
        
        Profiles_lh(VertexWithDataHS{1},:) = Mapping_both_hs{1}(:,:,LOCB_lh(iExemplar));
        Profiles_rh(VertexWithDataHS{2},:) = Mapping_both_hs{2}(:,:,LOCB_rh(iExemplar));
        
        for iROI = 1:numel(ROI)
            
            Feat_L = (Profiles_lh(ROI(iROI).VertOfInt{1},:))';
            Feat_R = (Profiles_rh(ROI(iROI).VertOfInt{2},:))';
            
            FeaturesAll{iROI} = [FeaturesAll{iROI} ; [(Feat_L(:))' (Feat_R(:))']];
            
        end
        
    end

    %% Run for different type of normalization
    for Norm = [5 7]
        
        switch Norm
            case 1
                opt.scaling.img.eucledian = 1;
                opt.scaling.img.zscore = 0;
                opt.scaling.feat.mean = 0;
                opt.scaling.feat.range = 0;
                opt.scaling.feat.sessmean = 1;
            case 2
                opt.scaling.img.eucledian = 1;
                opt.scaling.img.zscore = 0;
                opt.scaling.feat.mean = 0;
                opt.scaling.feat.range = 1;
                opt.scaling.feat.sessmean = 0;
            case 3
                opt.scaling.img.eucledian = 1;
                opt.scaling.img.zscore = 0;
                opt.scaling.feat.mean = 1;
                opt.scaling.feat.range = 0;
                opt.scaling.feat.sessmean = 0;
            case 4
                opt.scaling.img.eucledian = 0;
                opt.scaling.img.zscore = 1;
                opt.scaling.feat.mean = 0;
                opt.scaling.feat.range = 0;
                opt.scaling.feat.sessmean = 1;
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
        end
        
        SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);
        
        
        
        %% Run cross-validation for each model and ROI
        SVM = SVM_Ori;
        for i=1:numel(SVM)
            for j=1:numel(SVM_Ori(i).ROI_2_analyse)
                SVM(i).ROI(j) = struct('name', ROI(j).name, ...
                    'size', sum(cellfun('length',ROI(j).VertOfInt)),...
                    'opt', opt); 
            end
        end
        clear i j
        
        for iSVM=1:numel(SVM)
            
            for iROI=1:numel(ROI)
                

                
                fprintf('Analysing subject %s\n', SubLs(iSub).name)
                fprintf(' Running SVM:  %s\n', SVM(iSVM).name)
                fprintf('  Running ROI:  %s\n', SVM(iSVM).ROI(iROI).name)
                fprintf('  Number of vertices before FS/RFE: %i\n', SVM(iSVM).ROI(iROI).size)
                fprintf('   Running on %i layers\n', NbLayers)

                
                FeaturesBoth = FeaturesAll{iROI,1};
                LogFeatBoth= ~any(isnan(FeaturesBoth));
                FeaturesLayersBoth = repmat(NbLayers:-1:1, 1, size(FeaturesBoth,2)/NbLayers);
                

                % RNG init
                rng('default');
                opt.seed = rng;
                
                Class_Acc = struct('TotAcc', []);
                
                %% Subsample sessions for the learning curve (otherwise take all of them)
                for NbSess2Incl = opt.session.nsamples
                    
                    % All possible ways of only choosing X sessions of the total
                    CV_id = nchoosek(1:NbRuns, NbSess2Incl);
                    CV_id = CV_id(randperm(size(CV_id, 1)),:);
                    
                    % Limits the number of permutation if too many
                    if size(CV_id, 1) > opt.session.subsample.nreps
                        CV_id = CV_id(1:opt.session.subsample.nreps,:);
                    end
                    
                    % Defines the test sessions for the CV: take one
                    % session from each day as test: all the others as
                    % training
                    load(fullfile(StartDir, 'RunsPerSes.mat'))
                    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
                    RunPerSes = RunPerSes(Idx).RunsPerSes;
                    sets = {...
                        1:RunPerSes(1), ...
                        RunPerSes(1)+1:RunPerSes(1)+RunPerSes(2),...
                        RunPerSes(1)+RunPerSes(2)+1:sum(RunPerSes)};
                    [x, y, z] = ndgrid(sets{:});
                    cartProd = [x(:) y(:) z(:)];
                    clear x y z RunPerSes Idx
                    
                    for i=1:size(CV_id,1)
                        TestSessList{i,1} = cartProd;
                        % Limits to CV max
                        %TestSessList{i,1} = nchoosek(CV_id(i,:), floor(opt.session.proptest*NbSess2Incl));
                        %TestSessList{i,1} = TestSessList{i,1}(randperm(size(TestSessList{i,1},1)),:);
                        %if size(TestSessList{i,1}, 1) >  opt.session.maxcv
                        %   TestSessList{i,1} = TestSessList{i,1}(1:opt.session.maxcv,:);
                        %end
                    end
                    clear cartProd
                    
                    
                    %% Subsampled sessions loop
                    for iSubSampSess=1:size(CV_id, 1)
                        
                        % Permutation test
                        if NbSess2Incl < NbRuns
                            NbPerm = 1;
                            fprintf('\n    Running learning curve with %i sessions\n', NbSess2Incl)
                            fprintf('     %i of %i \n\n', iSubSampSess, size(CV_id, 1))
                        else
                            fprintf('    Running analysis with all sessions\n\n')
                            NbPerm = opt.permutation.nreps;
                        end
                        
                        %%
                        for iPerm=1:NbPerm
                            
                            CV_Mat = CV_Mat_Orig;
                            
                            %% Permute class within sessions when all sessions are included
                            if iPerm > 1
                                for iRun=1:max(CV_Mat.session)
                                    temp = CV_Mat((all([ismember(CV_Mat(:,1), SVM(iSVM).class), ...
                                        ismember(CV_Mat(:,2), iRun)], 2)),1);
                                    
                                    CV_Mat(:,1) = CV_Mat(temp(randperm(length(temp))),1);
                                end
                            end
                            clear temp
                            
                            
                            
                            %% Leave-one-run-out (LORO) cross-validation
                            NbCV = size(TestSessList{iSubSampSess,1}, 1);
                            
                            fprintf(1,'   [%s]\n   [ ',repmat('.',1,NbCV));
                            parfor iCV=1:NbCV
                                
%                                 fprintf('     Cross-Validation %i of %i', iCV, NbCV)
                                fprintf(1,'\b.\n');

                                TestSess = []; %#ok<NASGU>
                                TrainSess = []; %#ok<NASGU>
                                
                                % Separate training and test sessions
                                [TestSess, TrainSess] = deal(false(size(1:NbRuns)));
                                
                                TestSess(TestSessList{iSubSampSess,1}(iCV,:)) = 1; %#ok<*PFBNS>
                                TrainSess(setdiff(CV_id(iSubSampSess,:), TestSessList{iSubSampSess,1}(iCV,:)) )= 1;

                                [acc_layer, results_layer, results, ~] = RunSVM(SVM, FeaturesBoth, LogFeatBoth, FeaturesLayersBoth, CV_Mat, TrainSess, TestSess, opt, iSVM);
                                
                                TEMP(iCV,1).layers.results = {results_layer};
                                TEMP(iCV,1).layers.acc = acc_layer;
                                TEMP(iCV,1).results = {results};
                                TEMP(iCV,1).acc = mean(results.pred==results.label);
                                
%                                 fprintf('\n')
                                
                            end
                            fprintf(1,'\b]\n');
                            
                            for iCV=1:size(CV_id, 2)
                                for iSide=1:size(TEMP,2)
                                    SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,iSide).layers.results =...
                                        TEMP(iCV,iSide).layers.results;
                                    SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,iSide).layers.acc = ...
                                        TEMP(iCV,iSide).layers.acc;
                                    SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,iSide).results = ...
                                        TEMP(iCV,iSide).results;
                                    SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,iSide).acc = ...
                                        TEMP(iCV,iSide).acc;
                                end
                            end
                            
                        end % iPerm=1:NbPerm
                        %clear iPerm
                        
                    end % iSubSampSess=1:size(CV_id, 1)
                    %clear iSubSampSess
                    
                end % NbSess2Incl = opt.session.nsamples
                %clear NbSess2Incl
                
                %% Calculate prediction accuracies
                
                for Side = 1
                    Class_Acc.TotAcc(Side) = ...
                        nanmean([SVM(iSVM).ROI(iROI).session(end).rand.perm.CV(:,Side).acc]);
                    for iCV=1:size(CV_id, 2)
                        temp(:,:,iCV) = SVM(iSVM).ROI(iROI).session(end).rand.perm.CV(iCV,Side).layers.acc;
                    end
                    Class_Acc.TotAccLayers{Side} = nanmean(temp,3);
                    temp = [];
                end
                
                % Display some results
                fprintf('\n   Accuracy %i layers\n', NbLayers);
                disp(Class_Acc.TotAcc(:))
                disp(Class_Acc.TotAccLayers{1})
                
                
                % Save data
                Results = SVM(iSVM).ROI(iROI);
                SaveResults(SaveDir, Results, opt, Class_Acc, SVM, iSVM, iROI, SaveSufix)
                
            end % iSubROI=1:numel(SVM(iSVM).ROI)
            clear Mask Features
            
        end % iSVM=1:numel(SVM)
        clear iSVM SVM
        
    end % for Norm = 6:7
    clear Features RegNumbers
    
end % for iSub = 1:NbSub

CloseParWorkersPool(KillGcpOnExit)

end


function SaveResults(SaveDir, Results, opt, Class_Acc, SVM, iSVM, iROI, SaveSufix) %#ok<INUSL>

save(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]), 'Results', 'opt', 'Class_Acc', '-v7.3');

end

function [acc_layer, results_layer, results, weight] = RunSVM(SVM, Features, LogFeat, FeaturesLayers, CV_Mat, TrainSess, TestSess, opt, iSVM)

if isempty(Features) || all(Features(:)==Inf)
    
    warning('Empty ROI')
    
    acc_layer = NaN;
    results = struct();
    results_layer = struct();
    weight = [];
    
else
    
    [acc_layer, weight, results_layer] = machine_SVC_layers(SVM(iSVM), ...
        Features(:,LogFeat), FeaturesLayers(:,LogFeat), CV_Mat, TrainSess, TestSess, opt);
    
    if opt.verbose
        fprintf('\n       Running on all layers.')
    end
    
    results = machine_SVC(SVM(iSVM), Features(:,LogFeat), CV_Mat, TrainSess, TestSess, opt);
    
end

end
