function bold_profiles_vol_wht_betas_pool_hs
    clc;
    clear;
    close all;

    StartDir = fullfile(pwd, '..', '..', '..', '..');
    cd (StartDir);
    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
    Get_dependencies('/home/rxg243/Dropbox/');

    NbLayers = 6;

    CondNames = { ...
                 'AStimL', 'AStimR'; ...
                 'VStimL', 'VStimR'; ...
                 'TStimL', 'TStimR'
                 %         'ATargL','ATargR';...
                 %         'VTargL','VTargR';...
                 %         'TTargL','TTargR';...
                };

    % --------------------------------------------------------- %
    %                            ROIs                           %
    % --------------------------------------------------------- %

    Mask_Ori.ROI(1) = struct('name', 'A1_L', 'fname', 'SubjName_A1_lcr_RG_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'PT_L', 'fname', 'rwA41-42_L.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V1_L_thres', 'fname', 'SubjName_lcr_V1_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V2_L_thres', 'fname', 'SubjName_lcr_V2_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V3_L_thres', 'fname', 'SubjName_lcr_V3_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V4_L_thres', 'fname', 'SubjName_lcr_V4_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V5_L_thres', 'fname', 'SubjName_lcr_V5_Pmap_Ret_thres_10_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'A1_R', 'fname', 'SubjName_A1_rcr_RG_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'PT_R', 'fname', 'rwA41-42_R.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V1_R_thres', 'fname', 'SubjName_rcr_V1_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V2_R_thres', 'fname', 'SubjName_rcr_V2_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V3_R_thres', 'fname', 'SubjName_rcr_V3_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V4_R_thres', 'fname', 'SubjName_rcr_V4_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V5_R_thres', 'fname', 'SubjName_rcr_V5_Pmap_Ret_thres_10_data.nii');

    % Indicate which ROIs to pool - first column is left hs, second one is righ hs
    PoolHs = [(1:7)', (8:14)'];

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
        AnalysisFolder = fullfile(SubDir, 'ffx_rsa', 'betas');

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
        end

        clear xY j i;

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

            FeatureFile = fullfile(AnalysisFolder, ['Features_' Mask.ROI(i).name '_l-' num2str(NbLayers) '_s-0.mat']);

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
                fprintf('\n  Non existent data file: %s\n', FeatureFile);
                NeedFeat(i) = true;
            end

            clear FilesListSave MaskSave Features;

        end

        % Extract the features of the missing ROIs
        if any(NeedFeat)
            GetFeatures(Mask.ROI(NeedFeat), FilesList, AnalysisFolder, NbLayers);

            % Reload everything
            for i = 1:length(Mask.ROI)
                FeatureFile = fullfile(AnalysisFolder, ...
                                       ['Features_' Mask.ROI(i).name '_data_l-' num2str(NbLayers) '.mat']);
                load(FeatureFile, 'Features');
                FeaturesAll{i} = Features{1};
            end
        end

        Features = FeaturesAll;

        clear FilesList FeaturesAll;

        %% Averages across blocks and voxels for each set of ROIS
        for iROI = 1:size(PoolHs, 1)

            fprintf('\n Processing %s and %s', Mask_Ori.ROI(PoolHs(iROI, 1)).name,  ...
                    Mask_Ori.ROI(PoolHs(iROI, 2)).name);

            Features_ROI_L = Features{PoolHs(iROI, 1)};
            LayerLabels_ROI_L = LayerLabels{PoolHs(iROI, 1)};
            Features_ROI_R = Features{PoolHs(iROI, 2)};
            LayerLabels_ROI_R = LayerLabels{PoolHs(iROI, 2)};

            %% For ipsilateral stimulus
            for iCond = 1:numel(CondNames) / 2

                % Beta images to select for the left HS ROI
                Img2SelL = CondLines(:, iCond);
                Img2SelL(isnan(Img2SelL)) = [];

                % Beta images to select for the right HS ROI
                Img2SelR = CondLines(:, iCond + 3);
                Img2SelR(isnan(Img2SelR)) = [];

                for iImg = 1:size(Img2SelL, 1) % For each Block

                    BlockImg =  [Features_ROI_L(Img2SelL(iImg), :) Features_ROI_R(Img2SelR(iImg), :)];

                    Data_ROI.Ispi.WholeROI.MEAN(iImg, iCond) = nanmean(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                    Data_ROI.Ispi.WholeROI.MEDIAN(iImg, iCond) = nanmedian(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                    Data_ROI.Ispi.WholeROI.STD(iImg, iCond) = nanstd(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                    Data_ROI.Ispi.WholeROI.SEM(iImg, iCond) = nansem(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));

                    for iLayer = 1:NbLayers % Averages over voxels of a given layer

                        Data_ROI.Ispi.LayerMean(iLayer, iImg, iCond) = ...
                            nanmean(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                        Data_ROI.Ispi.LayerMedian(iLayer, iImg, iCond) = ...
                            nanmedian(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                        Data_ROI.Ispi.LayerSTD(iLayer, iImg, iCond) = ...
                            nanstd(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                        Data_ROI.Ispi.LayerSEM(iLayer, iImg, iCond)  = ...
                            nansem(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                    end
                    clear LayerInd BlockImg;

                end
                clear BlockInd Img2SelL Img2SelR;

            end

            %% For Contralateral stimulus
            for iCond = 1:numel(CondNames) / 2

                % Beta images to select for the left HS ROI
                Img2SelL = CondLines(:, iCond + 3);
                Img2SelL(isnan(Img2SelL)) = [];

                % Beta images to select for the right HS ROI
                Img2SelR = CondLines(:, iCond);
                Img2SelR(isnan(Img2SelR)) = [];

                for iImg = 1:size(Img2SelL, 1) % For each Block

                    BlockImg =  [Features_ROI_L(Img2SelL(iImg), :) Features_ROI_R(Img2SelR(iImg), :)];

                    Data_ROI.Contra.WholeROI.MEAN(iImg, iCond) = nanmean(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                    Data_ROI.Contra.WholeROI.MEDIAN(iImg, iCond) = nanmedian(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                    Data_ROI.Contra.WholeROI.STD(iImg, iCond) = nanstd(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                    Data_ROI.Contra.WholeROI.SEM(iImg, iCond) = nansem(BlockImg(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));

                    for iLayer = 1:NbLayers % Averages over voxels of a given layer

                        Data_ROI.Contra.LayerMean(iLayer, iImg, iCond) = ...
                            nanmean(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                        Data_ROI.Contra.LayerMedian(iLayer, iImg, iCond) = ...
                            nanmedian(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                        Data_ROI.Contra.LayerSTD(iLayer, iImg, iCond) = ...
                            nanstd(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                        Data_ROI.Contra.LayerSEM(iLayer, iImg, iCond)  = ...
                            nansem(BlockImg(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));
                    end
                    clear LayerInd BlockImg;

                end
                clear BlockInd Img2SelL Img2SelR;

            end

            %% Contralateral relative to ipsilateral
            Col2Sel = { ...
                       1, 4
                       2, 5
                       3, 6};

            Data_ROI.Contra_VS_Ipsi.LayerMean = nan(NbLayers, 20, size(Col2Sel, 1));
            Data_ROI.Contra_VS_Ipsi.LayerStd = nan(NbLayers, 20, size(Col2Sel, 1));
            Data_ROI.Contra_VS_Ipsi.LayerSEM = nan(NbLayers, 20, size(Col2Sel, 1));

            for iCond = 1:size(Col2Sel, 1)

                for iImg = 1:size(CondLines, 2) % For each Block

                    BlockImgL =  [ ...
                                  Features_ROI_L(CondLines(iImg, Col2Sel{iCond, 1}), :) ...
                                  Features_ROI_R(CondLines(iImg, Col2Sel{iCond, 2}), :)];

                    BlockImgR =  [ ...
                                  Features_ROI_L(CondLines(iImg, Col2Sel{iCond, 2}), :) ...
                                  Features_ROI_R(CondLines(iImg, Col2Sel{iCond, 1}), :)];

                    if any(isnan([CondLines(iImg, Col2Sel{iCond, 1}) CondLines(iImg, Col2Sel{iCond, 2})]))
                    else

                        Data_ROI.Contra_VS_Ipsi.WholeROI.MEAN(iImg, iCond) = nanmean( ...
                                                                                     BlockImgL(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                     BlockImgR(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.Contra_VS_Ipsi.WholeROI.MEDIAN(iImg, iCond) = nanmedian( ...
                                                                                         BlockImgL(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                         BlockImgR(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.Contra_VS_Ipsi.WholeROI.STD(iImg, iCond) = nanstd( ...
                                                                                   BlockImgL(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                   BlockImgR(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.Contra_VS_Ipsi.WholeROI.SEM(iImg, iCond) = nansem( ...
                                                                                   BlockImgL(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                   BlockImgR(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));

                        for iLayer = 1:NbLayers % Averages over voxels of a given layer

                            A(iLayer, iImg, :) = nanmean( ...
                                                         BlockImgL(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                         BlockImgR(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            B(iLayer, iImg, :) = nanmedian( ...
                                                           BlockImgL(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                           BlockImgR(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            C(iLayer, iImg, :) = nanstd( ...
                                                        BlockImgL(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                        BlockImgR(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            D(iLayer, iImg, :) = nansem( ...
                                                        BlockImgL(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                        BlockImgR(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                        end
                    end
                    clear LayerInd;

                end
                clear BlockInd;

                Data_ROI.Contra_VS_Ipsi.LayerMean(:, 1:size(A, 2), iCond) = A;
                Data_ROI.Contra_VS_Ipsi.LayerMedian(:, 1:size(B, 2), iCond) = B;
                Data_ROI.Contra_VS_Ipsi.LayerStd(:, 1:size(C, 2), iCond) = C;
                Data_ROI.Contra_VS_Ipsi.LayerSEM(:, 1:size(D, 2), iCond) = D;
            end

            %% Contrast between sensory modalities Ipsi
            Col2Sel = { ...
                       [1 4], [2 5]
                       [1 4], [3 6]
                       [2 5], [3 6]};

            Data_ROI.ContSensModIpsi.LayerMean = nan(NbLayers, 20, size(Col2Sel, 1));

            for iCond = 1:size(Col2Sel, 1)

                for iImg = 1:size(CondLines, 2) % For each Block

                    BlockImgSens1 =  [ ...
                                      Features_ROI_L(CondLines(iImg, Col2Sel{iCond, 1}(1)), :) ...
                                      Features_ROI_R(CondLines(iImg, Col2Sel{iCond, 1}(2)), :)];

                    BlockImgSens2 =  [ ...
                                      Features_ROI_L(CondLines(iImg, Col2Sel{iCond, 2}(1)), :) ...
                                      Features_ROI_R(CondLines(iImg, Col2Sel{iCond, 2}(2)), :)];

                    if any(isnan(CondLines(iImg, [Col2Sel{iCond, :}])))

                    else

                        Data_ROI.ContSensModIpsi.WholeROI.MEAN(iImg, iCond) = nanmean( ...
                                                                                      BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                      BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.ContSensModIpsi.WholeROI.MEDIAN(iImg, iCond) = nanmedian( ...
                                                                                          BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                          BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.ContSensModIpsi.WholeROI.STD(iImg, iCond) = nanstd( ...
                                                                                    BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                    BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.ContSensModIpsi.WholeROI.SEM(iImg, iCond) = nansem( ...
                                                                                    BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                    BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));

                        for iLayer = 1:NbLayers % Averages over voxels of a given layer

                            A(iLayer, iImg, :) = nanmean( ...
                                                         BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                         BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            B(iLayer, iImg, :) = nanmedian( ...
                                                           BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                           BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            C(iLayer, iImg, :) = nanstd( ...
                                                        BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                        BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            D(iLayer, iImg, :) = nansem( ...
                                                        BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                        BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                        end
                    end
                    clear LayerInd;

                end
                clear BlockInd;

                Data_ROI.ContSensModIpsi.LayerMean(:, 1:size(A, 2), iCond) = A;
                Data_ROI.ContSensModIpsi.LayerMedian(:, 1:size(B, 2), iCond) = B;
                Data_ROI.ContSensModIpsi.LayerStd(:, 1:size(C, 2), iCond) = C;
                Data_ROI.ContSensModIpsi.LayerSEM(:, 1:size(D, 2), iCond) = D;
            end

            %% Contrast between sensory modalities contra
            Col2Sel = { ...
                       [4 1], [5 2]
                       [4 1], [6 3]
                       [5 2], [6 3]};

            Data_ROI.ContSensModContra.LayerMean = nan(NbLayers, 20, size(Col2Sel, 1));

            for iCond = 1:size(Col2Sel, 1)

                for iImg = 1:size(CondLines, 2) % For each Block

                    BlockImgSens1 =  [ ...
                                      Features_ROI_L(CondLines(iImg, Col2Sel{iCond, 1}(1)), :) ...
                                      Features_ROI_R(CondLines(iImg, Col2Sel{iCond, 1}(2)), :)];

                    BlockImgSens2 =  [ ...
                                      Features_ROI_L(CondLines(iImg, Col2Sel{iCond, 2}(1)), :) ...
                                      Features_ROI_R(CondLines(iImg, Col2Sel{iCond, 2}(2)), :)];

                    if any(isnan(CondLines(iImg, [Col2Sel{iCond, :}])))

                    else

                        Data_ROI.ContSensModContra.WholeROI.MEAN(iImg, iCond) = nanmean( ...
                                                                                        BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                        BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.ContSensModContra.WholeROI.MEDIAN(iImg, iCond) = nanmedian( ...
                                                                                            BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                            BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.ContSensModContra.WholeROI.STD(iImg, iCond) = nanstd( ...
                                                                                      BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                      BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));
                        Data_ROI.ContSensModContra.WholeROI.SEM(iImg, iCond) = nansem( ...
                                                                                      BlockImgSens1(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]) - ...
                                                                                      BlockImgSens2(1, [LayerLabels_ROI_L > 0 LayerLabels_ROI_R > 0]));

                        for iLayer = 1:NbLayers % Averages over voxels of a given layer

                            A(iLayer, iImg, :) = nanmean( ...
                                                         BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                         BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            B(iLayer, iImg, :) = nanmedian( ...
                                                           BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                           BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            C(iLayer, iImg, :) = nanstd( ...
                                                        BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                        BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                            D(iLayer, iImg, :) = nansem( ...
                                                        BlockImgSens1(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]) - ...
                                                        BlockImgSens2(1, [LayerLabels_ROI_L == iLayer LayerLabels_ROI_R == iLayer]));

                        end
                    end
                    clear LayerInd;

                end
                clear BlockInd;

                Data_ROI.ContSensModContra.LayerMean(:, 1:size(A, 2), iCond) = A;
                Data_ROI.ContSensModContra.LayerMedian(:, 1:size(A, 2), iCond) = B;
                Data_ROI.ContSensModContra.LayerStd(:, 1:size(B, 2), iCond) = C;
                Data_ROI.ContSensModContra.LayerSEM(:, 1:size(C, 2), iCond) = D;
            end

            %%
            Data_ROI.Ispi.MEAN = squeeze(nanmean(Data_ROI.Ispi.LayerMean, 2));
            Data_ROI.Ispi.MEDIAN = squeeze(nanmean(Data_ROI.Ispi.LayerMedian, 2));
            Data_ROI.Ispi.STD = squeeze(nanstd(Data_ROI.Ispi.LayerMean, 2));
            Data_ROI.Ispi.SEM = squeeze(nansem(Data_ROI.Ispi.LayerMean, 2));

            Data_ROI.Contra.MEAN = squeeze(nanmean(Data_ROI.Contra.LayerMean, 2));
            Data_ROI.Contra.MEDIAN = squeeze(nanmean(Data_ROI.Contra.LayerMedian, 2));
            Data_ROI.Contra.STD = squeeze(nanstd(Data_ROI.Contra.LayerMean, 2));
            Data_ROI.Contra.SEM = squeeze(nansem(Data_ROI.Contra.LayerMean, 2));

            Data_ROI.Contra_VS_Ipsi.MEAN = squeeze(nanmean(Data_ROI.Contra_VS_Ipsi.LayerMean, 2));
            Data_ROI.Contra_VS_Ipsi.MEDIAN = squeeze(nanmean(Data_ROI.Contra_VS_Ipsi.LayerMedian, 2));
            Data_ROI.Contra_VS_Ipsi.STD = squeeze(nanstd(Data_ROI.Contra_VS_Ipsi.LayerMean, 2));
            Data_ROI.Contra_VS_Ipsi.SEM = squeeze(nansem(Data_ROI.Contra_VS_Ipsi.LayerMean, 2));

            Data_ROI.ContSensModIpsi.MEAN = squeeze(nanmean(Data_ROI.ContSensModIpsi.LayerMean, 2));
            Data_ROI.ContSensModIpsi.MEDIAN = squeeze(nanmean(Data_ROI.ContSensModIpsi.LayerMedian, 2));
            Data_ROI.ContSensModIpsi.STD = squeeze(nanstd(Data_ROI.ContSensModIpsi.LayerMean, 2));
            Data_ROI.ContSensModIpsi.SEM = squeeze(nansem(Data_ROI.ContSensModIpsi.LayerMean, 2));

            Data_ROI.ContSensModContra.MEAN = squeeze(nanmean(Data_ROI.ContSensModContra.LayerMean, 2));
            Data_ROI.ContSensModContra.MEDIAN = squeeze(nanmean(Data_ROI.ContSensModContra.LayerMedian, 2));
            Data_ROI.ContSensModContra.STD = squeeze(nanstd(Data_ROI.ContSensModContra.LayerMean, 2));
            Data_ROI.ContSensModContra.SEM = squeeze(nansem(Data_ROI.ContSensModContra.LayerMean, 2));

            save(fullfile(SaveDir, strcat('Data_Pooled_Wht_Betas_', strrep(Mask_Ori.ROI(PoolHs(iROI, 1)).name, '_L', ''), ...
                                          '_l-', num2str(NbLayers), '.mat')), 'Data_ROI');

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
