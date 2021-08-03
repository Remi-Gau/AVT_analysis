function MVPA_code_example
clc; clear;

StartDir = fullfile(pwd, '..','..','..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;

NbWorkers = 8; % number of CPU to use if you need to use parfor loops


% Options for the SVM
[opt, ~] = get_mvpa_options();


% CondNames = {...
%     'AStimL','AStimR',...
%     'VStimL','VStimR',...
%     'TStimL','TStimR'};

% --------------------------------------------------------- %
%              Classes and associated conditions            %
% --------------------------------------------------------- %
% Here we define each class that can later on be used in different
% classification or regression
% The field 'nbetas' is used to define how many examplars (e.g beta images) to expect per run
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
% Here we define which classifications to run: which classes have to be
% compared and on which ROIs
SVM_Ori(1) = struct('name', 'A Ipsi VS Contra', 'class', [1 2], 'ROI_2_analyse', 1);
SVM_Ori(end+1) = struct('name', 'V Ipsi VS Contra', 'class', [3 4], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'T Ipsi VS Contra', 'class', [5 6], 'ROI_2_analyse', 1:numel(ROIs_ori));

SVM_Ori(end+1) = struct('name', 'A VS V Ipsi', 'class', [1 3], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'A VS T Ipsi', 'class', [1 5], 'ROI_2_analyse',3);
SVM_Ori(end+1) = struct('name', 'V VS T Ipsi', 'class', [3 5], 'ROI_2_analyse', 1);

SVM_Ori(end+1) = struct('name', 'A VS V Contra', 'class', [2 4], 'ROI_2_analyse', 1:numel(ROIs_ori));
SVM_Ori(end+1) = struct('name', 'A VS T Contra', 'class', [2 6], 'ROI_2_analyse', 3);
SVM_Ori(end+1) = struct('name', 'V VS T Contra', 'class', [4 6], 'ROI_2_analyse', 1);

% -------------------------%
%          START           %
% -------------------------%
[KillGcpOnExit] = OpenParWorkersPool(NbWorkers); %open the required numbers of matlab workers (comment out is not necessary)

SubLs = dir('sub*');
NbSub = numel(SubLs);


for iSub = 1:NbSub

    % --------------------------------------------------------- %
    %                        Subject data                       %
    % --------------------------------------------------------- %
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)

    % If we want to have a learning curve
    NbRuns = numel(SPM.Sess); clear SPM
    if opt.session.curve
        % #sessions over which to run the learning curve
        opt.session.nsamples = 10:2:NbRuns;
    else
        opt.session.nsamples = NbRuns;
    end


    %% Creates a table that lists for each beta of interest:
    %   - its corresponding class
    %   - the session in which it occurs
    CV_Mat_Orig = [zeros(NbRuns*sum([Class.nbetas]), 1) ...
        zeros(NbRuns*sum([Class.nbetas]), 1)] ;




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Here you will have to code how the data is organized in the feature
    % matrix you will feed to the libSVM function
    % It is organized as an exemplar X features matrix but CV_Mat_Orig
    % defines for each exemplar:
    % - to which class it belongs to (first column)
    % - from which session it comes from (first column)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





    %% Get data
    for iROI=1:numel(ROIs_ori)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Here you will have to code the extraction of the DATA from the
        % ROIs. Each matrix has to be organized as an exemplar X features matrix
        % and match the information contained in the CV_Mat_Orig defined
        % above.

        % It is best to do both those at the same time but it does not have
        % to.

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        FeaturesAll{iROI,1} = Something
    end


    %% Run for different type of normalization
    % Here we can loop through the classification with different types of image and
    % feature scaling
    for Norm = 6

        opt = ChooseNorm(Norm, opt);

        SaveSufix = CreateSaveSuffix(opt, [], NbLayers, space);



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

            for iROI=SVM(iSVM).ROI_2_analyse

                ROI_idx = find(SVM(iSVM).ROI_2_analyse==iROI);

                fprintf('Analysing subject %s\n', SubLs(iSub).name)
                fprintf(' Running SVM:  %s\n', SVM(iSVM).name)
                fprintf('  Running ROI:  %s\n', SVM(iSVM).ROI(ROI_idx).name)
                fprintf('  Number of vertices before FS/RFE: %i\n', SVM(iSVM).ROI(ROI_idx).size)
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

                    %% Define the cross-validation scheme

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % Here you might have to change the the way the
                    % TestSessList is defined depending on what cross
                    % validation scheme you want to run.

                    % If you are not running any learning curves then
                    % only fill TestSessList{1,1} with the session to leave
                    % out as test set for each cross validation.

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

                    % Test sets for the different CVs
                    if opt.session.curve
                        for i=1:size(CV_id,1)
                            error('Not properly implemented.')
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

                            %% Run the cross-validations
                            NbCV = size(TestSessList{iSubSampSess,1}, 1);

                            fprintf(1,'    [%s]\n    [ ',repmat('.',1,NbCV));

                            % The use of the parfor can be useful in some
                            % cases.
                            parfor iCV=1:NbCV

                                fprintf(1,'\b.\n');

                                TestSess = []; %#ok<NASGU>
                                TrainSess = []; %#ok<NASGU>

                                % Separate training and test sessions
                                [TestSess, TrainSess] = deal(false(size(1:NbRuns)));

                                TestSess(TestSessList{iSubSampSess,1}(iCV,:)) = 1; %#ok<*PFBNS>
                                TrainSess(setdiff(CV_id(iSubSampSess,:), TestSessList{iSubSampSess,1}(iCV,:)) )= 1;

                                [results, ~] = RunSVM(SVM, FeaturesBoth, CV_Mat, TrainSess, TestSess, opt, iSVM);

                                TEMP(iCV,1).results = {results};
                                TEMP(iCV,1).acc = mean(results.pred==results.label);

                            end
                            fprintf(1,'\b]\n');

                            % Store the results
                            for iCV=1:NbCV
                                SVM(iSVM).ROI(ROI_idx).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).results = ...
                                    TEMP(iCV,1).results;
                                SVM(iSVM).ROI(ROI_idx).session(NbSess2Incl).rand(iSubSampSess).perm(iPerm).CV(iCV,1).acc = ...
                                    TEMP(iCV,1).acc;
                            end

                            T(end+1)=toc;
                            fprintf(1,'    Avg time elapsed / permutation = %i secs ; ETA = %s\n',...
                                round(mean(T)), Seconds_to_hours(round((NbPerm-iPerm)*mean(T))) );
                            fprintf(1,'    Time elapsed on last permutation = %i secs ; ETA = %s\n',...
                                round(T(end)), Seconds_to_hours(round((NbPerm-iPerm)*T(end))) );

                        end % iPerm=1:NbPerm
                        %clear iPerm

                    end % iSubSampSess=1:size(CV_id, 1)
                    %clear iSubSampSess

                end % NbSess2Incl = opt.session.nsamples
                %clear NbSess2Incl

                %% Calculate prediction accuracies
                Class_Acc.TotAcc(1) = ...
                    nanmean([SVM(iSVM).ROI(ROI_idx).session(end).rand.perm(1).CV(:,1).acc]);

                % Display some results
                if NbPerm==1
                    fprintf('\n   Accuracy\n');
                    disp(Class_Acc.TotAcc(:))
                end


                % Save data
                Results = SVM(iSVM).ROI(ROI_idx);
                SaveResults(SaveDir, Results, opt, Class_Acc, SVM, iSVM, ROI_idx, SaveSufix)

                clear Results

                % clears the saved data from the structure to clear memory
                SVM(iSVM).ROI(ROI_idx).session = [];

            end % iROI=1:numel(SVM(iSVM).ROI)
            clear Mask Features

        end % iSVM=1:numel(SVM)
        clear iSVM SVM

    end % for Norm = 6:7
    clear Features RegNumbers

end % for iSub = 1:NbSub

CloseParWorkersPool(KillGcpOnExit)

end


function [results, weight] = RunSVM(SVM, Features, CV_Mat, TrainSess, TestSess, opt, iSVM)

if isempty(Features) || all(Features(:)==Inf)

    warning('Empty ROI')

    results = struct();
    weight = [];

else

    results = machine_SVC(SVM(iSVM), Features(:,LogFeat), CV_Mat, TrainSess, TestSess, opt);

end

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
