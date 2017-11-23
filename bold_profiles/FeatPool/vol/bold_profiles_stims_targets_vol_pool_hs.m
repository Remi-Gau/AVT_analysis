function bold_profiles_stims_targets_vol_pool_hs
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;

CondNames = {...
    'AStimL','AStimR';...
    'VStimL','VStimR';...
    'TStimL','TStimR';...
    'ATargL','ATargR';...
    'VTargL','VTargR';...
    'TTargL','TTargR';...
    };

% --------------------------------------------------------- %
%                            ROIs                           %
% --------------------------------------------------------- %

Mask_Ori.ROI(1) = struct('name', 'V1_L_thres', 'fname', 'SubjName_lcr_V1_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V2_L_thres', 'fname', 'SubjName_lcr_V2_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V3_L_thres', 'fname', 'SubjName_lcr_V3_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V4_L_thres', 'fname', 'SubjName_lcr_V4_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V5_L_thres', 'fname', 'SubjName_lcr_V5_Pmap_Ret_thres_10_data.nii');


Mask_Ori.ROI(end+1) = struct('name', 'A1_L', 'fname', 'SubjName_A1_lcr_RG_data.nii');

Mask_Ori.ROI(end+1) = struct('name', 'PT_L', 'fname', 'rwA41-42_L.nii');


Mask_Ori.ROI(end+1) = struct('name', 'V1_R_thres', 'fname', 'SubjName_rcr_V1_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V2_R_thres', 'fname', 'SubjName_rcr_V2_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V3_R_thres', 'fname', 'SubjName_rcr_V3_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V4_R_thres', 'fname', 'SubjName_rcr_V4_Pmap_Ret_thres_10_data.nii');
Mask_Ori.ROI(end+1) = struct('name', 'V5_R_thres', 'fname', 'SubjName_rcr_V5_Pmap_Ret_thres_10_data.nii');
    
Mask_Ori.ROI(end+1) = struct('name', 'A1_R', 'fname', 'SubjName_A1_rcr_RG_data.nii');

Mask_Ori.ROI(end+1) = struct('name', 'PT_R', 'fname', 'rwA41-42_R.nii');


% Indicate which ROIs to pool - first column is left hs, second one is righ hs
PoolHs = [(1:7)',(8:14)'];

SubLs = dir('sub*');
NbSub = numel(SubLs);


for iSub = 1:NbSub % for each subject
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    Mask = Mask_Ori;
    
    for iROI =1:length(Mask.ROI)
        Mask.ROI(iROI).fname = strrep(Mask_Ori.ROI(iROI).fname,'SubjName',SubLs(iSub).name);
    end
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    RoiFolder = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp');
    AnalysisFolder = fullfile(SubDir, 'ffx_nat', 'betas');
    
    SaveDir = fullfile(SubDir, 'results', 'profiles');
    [~,~,~] = mkdir(SaveDir);
    
    % Gets the number of each beta images and the numbers of the beta of
    % interest
    load(fullfile(SubDir, 'ffx_nat','SPM.mat'))
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    
    for i=1:size(BetaNames,1)
        if BetaNames(i,6)==' '
            tmp(i,1:6) = BetaNames(i,7:12);
        else
            tmp(i,1:6) = BetaNames(i,8:13);
        end
    end
    BetaNames = tmp;
    clear SPM
    
    % Defines what condition each line of the feature matrix corresponds to
    CondLines = nan(20,numel(CondNames));
    FilesList = {};
    iRow = 1;
    
    for iCond=1:numel(CondNames)
        
        tmp=BetaNames(BetaOfInterest,1:length(CondNames{iCond}));
        tmp = BetaOfInterest(strcmp(CondNames{iCond}, cellstr(tmp)));        
        
        for i=1:length(tmp)
            
            CondLines(i,iCond) = iRow;
            
            FilesList{end+1,1} = fullfile(AnalysisFolder, ...
                sprintf('r%s_beta-%04d.nii', SubLs(iSub).name, tmp(i)));
            
            iRow = iRow+1;
        end
        
        clear tmp
    end
    
    
    %% Gets global mask from GLM and ROI masks for the data
    fprintf(' Reading masks\n')
    
    if ~exist(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii']), 'file')
        try
            gunzip(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii.gz']))
        catch
            error('The GLM mask file %s is missing.', ['r' SubLs(iSub).name '_GLM_mask.nii'])
        end
    end
    Mask.global.hdr = spm_vol(fullfile(AnalysisFolder, ['r' SubLs(iSub).name '_GLM_mask.nii']));
    Mask.global.img = logical(spm_read_vols(Mask.global.hdr));
    
    for i=1:length(Mask.ROI)
        Mask.ROI(i).hdr = spm_vol(fullfile(RoiFolder, Mask.ROI(i).fname));
    end
    
    hdr = cat(1, Mask.ROI.hdr);
    sts = spm_check_orientations([Mask.global.hdr; hdr]);
    if sts ~= 1
        error('Images not in same space!');
    end
    
    clear sts hdr i
    
    % Create mask in XYZ format (both world and voxel coordinates)
    [X, Y, Z] = ind2sub(size(Mask.global.img), find(Mask.global.img));
    Mask.global.XYZ = [X'; Y'; Z']; % XYZ format
    clear X Y Z
    Mask.global.size = size(Mask.global.XYZ, 2);
    Mask.global.XYZmm = Mask.global.hdr.mat(1:3,:) ...
        * [Mask.global.XYZ; ones(1, Mask.global.size)]; % voxel to world transformation
    
    % Combine masks
    xY.def = 'mask';
    for i=1:length(Mask.ROI)
        xY.spec = fullfile(RoiFolder, Mask.ROI(i).fname);
        [xY, Mask.ROI(i).XYZmm, j] = spm_ROI(xY, Mask.global.XYZmm);
        Mask.ROI(i).XYZ = Mask.global.XYZ(:,j);
        Mask.ROI(i).size = size(Mask.ROI(i).XYZ, 2);
    end
    
    clear xY j i
    
    
    %% Gets Layer labels
    fprintf(' Reading layer labels\n')
    
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
                LayerLabelsFile.name(1:end-3)));
        catch
            error(['The layer label file ' LayerLabels 'is missing.'])
        end
    end
    
    sts = spm_check_orientations([Mask.global.hdr; LayerLabelsHdr]);
    if sts ~= 1
        error('Images not in same space!');
    end
    clear sts
    
    for i=1:length(Mask.ROI)
        LayerLabels{i} = spm_get_data(LayerLabelsHdr, Mask.ROI(i).XYZ); %#ok<*AGROW>
    end
        
    
    %% Mask each image by each ROI and create a features set (images x voxel)
    fprintf('\n Get features\n')
    
    for i=1:length(Mask.ROI)
        
        FeatureFile = fullfile(AnalysisFolder, ['BOLD_stims_targets_' Mask.ROI(i).name '_data_l-' num2str(NbLayers) '.mat']);
        
        % Load the feature file if it exists
        if exist(FeatureFile, 'file')
            load(FeatureFile, 'Features', 'MaskSave', 'FilesListSave')
            
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
        
        clear FilesListSave MaskSave Features
        
    end
    
    % Extract the features of the missing ROIs
    if any(NeedFeat)
        GetFeaturesStimsTargets(Mask.ROI(NeedFeat), FilesList, AnalysisFolder, NbLayers);
        
        % Reload everything
        for i=1:length(Mask.ROI)
            FeatureFile = fullfile(AnalysisFolder, ...
                ['BOLD_stims_targets_' Mask.ROI(i).name '_data_l-' num2str(NbLayers) '.mat']);
            load(FeatureFile, 'Features')
            FeaturesAll{i} = Features{1};
        end
    end
    
    Features = FeaturesAll;
    
    clear FilesList FeaturesAll
    
    
    %% Averages across blocks and voxels for each set of ROIS
    for iROI=1:size(PoolHs,1)
        
        fprintf('\n Processing %s and %s', Mask_Ori.ROI(PoolHs(iROI,1)).name,  ...
            Mask_Ori.ROI(PoolHs(iROI,2)).name)
        
        Features_ROI_L = Features{PoolHs(iROI,1)};
        LayerLabels_ROI_L = LayerLabels{PoolHs(iROI,1)};
        Features_ROI_R = Features{PoolHs(iROI,2)};
        LayerLabels_ROI_R = LayerLabels{PoolHs(iROI,2)};
        
        %% For ipsilateral stimulus
        Col2Sel = {...
            [1 7], [4 10];
            [2 8], [5 11];
            [3 9], [6 12]};
        
        Data_ROI.StimTargIpsi.LayerMean = nan(NbLayers, 20, size(Col2Sel,1));
        
        for iCond = 1:size(Col2Sel,1)
            
            for iImg = 1:size(CondLines,2) % For each Block
                
                BlockImgSens1 =  [...
                    Features_ROI_L(CondLines(iImg,Col2Sel{iCond,1}(1)),:) ...
                    Features_ROI_R(CondLines(iImg,Col2Sel{iCond,1}(2)),:)];
                
                BlockImgSens2 =  [...
                    Features_ROI_L(CondLines(iImg,Col2Sel{iCond,2}(1)),:) ...
                    Features_ROI_R(CondLines(iImg,Col2Sel{iCond,2}(2)),:)];
                
                if any(isnan(CondLines(iImg,[Col2Sel{iCond,:}])))
                    
                else
                    
                    Data_ROI.StimTargIpsi.WholeROI.MEAN(iImg,iCond) = nanmean(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]));
                    Data_ROI.StimTargIpsi.WholeROI.MEDIAN(iImg,iCond) = nanmedian(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]));                    
                    Data_ROI.StimTargIpsi.WholeROI.STD(iImg,iCond) = nanstd(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0])) ;
                    Data_ROI.StimTargIpsi.WholeROI.SEM(iImg,iCond) = nansem(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]));
                    
                    for iLayer = 1:NbLayers % Averages over voxels of a given layer
                        
                        A(iLayer,iImg,:) = nanmean(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]));
                        
                        B(iLayer,iImg,:) = nanmedian(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]));
                        
                        C(iLayer,iImg,:) = nanstd(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer])) ;
                        
                        D(iLayer,iImg,:) = nansem(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]));
                        
                    end
                end
                clear LayerInd
                
            end
            clear BlockInd
            
            Data_ROI.StimTargIpsi.LayerMean(:,1:size(A,2),iCond) = A;
            Data_ROI.StimTargIpsi.LayerMedian(:,1:size(B,2),iCond) = B;            
            Data_ROI.StimTargIpsi.LayerStd(:,1:size(C,2),iCond) = C;
            Data_ROI.StimTargIpsi.LayerSEM(:,1:size(D,2),iCond) = D;
        end

        
        %% For contralateral stimulus
        Col2Sel = {...
            [7 1], [10 4];
            [8 2], [11 5];
            [9 3], [12 6]};
        
        Data_ROI.StimTargContra.LayerMean = nan(NbLayers, 20, size(Col2Sel,1));
        
        for iCond = 1:size(Col2Sel,1)
            
            for iImg = 1:size(CondLines,2) % For each Block
                
                
                BlockImgSens1 =  [...
                    Features_ROI_L(CondLines(iImg,Col2Sel{iCond,1}(1)),:) ...
                    Features_ROI_R(CondLines(iImg,Col2Sel{iCond,1}(2)),:)];
                
                BlockImgSens2 =  [...
                    Features_ROI_L(CondLines(iImg,Col2Sel{iCond,2}(1)),:) ...
                    Features_ROI_R(CondLines(iImg,Col2Sel{iCond,2}(2)),:)];
                
                if any(isnan(CondLines(iImg,[Col2Sel{iCond,:}])))
                    
                else
                    
                    Data_ROI.StimTargContra.WholeROI.MEAN(iImg,iCond) = nanmean(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]));
                    Data_ROI.StimTargContra.WholeROI.MEDIAN(iImg,iCond) = nanmedian(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]));                    
                    Data_ROI.StimTargContra.WholeROI.STD(iImg,iCond) = nanstd(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0])) ;
                    Data_ROI.StimTargContra.WholeROI.SEM(iImg,iCond) = nansem(...
                        BlockImgSens1(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]) - ...
                        BlockImgSens2(1,[LayerLabels_ROI_L>0 LayerLabels_ROI_R>0]));
                    
                    for iLayer = 1:NbLayers % Averages over voxels of a given layer
                        
                        A(iLayer,iImg,:) = nanmean(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]));
                        
                        B(iLayer,iImg,:) = nanmedian(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]));
                        
                        C(iLayer,iImg,:) = nanstd(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer])) ;
                        
                        D(iLayer,iImg,:) = nansem(...
                            BlockImgSens1(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]) - ...
                            BlockImgSens2(1,[LayerLabels_ROI_L==iLayer LayerLabels_ROI_R==iLayer]));
                        
                    end
                end
                clear LayerInd
                
            end
            clear BlockInd
            
            Data_ROI.StimTargContra.LayerMean(:,1:size(A,2),iCond) = A;
            Data_ROI.StimTargContra.LayerMedian(:,1:size(B,2),iCond) = B;            
            Data_ROI.StimTargContra.LayerStd(:,1:size(C,2),iCond) = C;
            Data_ROI.StimTargContra.LayerSEM(:,1:size(D,2),iCond) = D;
        end

        
        
        
        %%
        Data_ROI.StimTargIpsi.MEAN=squeeze(nanmean(Data_ROI.StimTargIpsi.LayerMean,2));
        Data_ROI.StimTargIpsi.MEDIAN=squeeze(nanmean(Data_ROI.StimTargIpsi.LayerMedian,2));        
        Data_ROI.StimTargIpsi.STD=squeeze(nanstd(Data_ROI.StimTargIpsi.LayerMean,2));
        Data_ROI.StimTargIpsi.SEM=squeeze(nansem(Data_ROI.StimTargIpsi.LayerMean,2));
        
        Data_ROI.StimTargContra.MEAN=squeeze(nanmean(Data_ROI.StimTargContra.LayerMean,2));
        Data_ROI.StimTargContra.MEDIAN=squeeze(nanmean(Data_ROI.StimTargContra.LayerMedian,2));
        Data_ROI.StimTargContra.STD=squeeze(nanstd(Data_ROI.StimTargContra.LayerMean,2));
        Data_ROI.StimTargContra.SEM=squeeze(nansem(Data_ROI.StimTargContra.LayerMean,2));
        
        save(fullfile(SaveDir, strcat('Data_stims_targets_Pooled_', strrep(Mask_Ori.ROI(PoolHs(iROI,1)).name, '_L',''), ...
            '_l-', num2str(NbLayers), '.mat')), 'Data_ROI')
        
        
        
    end % iSubROI=1:numel(SVM(iSVM).ROI)
    
    fprintf('\n')
    
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
    spm_jobman('run', matlabbatch)
    clear tmp matlabbatch
end