% (C) Copyright 2020 Remi Gau
% (C) Copyright 2020 Remi Gau

% Runs the PCM on the 3 sensory modalities (A, V and T) but separately for
% ipsi and contra
%
% Tt has 12 models that represent all the different ways that those 3
% conditions can be either:
%
% - scaled
% - scaled and independent
% - independent
%
% See also `SetPcm3X3models()`

% As reminder
%
% CondNames = { ...
%   'AStimL', 'AStimR', ...
%   'VStimL', 'VStimR', ...
%   'TStimL', 'TStimR', ...
%   'ATargL', 'ATargR', ...
%   'VTargL', 'VTargR', ...
%   'TTargL', 'TTargR' ...
%   };

clc;
clear;
close all;

%% Main parameters

% Choose on what type of data the analysis will be run
%
% b-parameters
%
% s-parameters
%
% 'Cst', 'Lin', 'Quad'
%

Parameter = 'Cst';

% Region of interest:
%  possible choices: A1, PT, V1-5

ROIs = { ...
        'V1'
        'V2'
        'A1'
        'PT'
       };

%% Analysis name condition to use for it

Analysis(1).name = 'Ipsi';
Analysis(1).CdtToSelect = 1:2:5;

Analysis(2).name = 'Contra';
Analysis(2).CdtToSelect = 2:2:6;

Analysis(3).name = 'ContraIpsi';
Analysis(3).CdtToSelect = 1:6;

%% Other parameters
% Unlikely to change

IsTarget = false;

DoFeaturePooling = true;

space = 'surf';

MVNN = true;

PrintModels = false;

%%

ConditionType = 'stim';
if IsTarget
    ConditionType = 'target';
end

Dirs = SetDir('surf', MVNN);

% TODO
% This input dir might have to change if we are dealing with volume data
InputDir = Dirs.LaminarGlm;

[SubLs, NbSub] = GetSubjectList(InputDir);

FigureDir = fullfile(Dirs.PCM, '3X3', 'figures');
mkdir(FigureDir);

%% Build the models
fprintf('Building models\n');
M_ori = SetPcm3X3models();

if PrintModels

    [~, ~, ~] = mkdir(fullfile(FigureDir, 'models')); %#ok<*UNRCH>

    fig_h = PlotPcmModelFeatures(M_ori);

    for iFig = 1:numel(fig_h)

        FigureName = ['Model-', num2str(iFig), '-', strrep( ...
                                                           strrep( ...
                                                                  fig_h(iFig).Name, ...
                                                                  ',', ...
                                                                  ''), ...
                                                           ' ', ...
                                                           ''), ...
                      '.tif'];

        print(fig_h(iFig), ...
              fullfile(FigureDir, 'models', FigureName), ...
              '-dtiff');

    end

end

%% Start
fprintf('Get started\n');

for iROI =  1:numel(ROIs)

    fprintf('\n %s\n', ROIs{iROI});

    Y = {};
    condVec = {};
    partVec = {};

    clear G_hat G Gm COORD;

    for ihs = 1:2

        if ihs == 1
            HsSufix = 'l';
        else
            HsSufix = 'r';
        end

        fprintf('\n %s\n', HsSufix);

        for iSub = 1:NbSub

            fprintf(' Loading %s\n', SubLs(iSub).name);

            Filename = returnFilename('hs_roi_run_cdt_s-param', ...
                                      SubLs(iSub).name, ...
                                      HsSufix, ...
                                      [], ... % NbLayers
                                      ROIs{iROI}, ...
                                      Parameter);

            Filename = fullfile(InputDir, SubLs(iSub).name, Filename);

            load(Filename, 'RoiDataSurfParam', 'ConditionVec', 'RunVec');

            RoiData = RoiDataSurfParam;

            [RoiData, RunVec, ConditionVec] = CheckInput(RoiData, RunVec, ConditionVec, IsTarget);

            ConditionVec = ReassignIpsiAndContra(ConditionVec, DoFeaturePooling);

            Y{iSub} = RoiData; %#ok<*SAGROW>
            condVec{iSub} = ConditionVec;
            partVec{iSub} = RunVec;

        end

    end

    %% Run the PCM

    for iAnalysis = 1:numel(Analysis)

        for iSub = 1:numel(Y)

            condVec{iSub}(~ismember(condVec{iSub}, CdtToSelect)) = 0;

            % collapse across ipsi and contra stimuli by averaging
            % we loop over partitions and then for each condition (A, V, T) we
            % average the ipsi and contra data of that partition.

            if iComparison == 3
                for ipart = 1:max(partVec{iSub})
                    this_part = partVec{iSub} == ipart;
                    for iCdt = 1:2:5
                        Y{iSub}(all([this_part, condVec{iSub} == iCdt], 2), :) = ...
                          mean(Y{iSub}(all([this_part, ismember(condVec{iSub}, iCdt:(iCdt + 1))], 2), :));
                    end
                end

                % Then we only keep the rows where the data has been averaged
                condVec{iSub}(condVec{iSub} == 2) = 0;
                condVec{iSub}(condVec{iSub} == 4) = 0;
                condVec{iSub}(condVec{iSub} == 6) = 0;

                partVec{iSub}(condVec{iSub} == 0) = [];
                Y{iSub}(condVec{iSub} == 0, :) = [];
                condVec{iSub}(condVec{iSub} == 0) = [];
            end

        end

        [G_hat, G] = computeGmatrix(Y, partVec, condVec);

        [T_group, theta_gr, G_pred_gr, T_cross, theta_cr, G_pred_cr] = RunPcm(Y, M, partVec, condVec);

        % Save
        filename = [ ...
                    'pcm_results', ...
                    '_roi-', ROIs{iROI}, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(Parameter), ...
                    '_analysis-' Analysis, ...
                    '.mat'];
        filename = fullfile(Dirs.PCM, '3X3', filename);

        save(filename, ...
             'M', 'partVec', 'condVec', 'G_hat', 'G', ...
             'T_group', 'theta_gr', 'G_pred_gr', ...
             'T_cross', 'theta_cr', 'G_pred_cr');

    end

end

function [RoiData, RunVec, ConditionVec] = CheckInput(RoiData, RunVec, ConditionVec, IsTarget)

    if ~IsTarget
        ConditionVec(ConditionVec > 6) = 0;
    end

    RoiData(ConditionVec == 0, :) = [];
    RunVec(ConditionVec == 0, :) = [];
    ConditionVec(ConditionVec == 0, :) = [];

    % check that we have the same number of conditions in each partition
    A = tabulate(RunVec);
    A = A(:, 1:2);

    if numel(unique(A(:, 2))) > 1

        warning('We have different numbers of conditions in at least one partition.');
        Sess2Remove = find(A(:, 2) < numel(unique(conditionVec)));
        conditionVec(ismember(partitionVec, Sess2Remove)) = [];
        X_temp(ismember(partitionVec, Sess2Remove), :) = [];
        partitionVec(ismember(partitionVec, Sess2Remove)) = [];
        Sess2Remove = [];

    end

    if any([numel(conditionVec) numel(partitionVec)] ~= size(X_temp, 1))
        error('Data matrix or condition or partition vector might be off.');

    end

end

function ConditionVec = ReassignIpsiAndContra(ConditionVec, DoFeaturePooling)

    if DoFeaturePooling
    end

end

function [G_hat, G] = computeGmatrix(Y, partVec, condVec)

    for iSub = 1:numel(Y)

        G_hat(:, :, iSub) = pcm_estGCrossval(Y{iSub}, partVec{iSub}, condVec{iSub}); %#ok<*AGROW>

        G(:, :, iSub) = Y{iSub} * Y{iSub}' / size(Y{iSub}, 2); % with no CV.

    end

end

function varargout = RunPcm(Y, M, partVec, condVec)

    MaxIteration = 50000;
    runEffect  = 'fixed';

    % Fit the models on the group level
    fprintf('\n\n  Running PCM %s\n\n', msg);

    [T_group, theta_gr, G_pred_gr] = pcm_fitModelGroup(Y, M, partVec, condVec, ...
                                                       'runEffect', runEffect, ...
                                                       'fitScale', 1);

    [T_cross, theta_cr, G_pred_cr] = pcm_fitModelGroupCrossval(Y, M, partVec, condVec, ...
                                                               'runEffect', runEffect, ...
                                                               'groupFit', theta_gr, ...
                                                               'fitScale', 1, ...
                                                               'MaxIteration', MaxIteration);

    varargout = { ...
                 T_group; ...
                 theta_gr; ...
                 G_pred_gr; ...
                 T_cross; ...
                 theta_cr; ...
                 G_pred_cr};

end
