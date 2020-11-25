% (C) Copyright 2020 Remi Gau

% Compiles data for a ROI from the different subjects and creates a single array for
% all subjects, runs, conditions, layers
%
% - rearrange the data as ipsi and contra
% - averages across vertices
% - m X n array:
%   - n = number of layers
%   - m = nb_subject * nb_runs * nb_conditions

clc;
clear;

Space = 'surf';

ROIs = {
        'A1', ...
        'PT', ...
        'V1', ...
        'V2', ...
        'V3', ...
        'V4', ...
        'V5'};

%%
MVNN = false;

% average across vertices / voxels
AverageType = 'median';

NbLayers = 6;

DoFeaturePooling = true;

[CondNames, CondNamesIpsiContra] = GetConditionList();

Dirs = SetDir(Space, MVNN);

[SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

for iROI = 1:numel(ROIs)

    fprintf('\n\nProcessing %s', ROIs{iROI});

    GrpData = [];
    GrpConditionVec = [];
    GrpRunVec = [];
    SubjVec = [];

    for iSub = 1:NbSub

        fprintf('\n Processing %s', SubLs(iSub).name);

        SubDir = fullfile(Dirs.ExtractedBetas, SubLs(iSub).name);

        load(fullfile(SubDir, 'SPM.mat'));
        BetaOfInterest = GetBOI(SPM, CondNames);
        NbBetas = numel(BetaOfInterest);
        clear SPM;

        %% For the 2 hemispheres
        for ihs = 1:2

            if ihs == 1
                HsSufix = 'l';
            else
                HsSufix = 'r';
            end

            Filename = ReturnFilename('hs_roi_run_cdt_layer', ...
                                      SubLs(iSub).name, ...
                                      HsSufix, ...
                                      NbLayers, ...
                                      ROIs{iROI});

            Filename = fullfile(SubDir, Filename);
            load(Filename, ...
                 'RoiData', 'ConditionVec', 'RunVec', 'LayerVec');

            DataHs{1, ihs} = ReassignIpsiAndContra(RoiData, ConditionVec, HsSufix, DoFeaturePooling);

        end

        % Pool data between hemispheres
        Data = [DataHs{1, 1} DataHs{1, 2}];
        clear DataHs;

        % Temp variable to store the surface parameter beta values
        % - nb of surface parameters to estimate
        % - nb vertices,
        % - nb beta from subject level GLM
        SubjData = nan(NbBetas, NbLayers);
        ConditionVec_tmp = nan(NbBetas, 1);
        RunVec_tmp = nan(NbBetas, 1);

        iBeta = 1;

        for iRun = 1:max(RunVec)

            for iCdt = 1:max(ConditionVec)

                beta2select = all([ConditionVec == iCdt, RunVec == iRun], 2);

                % to skip subjects with missing conditions
                if any(beta2select)

                    tmp = Data(beta2select, :);
                    switch AverageType
                        case 'mean'
                            tmp = mean(tmp, 2);
                        case 'median'
                            tmp = median(tmp, 2);
                    end

                    SubjData(iBeta, 1:NbLayers) = tmp';
                    clear tmp;

                    ConditionVec_tmp(iBeta, 1) = iCdt;
                    RunVec_tmp(iBeta, 1) = iRun;

                    iBeta = iBeta + 1;

                end

            end

        end

        ConditionVec = ConditionVec_tmp;
        RunVec = RunVec_tmp;

        CheckSizeOutput(SubjData, ConditionVec, RunVec);

        GrpData = [GrpData; SubjData]; %#ok<*AGROW>
        GrpConditionVec = [GrpConditionVec; ConditionVec];
        GrpRunVec = [GrpRunVec; RunVec];
        SubjVec = [SubjVec; ones(size(RunVec)) * iSub];

    end

    CheckSizeOutput(GrpData, GrpConditionVec, GrpRunVec, SubjVec);

    [~, ~, ~] = mkdir(fullfile(Dirs.ExtractedBetas, 'group'));

    Filename = ['Group-roi-', ROIs{iROI}, ...
                '_average-', AverageType, ...
                '_nbLayers-', num2str(NbLayers), '.mat' ...
               ];

    Filename = fullfile(Dirs.ExtractedBetas, 'group', Filename);

    save(Filename, ...
         'GrpData', 'SubjVec', 'GrpConditionVec', 'GrpRunVec', 'CondNamesIpsiContra', ...
         '-v7.3');

end
