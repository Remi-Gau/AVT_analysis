function MVPA_vol_pool_hs
clc; clear;

StartDir = fullfile(pwd, '..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;
FWHM = [0];

NbWorkers = 8;

% Options for the SVM
[opt, ~] = get_mvpa_options();

CondNames = {...
    'AStimL','AStimR';...
    'VStimL','VStimR';...
    'TStimL','TStimR';...
    'ATargL','ATargR';...
    'VTargL','VTargR';...
    'TTargL','TTargR';...
    };


% --------------------------------------------------------- %
%              Classes and associated conditions            %
% --------------------------------------------------------- %
Class(1) = struct('name', 'A Stim', 'cond', cell(1), 'nbetas', 2);
Class(end).cond = {'AStimL' 'AStimR'};

Class(2) = struct('name', 'V Stim', 'cond', cell(1), 'nbetas', 2);
Class(end).cond = {'VStimL' 'VStimR'};

Class(3) = struct('name', 'T Stim', 'cond', cell(1), 'nbetas', 2);
Class(end).cond = {'TStimL' 'TStimR'};


Class(4) = struct('name', 'A Stim - Left', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'AStimL'};

Class(5) = struct('name', 'A Stim - Right', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'AStimR'};


Class(6) = struct('name', 'V Stim - Left', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'VStimL'};

Class(7) = struct('name', 'V Stim - Right', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'VStimR'};


Class(8) = struct('name', 'T Stim - Left', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'TStimL'};

Class(9) = struct('name', 'T Stim - Right', 'cond', cell(1), 'nbetas', 1);
Class(end).cond = {'TStimR'};


% --------------------------------------------------------- %
%                            ROIs                           %
% --------------------------------------------------------- %
Mask_Ori.ROI(1) = struct('name', 'TE_L', 'fname', 'rwTe_L_Cyt.nii');
Mask_Ori.ROI(end+1) = struct('name', 'PT_L', 'fname', 'rwA41-42_L.nii');
Mask_Ori.ROI(end+1) = struct('name', 'pSTG_L', 'fname', 'rwpSTG_L.nii');

Mask_Ori.ROI(end+1) = struct('name', 'S1_L_cyt', 'fname', 'rwS1_L_Cyt.nii');
Mask_Ori.ROI(end+1) = struct('name', 'S1_L_aal', 'fname', 'rwS1_L_AAL.nii');

Mask_Ori.ROI(end+1) = struct('name', 'V1_L', 'fname', 'rwV1_L_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V2_L', 'fname', 'rwV2_L_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V3_L', 'fname', 'rwV3_L_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V4_L', 'fname', 'rwV4_L_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V5_L', 'fname', 'rwV5_L_ProbRet.nii');


Mask_Ori.ROI(end+1) = struct('name', 'TE_R', 'fname', 'rwTe_R_Cyt.nii');
Mask_Ori.ROI(end+1) = struct('name', 'PT_R', 'fname', 'rwA41-42_R.nii');
Mask_Ori.ROI(end+1) = struct('name', 'pSTG_R', 'fname', 'rwpSTG_R.nii');

Mask_Ori.ROI(end+1) = struct('name', 'S1_R_cyt', 'fname', 'rwS1_R_Cyt.nii');
Mask_Ori.ROI(end+1) = struct('name', 'S1_R_aal', 'fname', 'rwS1_R_AAL.nii');

Mask_Ori.ROI(end+1) = struct('name', 'V1_R', 'fname', 'rwV1_R_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V2_R', 'fname', 'rwV2_R_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V3_R', 'fname', 'rwV3_R_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V4_R', 'fname', 'rwV4_R_ProbRet.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V5_R', 'fname', 'rwV5_R_ProbRet.nii');

% Indicate which ROIs to pool - first column is left hs, second one is righ hs
PoolHs = [[1:10]',[11:20]']; %#ok<NBRAK>

% --------------------------------------------------------- %
%                     Analysis to perform                   %
% --------------------------------------------------------- %
SVM_Ori(1) = struct('name', 'A Ipsi VS Contra', 'class', [4 5], 'ROI', 2, 'swap', 1, 'shift', 0);
SVM_Ori(end+1) = struct('name', 'V Ipsi VS Contra', 'class', [6 7], 'ROI', 2, 'swap', 1, 'shift', 0);
SVM_Ori(end+1) = struct('name', 'T Ipsi VS Contra', 'class', [8 9], 'ROI', 2, 'swap', 1, 'shift', 0);
% 
SVM_Ori(end+1) = struct('name', 'A VS V Ipsi', 'class', [4 6], 'ROI', 2, 'swap', 0, 'shift', 1);
SVM_Ori(end+1) = struct('name', 'A VS T Ipsi', 'class', [4 8], 'ROI', 2, 'swap', 0, 'shift', 1);
SVM_Ori(end+1) = struct('name', 'V VS T Ipsi', 'class', [6 8], 'ROI', 2, 'swap', 0, 'shift', 1);

SVM_Ori(end+1) = struct('name', 'A VS V Contra', 'class', [5 7], 'ROI', 2, 'swap', 0, 'shift', -1);
SVM_Ori(end+1) = struct('name', 'A VS T Contra', 'class', [5 9], 'ROI', 2, 'swap', 0, 'shift', -1);
SVM_Ori(end+1) = struct('name', 'V VS T Contra', 'class', [7 9], 'ROI', 2, 'swap', 0, 'shift', -1);
% SVM_Ori(end+1) = struct('name', 'V VS T Contra', 'class', [7 9], 'ROI', 1:size(PoolHs,1), 'swap', 0, 'shift', -1);

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
    
    Mask = Mask_Ori;
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    RoiFolder = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp');
    AnalysisFolder = fullfile(SubDir, 'ffx_nat', 'betas');
    SaveDir = fullfile(SubDir, 'results', 'SVM');
    [~,~,~] = mkdir(SaveDir);
    
    
    % Gets the number of each beta images and the numbers of the beta of
    % interest
    load(fullfile(SubDir, 'ffx_nat','SPM.mat'))
    RegNumbers = GetRegNb(SPM);
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    
    for i=1:size(BetaNames,1)
        if BetaNames(i,6)==' '
            tmp(i,1:6) = BetaNames(i,7:12);
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
    
    
    %% Gets global mask from GLM and ROI masks for the data
    fprintf(' Reading masks\n')
    
    if ~exist(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii']), 'file')
        try
            gunzip(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii.gz']))
        catch
            error('The GLM mask file %s is missing.', ['r' SubLs(iSub).name '_GLM_mask.nii'])
        end
    end
    Mask.global.hdr = spm_vol(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii']));
    Mask.global.img = logical(spm_read_vols(Mask.global.hdr));
    
    for i=1:length(Mask.ROI)
        Mask.ROI(i).hdr = spm_vol(fullfile(RoiFolder, Mask.ROI(i).fname));
    end
    
    hdr = cat(1, Mask.ROI.hdr);
    sts = spm_check_orientations([Mask.global.hdr; hdr]);
    if sts ~= 1
        error('Images not in same space!');
    end
    
    clear sts hdr i
    
    
    % Create mask in XYZ format (both world and voxel coordinates)
    [X, Y, Z] = ind2sub(size(Mask.global.img), find(Mask.global.img));
    Mask.global.XYZ = [X'; Y'; Z']; % XYZ format
    clear X Y Z
    Mask.global.size = size(Mask.global.XYZ, 2);
    Mask.global.XYZmm = Mask.global.hdr.mat(1:3,:) ...
        * [Mask.global.XYZ; ones(1, Mask.global.size)]; % voxel to world transformation
    
    
    % Combine masks
    xY.def = 'mask';
    for i=1:length(Mask.ROI)
        xY.spec = fullfile(RoiFolder, Mask.ROI(i).fname);
        [xY, Mask.ROI(i).XYZmm, j] = spm_ROI(xY, Mask.global.XYZmm);
        Mask.ROI(i).XYZ = Mask.global.XYZ(:,j);
        Mask.ROI(i).size = size(Mask.ROI(i).XYZ, 2);
    end
    
    clear xY j i
    
    
    %% Gets Layer labels
    fprintf(' Reading layer labels\n')
    
    LayerLabelsFile = dir(fullfile(SubDir, 'anat', 'cbs', ...
        ['sub-*_MP2RAGE_T1map_Layers-' sprintf('%02.0f', NbLayers) '.nii']));
    
    
    % Unzip the file if necessary
    if ~isempty(LayerLabelsFile)
        LayerLabelsHdr = spm_vol(fullfile(SubDir, 'anat', 'cbs', ...
            LayerLabelsFile.name));
    else
        try
            LayerLabelsFile = dir(fullfile(SubDir, 'anat', 'cbs', ...
                ['sub-*_MP2RAGE_T1map_Layers-' sprintf('%02.0f', NbLayers) '.nii.gz']));
            gunzip(fullfile(SubDir, 'anat', 'cbs', ...
                LayerLabelsFile.name));
            LayerLabelsHdr = spm_vol(fullfile(SubDir, 'anat', 'cbs', ...
                LayerLabelsFile.name(1:end-3)));
        catch
            error(['The layer label file ' LayerLabels 'is missing.'])
        end
    end
    
    sts = spm_check_orientations([Mask.global.hdr; LayerLabelsHdr]);
    if sts ~= 1
        error('Images not in same space!');
    end
    clear sts
    
    for i=1:length(Mask.ROI)
        LayerLabels{i} = spm_get_data(LayerLabelsHdr, Mask.ROI(i).XYZ); %#ok<*AGROW>
    end
    
    
    %% Run for different smoothness
    for iFWHM = 1:length(FWHM)
        
        if FWHM(iFWHM)==0
            SmoothSufix=[];
        else
            SmoothSufix=['_l-' num2str(NbLayers) '_s-' num2str(FWHM(iFWHM)) '_Slab'];
        end
        
        %% Creates a dataset that lists for each beta of interest:
        %   - its corresponding class
        %   - the session in which it occurs
        CV_Mat_Orig = [zeros(NbRuns*sum([Class.nbetas]), 1) ...
            zeros(NbRuns*sum([Class.nbetas]), 1)] ;
        
        % For each condition of each class we figure out what is the associated
        % regressors and in which sessions they occur.
        FilesList = {};
        irow = 1;
        for iClass=1:numel(Class)
            for iCond=1:numel(Class(iClass).cond)
                
                tmp=BetaNames(BetaOfInterest,1:length(char(Class(iClass).cond(iCond))));
                TEMP = BetaOfInterest(strcmp(Class(iClass).cond(iCond), cellstr(tmp)));
                
                for i=1:length(TEMP)
                    CV_Mat_Orig(irow,1) = iClass;
                    [I,~] = find(TEMP(i)==RegNumbers);
                    CV_Mat_Orig(irow,2) = I;
                    irow = irow + 1;
                    
                    FilesList{end+1,1} = fullfile(AnalysisFolder, ...
                        sprintf('r%s_beta-%04d%s.nii', SubLs(iSub).name, TEMP(i), SmoothSufix));
                end
                clear TEMP I i tmp
                
            end
        end
        
        clear irow iClass iCond
        
        
        %% Mask each image by each ROI and create a features set (images x voxel)
        fprintf('\n Get features\n')

        for i=1:length(Mask.ROI)
            
            FeatureFile = fullfile(AnalysisFolder, ['Features_' Mask.ROI(i).name ...
                '_l-' num2str(NbLayers) '_s-' num2str(FWHM)  '.mat']);
            
            % Load the feature file if it exists
            if exist(FeatureFile, 'file')
                load(FeatureFile, 'Features', 'MaskSave', 'FilesListSave')
                
                % Make sure that we have the right ROI
                if ~isequal(MaskSave, Mask.ROI(i))
                    NeedFeat(i) = true;
                end
                
                % Make sure that the right features were extracted
                if ~isequal(FilesListSave, FilesList)
                    NeedFeat(i) = true;
                end
                
                FeaturesAll{i} = Features{1};
                NeedFeat(i) = false;
                
                % Otherwise flag this ROI to feature extraction
            else
                NeedFeat(i) = true;
            end
            
            clear FilesListSave MaskSave Features
            
        end
        
        % Extract the features of the missing ROIs
        if any(NeedFeat)
            GetFeaturesMVPA(Mask.ROI(NeedFeat), FilesList, AnalysisFolder, NbLayers, FWHM(iFWHM));
            
            % Reload everything
            for i=1:length(Mask.ROI)
                FeatureFile = fullfile(AnalysisFolder, ['Features_' Mask.ROI(i).name '_l-' ...
                    num2str(NbLayers) '_s-' num2str(FWHM)  '.mat']);
                load(FeatureFile, 'Features')
                FeaturesAll{i} = Features{1};
            end
        end
        
        Features = FeaturesAll;
        
        clear FilesList FeaturesAll
        
        
        %% Run for different type of normalization
        for Norm = [6]
            
        opt = ChooseNorm(Norm, opt);
        
                    SaveSufix = CreateSaveSuffix(opt, FWHM(iFWHM), NbLayers, 'vol');
            
            %% Run cross-validation for each model and ROI
            SVM = SVM_Ori;
            
            for i=1:numel(SVM)
                for j=1:numel(SVM(i).ROI)
                    
                    SVM(i).ROI_XYZ{j,1} = [...
                        Mask.ROI(PoolHs(SVM(i).ROI(j),1)).XYZ ...
                        Mask.ROI(PoolHs(SVM(i).ROI(j),2)).XYZ];

                end
                
                SVM(i).ROI = struct('name', strrep({Mask.ROI(SVM(i).ROI).name}','_L', ''), ...
                    'size', num2cell([Mask.ROI(PoolHs(SVM(i).ROI,1)).size]' ...
                    + [Mask.ROI(PoolHs(SVM(i).ROI,2)).size]') );

                
            end
            
            clear i j
            
            for iSVM=1:numel(SVM)
                
                for iROI=1:numel(SVM(iSVM).ROI)
                    
                    % RNG init
                    rng('default');
                    opt.seed = rng;
                    
                    Class_Acc = struct('Pred', [], 'Label', [], 'Acc', [], 'TotAcc', []);
                    
                    
                    % ROI index
                    ROI_L = ismember(strrep({Mask.ROI(1:numel(Mask.ROI)/2).name},'_L',''),...
                        SVM(iSVM).ROI(iROI).name);
                    ROI_L = PoolHs(ROI_L,1);
                    ROI_R = ismember(strrep({Mask.ROI(numel(Mask.ROI)/2+1:end).name},'_R',''),...
                        SVM(iSVM).ROI(iROI).name);
                    ROI_R = PoolHs(ROI_R,2);

                    fprintf('\n Subject %s running SVM:  %s\n', SubLs(iSub).name, SVM(iSVM).name)
                    fprintf('  Running ROI:  %s\n', SVM(iSVM).ROI(iROI).name)
                    fprintf('  Number of voxel before FS/RFE: %i\n', SVM(iSVM).ROI(iROI).size)
                    
                    
                    %% Subsample sessions for the learning curve (otherwise take
                    % all of them)
                    for NbSess2Incl = opt.session.nsamples
                        
                        if NbSess2Incl < NbRuns
                            fprintf('  Running learning curve with %i sessions\n', NbSess2Incl)
                        else
                            fprintf('  Running analysis with all sessions\n')
                        end
                                                
                        % All possible ways of only choosing X sessions of the total
                        CV_id = nchoosek(1:NbRuns, NbSess2Incl);
                        CV_id = CV_id(randperm(size(CV_id, 1)),:);
                        
                        % Limits the number of permutation if too many
                        if size(CV_id, 1) > opt.session.subsample.nreps
                            CV_id = CV_id(1:opt.session.subsample.nreps,:);
                        end
                        
                        % Defines the test sessions for the CV
                        % Limits to CV max
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
%                             TestSessList{i,1} = nchoosek(CV_id(i,:), floor(opt.session.proptest*NbSess2Incl));
%                             TestSessList{i,1} = TestSessList{i,1}(randperm(size(TestSessList{i,1},1)),:);
%                             if size(TestSessList{i,1}, 1) >  opt.session.maxcv    
%                                 TestSessList{i,1} = TestSessList{i,1}(1:opt.session.maxcv,:);
%                             end                        
                        end

                        
                        %% Subsampled sessions loop
                        for iSubSampSess=1:size(CV_id, 1)
                            
                            % Permutation test
                            if NbSess2Incl < NbRuns
                                NbPerm = 1;
                            else
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

                                
                                %% Get ROIs features
                                % Swap features rows for the right ROI
                                tmp = Features{ROI_R};
                                if SVM(iSVM).swap
                                    tmp(CV_Mat(:,1)==SVM(iSVM).class(1),:) = Features{ROI_R}(CV_Mat(:,1)==SVM(iSVM).class(2),:);
                                    tmp(CV_Mat(:,1)==SVM(iSVM).class(2),:) = Features{ROI_R}(CV_Mat(:,1)==SVM(iSVM).class(1),:);
                                elseif SVM(iSVM).shift
                                    tmp(CV_Mat(:,1)==SVM(iSVM).class(1),:) = Features{ROI_R}(CV_Mat(:,1)==SVM(iSVM).class(1)+SVM(iSVM).shift,:);
                                    tmp(CV_Mat(:,1)==SVM(iSVM).class(2),:) = Features{ROI_R}(CV_Mat(:,1)==SVM(iSVM).class(2)+SVM(iSVM).shift,:);
                                end
                                
                                Features_ROI = [Features{ROI_L} tmp];
                                LayerLabels_ROI = [LayerLabels{ROI_L} LayerLabels{ROI_R}];
                                
                                LayerLabels_ROI(:,any(isnan(Features_ROI),1))=[];
                                Features_ROI(:,any(isnan(Features_ROI),1))=[];
                                
                                Features_ROI = Features_ROI(:,logical(LayerLabels_ROI));
                                LayerLabels_ROI = LayerLabels_ROI(:,logical(LayerLabels_ROI));

                                
                                %% Subsample voxels withing a layer
                                % so that all layers an equal number of voxels
                                if opt.layersubsample.do==0
                                    
                                    Class_Acc = struct('Pred', [], 'Label', [], 'Acc', [], 'TotAcc', []);
                                    
                                    Features_ROI_Cell = {Features_ROI};
                                    LayerLabels_ROI_Cell = {LayerLabels_ROI};
                                    
                                else
                                    RepScheme = opt.layersubsample.repscheme;
                                    
                                    for i = 1:(max(RepScheme))
                                        for j = 1:size(RepScheme,2)
                                            Class_Acc(i,j) = struct('Pred', [], 'Label', [], 'Acc', [], 'TotAcc', []);
                                        end
                                    end
                                    
                                    MIN = tabulate(LayerLabels_ROI);
                                    MIN = min(MIN(:,2));
                                    
                                    TEMP = cell(RepScheme);
                                    TEMP2 = cell(RepScheme);
                                    
                                    for iLayer = 1:(NbLayers)
                                        
                                        for i = 1:(max(RepScheme))
                                            for j = 1:size(RepScheme,2)
                                                
                                                tmp = find(LayerLabels_ROI==iLayer);
                                                tmp = tmp(randperm(length(tmp)));
                                                tmp = tmp(1:MIN);
                                                
                                                TEMP{i,j} = [TEMP{i,j} LayerLabels_ROI(tmp)];
                                                TEMP2{i,j} = [TEMP2{i,j} Features_ROI(:,tmp)];
                                                
                                                clear tmp
                                                
                                            end
                                        end
                                    end
                                    
                                    Features_ROI_Cell = TEMP2;
                                    LayerLabels_ROI_Cell = TEMP;
                                    
                                    clear TEMP TEMP2 MIN i j
                                    
                                end
                                
                                %% Leave-X-run-out cross-validation
                                tic;
                                
                                for i=1:size(Features_ROI_Cell,1)
                                    for j=1:size(Features_ROI_Cell,2)
                                        
                                        LayerLabels_ROI = LayerLabels_ROI_Cell{i,j};
                                        Features_ROI = Features_ROI_Cell{i,j};
                                        
                                        parfor iCV=1:size(TestSessList{iSubSampSess,1}, 1)
                                            TestSess = []; %#ok<NASGU>
                                            TrainSess = []; %#ok<NASGU>
                                            
                                            % Separate training and test sessions
                                            [TestSess, TrainSess] = deal(false(size(1:NbRuns)));
                                            
                                            TestSess(TestSessList{iSubSampSess,1}(iCV,:)) = 1;
                                            TrainSess(setdiff(CV_id(iSubSampSess,:), TestSessList{iSubSampSess,1}(iCV,:)) )= 1;
                                            
                                            % Run SVM
                                            TEMP{iCV,1} = machine_SVC(SVM(iSVM), Features_ROI, CV_Mat, TrainSess, TestSess, opt);
                                            
                                            % Run SVM
                                            for iLayer= 1:NbLayers
                                                Features_ROI_Layer = Features_ROI(:,LayerLabels_ROI==iLayer);
                                                TEMP2{iCV,iLayer} = machine_SVC(SVM(iSVM), Features_ROI_Layer, CV_Mat, TrainSess, TestSess, opt);
                                            end
                                        end
                                        clear iCV TestSess TrainSess
                                        
                                        for iCV=1:size(TestSessList{iSubSampSess,1}, 1)
                                            SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{i,j}.CV(iCV,1) = TEMP{iCV,1};
                                            for iLayer = 1:NbLayers
                                                SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{i,j}.CV(iCV,1+iLayer) = TEMP2{iCV,iLayer};
                                            end
                                        end
                                        clear TEMP TEMP2
                                        
                                        SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{i,j}.CV_id= CV_id;
                                        SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{i,j}.TestSessList = TestSessList;
                                        
                                        % Calculate prediction accuracies                                        
                                        for iLayer = 1:(NbLayers+1)
                                            for iCV=1:size(TestSessList{iSubSampSess,1}, 1) 
                                                pred = SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{i,j}.CV(iCV,iLayer).pred;
                                                label = SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{i,j}.CV(iCV,iLayer).label;
                                                Acc(iCV) = mean(pred==label);
                                                clear pred label
                                            end
                                            Class_Acc(i,j).TotAcc(NbSess2Incl,iSubSampSess,iPerm,iLayer) = mean(Acc);
                                            clear Acc
                                        end
                                        clear tmp
                                    end
                                end
                                
                                t = toc;
                                SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).ExecTime = t;
                                

                                %% Display some results
                                if iPerm == 1 && NbSess2Incl == NbRuns && opt.layersubsample.do==0
                                    if ~isempty(SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{1,1}.CV(1).fs)
                                        fprintf('  Number of voxel after FS :  %i\n', ...
                                            mean([SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{1,1}.CV(:).fs.size]));
                                    end
                                    if  ~isempty(SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{1,1}.CV(1).rfe)
                                        fprintf('  Number of voxel after RFE:  %i\n', ...
                                            mean([SVM(iSVM).ROI(iROI).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).SubSamp{1,1}.CV(:).rfe.size]));
                                    end
                                    seq = repmat(' %0.3f',[1 NbLayers+1]);
                                    fprintf(['  Accuracy\n' seq '\n'], squeeze(Class_Acc.TotAcc(end,1,1,:))');
                                    if opt.permutation.test
                                        fprintf('  Running permutations\n')
                                    end
                                end
                                
                                if opt.permutation.test && iPerm == opt.permutation.nreps && NbSess2Incl == NbRuns
                                    fprintf('  Accuracy over permutations = %2.3f +/- %2.3f\n', ...
                                        mean(squeeze(Class_Acc.TotAcc(NbSess2Incl,iSubSampSess,2:iPerm))), ...
                                        std(squeeze(Class_Acc.TotAcc(NbSess2Incl,iSubSampSess,2:iPerm))) )
                                end
                                
                            end % iPerm=1:NbPerm
                            clear iPerm
                            
                        end % iSubSampSess=1:size(CV_id, 1)
                        clear iSubSampSess
                        
                    end % NbSess2Incl = opt.session.nsamples
                    clear NbSess2Incl
                    
                    % Save data into partially readable mat file (see matfile)
                    Results = SVM(iSVM).ROI(iROI);
                    SVM(iSVM).ROI(iROI).session=[]; % Remove the last results to save memory.
                    SaveResults(SaveDir, Results, opt, Class_Acc, SVM, iSVM, iROI, SaveSufix)
                    
                end % iSubROI=1:numel(SVM(iSVM).ROI)
                
            end % iSVM=1:numel(SVM)
            clear iSVM SVM
            
        end % for Norm = 6:7
        clear Features
        
    end % for iFWHM = 1:length(FWHM)
    clear RegNumbers
    
end % for iSub = 1:NbSub


CloseParWorkersPool(KillGcpOnExit)

end