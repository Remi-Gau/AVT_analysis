% (C) Copyright 2020 Remi Gau

clc;
clear;

MVNN = true;

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

Quad = true;

Dirs = SetDir('surf', MVNN);

[SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

DesMat = SetDesignMatLamGlm(NbLayers, Quad);

SurfParameters = {'Cst', 'Lin', 'Quad'};

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    SubDir = fullfile(Dirs.ExtractedBetas, SubLs(iSub).name);

    % Load Vertices of interest for each ROI
    load(fullfile(SubDir, [SubLs(iSub).name  '_roi-VerticesOfInterest.mat']), ...
         'ROI', 'NbVertex');

    load(fullfile(SubDir, 'SPM.mat'));
    BetaOfInterest = GetBOI(SPM, CondNames);
    NbBetas = numel(BetaOfInterest);
    clear SPM;

    %% For the 2 hemispheres
    for hs = 1:2

        if hs == 1
            fprintf('\n\n Left hemipshere\n');
            HsSufix = 'l';
        else
            fprintf('\n\n Right hemipshere\n');
            HsSufix = 'r';
        end

        for iROI = 1:numel(ROI)

            Filename = returnOutputFilename('hs_roi_run_cdt_layer', ...
                                            SubLs(iSub).name, ...
                                            HsSufix, ...
                                            NbLayers, ...
                                            ROI(iROI).name);

            RoiSaveFile = fullfile(SubDir, Filename);
            load(RoiSaveFile);

            % Temp variable to store the surface parameter beta values
            % - nb of surface parameters to estimate
            % - nb vertices,
            % - nb beta from subject level GLM
            SurfParam = nan(size(DesMat, 2), size(RoiData, 2), NbBetas);
            ConditionVec_tmp = nan(NbBetas, 1);
            RunVec_tmp = nan(NbBetas, 1);

            iBeta = 1;

            for iRun = 1:max(RunVec)

                for iCdt = 1:max(ConditionVec)

                    beta2select = all([ConditionVec == iCdt, RunVec == iRun], 2);

                    if any(beta2select)

                        Y = RoiData(beta2select, :);
                        X = DesMat;
                        B = pinv(X) * Y;
                        SurfParam(:, :, iBeta) = B;

                        ConditionVec_tmp(iBeta) = iCdt;
                        RunVec_tmp(iBeta) = iRun;

                        iBeta = iBeta + 1;

                    end

                end

            end

            if iBeta ~= (NbBetas + 1)

                error('We are either missing or have too much data compare to what we should have.');

            end

            % save data for each ROI, hs and for Cst / Lin / Avg
            for iSurfParameters = 1:size(SurfParam, 1)

                % each surface parameter is in a variable n X m
                % n = nb cdt * nb runs = nb betas
                % m = nb vertices
                RoiDataSurfParam = squeeze(SurfParam(iSurfParameters, :, :));
                RoiDataSurfParam = RoiDataSurfParam';

                [~, ~, ~] = mkdir(Dirs.SurfaceGlm, SubLs(iSub).name);

                Filename = returnOutputFilename('hs_roi_run_cdt_s-param', ...
                                                SubLs(iSub).name, ...
                                                HsSufix, ...
                                                NbLayers, ...
                                                ROI(iROI).name, ...
                                                SurfParameters{iSurfParameters});

                RoiSurfParamFile = fullfile(Dirs.SurfaceGlm, SubLs(iSub).name, Filename);

                save(RoiSurfParamFile, ...
                     'RoiDataSurfParam', 'ConditionVec', 'RunVec', ...
                     '-v7.3');

            end

        end

    end

end
