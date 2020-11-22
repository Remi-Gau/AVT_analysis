% (C) Copyright 2020 Remi Gau
%
% Generates ROI noise data for a handfull of subjects
%
%
% data is a n X m array with
% - n = nb layers * nb betas
% - m = nb vertices
%
% data(1,:) = beta 1, layer 1
% data(2,:) = beta 1, layer 2
% ...
% data(7,:) = beta 2, layer 1
% ...

clc;
clear;

MVNN = false;

%%
NbLayers = 6;

MinNbVertices = 500;
MaxNbVertices = 1500;

% Reuse the same number of runs as we have for the real subjects
% Makes it easier to test analysis script on this later.
RunPerSes = ReturnNbRunsPerSession();

CondNames = GetConditionList();

ROI.name = 'dummyROI';

Dirs = SetDir('surf', MVNN);

for iSub = 1:size(RunPerSes.Subject, 1)

    SubLs(iSub).name = RunPerSes.Subject(iSub, :);

    NdConditions = numel(CondNames);

    NbRuns = sum(RunPerSes.RunsPerSes(iSub, :));

    NbBetas = NbRuns * NdConditions;

    fprintf('\nGenerating %s\n', SubLs(iSub).name);

    ConditionVec = repmat(1:NdConditions, NbLayers, 1);
    ConditionVec = ConditionVec(:);
    ConditionVec = repmat(ConditionVec, NbRuns, 1);

    RunVec = repmat(1:NbRuns, NdConditions * NbLayers, 1);
    RunVec = RunVec(:);

    LayerVec = repmat((1:NbLayers)', [NbBetas, 1]);

    %% For the 2 hemispheres
    for hs = 1:2

        if hs == 1
            HsSufix = 'l';
        else
            HsSufix = 'r';
        end

        % Vary randomly the number of vertices for each hemisphere, subject...
        NbVertices = randi([MinNbVertices, MaxNbVertices]);

        for iROI = 1:numel(ROI)

            Filename = ReturnFilename('hs_roi_run_cdt_layer', ...
                                      SubLs(iSub).name, ...
                                      HsSufix, ...
                                      NbLayers, ...
                                      ROI(iROI).name);

            RoiData = rand(size(LayerVec, 1), NbVertices);

            CheckSizeOutput(RoiData, ConditionVec, RunVec, LayerVec);

            RoiSaveFile = fullfile(Dirs.DummyData, SubLs(iSub).name, Filename);
            [~, ~, ~] = mkdir(fullfile(Dirs.DummyData, SubLs(iSub).name));

            save(RoiSaveFile, ...
                 'RoiData', 'ConditionVec', 'RunVec', 'LayerVec', 'CondNames', ...
                 '-v7.3');

        end

    end

end
