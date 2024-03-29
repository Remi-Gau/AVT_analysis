% (C) Copyright 2020 Remi Gau
%
% Runs the PCM

% TODO
% - Allow for possibility to run on each hs independently
% - Make it run on the b parameters
% - Make it run on volume
%

clc;
clear;
close all;

%% Main parameters

% '3X3', '6X6', 'subset6X6'
ModelType = 'subset6X6';

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

InputType = 'Cst';

% Region of interest:
%  possible choices: A1, PT, V1-5

ROIs = { ...
        'V1'
        'V2'
        'A1'
        'PT'
       };

%% Other parameters
% Unlikely to change

Opt = SetDefaults();

Space = 'surf';
MVNN = true;

IndividualPcmDo = false;

%%

ConditionType = 'stim';
if Opt.Targets
    ConditionType = 'target'; %#ok<*UNRCH>
end

Dirs = SetDir(Space, MVNN);

% TODO
% This input dir might have to change if we are dealing with volume data
InputDir = Dirs.ExtractedBetas;
if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))
    InputDir = Dirs.LaminarGlm;
end

OutputDir = fullfile(Dirs.PCM, ModelType);
spm_mkdir(OutputDir);

%% Start
fprintf('Get started\n');

for iROI =  1:numel(ROIs)

    [GrpDataSource, GrpConditionVecSource, GrpRunVecSource] = LoadAndPreparePcmData(ROIs{iROI}, InputDir, Opt, InputType);

    IsAuditoryRoi = true;
    if any(strcmp(ROIs{iROI}, {'V1', 'V2', 'V3', 'V4', 'V5'}))
        IsAuditoryRoi = false;
    end

    [Analysis, Models] = BuildModels(ModelType, IsAuditoryRoi);

    %% Run the PCM

    for iAnalysis = 1:numel(Analysis)

        fprintf('\n\n  Running analysis: %s\n', Analysis(iAnalysis).name);

        Filename = ['pcm_results', ...
                    '_roi-', ROIs{iROI}, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '.mat'];

        if Opt.PerformDeconvolution
            Filename = strrep(Filename, '.mat', '_deconvolved-1.mat');
        end

        [GrpData, GrpRunVec, GrpConditionVec] = PreparePcmInput( ...
                                                                GrpDataSource, ...
                                                                GrpConditionVecSource, ...
                                                                GrpRunVecSource, ...
                                                                Analysis(iAnalysis));

        if ~Opt.CombineHemisphere
            error('Running PCM on each hemisphere separately: not supported');
        end

        G_hat = ComputeGmatrix(GrpData, GrpRunVec, GrpConditionVec);

        if IndividualPcmDo
            [T_ind, theta_ind, G_pred_ind, D, T_ind_cross, theta_ind_cross] = RunIndividualPcm( ...
                                                                                               GrpData, ...
                                                                                               Models, ...
                                                                                               GrpRunVec, ...
                                                                                               GrpConditionVec);

            save(fullfile(OutputDir,  ['individual_' Filename]), ...
                 'Models', ...
                 'T_ind', 'theta_ind', 'G_pred_ind', ...
                 'D', 'T_ind_cross', 'theta_ind_cross');
        end

        [T_grp, theta_grp, G_pred_grp, T_cr, theta_cr, G_pred_cr] = RunGroupPcm( ...
                                                                                GrpData, ...
                                                                                Models, ...
                                                                                GrpRunVec, ...
                                                                                GrpConditionVec);

        save(fullfile(OutputDir, ['group_' Filename]), ...
             'Analysis', ...
             'Models', ...
             'GrpRunVec', 'GrpConditionVec', ...
             'G_hat', ...
             'T_grp', 'theta_grp', 'G_pred_grp', ...
             'T_cr',  'theta_cr',  'G_pred_cr');

    end

end

function [T_ind, theta_ind, G_pred_ind, D, T_ind_cross, theta_ind_cross] = RunIndividualPcm(Data, Models, RunVec, ConditionVec)

    MaxIteration = 50000;
    runEffect  = 'fixed';

    fprintf('   Doing individual analysis\n');

    [T_ind, theta_ind, G_pred_ind] = pcm_fitModelIndivid( ...
                                                         Data, ...
                                                         Models, ...
                                                         RunVec, ...
                                                         ConditionVec, ...
                                                         'runEffect', runEffect, ...
                                                         'MaxIteration', MaxIteration); %#ok<*ASGLU>

    [D, T_ind_cross, theta_ind_cross] = pcm_fitModelIndividCrossval( ...
                                                                    Data, ...
                                                                    Models, ...
                                                                    RunVec, ...
                                                                    ConditionVec, ...
                                                                    'runEffect', runEffect, ...
                                                                    'MaxIteration', MaxIteration);

end
