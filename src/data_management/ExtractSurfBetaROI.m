% (C) Copyright 2020 Remi Gau
%
% Loads output ExtractMappedBetaFromVTK with data for all betas, layers,
% vertices for each hemisphere and extracts the data for each ROI
%
%
% OUTPUT::
%
%   filename = [ ...
%               SubjectName, ...
%               '_hs-', HemiSphere, ...
%               '_roi-', ROI, ...
%               '_nbLayer-', num2str(NbLayers), '.mat' ...
%              ];
%
% - RoiData: a n X m array with
%
%   - n = nb layers * nb betas
%   - m = nb vertices
%
%  ::
%
%     data(1,:) = beta 1, layer 1
%     data(2,:) = beta 1, layer 2
%     ...
%     data(7,:) = beta 2, layer 1
%     ...
%
% - ConditionVec: a vertical vector that identifies which condition a row of RoiData belongs to
% - RunVec: a vertical vector that identifies which run a row of RoiData belongs to
% - LayerVec: : a vertical vector that identifies which layer a row of RoiData belongs to
%

clc;
clear;

MVNN = false;

%%
NbLayers = 6;

CondNames = GetConditionList();

Dirs = SetDir('surf', MVNN);

[SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    SubDir = fullfile(Dirs.ExtractedBetas, SubLs(iSub).name);

    % Load Vertices of interest for each ROI
    load(fullfile(SubDir, [SubLs(iSub).name  '_roi-VerticesOfInterest.mat']), ...
         'ROI', 'NbVertex');

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(SubDir, 'SPM.mat'));
    [BetaOfInterest, BetaNames] =  GetBOI(SPM, CondNames);
    NbBetas = numel(BetaOfInterest);
    NbRuns = numel(SPM.Sess);
    clear SPM;

    tmp1 = cellstr(BetaNames(BetaOfInterest, :));
    tmp1 = deblank(tmp1);

    % Create a vertical vector that identifies which run a row belongs to
    tmp2 = strfind(tmp1, 'Sn(');
    tmp3 = strfind(tmp1, ') ');

    RunVec = cellfun(@(x, y, z) x(y + 3:z - 1), tmp1, tmp2, tmp3, 'UniformOutput', false);
    RunVec = cellfun(@str2num, RunVec);
    RunVec = RunVec';
    RunVec = repmat(RunVec, [NbLayers, 1]);
    RunVec = RunVec(:);

    % Create a vertical vector that identifies which run a row belongs to
    tmp2 = strfind(tmp1, ') ');
    tmp3 = strfind(tmp1, '*bf(');

    tmp4 = cellfun(@(x, y, z) x(y + 2:z - 1), tmp1, tmp2, tmp3, 'UniformOutput', false);

    ConditionVec = nan(size(tmp4));
    for iCond = 1:numel(CondNames)
        idx = strfind(tmp4, CondNames{iCond});
        idx = ~cellfun(@isempty, idx);
        ConditionVec(idx) = iCond;
    end
    ConditionVec = ConditionVec';
    ConditionVec = repmat(ConditionVec, NbLayers, 1);
    ConditionVec = ConditionVec(:);

    % Create a vertical vector that identifies which layer a row belongs to
    LayerVec = repmat((1:NbLayers)', [NbBetas, 1]);

    %% For the 2 hemispheres
    for hs = 1:2

        if hs == 1
            fprintf('\n\n Left hemipshere\n');
            HsSufix = 'l';
        else
            fprintf('\n\n Right hemipshere\n');
            HsSufix = 'r';
        end

        Filename = ReturnFilename('hs_run_cdt_layer', SubLs(iSub).name, HsSufix, NbLayers);

        FeatureSaveFile = fullfile(SubDir, Filename);

        % Load data or extract them
        fprintf('  Reading data\n');
        if exist(FeatureSaveFile, 'file')

            load(FeatureSaveFile);

        else
            error('The features have not been extracted from the VTK files.');

        end

        % reshapes data so we have a n X m array with
        % - n = nb layers * nb betas
        % - m = nb vertices
        %
        % data(1,:) = beta 1, layer 1
        % data(2,:) = beta 1, layer 2
        % ...
        % data(7,:) = beta 2, layer 1
        % ...
        A = shiftdim(AllMapping, 1);
        NbBetas = size(A, 2);
        ValidData = reshape(A, [NbLayers * NbBetas, size(A, 3)]);

        % remap the data on a whole surface temporarily to be able to extract the
        % correct data for each ROI as the ROI vertices indices are in reference to
        % the whole surface.
        SurfaceData = nan(NbLayers * NbBetas, NbVertex(hs));
        SurfaceData(:, VertexWithData) = ValidData;

        for iROI = 1:numel(ROI)

            Filename = ReturnFilename('hs_roi_run_cdt_layer', ...
                                      SubLs(iSub).name, ...
                                      HsSufix, ...
                                      NbLayers, ...
                                      ROI(iROI).name);

            RoiData = SurfaceData(:, ROI(iROI).VertOfInt{hs});

            % remove any vertex with nan data
            A = isnan(RoiData);
            A = any(A);
            RoiData(:, A) = [];

            CheckSizeOutput(RoiData, ConditionVec, RunVec, LayerVec);

            RoiSaveFile = fullfile(SubDir, Filename);

            save(RoiSaveFile, ...
                 'RoiData', 'ConditionVec', 'RunVec', 'LayerVec', 'CondNames', ...
                 '-v7.3');

        end

        clear SurfaceData AllMapping;

    end

end
