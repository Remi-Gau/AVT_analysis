% (C) Copyright 2020 Remi Gau
%
% Generic script to run MVPA
%
% For surface based analysis
% - either on B parameters layer by layer or on the whole ROI
% - or on the S parameters (cst, lin or average for each vertex)
%
% For Volume
% - either on layer by layer or on the whole ROI
%

% TODO
% - make it usable with targets
% - make it usable with volume
% - make it usable with to run each hemisphere independently

clc;
clear;

% Choose on what type of data the analysis will be run
%
% b-parameters
%
% 'ROI'
%
% s-parameters
%
% 'Cst', 'Lin', 'Quad'
%

IsTarget = false;
InputType = 'ROI';

ROIs = {
        'A1', ...
        'PT', ...
        'V1', ...
        'V2'};

% See get_mvpa_classification() for more info
ClassificationsToRun = 5; % 1:9

Space = 'surf';

Norm = 6;
MVNN = false;

NbLayers = 6;
RunOnLayers = true;

NbWorkers = 3;

FWHM = 0;

% To run the analysis on dummy noise data
% see GenerateNoiseData()
DummyData = true;

%% Set up

% Avoid some impossible choices in terms of analysis
if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))
    Space = 'surf';
    RunOnLayers = false;
end

ConditionType = 'stim';
if IsTarget
    ConditionType = 'target';
end

opt = get_mvpa_options(MVNN, Norm);
opt.input = InputType;

Dirs = SetDir(Space, MVNN);
InputDir = Dirs.ExtractedBetas;
if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))
    InputDir = Dirs.LaminarGlm;
end
if DummyData
    InputDir = Dirs.DummyData;
    ROIs = {'dummyROI'};
end

[SubLs, NbSub] = GetSubjectList(InputDir);

KillGcpOnExit = OpenParWorkersPool(NbWorkers);

%%
for iSub = 1:NbSub

    fprintf('Analysing subject %s\n', SubLs(iSub).name);

    SvmOri = get_mvpa_classification(opt);
    SvmOri = SvmOri(ClassificationsToRun);

    SubDir = fullfile(InputDir, SubLs(iSub).name);

    OutputDir = fullfile(Dirs.MvpaResultsDir, SubLs(iSub).name);
    [~, ~, ~] = mkdir(OutputDir);

    for iSVM = 1:numel(SvmOri)

        for iROI = 1:numel(ROIs)

            SVM = SvmOri(iSVM);

            fprintf(' Running SVM: %s\n', SVM.name);
            fprintf('  Running ROI: %s\n', ROIs{iROI});

            %% Load from both hemisphere and rearrange data
            DataHs = cell(1, 2);

            for ihs = 1:2

                HsSufix = 'l';
                if ihs == 2
                    HsSufix = 'r';
                end

                Filename = GetNameFileToLoad( ...
                                             SubDir, SubLs(iSub).name, ...
                                             HsSufix, ...
                                             NbLayers, ...
                                             ROIs{iROI}, ...
                                             InputType);

                load(Filename, 'RoiData', 'ConditionVec', 'RunVec');
                LayerVec = ones(size(ConditionVec));
                if strcmp(InputType, 'ROI')
                    load(Filename, 'LayerVec');
                end

                [Data, RunVec, ConditionVec, LayerVec] = CheckInput( ...
                                                                    RoiData, ...
                                                                    RunVec, ...
                                                                    ConditionVec, ...
                                                                    IsTarget, ...
                                                                    LayerVec);

                DataHs{1, ihs} = ReassignIpsiAndContra(Data, ConditionVec, HsSufix, SVM.Featpool);

            end

            CvMatOrig = [ConditionVec RunVec LayerVec];

            % Pool data between hemispheres
            Data = CombineDataBothHemisphere(DataHs);
            clear DataHs;

            % TODO
            % Check that there is no NaN or fetaure with all 0

            SVM.ROI = struct( ...
                             'name', ROIs{iROI}, ...
                             'size', size(Data, 2));

            fprintf('   Number of features before FS/RFE: %i\n', SVM.ROI.size);

            %% Number of partitions
            % If we want to have a learning curve
            NbRuns = numel(unique(RunVec));

            if opt.runs.curve
                % nb runs over which to run the learning curve
                opt.runs.nsamples = 10:2:NbRuns;
            else
                opt.runs.nsamples = NbRuns;
            end

            % RNG init
            rng('default');
            opt.seed = rng;

            %% Subsample sessions for the learning curve (otherwise take all of them)
            for NbRuns2Incl = opt.runs.nsamples

                % All possible ways of only choosing X runs of the total
                cv = nchoosek(unique(RunVec), NbRuns2Incl);
                cv = cv(randperm(size(cv, 1)), :);

                % Limits the number of permutation if too many
                if size(cv, 1) > opt.runs.subsample.nreps
                    cv = cv(1:opt.runs.subsample.nreps, :);
                end

                TestRunsList = define_test_runs_list(opt, iSub, unique(RunVec));

                %% For each sub-sample of runs loop for learning curve
                for RunSubSamp = 1:size(cv, 1)

                    % Permutation test
                    NbPerm = 1;
                    if NbRuns2Incl < NbRuns
                        fprintf('    Running learning curve with %i runs\n', NbRuns2Incl);
                        fprintf('     %i of %i \n\n', RunSubSamp, size(cv, 1));
                    else
                        fprintf('    Running analysis with all runs\n');
                        NbPerm = opt.permutation.nreps;
                    end

                    %% Permutation loop
                    for iPerm = 1:NbPerm

                        CvMat = CvMatOrig;

                        CvMat = permutate_labels(opt, CvMat, SVM);

                        ClassAcc = struct('TotAcc', []);

                        NbCV = size(TestRunsList{RunSubSamp, 1}, 1);

                        %% Decoding layer by layer if needed
                        % TODO:
                        % - reimplement cross layer decoding ?

                        if RunOnLayers
                            fprintf('    Running on %i layers\n', NbLayers);

                            fprintf(1, '    [%s]\n    [', repmat('.', 1, NbCV));

                            for iCV = 1:NbCV

                                fprintf(1, '.');

                                for iLayer = 1:NbLayers

                                    [TestRuns, TrainRuns] = define_train_and_test_runs( ...
                                                                                       NbRuns, ...
                                                                                       TestRunsList, ...
                                                                                       RunSubSamp, ...
                                                                                       cv, ...
                                                                                       iCV);

                                    results = run_SVC( ...
                                                      SVM, ...
                                                      Data(CvMat(:, 3) == iLayer, :), ...
                                                      CvMat(CvMat(:, 3) == iLayer, :), ...
                                                      TrainRuns, ...
                                                      TestRuns, ...
                                                      opt);

                                    TEMP(iCV, 1).layers(iLayer, 1).results = results;
                                    ClassAcc.TotAccLayers(iCV, iLayer) = mean(results.pred == results.label);

                                end

                            end

                            fprintf(1, ']\n');

                            if NbPerm == 1
                                disp(mean(ClassAcc.TotAccLayers));
                            end

                        end

                        %% Run cross-validations

                        % If we have the layers data on several rows of the data
                        % matrix we put them back on a single row
                        if strcmpi(InputType, 'roi') && strcmpi(Space, 'surf')
                            [Data, CvMat] = LineariseLaminarData(Data, CvMat);
                        end

                        fprintf(1, '    [%s]\n    [', repmat('.', 1, NbCV));

                        for iCV = 1:NbCV

                            fprintf(1, '.');

                            [TestRuns, TrainRuns] = define_train_and_test_runs(NbRuns, ...
                                                                               TestRunsList, ...
                                                                               RunSubSamp, ...
                                                                               cv, ...
                                                                               iCV);

                            results = run_SVC( ...
                                              SVM, ...
                                              Data, ...
                                              CvMat, ...
                                              TrainRuns, ...
                                              TestRuns, ...
                                              opt);

                            TEMP(iCV, 1).results = {results};
                            ClassAcc.TotAcc(iCV, 1) = mean(results.pred == results.label);

                        end

                        fprintf(1, ']\n');

                        if NbPerm == 1
                            disp(mean(ClassAcc.TotAcc));
                        end

                        %%
                        SVM = reorganize_mvpa_results(SVM, TEMP, NbRuns2Incl, RunSubSamp, iPerm);

                    end

                end

            end

            save_mvpa_results(OutputDir, opt, ClassAcc, SVM, NbLayers);

        end

    end

end

CloseParWorkersPool(KillGcpOnExit);
