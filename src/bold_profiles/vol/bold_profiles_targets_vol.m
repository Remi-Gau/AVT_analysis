% (C) Copyright 2020 Remi Gau
function bold_profiles_targets_vol
    clc;
    clear;

    StartDir = fullfile(pwd, '..', '..');
    cd (StartDir);
    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

    NbLayers = 6;

    CondNames = {
                 %     'AStimL','AStimR';...
                 %     'VStimL','VStimR';...
                 %     'TStimL','TStimR';...
                 'ATargL', 'ATargR'; ...
                 'VTargL', 'VTargR'; ...
                 'TTargL', 'TTargR' ...
                };

    % --------------------------------------------------------- %
    %                            ROIs                           %
    % --------------------------------------------------------- %

    % Mask_Ori.ROI(1) = struct('name', 'S1_aal', 'fname', 'rwS1_AAL.nii');
    % Mask_Ori.ROI(1) = struct('name', 'S1_L_aal', 'fname', 'rwS1_L_AAL.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'S1_R_aal', 'fname', 'rwS1_R_AAL.nii');

    % Mask_Ori.ROI(1) = struct('name', 'TE', 'fname', 'rwTe_Cyt.nii');

    %
    % Mask_Ori.ROI(end+1) = struct('name', 'S1_cyt', 'fname', 'rwS1_Cyt.nii');
    %
    % Mask_Ori.ROI(end+1) = struct('name', 'V1', 'fname', 'rwV1_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V2', 'fname', 'rwV2_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V3', 'fname', 'rwV3_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V4', 'fname', 'rwV4_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V5', 'fname', 'rwV5_ProbRet.nii');
    %
    % Mask_Ori.ROI(end+1) = struct('name', 'TE_L', 'fname', 'rwTe_L_Cyt.nii');

    %
    % Mask_Ori.ROI(end+1) = struct('name', 'S1_L_cyt', 'fname', 'rwS1_L_Cyt_MNI.nii');
    %
    %
    % Mask_Ori.ROI(end+1) = struct('name', 'V1_L', 'fname', 'rwV1_L_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V2_L', 'fname', 'rwV2_L_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V3_L', 'fname', 'rwV3_L_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V4_L', 'fname', 'rwV4_L_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V5_L', 'fname', 'rwV5_L_ProbRet.nii');
    %
    %
    % Mask_Ori.ROI(end+1) = struct('name', 'TE_R', 'fname', 'rwTe_R_Cyt.nii');

    %
    % Mask_Ori.ROI(end+1) = struct('name', 'S1_R_cyt', 'fname', 'rwS1_R_Cyt_MNI.nii');
    %
    % Mask_Ori.ROI(end+1) = struct('name', 'V1_R', 'fname', 'rwV1_R_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V2_R', 'fname', 'rwV2_R_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V3_R', 'fname', 'rwV3_R_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V4_R', 'fname', 'rwV4_R_ProbRet.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'V5_R', 'fname', 'rwV5_R_ProbRet.nii');

    % Mask_Ori.ROI(end+1) = struct('name', 'pSTG', 'fname', 'rwpSTG.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'pSTG_L', 'fname', 'rwpSTG_L.nii');
    % Mask_Ori.ROI(end+1) = struct('name', 'pSTG_R', 'fname', 'rwpSTG_R.nii');

    Mask_Ori.ROI(1) = struct('name', 'PT', 'fname', 'rwA41-42.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'PT_L', 'fname', 'rwA41-42_L.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'PT_R', 'fname', 'rwA41-42_R.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'V1_thres', 'fname', 'SubjName_V1_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V2_thres', 'fname', 'SubjName_V2_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V3_thres', 'fname', 'SubjName_V3_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V4_thres', 'fname', 'SubjName_V4_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V5_thres', 'fname', 'SubjName_V5_Pmap_Ret_thres_10_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'V1_L_thres', 'fname', 'SubjName_lcr_V1_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V2_L_thres', 'fname', 'SubjName_lcr_V2_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V3_L_thres', 'fname', 'SubjName_lcr_V3_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V4_L_thres', 'fname', 'SubjName_lcr_V4_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V5_L_thres', 'fname', 'SubjName_lcr_V5_Pmap_Ret_thres_10_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'V1_R_thres', 'fname', 'SubjName_rcr_V1_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V2_R_thres', 'fname', 'SubjName_rcr_V2_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V3_R_thres', 'fname', 'SubjName_rcr_V3_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V4_R_thres', 'fname', 'SubjName_rcr_V4_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V5_R_thres', 'fname', 'SubjName_rcr_V5_Pmap_Ret_thres_10_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'A1', 'fname', 'SubjName_A1_RG_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'A1_L', 'fname', 'SubjName_A1_lcr_RG_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'A1_R', 'fname', 'SubjName_A1_rcr_RG_data.nii');

    SubLs = dir('sub*');
    NbSub = numel(SubLs);

    for iSub = 1:NbSub % for each subject

        fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

        Mask = Mask_Ori;

        for iROI = 1:length(Mask.ROI)
            Mask.ROI(iROI).fname = strrep(Mask_Ori.ROI(iROI).fname, 'SubjName', SubLs(iSub).name);
        end

        SubDir = fullfile(StartDir, SubLs(iSub).name);
        RoiFolder = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp');
        AnalysisFolder = fullfile(SubDir, 'ffx_nat', 'betas');

        SaveDir = fullfile(SubDir, 'results', 'profiles');
        [~, ~, ~] = mkdir(SaveDir);

        % Gets the number of each beta images and the numbers of the beta of
        % interest
        load(fullfile(SubDir, 'ffx_nat', 'SPM.mat'));
        [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);

        for i = 1:size(BetaNames, 1)
            if BetaNames(i, 6) == ' '
                tmp(i, 1:6) = BetaNames(i, 7:12);
            else
                tmp(i, 1:6) = BetaNames(i, 8:13);
            end
        end
        BetaNames = tmp;
        clear SPM;

        % Defines what condition each line of the feature matrix corresponds to
        CondLines = nan(20, numel(CondNames));
        FilesList = {};
        iRow = 1;

        for iCond = 1:numel(CondNames)

            tmp = BetaNames(BetaOfInterest, 1:length(CondNames{iCond}));
            tmp = BetaOfInterest(strcmp(CondNames{iCond}, cellstr(tmp)));

            for i = 1:length(tmp)

                CondLines(i, iCond) = iRow;

                FilesList{end + 1, 1} = fullfile(AnalysisFolder, ...
                                                 sprintf('r%s_beta-%04d.nii', SubLs(iSub).name, tmp(i)));

                iRow = iRow + 1;
            end

            clear tmp;
        end

        %% Gets global mask from GLM and ROI masks for the data
        fprintf(' Reading masks\n');

        if ~exist(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii']), 'file')
            try
                gunzip(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii.gz']));
            catch
                error('The GLM mask file %s is missing.', ['r' SubLs(iSub).name '_GLM_mask.nii']);
            end
        end
        Mask.global.hdr = spm_vol(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii']));
        Mask.global.img = logical(spm_read_vols(Mask.global.hdr));

        for i = 1:length(Mask.ROI)
            Mask.ROI(i).hdr = spm_vol(fullfile(RoiFolder, Mask.ROI(i).fname));
        end

        hdr = cat(1, Mask.ROI.hdr);
        sts = spm_check_orientations([Mask.global.hdr; hdr]);
        if sts ~= 1
            error('Images not in same space!');
        end

        clear sts hdr i;

        % Create mask in XYZ format (both world and voxel coordinates)
        [X, Y, Z] = ind2sub(size(Mask.global.img), find(Mask.global.img));
        Mask.global.XYZ = [X'; Y'; Z']; % XYZ format
        clear X Y Z;
        Mask.global.size = size(Mask.global.XYZ, 2);
        Mask.global.XYZmm = Mask.global.hdr.mat(1:3, :) ...
            * [Mask.global.XYZ; ones(1, Mask.global.size)]; % voxel to world transformation

        % Combine masks
        xY.def = 'mask';
        for i = 1:length(Mask.ROI)
            xY.spec = fullfile(RoiFolder, Mask.ROI(i).fname);
            [xY, Mask.ROI(i).XYZmm, j] = spm_ROI(xY, Mask.global.XYZmm);
            Mask.ROI(i).XYZ = Mask.global.XYZ(:, j);
            Mask.ROI(i).size = size(Mask.ROI(i).XYZ, 2);
            A = spm_read_vols(Mask.ROI(i).hdr);
            A(isnan(A)) = 0;
            Mask.ROI(i).size(2) = sum(logical(A(:)));
        end

        clear xY j i A;

        %% Gets Layer labels
        fprintf(' Reading layer labels\n');

        LayerLabelsFile = dir(fullfile(SubDir, 'anat', 'cbs', ...
                                       ['sub-*_MP2RAGE_T1map_Layers-' sprintf('%02.0f', NbLayers) '.nii']));

        % Unzip the file if necessary
        if ~isempty(LayerLabelsFile)
            LayerLabelsHdr = spm_vol(fullfile(SubDir, 'anat', 'cbs', ...
                                              LayerLabelsFile.name));
        else
            try
                LayerLabelsFile = dir(fullfile(SubDir, 'anat', 'cbs', ...
                                               ['sub-*_MP2RAGE_T1map_Layers-' sprintf('%02.0f', NbLayers) '.nii.gz']));
                gunzip(fullfile(SubDir, 'anat', 'cbs', ...
                                LayerLabelsFile.name));
                LayerLabelsHdr = spm_vol(fullfile(SubDir, 'anat', 'cbs', ...
                                                  LayerLabelsFile.name(1:end - 3)));
            catch
                error(['The layer label file ' LayerLabels 'is missing.']);
            end
        end

        sts = spm_check_orientations([Mask.global.hdr; LayerLabelsHdr]);
        if sts ~= 1
            error('Images not in same space!');
        end
        clear sts;

        for i = 1:length(Mask.ROI)
            LayerLabels{i} = spm_get_data(LayerLabelsHdr, Mask.ROI(i).XYZ); %#ok<*AGROW>
        end

        %% Mask each image by each ROI and create a features set (images x voxel)
        fprintf('\n Get features\n');

        for i = 1:length(Mask.ROI)

            FeatureFile = fullfile(AnalysisFolder, ['BOLD_targets_' Mask.ROI(i).name '_data_l-' num2str(NbLayers) '.mat']);

            % Load the feature file if it exists
            if exist(FeatureFile, 'file')
                load(FeatureFile, 'Features', 'MaskSave', 'FilesListSave');

                % Make sure that we have the right ROI
                if ~isequal(MaskSave, Mask.ROI(i))
                    NeedFeat(i) = true;
                end

                % Make sure that the right features were extracted
                if ~isequal(FilesListSave, FilesList)
                    NeedFeat(i) = true;
                end

                FeaturesAll{i} = Features{1};
                NeedFeat(i) = false;

                % Otherwise flag this ROI to feature extraction
            else
                NeedFeat(i) = true;
            end

            clear FilesListSave MaskSave Features;

        end

        % Extract the features of the missing ROIs
        if any(NeedFeat)
            GetFeaturesTargets(Mask.ROI(NeedFeat), FilesList, AnalysisFolder, NbLayers);

            % Reload everything
            for i = 1:length(Mask.ROI)
                FeatureFile = fullfile(AnalysisFolder, ...
                                       ['BOLD_targets_' Mask.ROI(i).name '_data_l-' num2str(NbLayers) '.mat']);
                load(FeatureFile, 'Features');
                FeaturesAll{i} = Features{1};
            end
        end

        Features = FeaturesAll;

        clear FilesList FeaturesAll;

        %% Averages across blocks and voxels for each ROI
        for iROI = 1:numel(Mask.ROI)

            fprintf('\n Processing %s \t', Mask.ROI(iROI).name);
            Features_ROI = Features{iROI};
            LayerLabels_ROI = LayerLabels{iROI};

            clear Data_ROI;

            Data_ROI.info.name = Mask.ROI(iROI).name;
            Data_ROI.info.fname = Mask.ROI(iROI).fname;
            Data_ROI.info.size = Mask.ROI(iROI).size;
            Data_ROI.info.vox_per_layer = tabulate(LayerLabels_ROI);

            disp(Data_ROI.info.vox_per_layer(:, 2)');

            %% For each Condition
            for iCond = 1:numel(CondNames)

                Img2Sel = CondLines(:, iCond);
                Img2Sel(isnan(Img2Sel)) = [];

                for iImg = 1:size(Img2Sel, 1) % For each Block

                    Data_ROI.WholeROI.MEAN(iImg, iCond) = nanmean(Features_ROI(Img2Sel(iImg), LayerLabels_ROI > 0));
                    Data_ROI.WholeROI.MEDIAN(iImg, iCond) = nanmedian(Features_ROI(Img2Sel(iImg), LayerLabels_ROI > 0));
                    Data_ROI.WholeROI.STD(iImg, iCond) = nanstd(Features_ROI(Img2Sel(iImg), LayerLabels_ROI > 0));
                    Data_ROI.WholeROI.SEM(iImg, iCond) = nansem(Features_ROI(Img2Sel(iImg), LayerLabels_ROI > 0));

                    for iLayer = 1:NbLayers % Averages over voxels of a given layer

                        Data_ROI.LayerMean(iLayer, iImg, iCond) = ...
                            nanmean(Features_ROI(Img2Sel(iImg), LayerLabels_ROI == iLayer));
                        Data_ROI.LayerMedian(iLayer, iImg, iCond) = ...
                            nanmedian(Features_ROI(Img2Sel(iImg), LayerLabels_ROI == iLayer));
                        Data_ROI.LayerSTD(iLayer, iImg, iCond) = ...
                            nanstd(Features_ROI(Img2Sel(iImg), LayerLabels_ROI == iLayer));
                        Data_ROI.LayerSEM(iLayer, iImg, iCond)  = ...
                            nansem(Features_ROI(Img2Sel(iImg), LayerLabels_ROI == iLayer));
                    end
                    clear LayerInd;

                end
                clear BlockInd;

            end

            %% For each sensory modality
            Col2Sel = [1 4; 2 5; 3 6];
            for iCond = 1:size(CondNames, 1)

                Img2Sel = CondLines(:, Col2Sel(iCond, :));
                Img2Sel(any(isnan(Img2Sel), 2), :) = [];

                for iImg = 1:size(Img2Sel, 1) % For each Block

                    Data_ROI.SensMod.WholeROI.MEAN(iImg, iCond) = mean(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI > 0)));
                    Data_ROI.SensMod.WholeROI.MEDIAN(iImg, iCond) = nanmedian(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI > 0)));
                    Data_ROI.SensMod.WholeROI.STD(iImg, iCond) = nanstd(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI > 0)));
                    Data_ROI.SensMod.WholeROI.SEM(iImg, iCond) = nansem(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI > 0)));

                    for iLayer = 1:NbLayers % Averages over voxels of a given layer
                        Data_ROI.SensMod.LayerMean(iLayer, iImg, iCond) = ...
                            mean(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI == iLayer)));
                        Data_ROI.SensMod.LayerMedian(iLayer, iImg, iCond) = ...
                            median(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI == iLayer)));
                        Data_ROI.SensMod.LayerSTD(iLayer, iImg, iCond) = ...
                            nanstd(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI == iLayer)));
                        Data_ROI.SensMod.LayerSEM(iLayer, iImg, iCond) = ...
                            nansem(nanmean(Features_ROI(Img2Sel(iImg, :), LayerLabels_ROI == iLayer)));
                    end
                    clear LayerInd;

                end
                clear BlockInd;

            end

            %% Contrast between left and right for each sensory modality
            Col2Sel = { ...
                       1, 4
                       2, 5
                       3, 6};

            Data_ROI.ContSide.LayerMean = nan(NbLayers, 20, size(Col2Sel, 1));

            for iCond = 1:size(Col2Sel, 1)

                for iImg = 1:size(Img2Sel, 1) % For each Block

                    if any(isnan([CondLines(iImg, Col2Sel{iCond, 1}) CondLines(iImg, Col2Sel{iCond, 2})]))

                    else

                        Data_ROI.ContSide.WholeROI.MEAN(iImg, iCond) = nanmean( ...
                                                                               nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                               nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));
                        Data_ROI.ContSide.WholeROI.MEDIAN(iImg, iCond) = nanmedian( ...
                                                                                   nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                                   nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));
                        Data_ROI.ContSide.WholeROI.STD(iImg, iCond) = nanstd( ...
                                                                             nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                             nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));
                        Data_ROI.ContSide.WholeROI.SEM(iImg, iCond) = nansem( ...
                                                                             nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                             nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));

                        for iLayer = 1:NbLayers % Averages over voxels of a given layer

                            A(iLayer, iImg, :) = mean( ...
                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                            B(iLayer, iImg, :) = nanmedian( ...
                                                           nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                           nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                            C(iLayer, iImg, :) = nanstd( ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                            D(iLayer, iImg, :) = nansem( ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                        end
                    end
                    clear LayerInd;

                end
                clear BlockInd;

                Data_ROI.ContSide.LayerMean(:, 1:size(A, 2), iCond) = A;
                Data_ROI.ContSide.LayerMedian(:, 1:size(B, 2), iCond) = B;
                Data_ROI.ContSide.LayerSEM(:, 1:size(C, 2), iCond) = C;
                Data_ROI.ContSide.LayerSEM(:, 1:size(D, 2), iCond) = D;
            end

            clear A B C D;

            %% Contrast between sensory modalities
            Col2Sel = {[1 4], [2 5]
                       [1 4], [3 6]
                       [2 5], [3 6]};

            Data_ROI.ContSensMod.LayerMean = nan(NbLayers, 20, size(Col2Sel, 1));

            for iCond = 1:size(Col2Sel, 1)

                for iImg = 1:size(Img2Sel, 1) % For each Block

                    if any(isnan([CondLines(iImg, Col2Sel{iCond, 1}) CondLines(iImg, Col2Sel{iCond, 2})]))

                    else

                        Data_ROI.ContSensMod.WholeROI.MEAN(iImg, iCond) = nanmean( ...
                                                                                  nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                                  nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensMod.WholeROI.MEDIAN(iImg, iCond) = nanmedian( ...
                                                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensMod.WholeROI.STD(iImg, iCond) = nanstd( ...
                                                                                nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                                nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensMod.WholeROI.SEM(iImg, iCond) = nansem( ...
                                                                                nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI > 0)) - ...
                                                                                nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI > 0)));

                        for iLayer = 1:NbLayers % Averages over voxels of a given layer

                            A(iLayer, iImg, :) = mean( ...
                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                            B(iLayer, iImg, :) = median( ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                            C(iLayer, iImg, :) = nanstd( ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                            D(iLayer, iImg, :) = nansem( ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}), LayerLabels_ROI == iLayer)) - ...
                                                        nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}), LayerLabels_ROI == iLayer)));

                        end
                    end
                    clear LayerInd;

                end
                clear BlockInd;

                Data_ROI.ContSensMod.LayerMean(:, 1:size(A, 2), iCond) = A;
                Data_ROI.ContSensMod.LayerMedian(:, 1:size(B, 2), iCond) = B;
                Data_ROI.ContSensMod.LayerStd(:, 1:size(C, 2), iCond) = C;
                Data_ROI.ContSensMod.LayerSEM(:, 1:size(D, 2), iCond) = D;

            end

            clear A B C D;

            %% Contrast between sensory modalities - LEFT and RIGHT indepently
            Col2Sel = {[1 4], [2 5]
                       [1 4], [3 6]
                       [2 5], [3 6]};

            Data_ROI.ContSensModLeft.LayerMean = nan(NbLayers, 20, size(Col2Sel, 1));
            Data_ROI.ContSensModRight.LayerMean = nan(NbLayers, 20, size(Col2Sel, 1));

            for iCond = 1:size(Col2Sel, 1)

                for iImg = 1:size(Img2Sel, 1) % For each Block

                    if any(isnan(CondLines(iImg, Col2Sel{iCond, 1})))
                    else
                        Data_ROI.ContSensModLeft.WholeROI.MEAN(iImg, iCond) = nanmean( ...
                                                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI > 0)) - ...
                                                                                      nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensModLeft.WholeROI.MEDIAN(iImg, iCond) = nanmedian( ...
                                                                                          nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI > 0)) - ...
                                                                                          nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensModLeft.WholeROI.STD(iImg, iCond) = nanstd( ...
                                                                                    nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI > 0)) - ...
                                                                                    nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensModLeft.WholeROI.SEM(iImg, iCond) = nansem( ...
                                                                                    nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI > 0)) - ...
                                                                                    nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI > 0)));

                        for iLayer = 1:NbLayers % Averages over voxels of a given layer

                            A1(iLayer, iImg, :) = mean( ...
                                                       nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI == iLayer)) - ...
                                                       nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI == iLayer)));

                            B1(iLayer, iImg, :) = median( ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI == iLayer)) - ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI == iLayer)));

                            C1(iLayer, iImg, :) = nanstd( ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI == iLayer)) - ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI == iLayer)));

                            D1(iLayer, iImg, :) = nansem( ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(1)), LayerLabels_ROI == iLayer)) - ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 1}(2)), LayerLabels_ROI == iLayer)));
                        end

                    end

                    if any(isnan(CondLines(iImg, Col2Sel{iCond, 2})))
                    else
                        Data_ROI.ContSensModRight.WholeROI.MEAN(iImg, iCond) = nanmean( ...
                                                                                       nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI > 0)) - ...
                                                                                       nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensModRight.WholeROI.MEDIAN(iImg, iCond) = nanmedian( ...
                                                                                           nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI > 0)) - ...
                                                                                           nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensModRight.WholeROI.STD(iImg, iCond) = nanstd( ...
                                                                                     nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI > 0)) - ...
                                                                                     nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI > 0)));
                        Data_ROI.ContSensModRight.WholeROI.SEM(iImg, iCond) = nansem( ...
                                                                                     nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI > 0)) - ...
                                                                                     nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI > 0)));

                        for iLayer = 1:NbLayers % Averages over voxels of a given layer

                            A2(iLayer, iImg, :) = mean( ...
                                                       nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI == iLayer)) - ...
                                                       nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI == iLayer)));

                            B2(iLayer, iImg, :) = median( ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI == iLayer)) - ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI == iLayer)));

                            C2(iLayer, iImg, :) = nanstd( ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI == iLayer)) - ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI == iLayer)));

                            D2(iLayer, iImg, :) = nansem( ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(1)), LayerLabels_ROI == iLayer)) - ...
                                                         nanmean(Features_ROI(CondLines(iImg, Col2Sel{iCond, 2}(2)), LayerLabels_ROI == iLayer)));
                        end

                    end
                    clear LayerInd;

                end
                clear BlockInd;

                Data_ROI.ContSensModRight.LayerMean(:, 1:size(A1, 2), iCond) = A1;
                Data_ROI.ContSensModRight.LayerMedian(:, 1:size(B1, 2), iCond) = B1;
                Data_ROI.ContSensModRight.LayerStd(:, 1:size(C1, 2), iCond) = C1;
                Data_ROI.ContSensModRight.LayerSEM(:, 1:size(D1, 2), iCond) = D1;

                Data_ROI.ContSensModRight.LayerMean(:, 1:size(A2, 2), iCond) = A2;
                Data_ROI.ContSensModRight.LayerMedian(:, 1:size(B2, 2), iCond) = B2;
                Data_ROI.ContSensModRight.LayerStd(:, 1:size(C2, 2), iCond) = C2;
                Data_ROI.ContSensModRight.LayerSEM(:, 1:size(D2, 2), iCond) = D2;

            end

            clear A1 B1 C1 D1 A2 B2 C2 D2;

            %%
            Data_ROI.MEAN = squeeze(nanmean(Data_ROI.LayerMean, 2));
            Data_ROI.MEDIAN = squeeze(nanmean(Data_ROI.LayerMedian, 2));
            Data_ROI.STD = squeeze(nanstd(Data_ROI.LayerMean, 2));
            Data_ROI.SEM = squeeze(nansem(Data_ROI.LayerMean, 2));

            Data_ROI.SensMod.MEAN = squeeze(nanmean(Data_ROI.SensMod.LayerMean, 2));
            Data_ROI.SensMod.MEDIAN = squeeze(nanmean(Data_ROI.SensMod.LayerMedian, 2));
            Data_ROI.SensMod.STD = squeeze(nanstd(Data_ROI.SensMod.LayerMean, 2));
            Data_ROI.SensMod.SEM = squeeze(nansem(Data_ROI.SensMod.LayerMean, 2));

            Data_ROI.ContSide.MEAN = squeeze(nanmean(Data_ROI.ContSide.LayerMean, 2));
            Data_ROI.ContSide.MEDIAN = squeeze(nanmean(Data_ROI.ContSide.LayerMedian, 2));
            Data_ROI.ContSide.STD = squeeze(nanstd(Data_ROI.ContSide.LayerMean, 2));
            Data_ROI.ContSide.SEM = squeeze(nansem(Data_ROI.ContSide.LayerMean, 2));

            Data_ROI.ContSensMod.MEAN = squeeze(nanmean(Data_ROI.ContSensMod.LayerMean, 2));
            Data_ROI.ContSensMod.MEDIAN = squeeze(nanmean(Data_ROI.ContSensMod.LayerMedian, 2));
            Data_ROI.ContSensMod.STD = squeeze(nanstd(Data_ROI.ContSensMod.LayerMean, 2));
            Data_ROI.ContSensMod.SEM = squeeze(nansem(Data_ROI.ContSensMod.LayerMean, 2));

            save(fullfile(SaveDir, strcat('Data_targets_', Mask.ROI(iROI).name, '_l-', num2str(NbLayers), '.mat')), 'Data_ROI');

        end % iSubROI=1:numel(SVM(iSVM).ROI)

        fprintf('\n');

        % clean decompressed files
        %     delete(fullfile(AnalysisFolder, 'rsub-*_beta-*.nii'))

    end % for iSub = 1:NbSub

end

function Reslice(Files2Reslice, AnalysisFolder)
    tmp = dir(fullfile(AnalysisFolder, 'r*_GLM_mask.nii'));
    matlabbatch{1}.spm.spatial.coreg.write.ref = {fullfile(AnalysisFolder, tmp.name)};
    matlabbatch{1}.spm.spatial.coreg.write.source = Files2Reslice;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
    spm_jobman('run', matlabbatch);
    clear tmp matlabbatch;
end
