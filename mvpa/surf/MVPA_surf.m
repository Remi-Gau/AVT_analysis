function MVPA_surf

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

NbWorkers = 10;


% Options for the SVM
[opt, ~] = get_mvpa_options();


CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR'};

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

SVM_Ori(end+1) = struct('name', 'A VS V Ipsi', 'class', [1 3], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'A VS T Ipsi', 'class', [1 5], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'V VS T Ipsi', 'class', [3 5], 'ROI_2_analyse', 1:numel(ROIs_ori));

SVM_Ori(end+1) = struct('name', 'A VS V Contra', 'class', [2 4], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'A VS T Contra', 'class', [2 6], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'V VS T Contra', 'class', [4 6], 'ROI_2_analyse', 1:numel(ROIs_ori));


% -------------------------%
%          START           %
% -------------------------%
[KillGcpOnExit] = OpenParWorkersPool(NbWorkers);


for iSub = 1:NbSub
    
    % --------------------------------------------------------- %
    %                        Subject data                       %
    % --------------------------------------------------------- %
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    SubDir = fullfile(Dirs.DerDir, SubLs(iSub).name);
    
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
    FeaturesAll = cell(numel(ROI),2); %#ok<*USENS>
    
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
            
            FeaturesAll{iROI,1} = [FeaturesAll{iROI,1} ; (Feat_L(:))' ];
            FeaturesAll{iROI,2} = [FeaturesAll{iROI,2} ; (Feat_R(:))' ];
        end
        
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
                    SVM(i).ROI(1,1) = struct('name', ROI(j).name, ...
                        'size', numel(ROI(j).VertOfInt(2)),...
                        'opt', opt);
                    SVM(iStartDir).ROI(1,2) = struct('name', ROI(j).name, ...
                        'size', numel(ROI(j).VertOfInt(2)),...
                        'opt', opt);
                else
                    SVM(i).ROI(end+1,1) = struct('name', ROI(j).name, ...
                        'size', numel(ROI(j).VertOfInt(1)),...
                        'opt', opt);
                    SVM(i).ROI(end,2) = struct('name', ROI(j).name, ...
                        'size', numel(ROI(j).VertOfInt(2)),...
                        'opt', opt);
                end
            end
        end
        clear i j
        
        for iSVM=1:numel(SVM)
            
            for iROI=SVM(iSVM).ROI_2_analyse
                
                ROI_idx = find(SVM(iSVM).ROI_2_analyse==iROI);
                
                fprintf('Analysing subject %s\n', SubLs(iSub).name)
                fprintf(' Running SVM:  %s\n', SVM(iSVM).name)
                fprintf('  Running ROI:  %s\n', SVM(iSVM).ROI(ROI_idx,1).name)
                fprintf('  Number of vertices before FS/RFE: %i %i\n', [SVM(iSVM).ROI(ROI_idx,1).size SVM(iSVM).ROI(ROI_idx,2).size])
                fprintf('   Running on %i layers\n', NbLayers)
                
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
                    load(fullfile(Dirs.DerDir, 'RunsPerSes.mat'))
                    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
                    RunPerSes = RunPerSes(Idx).RunsPerSes;
                    sets = {...
                        1:RunPerSes(1), ...
                        RunPerSes(1)+1:RunPerSes(1)+RunPerSes(2),...
                        RunPerSes(1)+RunPerSes(2)+1:sum(RunPerSes)};
                    [x, y, z] = ndgrid(sets{:});
                    cartProd = [x(:) y(:) z(:)];
                    clear x y z RunPerSes Idx
                    
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
                        TestSessList{1,1} = cartProd; % take all possible CVs
                        if opt.permutation.test % limits the number of CV for permutation
                            cartProd = cartProd(randperm(size(cartProd,1)),:);
                            TestSessList{1,1} = cartProd(1:opt.session.maxcv,:);
                        end
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
                        T = [];
                        for iPerm=1:NbPerm
                            
                            fprintf(1,'    Permutation %i out of %i\n',iPerm, NbPerm);
                            tic
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
                            
                            %%
                            for ihs=1:2
                                
                                Features = FeaturesAll{iROI,ihs};
                                LogFeat= ~any(isnan(Features));
                                FeaturesLayers = repmat(NbLayers:-1:1, 1, size(Features,2)/NbLayers);
                                
                                %% Leave-one-run-out (LORO) cross-validation
                                NbCV = size(TestSessList{iSubSampSess,1}, 1);
                                
                                fprintf(1,'    [%s]\n    [ ',repmat('.',1,NbCV));
                                parfor iCV=1:NbCV
                                    
                                    fprintf(1,'\b.\n');
                                    
                                    TestSess = []; %#ok<NASGU>
                                    TrainSess = []; %#ok<NASGU>
                                    
                                    % Separate training and test sessions
                                    [TestSess, TrainSess] = deal(false(size(1:NbRuns)));
                                    
                                    TestSess(TestSessList{iSubSampSess,1}(iCV,:)) = 1; %#ok<*PFBNS>
                                    TrainSess(setdiff(CV_id(iSubSampSess,:), TestSessList{iSubSampSess,1}(iCV,:)) )= 1;
                                    
                                    [acc_layer, results_layer, results, ~] = RunSVM(SVM, Features, LogFeat, FeaturesLayers, CV_Mat, TrainSess, TestSess, opt, iSVM);
                                    
                                    TEMP(iCV,1).layers.results = {results_layer};
                                    TEMP(iCV,1).layers.acc = acc_layer;
                                    TEMP(iCV,1).results = {results};
                                    TEMP(iCV,1).acc = mean(results.pred==results.label);
                                    
                                end
                                fprintf(1,'\b]\n');
                                
                                for iCV=1:NbCV
                                    SVM(iSVM).ROI(ROI_idx,ihs).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).layers.results =...
                                        TEMP(iCV,1).layers.results;
                                    SVM(iSVM).ROI(ROI_idx,ihs).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).layers.acc = ...
                                        TEMP(iCV,1).layers.acc;
                                    SVM(iSVM).ROI(ROI_idx,ihs).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).results = ...
                                        TEMP(iCV,1).results;
                                    SVM(iSVM).ROI(ROI_idx,ihs).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).acc = ...
                                        TEMP(iCV,1).acc;
                                end
                                
                                T(end+1)=toc;
                                fprintf(1,'    Avg time elapsed / permutation = %i secs ; ETA = %s\n',...
                                    round(mean(T)), Seconds_to_hours(round((NbPerm-iPerm)*mean(T))) );
                                fprintf(1,'    Time elapsed on last permutation = %i secs ; ETA = %s\n',...
                                    round(T(end)), Seconds_to_hours(round((NbPerm-iPerm)*T(end))) );
                                
                            end
                        end % iPerm=1:NbPerm
                        %clear iPerm
                        
                    end % iSubSampSess=1:size(CV_id, 1)
                    %clear iSubSampSess
                    
                end % NbSess2Incl = opt.session.nsamples
                %clear NbSess2Incl
                
                %% Calculate prediction accuracies
                for ihs=1:2
                    
                    Class_Acc.TotAcc(ihs,:) = ...
                        nanmean([SVM(iSVM).ROI(ROI_idx,ihs).session(end).rand.perm(1).CV(:,1).acc]);
                    for iCV=1:size(CV_id, 2)
                        temp(:,:,iCV) = SVM(iSVM).ROI(ROI_idx,ihs).session(end).rand.perm(1).CV(iCV,1).layers.acc;
                    end
                    Class_Acc.TotAccLayers{ihs} = nanmean(temp,3);
                    temp = [];
                    
                    
                    % Display some results
                    if NbPerm==1
                        fprintf('\n   Accuracy %i layers\n', NbLayers);
                        disp(Class_Acc.TotAcc(ihs,:))
                        disp(Class_Acc.TotAccLayers{ihs})
                    end
                end
                
                
                % Save data
                Results = SVM(iSVM).ROI(ROI_idx,:);
                SaveResults(SaveDir, Results, opt, Class_Acc, SVM, iSVM, ROI_idx, SaveSufix)
                
                clear Results
                

               SVM(iSVM).ROI(ROI_idx,1).session =[];
               SVM(iSVM).ROI(ROI_idx,2).session =[];
                
                

            end % iROI=1:numel(SVM(iSVM).ROI)
            clear Mask Features
            
        end % iSVM=1:numel(SVM)
        clear iSVM SVM
        
    end % for Norm = 6:7
    clear Features RegNumbers
    
end % for iSub = 1:NbSub

CloseParWorkersPool(KillGcpOnExit)

end


function str = Seconds_to_hours(s)

h = floor(s/3600);
min = floor(mod(s,3600)/60);

if h==0
    str = sprintf('%i min',min);
else
    str = sprintf('%i hrs %i min',h, min);
end

end
