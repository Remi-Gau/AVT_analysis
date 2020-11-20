% (C) Copyright 2020 Remi Gau

% Loads mat file and runs laminar GLM and saves results in another mat file

clc;
clear;

MVNN = false;

%%
NbLayers = 6;

CondNames = { ...
             'AStimL', 'AStimR', ...
             'VStimL', 'VStimR', ...
             'TStimL', 'TStimR', ...
             'ATargL', 'ATargR', ...
             'VTargL', 'VTargR', ...
             'TTargL', 'TTargR' ...
            };

Dirs = SetDir('surf', MVNN);

[SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

for iSub = 1 % 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    SubDir = fullfile(Dirs.ExtractedBetas, SubLs(iSub).name);

    % Load Vertices of interest for each ROI
    load(fullfile(SubDir, [SubLs(iSub).name  '_roi-VerticesOfInterest.mat']), ...
         'ROI', 'NbVertex');

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(SubDir, 'SPM.mat'));
    BetaOfInterest = GetBOI(SPM, CondNames);
    NbBetas = numel(BetaOfInterest);
    NbRuns = numel(SPM.Sess);
    clear SPM;
    
    
    
    
    

    ConditionVec = repmat(1:numel(CondNames), NbLayers, 1);
    ConditionVec = ConditionVec(:);
    ConditionVec = repmat(ConditionVec, NbRuns, 1);

    RunVec = repmat(1:NbRuns, numel(CondNames) * NbLayers, 1);
    RunVec = RunVec(:);

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

        Filename = returnOutputFilename('hs_run_cdt_layer', SubLs(iSub).name, HsSufix, NbLayers);

        FeatureSaveFile = fullfile(SubDir, Filename);

        % Load data or extract them
        fprintf('  Reading VTKs\n');
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

            Filename = returnOutputFilename('hs_roi_run_cdt_layer', ...
                                            SubLs(iSub).name, ...
                                            HsSufix, ...
                                            NbLayers, ...
                                            ROI(iROI).name);

            RoiData = SurfaceData(:, ROI(iROI).VertOfInt{hs});

            RoiSaveFile = fullfile(SubDir, Filename);

            save(RoiSaveFile, ...
                 'RoiData', 'ConditionVec', 'RunVec', 'LayerVec', ...
                 '-v7.3');

        end

        clear SurfaceData AllMapping;

    end

end
