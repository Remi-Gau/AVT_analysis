% (C) Copyright 2020 Remi Gau
%
% Compiles BOLD profile data for a ROI from the different subjects and creates a single array for
% all subjects, runs, conditions, layers
%
% For each subject tha data is:
%
% - rearrange the data as ipsi and contra
% - averages across vertices
%
% ``GrpData``
%
% - m X n array:
%   - n = number of layers
%   - m = nb_subject * nb_runs * nb_conditions
%
% Note that the data from run 17 of subject
% 6 is omitted in the output: this run is missing auditory stimulation and
% creates some imbalances in downstream analysis that are easier resvolved by
% removing all the data from that run.

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

[NbLayers, AverageType] = GetPlottingDefaults();

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

            Data{1, ihs} = ReassignIpsiAndContra(RoiData, ConditionVec, HsSufix, DoFeaturePooling);

        end

        Data = CombineDataBothHemisphere(Data);

        % Temp variable to store the surface parameter beta values
        % - nb of surface parameters to estimate
        % - nb vertices,
        % - nb beta from subject level GLM
        SubjData = nan(NbBetas, NbLayers);
        ConditionVec_tmp = nan(NbBetas, 1);
        RunVec_tmp = nan(NbBetas, 1);

        iBeta = 1;

        % average across vertices / voxels for each run and condition
        for iRun = 1:max(RunVec)

            for iCdt = 1:max(ConditionVec)

                beta2select = all([ConditionVec == iCdt, RunVec == iRun], 2);

                % omit data from run 17 of subject 06
                if strcmp(SubLs(iSub).name, 'sub-06') && iRun == 17
                    beta2select = false;
                end

                % to skip subjects with missing conditions
                if any(beta2select)

                    tmp = Data{1}(beta2select, :);
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
