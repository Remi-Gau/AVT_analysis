function MVPA_surf_wht_betas
clc; clear;

StartDir = fullfile(pwd, '..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

NbLayers = 6;

NbWorkers = 3;


% Options for the SVM
opt.fs.do = 0; % feature selection
opt.rfe.do = 0; % recursive feature elimination
opt.scaling.idpdt = 1; % scale test and training sets independently
opt.permutation.test = 0;  % do permutation test
opt.session.curve = 0; % learning curves on a subsample of all the sessions
opt.session.proptest = 0.2; % proportion of all sessions to keep as a test set
opt.verbose = 0;
opt.session.loro = 1;
opt.MVNN = 1;

CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR'};

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
Class(end).cond = {'TStimR'}; %#ok<*STRNU>

ROIs_ori = {
    'A1',...
    'PT',...
    'V1',...
    'V2',...
    'V3'};

ToPlot={'Cst','Lin','Avg','ROI'};

% --------------------------------------------------------- %
%                     Analysis to perform                   %
% --------------------------------------------------------- %
% SVM_Ori(1) = struct('name', 'A Ipsi VS Contra', 'class', [1 2], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 1);
% SVM_Ori(end+1) = struct('name', 'V Ipsi VS Contra', 'class', [3 4], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 1);
% SVM_Ori(end+1) = struct('name', 'T Ipsi VS Contra', 'class', [5 6], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 1);
% 
% SVM_Ori(end+1) = struct('name', 'A VS V Ipsi', 'class', [1 3], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 1);
% SVM_Ori(end+1) = struct('name', 'A VS T Ipsi', 'class', [1 5], ...
%     'ROI_2_analyse',1:numel(ROIs_ori), 'Featpool', 1);
% SVM_Ori(end+1) = struct('name', 'V VS T Ipsi', 'class', [3 5], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 1);

% SVM_Ori(1) = struct('name', 'A VS V Contra', 'class', [2 4], ...
%     'ROI_2_analyse', 1, 'Featpool', 1);
% SVM_Ori(end+1) = struct('name', 'A VS T Contra', 'class', [2 6], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 1);
SVM_Ori(1) = struct('name', 'V VS T Contra', 'class', [4 6], ...
    'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 1);



% SVM_Ori(end+1) = struct('name', 'A_L VS A_R', 'class', [1 2], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);
% SVM_Ori(end+1) = struct('name', 'V_L VS V_R', 'class', [3 4], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);
% SVM_Ori(end+1) = struct('name', 'T_L VS T_R', 'class', [5 6], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);
% 
% SVM_Ori(end+1) = struct('name', 'A_L VS V_L', 'class', [1 3], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);
% SVM_Ori(end+1) = struct('name', 'A_L VS T_L', 'class', [1 5], ...
%     'ROI_2_analyse',1:numel(ROIs_ori), 'Featpool', 0);
% SVM_Ori(end+1) = struct('name', 'V_L VS T_L', 'class', [3 5], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);
% 
% SVM_Ori(end+1) = struct('name', 'A_R VS V_R', 'class', [2 4], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);
% SVM_Ori(end+1) = struct('name', 'A_R VS T_R', 'class', [2 6], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);
% SVM_Ori(end+1) = struct('name', 'V_R VS T_R', 'class', [4 6], ...
%     'ROI_2_analyse', 1:numel(ROIs_ori), 'Featpool', 0);

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
if opt.permutation.test
    opt.permutation.nreps = 1000; % #repetitions for permutation test
else
    opt.permutation.nreps = 1;
end

% Learning curve
% #repetitions for session subsampling if needed
opt.session.subsample.nreps = 30;

% Maximum numbers of CVs
opt.session.maxcv = 25;


% -------------------------%
%          START           %
% -------------------------%
[KillGcpOnExit] = OpenParWorkersPool(NbWorkers);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iToPlot = 4
    
    opt.toplot = ToPlot{iToPlot};
    
    for iSub = 1 %NbSub
        
        % --------------------------------------------------------- %
        %                        Subject data                       %
        % --------------------------------------------------------- %
        fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
        
        SubDir = fullfile(StartDir, SubLs(iSub).name);
        
        Data_dir = fullfile(SubDir,'results','profiles','surf','PCM');
        
        GLM_dir = fullfile(SubDir,'ffx_nat');
        
        SaveDir = fullfile(SubDir, 'results', 'SVM');
        [~,~,~] = mkdir(SaveDir);
        
        % Load Vertices of interest for each ROI;
        load(fullfile(SubDir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex')
        
        
        %% Get beta images names
        load(fullfile(GLM_dir,'SPM.mat'))
        
        % If we want to have a learning curve
        Nb_sess = numel(SPM.Sess);
        if opt.session.curve
            % #sessions over which to run the learning curve
            opt.session.nsamples = 10:2:Nb_sess;
        else
            opt.session.nsamples = Nb_sess;
        end
        
        clear SPM
        
        
        %% Create partition and condition vector
        conditionVec = repmat(1:numel(CondNames)*2,Nb_sess,1);
        conditionVec = conditionVec(:);
        
        partitionVec = repmat((1:Nb_sess)',numel(CondNames)*2,1);
        
        if iToPlot==4 && iSub==5
            % remove lines corresponding to auditory stim and
            % targets for sub-06
            ToRemove = all([any([conditionVec<3 conditionVec==7 conditionVec==8],2) partitionVec==17],2);
            
            partitionVec(ToRemove) = [];
            conditionVec(ToRemove) = [];
            clear ToRemove
        end
        
        % "remove" rows corresponding to targets
        partitionVec(conditionVec>6)=0;
        conditionVec(conditionVec>6)=0;
        %         conditionVec(conditionVec>6)=conditionVec(conditionVec>6)-6;
        
        %% Read features
        fprintf(' Reading features\n')
        if iToPlot<4
            FeatureSaveFile = 'Data_PCM.mat';
            load(fullfile(Data_dir,FeatureSaveFile), 'PCM_data')
            for iROI = 1:numel(ROI)
                Data{iROI,1} = PCM_data{iToPlot,iROI,1}; %#ok<*AGROW,*USENS>
                Data{iROI,2} = PCM_data{iToPlot,iROI,2};
            end
        else
            FeatureSaveFile = 'Data_PCM_whole_ROI.mat';
            load(fullfile(Data_dir,FeatureSaveFile), 'PCM_data')
            Data = PCM_data;
        end
        clear PCM_data
        
        %% Remove extra data and checks for zeros and NANs
        for iROI = 1:numel(ROI)
            % Get just the right data
            Data{iROI,1}(conditionVec==0,:)=[];
            Data{iROI,2}(conditionVec==0,:)=[];
            
            % Remove nans
            if iToPlot==4
                % reshape data to remove a whole vertex even if it has one
                % NAN
                Data{iROI,1} = reshape(Data{iROI,1}, ...
                    [size(Data{iROI,1},1), NbLayers, numel(ROI(iROI).VertOfInt{1})]);
                Data{iROI,2} = reshape(Data{iROI,2}, ...
                    [size(Data{iROI,2},1), NbLayers, numel(ROI(iROI).VertOfInt{2})]);
                
                ToRemove = find(any(any(isnan(Data{iROI,1}))));
                Data{iROI,1}(:,:,ToRemove)=[]; clear ToRemove
                ToRemove = find(any(any(isnan(Data{iROI,2}))));
                Data{iROI,2}(:,:,ToRemove)=[]; clear ToRemove
                
                % Puts them back in original shape
                Data{iROI,1} = reshape(Data{iROI,1}, ...
                    [size(Data{iROI,1},1), NbLayers*size(Data{iROI,1},3)]);
                Data{iROI,2} = reshape(Data{iROI,2}, ...
                    [size(Data{iROI,2},1), NbLayers*size(Data{iROI,2},3)]);
            else
                ToRemove = find(any(isnan(Data{iROI,1})));
                Data{iROI,1}(:,ToRemove)=[]; clear ToRemove
                ToRemove = find(any(isnan(Data{iROI,2})));
                Data{iROI,2}(:,ToRemove)=[]; clear ToRemove
            end
           
            
            if any(all(isnan(Data{iROI,1}),2)) || any(all(Data{iROI,1}==0,2)) || ...
                    any(all(isnan(Data{iROI,2}),2)) || any(all(Data{iROI,2}==0,2))
                warning('We have some NaNs or zeros issue: ignore if sub-06')
                ZeroRowsToRemove(:,iROI) = any([all(isnan(Data{iROI,1}),2) all(Data{iROI,1}==0,2) ...
                    all(isnan(Data{iROI,2}),2) all(Data{iROI,2}==0,2)],2);
                Data{iROI,1}(ZeroRowsToRemove(:,iROI),:) = [];
                Data{iROI,2}(ZeroRowsToRemove(:,iROI),:) = [];
            end
            
            % construc a vector that identify what column belongs to which
            % layer
            if iToPlot==4
                FeaturesLayers{iROI,1} = ...
                    repmat(NbLayers:-1:1, 1, size(Data{iROI,1},2)/NbLayers);
                FeaturesLayers{iROI,2} = ...
                    repmat(NbLayers:-1:1, 1, size(Data{iROI,2},2)/NbLayers);
            end
            
        end
        
        if exist('ZeroRowsToRemove', 'var')
            partitionVec(any(ZeroRowsToRemove,2),:)=[];
            conditionVec(any(ZeroRowsToRemove,2),:)=[];
        end
        clear ZeroRowsToRemove
        
        CV_Mat_Orig = [conditionVec partitionVec];
        CV_Mat_Orig(conditionVec==0,:) = [];
        partitionVec(conditionVec==0,:) = [];
        conditionVec(conditionVec==0,:) = [];
        
        
        %% check that we have the same number of conditions in each partition
        A = tabulate(CV_Mat_Orig(:,2));
        A = A(:,1:2);
        if numel(unique(A(:,2)))>1
            warning('We have different numbers of conditions in at least one partition.')
            Sess2Remove = find(A(:,2)<numel(unique(conditionVec)));
            conditionVec(ismember(partitionVec,Sess2Remove)) = [];
            for iROI = 1:numel(ROI)
                Data{iROI,1}(ismember(partitionVec,Sess2Remove),:) = [];
                Data{iROI,2}(ismember(partitionVec,Sess2Remove),:) = [];
            end
            CV_Mat_Orig(ismember(partitionVec,Sess2Remove),:) = [];
            partitionVec(ismember(partitionVec,Sess2Remove)) = [];
            Sess2Remove = [];
        end
        clear A Sess2Remove
        
        
        
        %% Run for different type of normalization
        for Norm = 6
            
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
                case 8
                    opt.scaling.img.eucledian = 0;
                    opt.scaling.img.zscore = 0;
                    opt.scaling.feat.mean = 0;
                    opt.scaling.feat.range = 0;
                    opt.scaling.feat.sessmean = 0;
            end
            
            SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);
            
            
            %% Run cross-validation for each model and ROI
            SVM = SVM_Ori;
            for i=1:numel(SVM)
                for j=SVM_Ori(i).ROI_2_analyse
                    if ~isfield(SVM,'ROI')
                        SVM(i).ROI = struct('name', ROI(j).name, ...
                            'size', sum(cellfun('length',ROI(j).VertOfInt)),...
                            'opt', opt);
                    else
                        SVM(i).ROI(end+1) = struct('name', ROI(j).name, ...
                            'size', sum(cellfun('length',ROI(j).VertOfInt)),...
                            'opt', opt);
                    end
                end
            end
            clear i j
            
            for iSVM=1:numel(SVM)
                
                %% reorganise data for this SVM if we need feature pooling or not
                clear FeaturesAll
                if SVM(iSVM).Featpool
                    for iROI = 1:numel(ROI)
                        tmp = Data{iROI,2};
                        for i=1:2:12
                            tmp(conditionVec==i,:) = Data{iROI,2}(conditionVec==(i+1),:);
                        end
                        for i=2:2:12
                            tmp(conditionVec==i,:) = Data{iROI,2}(conditionVec==(i-1),:);
                        end
                        FeaturesAll{iROI,1}= [ Data{iROI,1} tmp ];
                    end
                else
                    for iROI = 1:numel(ROI)
                        FeaturesAll{iROI,1}= [ Data{iROI,1} Data{iROI,2} ];
                    end
                end
                
                for iROI=SVM(iSVM).ROI_2_analyse
                    
                    clear FeaturesBoth LogFeatBoth
                    
                    ROI_idx = find(SVM(iSVM).ROI_2_analyse==iROI);
                    
                    fprintf('Analysing subject %s\n', SubLs(iSub).name)
                    fprintf(' Running SVM:  %s\n', SVM(iSVM).name)
                    fprintf('  Running ROI:  %s\n', SVM(iSVM).ROI(ROI_idx).name)
                    fprintf('  Number of vertices before FS/RFE: %i\n', SVM(iSVM).ROI(ROI_idx).size)
                    fprintf('   Running on %i layers\n', NbLayers)
                    
                    FeaturesBoth = FeaturesAll{iROI,1};
                    LogFeatBoth= ~any(isnan(FeaturesBoth));
                    if iToPlot==4
                        FeaturesLayersBoth = ...
                            [FeaturesLayers{iROI,1} FeaturesLayers{iROI,2}];
                    else
                        FeaturesLayersBoth = [];
                    end
                    
                    % RNG init
                    rng('default');
                    opt.seed = rng;
                    
                    Class_Acc = struct('TotAcc', []);
                    
                    %% Subsample sessions for the learning curve (otherwise take all of them)
                    for NbSess2Incl = opt.session.nsamples
                        
                        % All possible ways of only choosing X sessions of the total
                        CV_id = nchoosek(1:Nb_sess, NbSess2Incl);
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
                        clear x y Idx
                        
                        % Test sets for the different CVs
                        if opt.session.curve
                            for i=1:size(CV_id,1)
                                % Limits to CV max
                                %TestSessList{i,1} = nchoosek(CV_id(i,:), floor(opt.session.proptest*NbSess2Incl));
                                %TestSessList{i,1} = TestSessList{i,1}(randperm(size(TestSessList{i,1},1)),:);
                                %if size(TestSessList{i,1}, 1) >  opt.session.maxcv
                                %   TestSessList{i,1} = TestSessList{i,1}(1:opt.session.maxcv,:);
                                %end
                                %if opt.permutation.test
                                %     TestSessList{i,1} = cartProd;
                                %end
                            end
                        else
                            if opt.session.loro
                                TestSessList{1,1} = (1:sum(RunPerSes))';
                                if iSub==5
                                    TestSessList{1,1}(TestSessList{1,1}==17) = [];
                                end
                            else
                                TestSessList{1,1} = cartProd; % take all possible CVs
                                if opt.permutation.test % limits the number of CV for permutation
                                    cartProd = cartProd(randperm(size(cartProd,1)),:);
                                    TestSessList{1,1} = cartProd(1:opt.session.maxcv,:);
                                end
                            end
                        end
                        clear cartProd RunPerSes
                        
                        
                        %% Subsampled sessions loop
                        for iSubSampSess=1:size(CV_id, 1)
                            
                            % Permutation test
                            if NbSess2Incl < Nb_sess
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
                                    for iRun=1:max(CV_Mat(:,2))
                                        Cdt_2_perm = all([ismember(CV_Mat(:,1), SVM(iSVM).class), ...
                                            ismember(CV_Mat(:,2), iRun)], 2);
                                        
                                        temp = CV_Mat(Cdt_2_perm,1);
                                        
                                        CV_Mat(Cdt_2_perm,1) = temp(randperm(length(temp)));
                                    end
                                end
                                clear temp
                                
                                %% Run cross-validations
                                NbCV = size(TestSessList{iSubSampSess,1}, 1);
                                
                                fprintf(1,'    [%s]\n    [ ',repmat('.',1,NbCV));
                                parfor iCV=1:NbCV
                                    fprintf(1,'.');
                                    
                                    TestSess = []; %#ok<NASGU>
                                    TrainSess = []; %#ok<NASGU>
                                    
                                    % Separate training and test sessions
                                    [TestSess, TrainSess] = deal(false(size(1:Nb_sess)));
                                    
                                    TestSess(TestSessList{iSubSampSess,1}(iCV,:)) = 1; %#ok<*PFBNS>
                                    TrainSess(setdiff(CV_id(iSubSampSess,:), TestSessList{iSubSampSess,1}(iCV,:)) )= 1;
                                    
                                    results = machine_SVC(SVM(iSVM), FeaturesBoth(:,LogFeatBoth), CV_Mat, TrainSess, TestSess, opt);
                                    
                                    TEMP(iCV,1).results = {results};
                                    TEMP(iCV,1).acc = mean(results.pred==results.label);
                                end
                                fprintf(1,'\b]\n');
                                
                                %do the same but layer by layer if needed
                                if iToPlot==4
                                    fprintf(1,'    [%s]\n    [ ',repmat('.',1,NbCV));
                                    parfor iCV=1:NbCV
                                        fprintf(1,'.');
                                        
                                        TestSess = []; %#ok<NASGU>
                                        TrainSess = []; %#ok<NASGU>
                                        
                                        % Separate training and test sessions
                                        [TestSess, TrainSess] = deal(false(size(1:Nb_sess)));
                                        
                                        TestSess(TestSessList{iSubSampSess,1}(iCV,:)) = 1; %#ok<*PFBNS>
                                        TrainSess(setdiff(CV_id(iSubSampSess,:), TestSessList{iSubSampSess,1}(iCV,:)) )= 1;
                                        
                                        [acc_layer, results_layer, ~] = RunSVM(SVM, FeaturesBoth, LogFeatBoth, FeaturesLayersBoth, CV_Mat, TrainSess, TestSess, opt, iSVM);
                                        TEMP(iCV,1).layers.results = {results_layer};
                                        TEMP(iCV,1).layers.acc = acc_layer;
                                    end
                                    fprintf(1,'\b]\n');
                                end
                                
                                for iCV=1:NbCV
                                    SVM(iSVM).ROI(ROI_idx).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).results = ...
                                        TEMP(iCV,1).results;
                                    SVM(iSVM).ROI(ROI_idx).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).acc = ...
                                        TEMP(iCV,1).acc;
                                    
                                    if iToPlot==4
                                        SVM(iSVM).ROI(ROI_idx).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).layers.results =...
                                            TEMP(iCV,1).layers.results;
                                        SVM(iSVM).ROI(ROI_idx).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).layers.acc = ...
                                            TEMP(iCV,1).layers.acc;
                                    end
                                    
                                end
                                
                            end % iPerm=1:NbPerm
                            %clear iPerm
                            
                        end % iSubSampSess=1:size(CV_id, 1)
                        %clear iSubSampSess
                        
                    end % NbSess2Incl = opt.session.nsamples
                    %clear NbSess2Incl
                    
                    %% Calculate prediction accuracies
                    Class_Acc.TotAcc(1) = ...
                        nanmean([SVM(iSVM).ROI(ROI_idx).session(end).rand.perm(1).CV(:,1).acc]);
                    
                    if iToPlot==4
                        for iCV=1:size(CV_id, 2)
                            temp(:,:,iCV) = SVM(iSVM).ROI(ROI_idx).session(end).rand.perm(1).CV(iCV,1).layers.acc;
                        end
                        Class_Acc.TotAccLayers{1} = nanmean(temp,3);
                        temp = [];
                    end
                    
                    % Display some results
                    if NbPerm==1
                        disp(Class_Acc.TotAcc(:))
                        if iToPlot==4
                            disp(Class_Acc.TotAccLayers{1})
                        end
                    end
                    
                    % Save data
                    Results = SVM(iSVM).ROI(ROI_idx);
                    SaveResults(SaveDir, Results, opt, Class_Acc, SVM, iSVM, ROI_idx, SaveSufix)
                    
                    clear Results
                    
                    SVM(iSVM).ROI(ROI_idx).session = [];
                    
                end % iROI=1:numel(SVM(iSVM).ROI)
                clear Mask Features
                
            end % iSVM=1:numel(SVM)
            clear iSVM SVM
            
        end % for Norm = 6:7
        clear Features RegNumbers
        
    end % for iSub = 1:NbSub
    
    
end

CloseParWorkersPool(KillGcpOnExit)

end




function SaveResults(SaveDir, Results, opt, Class_Acc, SVM, iSVM, iROI, SaveSufix) %#ok<INUSL>

save(fullfile(SaveDir, ['SVM-' SVM(iSVM).name '_ROI-' SVM(iSVM).ROI(iROI).name SaveSufix]), 'Results', 'opt', 'Class_Acc', '-v7.3');

end

function [acc_layer, results_layer, weight] = RunSVM(SVM, Features, LogFeat, FeaturesLayers, CV_Mat, TrainSess, TestSess, opt, iSVM)

if isempty(Features) || all(Features(:)==Inf)
    
    warning('Empty ROI')
    
    acc_layer = NaN;
    results_layer = struct();
    weight = [];
    
else
    
    if ~opt.permutation.test
        [acc_layer, weight, results_layer] = machine_SVC_layers(SVM(iSVM), ...
            Features(:,LogFeat), FeaturesLayers(:,LogFeat), CV_Mat, TrainSess, TestSess, opt);
    else
        acc_layer = NaN;
        results_layer = struct();
        weight = [];
    end
    
    if opt.verbose
        fprintf('\n       Running on all layers.')
    end
    
end

end
