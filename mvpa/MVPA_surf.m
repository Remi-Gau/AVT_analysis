function MVPA_surf
% very generic function to run MVPA on surface data
% - either on B parameters layer by layer (or on the whole ROI)
% - or on the S parameters (cst, lin or average for each vertex)
%
% Analysis is run by pooling over hemisphere


% to do
% test on whole ROI


% to do
% make it usable with targets


clc; clear;

if isunix
    CodeDir = '/home/remi/github/AVT_analysis';
    StartDir = '/home/remi';
elseif ispc
    CodeDir = 'D:\github\AVT-7T-code';
    StartDir = 'D:\';
else
    disp('Platform not supported')
end

addpath(genpath(fullfile(CodeDir, 'subfun')))

[Dirs] = set_dir();

Get_dependencies()

SubLs = dir(fullfile(Dirs.DerDir, 'sub*'));
NbSub = numel(SubLs);

NbLayers = 6;

NbWorkers = 3;

CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR'};

ROIs_ori = {
    'A1',...
    'PT',...
    'V1',...
    'V2'};

ToPlot={'Cst','Lin','Avg','ROI'};

[opt, file2load_suffix] = get_mvpa_options();

opt

% Class = get_mvpa_class();

SVM_Ori = get_mvpa_classification(ROIs_ori);
SVM_Ori(10:end) = [];

% -------------------------%
%          START           %
% -------------------------%
[KillGcpOnExit] = OpenParWorkersPool(NbWorkers);

for iToPlot = 1:2
    
    opt.toplot = ToPlot{iToPlot};
    
    for iSub = 5 %[1:4 6:NbSub]
        
        % --------------------------------------------------------- %
        %                        Subject data                       %
        % --------------------------------------------------------- %
        fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
        
        SubDir = fullfile(Dirs.DerDir, SubLs(iSub).name);
        
        Data_dir = fullfile(SubDir,'results','profiles','surf','PCM');

        SaveDir = fullfile(SubDir, 'results', 'SVM');
        [~,~,~] = mkdir(SaveDir);
        
        % Load Vertices of interest for each ROI;
        load(fullfile(SubDir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex')
        
        
        %% Read features
        fprintf(' Reading features\n')
        if iToPlot<4
            FeatureSaveFile = ['Data_' file2load_suffix '.mat'];
            load(fullfile(Data_dir, FeatureSaveFile), 'PCM_data', 'conditionVec', 'partitionVec')
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
        
        
        %% process partition and condition vector
        if iSub==5
            % remove session 17 for sub-06
            RowsToRemove = all(partitionVec==17,2);
            partitionVec(partitionVec>17) = partitionVec(partitionVec>17) - 1;
        else
            RowsToRemove = zeros(size(partitionVec));
        end
        
        RowsToRemove(conditionVec>6) = 1;
 
        
        %% Remove extra data and checks for zeros and NANs
        for iROI = 1:numel(ROIs_ori)
            
            % Remove nans along columns
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
                
                Data{iROI,1} = clean_data(Data{iROI,1}, 2);
                Data{iROI,2} = clean_data(Data{iROI,2}, 2);
                
            end
            
            % note rows made of only NaNs and zeros
            [~, RowsToRemove] = clean_data(Data{iROI,1}, 1, RowsToRemove);
            [~, RowsToRemove] = clean_data(Data{iROI,2}, 1, RowsToRemove);

            
            % construct a vector that identify what column belongs to which layer
            if iToPlot==4
                FeaturesLayers{iROI,1} = ...
                    repmat(NbLayers:-1:1, 1, size(Data{iROI,1},2)/NbLayers);
                FeaturesLayers{iROI,2} = ...
                    repmat(NbLayers:-1:1, 1, size(Data{iROI,2},2)/NbLayers);
            end
            
        end
        
        % take note of any row that needs to be removed across all ROIs
        RowsToRemove = any(RowsToRemove,2);
        
        % remove those rows from all ROIs
        for iROI = 1:numel(ROIs_ori) 
            
            Data{iROI,1}(RowsToRemove,:) = [];
            Data{iROI,2}(RowsToRemove,:) = [];
        
        end


        %% check that we have the same number of conditions in each partition
        
        partitionVec(RowsToRemove) = [];
        conditionVec(RowsToRemove) = [];
        
        CV_Mat_Orig = [conditionVec partitionVec];
        
        
        A = tabulate(CV_Mat_Orig(:,2));
        A = A(:,1:2);
        if numel(unique(A(:,2)))>1
            error('We have different numbers of conditions in at least one partition.')
            
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
        
        
        
        %% Number of partitions
        % If we want to have a learning curve
        Nb_sess = max(partitionVec);
        if opt.session.curve
            % #sessions over which to run the learning curve
            opt.session.nsamples = 10:2:Nb_sess;
        else
            opt.session.nsamples = Nb_sess;
        end
        
        
        %% Run for different type of normalization
        for Norm = 6
            
            opt = ChooseNorm(Norm, opt);
            
            SaveSufix = CreateSaveSuffix(opt, [], NbLayers, 'surf');
            
            
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
                    for iROI = 1:numel(ROIs_ori)
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
                    for iROI = 1:numel(ROIs_ori)
                        FeaturesAll{iROI,1}= [ Data{iROI,1} Data{iROI,2} ];
                    end
                end
                
                for iROI=SVM(iSVM).ROI_2_analyse
                    
                    clear FeaturesBoth LogFeatBoth
                    
                    ROI_idx = find(SVM(iSVM).ROI_2_analyse==iROI);
                    
                    fprintf('Analysing subject %s\n', SubLs(iSub).name)
                    fprintf(' Running SVM:  %s\n', SVM(iSVM).name)
                    fprintf('  Running ROI:  %s\n', SVM(iSVM).ROI(ROI_idx).name)
                    fprintf('  Number of features before FS/RFE: %i\n', SVM(iSVM).ROI(ROI_idx).size)
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
                        load(fullfile(Dirs.DerDir, 'RunsPerSes.mat'))
                        Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
                        RunPerSes = RunPerSes(Idx).RunsPerSes;
                        
                        if iSub==5
                            RunPerSes(end) = RunPerSes(end)-1;
                        end

                        % Test sets for the different CVs
                        if opt.session.curve
                            
                            error('learning curves are not implemented')
                            
%                             for i=1:size(CV_id,1)
%                                 Limits to CV max
%                                 TestSessList{i,1} = nchoosek(CV_id(i,:), floor(opt.session.proptest*NbSess2Incl));
%                                 TestSessList{i,1} = TestSessList{i,1}(randperm(size(TestSessList{i,1},1)),:);
%                                 if size(TestSessList{i,1}, 1) >  opt.session.maxcv
%                                   TestSessList{i,1} = TestSessList{i,1}(1:opt.session.maxcv,:);
%                                 end
%                                 if opt.permutation.test
%                                     TestSessList{i,1} = cartProd;
%                                 end
%                             end

                        else
                            
                            if opt.session.loro
                                
                                TestSessList{1,1} = (1:sum(RunPerSes))';
                                
                            else
                                
                                sets = {...
                                    1:RunPerSes(1), ...
                                    RunPerSes(1)+1:RunPerSes(1)+RunPerSes(2),...
                                    RunPerSes(1)+RunPerSes(2)+1:sum(RunPerSes)};
                                
                                [x, y, z] = ndgrid(sets{:});
                                
                                cartProd = [x(:) y(:) z(:)];

                                TestSessList{1,1} = cartProd; % take all possible CVs
                                
                                clear cartProd sets x y Idx
                                
                                if opt.permutation.test % limits the number of CV for permutation
                                    cartProd = cartProd(randperm(size(cartProd,1)),:);
                                    TestSessList{1,1} = cartProd(1:opt.session.maxcv,:);
                                end
                            end
                            
                        end
                        clear  RunPerSes
                        
                        
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