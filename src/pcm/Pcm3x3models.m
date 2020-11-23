% (C) Copyright 2020 Remi Gau
%
% Runs the PCM on the 3 sensory modalities (A, V and T) but separately for
% ipsi and contra
%
% It has 12 models that represent all the different ways that those 3
% conditions can be either:
%
% - scaled
% - scaled and independent
% - independent
%
% See also `SetPcm3X3models()`
%

% TODO
% - Make it run on the b parameters
% - MAke it run on volume

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

InputType = 'ROI';

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

Space = 'surf';

MVNN = true;

PrintModels = false;

%%

NbLayers = 6;

ConditionType = 'stim';
if IsTarget
    ConditionType = 'target';
end

Dirs = SetDir(Space, MVNN);

% TODO
% This input dir might have to change if we are dealing with volume data
InputDir = Dirs.ExtractedBetas;
if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))
    InputDir = Dirs.LaminarGlm;
end

[SubLs, NbSub] = GetSubjectList(InputDir);

FigureDir = fullfile(Dirs.PCM, '3X3', 'figures');
mkdir(FigureDir);

%% Build the models
fprintf('Building models\n');
Models = SetPcm3X3models();

if PrintModels

    [~, ~, ~] = mkdir(fullfile(FigureDir, 'models')); %#ok<*UNRCH>

    fig_h = PlotPcmModelFeatures(Models);

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

    %% Run the PCM

    GrpDataSource = GrpData;
    GrpConditionVecSource = GrpConditionVec;
    GrpRunVecSource = GrpRunVec;

    for iAnalysis = 1:numel(Analysis)

        fprintf('\n\n  Running analysis: %s\n\n', Analysis(iAnalysis).name);

        [GrpData, GrpRunVec, GrpConditionVec] = PreparePcmInput( ...
                                                                GrpDataSource, ...
                                                                GrpConditionVecSource, ...
                                                                GrpRunVecSource, ...
                                                                Analysis(iAnalysis));

        G_hat = ComputeGmatrix(GrpData, GrpRunVec, GrpConditionVec);

        [T_grp, theta_grp, G_pred_grp, T_cr, theta_cr, G_pred_cr] = RunPcm( ...
                                                                           GrpData, ...
                                                                           Models, ...
                                                                           GrpRunVec, ...
                                                                           GrpConditionVec);

        % Save
        filename = ['pcm_results', ...
                    '_roi-', ROIs{iROI}, ...
                    '_cdt-', ConditionType, ...
                    '_param-', lower(InputType), ...
                    '_analysis-', Analysis(iAnalysis).name, ...
                    '.mat'];
        filename = fullfile(Dirs.PCM, '3X3', filename);

        save(filename, ...
             'Models', ...
             'GrpRunVec', 'GrpConditionVec', ...
             'G_hat', ...
             'T_grp', 'theta_grp', 'G_pred_grp', ...
             'T_cr',  'theta_cr',  'G_pred_cr');

    end

end

function varargout = PreparePcmInput(Data, RunVec, ConditionVec, Analysis)

    for iSub = 1:size(Data, 1)

        % Only keep the conditions for that analysis

        ConditionVec{iSub}(~ismember(ConditionVec{iSub}, Analysis.CdtToSelect)) = 0;

        if strcmpi(Analysis.name, 'contraipsi')
            [Data{iSub}, ConditionVec{iSub}, RunVec{iSub}] = CombineIpsiAndContra( ...
                                                                                  Data{iSub}, ...
                                                                                  ConditionVec{iSub}, ...
                                                                                  RunVec{iSub}, ...
                                                                                  'pool');
        end

    end

    varargout = {Data, RunVec, ConditionVec};

end
