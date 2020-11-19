function bold_profiles_vol_distribution
  clc;
  clear;

  StartDir = fullfile(pwd, '..', '..');
  cd (StartDir);
  addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

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

  SubLs = dir('sub*');
  NbSub = numel(SubLs);

  COLOR =   [ ...
             255 150 150; ...
             150 255 150; ...
             150 220 255; ...
             255 75 75; ...
             75 255 75; ...
             75 75 255];
  COLOR = COLOR / 255;

  FigDim = [100 100 1800 1000];

  Fontsize = 10;

  Visible = 'off';

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

      FeatureFile = fullfile(AnalysisFolder, ['BOLD_' Mask.ROI(i).name '_data_l-' num2str(NbLayers) '.mat']);

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
      GetFeatures(Mask.ROI(NeedFeat), FilesList, AnalysisFolder, NbLayers);

      % Reload everything
      for i = 1:length(Mask.ROI)
        FeatureFile = fullfile(AnalysisFolder, ...
                               ['BOLD_' Mask.ROI(i).name '_data_l-' num2str(NbLayers) '.mat']);
        load(FeatureFile, 'Features');
        FeaturesAll{i} = Features{1};
      end
    end

    Features = FeaturesAll;

    clear FilesList FeaturesAll;

    %% Averages across blocks and voxels for each ROI
    for iROI = 1:numel(Mask.ROI)

      close all;

      fprintf('\n Processing %s \t', Mask.ROI(iROI).name);
      Features_ROI = Features{iROI};
      LayerLabels_ROI = LayerLabels{iROI};

      clear Data_ROI;

      %%
      figure('position', FigDim, 'name', 'Attention', 'Color', [1 1 1], 'visible', Visible);
      set(gca, 'units', 'centimeters');
      pos = get(gca, 'Position');
      ti = get(gca, 'TightInset');

      set(gcf, 'PaperUnits', 'centimeters');
      set(gcf, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
      set(gcf, 'PaperPositionMode', 'manual');
      set(gcf, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

      % For each Condition
      SubPlot = [1 3 5 2 4 6];
      for iCond = 1:numel(CondNames)

        Img2Sel = CondLines(:, iCond);
        Img2Sel(isnan(Img2Sel)) = [];

        for iLayer = 1:NbLayers % Averages over voxels of a given layer
          DistToPlot{iLayer} = ...
              nanmean(Features_ROI(Img2Sel, LayerLabels_ROI == iLayer));
        end
        clear iLayer;

        subplot(3, 2, SubPlot(iCond));
        hold on;
        distributionPlot(DistToPlot, 'xValues', 1:NbLayers, 'color', 'k', ...
                         'distWidth', 0.8, 'showMM', 1, 'globalNorm', 2, 'histOpt', 1.1);
        set(gca, 'tickdir', 'out', 'xtick', 1:NbLayers, ...
            'xticklabel', NbLayers:-1:1, ...
            'ticklength', [0.01 0.01], 'fontsize', Fontsize);
        plot([0 NbLayers + 1], [0 0], '--k');
        axis([0 NbLayers + 1 -10 10]);

        t = xlabel('layer');
        set(t, 'fontsize', Fontsize);

      end

      subplot(3, 2, 1);
      t = ylabel('A stimulation');
      set(t, 'fontsize', Fontsize);
      t = title('Left');
      set(t, 'fontsize', Fontsize);

      subplot(3, 2, 2);
      t = title('Right');
      set(t, 'fontsize', Fontsize);

      subplot(3, 2, 3);
      t = ylabel('V stimulation');
      set(t, 'fontsize', Fontsize);

      subplot(3, 2, 5);
      t = ylabel('T stimulation');
      set(t, 'fontsize', Fontsize);

      %         mtit([SubLs(iSub).name '-' strrep(Mask.ROI(iROI).name,'_','-')],'xoff',0,'yoff',.025)

      print(gcf, fullfile(SubDir, 'fig', ...
                          [SubLs(iSub).name '_VoxelsDist_', Mask.ROI(iROI).name '.tif']), '-dtiff');

    end % iSubROI=1:numel(SVM(iSVM).ROI)

    fprintf('\n');

  end % for iSub = 1:NbSub

end
