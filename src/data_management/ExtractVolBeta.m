% (C) Copyright 2020 Remi Gau

function ExtractVolBeta

    % Extracts data from volume beta nifti data and saves in a mat file

    clc;
    clear;

    StartDir = fullfile(pwd, '..', '..', '..');
    cd (StartDir);
    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

    NbLayers = 6;

    Whitened_beta = 0;
    Trim_beta = 1;
    if Whitened_beta
        Beta_suffix = 'w';
        FFX_dir = 'ffx_rsa';
        Save_suffix = 'beta-wht';
    elseif Trim_beta
        Beta_suffix = '';
        FFX_dir = 'ffx_trim';
        Save_suffix = 'beta-trim';
    else
        Beta_suffix = ''; %#ok<*UNRCH>
        FFX_dir = 'ffx_nat';
        Save_suffix = 'beta-raw';
    end

    FWHM = 0;
    if FWHM == 0
        SmoothSufix = [];
    end

    CondNames = { ...
                 'AStimL', 'AStimR', ...
                 'VStimL', 'VStimR', ...
                 'TStimL', 'TStimR', ...
                 'ATargL', 'ATargR', ...
                 'VTargL', 'VTargR', ...
                 'TTargL', 'TTargR' ...
                };

    ROIs = { ...
            'A1', ...
            'PT', ...
            'V1_thres', ...
            'V2_thres', ...
            'V3_thres', ...
            'V4_thres', ...
            'V5_thres' ...
           };

    % --------------------------------------------------------- %
    %                            ROIs                           %
    % --------------------------------------------------------- %
    Mask_Ori.ROI(1) = struct('name', 'V1_L_thres', 'fname', 'SubjName_lcr_V1_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V2_L_thres', 'fname', 'SubjName_lcr_V2_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V3_L_thres', 'fname', 'SubjName_lcr_V3_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V4_L_thres', 'fname', 'SubjName_lcr_V4_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V5_L_thres', 'fname', 'SubjName_lcr_V5_Pmap_Ret_thres_10_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'A1_L', 'fname', 'SubjName_A1_lcr_RG_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'PT_L', 'fname', 'rwA41-42_L.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'V1_R_thres', 'fname', 'SubjName_rcr_V1_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V2_R_thres', 'fname', 'SubjName_rcr_V2_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V3_R_thres', 'fname', 'SubjName_rcr_V3_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V4_R_thres', 'fname', 'SubjName_rcr_V4_Pmap_Ret_thres_10_data.nii');
    Mask_Ori.ROI(end + 1) = struct('name', 'V5_R_thres', 'fname', 'SubjName_rcr_V5_Pmap_Ret_thres_10_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'A1_R', 'fname', 'SubjName_A1_rcr_RG_data.nii');

    Mask_Ori.ROI(end + 1) = struct('name', 'PT_R', 'fname', 'rwA41-42_R.nii');

    % Indicate which ROIs to pool - first column is left hs, second one is righ hs
    PoolHs = [(1:7)', (8:14)']; %#ok<*NASGU>

    SubLs = dir('sub*');
    NbSub = numel(SubLs);

    for iSub = 1:NbSub

        fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

        Mask = Mask_Ori;

        for iROI = 1:length(Mask.ROI)
            Mask.ROI(iROI).fname = strrep(Mask_Ori.ROI(iROI).fname, 'SubjName', SubLs(iSub).name);
        end

        SubDir = fullfile(StartDir, SubLs(iSub).name);
        RoiFolder = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp');
        AnalysisFolder = fullfile(SubDir, FFX_dir, 'betas');

        SaveDir = fullfile(SubDir, 'results', 'PCM', 'vol');
        mkdir(SaveDir);

        %% Gets the number of each beta images and each of beta of interest
        load(fullfile(SubDir, 'ffx_nat', 'SPM.mat'));
        [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);

        for i = 1:size(BetaNames, 1)
            if BetaNames(i, 6) == ' '
                tmp(i, 1:6) = BetaNames(i, 7:12); %#ok<*AGROW>
            else
                tmp(i, 1:6) = BetaNames(i, 8:13);
            end
        end
        BetaNames = tmp;

        %% Gets global mask from GLM and ROI masks for the data
        fprintf(' Reading masks\n');

        if ~exist(fullfile(SubDir, 'ffx_nat', 'betas', ['r' SubLs(iSub).name '_GLM_mask.nii']), 'file')
            try
                gunzip(fullfile(SubDir, 'ffx_nat', 'betas', ['r' SubLs(iSub).name '_GLM_mask.nii.gz']));
            catch
                error('The GLM mask file %s is missing.', ['r' SubLs(iSub).name '_GLM_mask.nii']);
            end
        end
        Mask.global.hdr = spm_vol(fullfile(SubDir, 'ffx_nat', 'betas', ['r' SubLs(iSub).name '_GLM_mask.nii']));
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
        Mask.global.XYZmm = Mask.global.hdr.mat(1:3, :) * ...
            [Mask.global.XYZ; ones(1, Mask.global.size)]; % voxel to world transformation

        % Combine masks
        xY.def = 'mask';
        for i = 1:length(Mask.ROI)
            xY.spec = fullfile(RoiFolder, Mask.ROI(i).fname);
            [xY, Mask.ROI(i).XYZmm, j] = spm_ROI(xY, Mask.global.XYZmm);
            Mask.ROI(i).XYZ = Mask.global.XYZ(:, j);
            Mask.ROI(i).size = size(Mask.ROI(i).XYZ, 2);
        end

        clear xY j i;

        %% Make a list of the beta files
        FilesList = {};
        for iCond = 1:numel(CondNames)

            tmp = BetaNames(BetaOfInterest, 1:length(CondNames{iCond}));
            TEMP = BetaOfInterest(strcmp(CondNames{iCond}, cellstr(tmp)));

            for i = 1:length(TEMP)
                FilesList{end + 1, 1} = fullfile(AnalysisFolder, ...
                                                 sprintf('r%s_%sbeta-%04d%s.nii', SubLs(iSub).name, Beta_suffix, TEMP(i), SmoothSufix));
                %             if ~exist(FilesList{end,1},'file') && ~exist([FilesList{end,1} '.gz'],'file')
                %                 error('This file does not seem to exist: \n%s',FilesList{end,1})
                %             end
            end
            clear TEMP I i tmp;

        end

        clear iClass iCond;

        %% Mask each image by each ROI and create a features set (images x voxel)
        fprintf('\n Get features\n');

        for i = 1:length(Mask.ROI)

            FeatureFile = fullfile(AnalysisFolder, ['Features_' Mask.ROI(i).name ...
                                                    '_l-' num2str(NbLayers) '_s-' num2str(FWHM)  '.mat']);

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
            GetFeaturesMVPA(Mask.ROI(NeedFeat), FilesList, AnalysisFolder, NbLayers, FWHM);

            % Reload everything
            for i = 1:length(Mask.ROI)
                FeatureFile = fullfile(AnalysisFolder, ['Features_' Mask.ROI(i).name '_l-' ...
                                                        num2str(NbLayers) '_s-' num2str(FWHM)  '.mat']);
                load(FeatureFile, 'Features');
                FeaturesAll{i} = Features{1};
            end
        end

        Features = FeaturesAll;

        clear FilesList FeaturesAll;

        for iROI = 1:numel(ROIs)

            % ROI index
            ROI_L = ismember(strrep({Mask.ROI(1:numel(Mask.ROI) / 2).name}, '_L', ''), ...
                             ROIs{iROI});
            ROI_L = PoolHs(ROI_L, 1);
            ROI_R = ismember(strrep({Mask.ROI(numel(Mask.ROI) / 2 + 1:end).name}, '_R', ''), ...
                             ROIs{iROI});
            ROI_R = PoolHs(ROI_R, 2);

            % swap left and right for the right ROI, so that we have everything
            % in terms of contra and ispi
            tmp = Features{ROI_R};
            tmp(1:2:size(tmp, 1), :) = Features{ROI_R}(2:2:size(tmp, 1), :);
            tmp(2:2:size(tmp, 1), :) = Features{ROI_R}(1:2:size(tmp, 1), :);

            Features_ROI = [Features{ROI_L} tmp];

            PCM_data{iROI} = Features_ROI;

            clear Features_ROI tmp;

        end

        save(fullfile(SaveDir, ['Data_PCM_' Save_suffix '.mat']), 'PCM_data', 'ROIs');

        clear Features;

    end
