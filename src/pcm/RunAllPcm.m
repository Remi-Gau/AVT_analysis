% (C) Copyright 2020 Remi Gau
%
% Runs the PCM

% TODO
% - Make it run on the b parameters
% - Make it run on volume
%

clc;
clear;
close all;

%% Main parameters

ModelType = 'subset6X6'; % '3X3', '6X6', 'subset6X6'

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

IsTarget = false;

DoFeaturePooling = true;

Space = 'surf';

MVNN = true;

IndividualPcmDo = false;

%%

NbLayers = 6;

ConditionType = 'stim';
if IsTarget
    ConditionType = 'target'; %#ok<*UNRCH>
end

Dirs = SetDir(Space, MVNN);

% TODO
% This input dir might have to change if we are dealing with volume data
InputDir = Dirs.ExtractedBetas;
if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))
    InputDir = Dirs.LaminarGlm;
end

[SubLs, NbSub] = GetSubjectList(InputDir);

OutputDir = fullfile(Dirs.PCM, ModelType);
mkdir(OutputDir);

%% Build the models
fprintf('Building models\n');

switch lower(ModelType)

    case '3x3'
        Analysis(1).name = 'Ipsi';
        Analysis(1).CdtToSelect = 1:2:5;

        Analysis(2).name = 'Contra';
        Analysis(2).CdtToSelect = 2:2:6;

        Analysis(3).name = 'ContraIpsi';
        Analysis(3).CdtToSelect = 1:6;

    case {'6x6', 'subset6x6'}
        Analysis(1).name = 'AllConditions';
        Analysis(1).CdtToSelect = 1:6;

end

%% Start
fprintf('Get started\n');

for iROI =  1:numel(ROIs)

    fprintf('\n %s\n', ROIs{iROI});

    GrpData = {};
    GrpConditionVec = {};
    GrpRunVec = {};

    clear G_hat G Gm COORD;

    for ihs = 1:2

        HsSufix = 'l';
        if ihs == 2
            HsSufix = 'r';
        end

        fprintf('\n  Hemisphere: %s\n', HsSufix);

        for iSub = 1:NbSub

            fprintf('   Loading %s\n', SubLs(iSub).name);

            SubDir = fullfile(InputDir, SubLs(iSub).name);

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

            [RoiData, RunVec, ConditionVec, LayerVec] = CheckInput(RoiData, ...
                                                                   RunVec, ...
                                                                   ConditionVec, ...
                                                                   IsTarget, ...
                                                                   LayerVec);

            RoiData = ReassignIpsiAndContra(RoiData, ConditionVec, HsSufix, DoFeaturePooling);

            % If we have the layers data on several rows of the data
            % matrix we put them back on a single row
            CvMat = [ConditionVec RunVec LayerVec];
            if strcmpi(InputType, 'roi') && strcmpi(Space, 'surf')
                [RoiData, CvMat] = LineariseLaminarData(RoiData, CvMat);
            end
            ConditionVec = CvMat(:, 1);
            RunVec = CvMat(:, 2);

            GrpData{iSub, ihs} = RoiData; %#ok<*SAGROW>
            GrpConditionVec{iSub} = ConditionVec;
            GrpRunVec{iSub} = RunVec;

        end

    end

    %% Pool data between hemispheres
    tmp = {};
    for iSub = 1:NbSub
        tmp{iSub, 1} = [GrpData{iSub, 1} GrpData{iSub, 2}];
    end

    GrpData = tmp;

    IsAuditoryRoi = true;
    if any(strcmp(ROIs{iROI}, {'V1', 'V2', 'V3', 'V4', 'V5'}))
        IsAuditoryRoi = false;
    end

    switch lower(ModelType)
        case '3x3'
            Models = Set3X3models();
        case '6x6'
            Models = Set6X6models(IsAuditoryRoi);
        case 'subset6x6'
            Models = SetSubset6X6Models(IsAuditoryRoi);
    end

    %% Run the PCM

    GrpDataSource = GrpData;
    GrpConditionVecSource = GrpConditionVec;
    GrpRunVecSource = GrpRunVec;

    for iAnalysis = 1:numel(Analysis)

        fprintf('\n\n  Running analysis: %s\n', Analysis(iAnalysis).name);

        Filename = ['pcm_results', ...
                    '_roi-', ROIs{iROI}, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '.mat'];

        [GrpData, GrpRunVec, GrpConditionVec] = PreparePcmInput( ...
                                                                GrpDataSource, ...
                                                                GrpConditionVecSource, ...
                                                                GrpRunVecSource, ...
                                                                Analysis(iAnalysis));

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
