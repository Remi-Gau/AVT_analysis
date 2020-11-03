clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox/');

NbLayers = 6;

CondNames = { ...
             'AStimL', 'AStimR', ...
             'VStimL', 'VStimR', ...
             'TStimL', 'TStimR'};

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub

  % --------------------------------------------------------- %
  %                        Subject data                       %
  % --------------------------------------------------------- %
  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  SubDir = fullfile(StartDir, SubLs(iSub).name);

  Results_dir = fullfile(SubDir, 'results', 'profiles', 'surf');

  Data_dir = fullfile(SubDir, 'results', 'profiles', 'surf', 'PCM');

  GLM_dir = fullfile(SubDir, 'ffx_nat');

  SaveDir = fullfile(SubDir, 'results', 'SVM');
  [~, ~, ~] = mkdir(SaveDir);

  % Load Vertices of interest for each ROI;
  load(fullfile(SubDir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

  %% Get beta images names
  load(fullfile(GLM_dir, 'SPM.mat'));

  % If we want to have a learning curve
  Nb_sess = numel(SPM.Sess);

  clear SPM;

  %% Create partition and condition vector
  conditionVec = repmat(1:numel(CondNames) * 2, Nb_sess, 1);
  conditionVec = conditionVec(:);

  partitionVec = repmat((1:Nb_sess)', numel(CondNames) * 2, 1);

  if iSub == 5
    % remove lines corresponding to auditory stim and
    % targets for sub-06
    ToRemove = all([any([conditionVec < 3 conditionVec == 7 conditionVec == 8], 2) partitionVec == 17], 2);

    partitionVec(ToRemove) = [];
    conditionVec(ToRemove) = [];
    clear ToRemove;
  end

  % "remove" rows corresponding to targets
  partitionVec(conditionVec > 6) = 0;
  conditionVec(conditionVec > 6) = 0;
  %         conditionVec(conditionVec>6)=conditionVec(conditionVec>6)-6;

  %% Read features
  FeatureSaveFile = 'Data_PCM_whole_ROI.mat';
  load(fullfile(Data_dir, FeatureSaveFile), 'PCM_data');
  Data = PCM_data;

  %% Remove extra data and checks for zeros and NANs
  for iROI = 1:numel(ROI)
    % Get just the right data
    Data{iROI, 1}(conditionVec == 0, :) = [];
    Data{iROI, 2}(conditionVec == 0, :) = [];

    % Remove nans
    % reshape data to remove a whole vertex even if it has one
    % NAN
    Data{iROI, 1} = reshape(Data{iROI, 1}, ...
                            [size(Data{iROI, 1}, 1), NbLayers, numel(ROI(iROI).VertOfInt{1})]);
    Data{iROI, 2} = reshape(Data{iROI, 2}, ...
                            [size(Data{iROI, 2}, 1), NbLayers, numel(ROI(iROI).VertOfInt{2})]);

    ToRemove = find(any(any(isnan(Data{iROI, 1}))));
    Data{iROI, 1}(:, :, ToRemove) = [];
    clear ToRemove;
    ToRemove = find(any(any(isnan(Data{iROI, 2}))));
    Data{iROI, 2}(:, :, ToRemove) = [];
    clear ToRemove;

    % Puts them back in original shape
    Data{iROI, 1} = reshape(Data{iROI, 1}, ...
                            [size(Data{iROI, 1}, 1), NbLayers * size(Data{iROI, 1}, 3)]);
    Data{iROI, 2} = reshape(Data{iROI, 2}, ...
                            [size(Data{iROI, 2}, 1), NbLayers * size(Data{iROI, 2}, 3)]);

    if any(all(isnan(Data{iROI, 1}), 2)) || any(all(Data{iROI, 1} == 0, 2)) || ...
            any(all(isnan(Data{iROI, 2}), 2)) || any(all(Data{iROI, 2} == 0, 2))
      warning('We have some NaNs or zeros issue: ignore if sub-06');
      ZeroRowsToRemove(:, iROI) = any([all(isnan(Data{iROI, 1}), 2) all(Data{iROI, 1} == 0, 2) ...
                                       all(isnan(Data{iROI, 2}), 2) all(Data{iROI, 2} == 0, 2)], 2);
      Data{iROI, 1}(ZeroRowsToRemove(:, iROI), :) = [];
      Data{iROI, 2}(ZeroRowsToRemove(:, iROI), :) = [];
    end

    % construc a vector that identify what column belongs to which
    % layer
    FeaturesLayers{iROI, 1} = ...
        repmat(NbLayers:-1:1, 1, size(Data{iROI, 1}, 2) / NbLayers);
    FeaturesLayers{iROI, 2} = ...
        repmat(NbLayers:-1:1, 1, size(Data{iROI, 2}, 2) / NbLayers);

  end

  if exist('ZeroRowsToRemove', 'var')
    partitionVec(any(ZeroRowsToRemove, 2), :) = [];
    conditionVec(any(ZeroRowsToRemove, 2), :) = [];
  end
  clear ZeroRowsToRemove;

  partitionVec(conditionVec == 0, :) = [];
  conditionVec(conditionVec == 0, :) = [];

  %% check that we have the same number of conditions in each partition
  A = tabulate(partitionVec);
  A = A(:, 1:2);
  if numel(unique(A(:, 2))) > 1
    warning('We have different numbers of conditions in at least one partition.');
    Sess2Remove = find(A(:, 2) < numel(unique(conditionVec)));
    conditionVec(ismember(partitionVec, Sess2Remove)) = [];
    for iROI = 1:numel(ROI)
      Data{iROI, 1}(ismember(partitionVec, Sess2Remove), :) = [];
      Data{iROI, 2}(ismember(partitionVec, Sess2Remove), :) = [];
    end
    partitionVec(ismember(partitionVec, Sess2Remove)) = [];
    Sess2Remove = [];
  end
  clear A Sess2Remove;

  for iROI = 1:numel(ROI)

    %% For ipsi-lateral stimulus
    Cdt_ROI_lhs = [1 3 5];
    Cdt_ROI_rhs = [2 4 6];

    Data_ROI.Ispi.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.Ispi.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));

    Data_ROI.Ispi.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.Ispi.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));

    for iCdt = 1:numel(Cdt_ROI_lhs)

      tmpL = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs(iCdt), :);
      tmpR = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs(iCdt), :);

      tmp = [tmpL tmpR];
      tmp = reshape(tmp, ...
                    [size(tmp, 1), numel(tmp) / (NbLayers * size(tmp, 1)), NbLayers]);

      Data_ROI.Ispi.WholeROI.MEAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmean(tmp, 3), 2));
      Data_ROI.Ispi.WholeROI.MEDIAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmedian(tmp, 3), 2));

      Data_ROI.Ispi.LayerMean(:, 1:size(tmp, 1), iCdt) = squeeze(nanmean(tmp, 2))';
      Data_ROI.Ispi.LayerMedian(:, 1:size(tmp, 1), iCdt) = squeeze(nanmedian(tmp, 2))';

    end

    %% For contra-lateral stimulus
    Cdt_ROI_lhs = [2 4 6];
    Cdt_ROI_rhs = [1 3 5];

    Data_ROI.Contra.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.Contra.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));

    Data_ROI.Contra.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.Contra.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));

    for iCdt = 1:numel(Cdt_ROI_lhs)

      tmpL = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs(iCdt), :);
      tmpR = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs(iCdt), :);

      tmp = [tmpL tmpR];
      tmp = reshape(tmp, ...
                    [size(tmp, 1), numel(tmp) / (NbLayers * size(tmp, 1)), NbLayers]);

      Data_ROI.Contra.WholeROI.MEAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmean(tmp, 3), 2));
      Data_ROI.Contra.WholeROI.MEDIAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmedian(tmp, 3), 2));

      Data_ROI.Contra.LayerMean(:, 1:size(tmp, 1), iCdt) = squeeze(nanmean(tmp, 2))';
      Data_ROI.Contra.LayerMedian(:, 1:size(tmp, 1), iCdt) = squeeze(nanmedian(tmp, 2))';

    end

    %% For contra - ipsi
    Cdt_ROI_lhs = { ...
                   2 1
                   4 3
                   6 5};
    Cdt_ROI_rhs = { ...
                   1 2
                   3 4
                   5 6};

    Data_ROI.Contra_VS_Ipsi.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.Contra_VS_Ipsi.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));

    Data_ROI.Contra_VS_Ipsi.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.Contra_VS_Ipsi.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));

    for iCdt = 1:size(Cdt_ROI_lhs, 1)

      Contra_L = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs{iCdt, 1}, :);
      Contra_R = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs{iCdt, 1}, :);
      Contra = [Contra_L Contra_R];
      Contra = reshape(Contra, ...
                       [size(Contra, 1), numel(Contra) / (NbLayers * size(Contra, 1)), NbLayers]);

      Ipsi_L = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs{iCdt, 2}, :);
      Ipsi_R = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs{iCdt, 2}, :);
      Ipsi = [Ipsi_L Ipsi_R];
      Ipsi = reshape(Ipsi, ...
                     [size(Ipsi, 1), numel(Ipsi) / (NbLayers * size(Ipsi, 1)), NbLayers]);

      tmp = Contra - Ipsi;

      Data_ROI.Contra_VS_Ipsi.WholeROI.MEAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmean(tmp, 3), 2));
      Data_ROI.Contra_VS_Ipsi.WholeROI.MEDIAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmedian(tmp, 3), 2));

      Data_ROI.Contra_VS_Ipsi.LayerMean(:, 1:size(tmp, 1), iCdt) = squeeze(nanmean(tmp, 2))';
      Data_ROI.Contra_VS_Ipsi.LayerMedian(:, 1:size(tmp, 1), iCdt) = squeeze(nanmedian(tmp, 2))';

    end

    %% Contrast between sensory modalities Ipsi
    Cdt_ROI_lhs = { ...
                   1 3
                   1 5
                   3 5};
    Cdt_ROI_rhs = { ...
                   2 4
                   2 6
                   4 6};

    Data_ROI.ContSensModIpsi.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.ContSensModIpsi.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));

    Data_ROI.ContSensModIpsi.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.ContSensModIpsi.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));

    for iCdt = 1:size(Cdt_ROI_lhs, 1)

      SensMod1_L = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs{iCdt, 1}, :);
      SensMod1_R = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs{iCdt, 1}, :);
      SensMod1 = [SensMod1_L SensMod1_R];
      SensMod1 = reshape(SensMod1, ...
                         [size(SensMod1, 1), numel(SensMod1) / (NbLayers * size(SensMod1, 1)),  NbLayers]);

      SensMod2_L = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs{iCdt, 2}, :);
      SensMod2_R = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs{iCdt, 2}, :);
      SensMod2 = [SensMod2_L SensMod2_R];
      SensMod2 = reshape(SensMod2, ...
                         [size(SensMod2, 1), numel(SensMod2) / (NbLayers * size(SensMod2, 1)), NbLayers]);

      tmp = SensMod1 - SensMod2;

      Data_ROI.ContSensModIpsi.WholeROI.MEAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmean(tmp, 3), 2));
      Data_ROI.ContSensModIpsi.WholeROI.MEDIAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmedian(tmp, 3), 2));

      Data_ROI.ContSensModIpsi.LayerMean(:, 1:size(tmp, 1), iCdt) = squeeze(nanmean(tmp, 2))';
      Data_ROI.ContSensModIpsi.LayerMedian(:, 1:size(tmp, 1), iCdt) = squeeze(nanmedian(tmp, 2))';

    end

    %% Contrast between sensory modalities Contra
    Cdt_ROI_lhs = { ...
                   2 4
                   2 6
                   4 6};
    Cdt_ROI_rhs = { ...
                   1 3
                   1 5
                   3 5};

    Data_ROI.ContSensModContra.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.ContSensModContra.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs, 1));

    Data_ROI.ContSensModContra.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));
    Data_ROI.ContSensModContra.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs, 1));

    for iCdt = 1:size(Cdt_ROI_lhs, 1)

      SensMod1_L = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs{iCdt, 1}, :);
      SensMod1_R = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs{iCdt, 1}, :);
      SensMod1 = [SensMod1_L SensMod1_R];
      SensMod1 = reshape(SensMod1, ...
                         [size(SensMod1, 1), numel(SensMod1) / (NbLayers * size(SensMod1, 1)), NbLayers]);

      SensMod2_L = Data{iROI, 1}(conditionVec == Cdt_ROI_lhs{iCdt, 2}, :);
      SensMod2_R = Data{iROI, 2}(conditionVec == Cdt_ROI_rhs{iCdt, 2}, :);
      SensMod2 = [SensMod2_L SensMod2_R];
      SensMod2 = reshape(SensMod2, ...
                         [size(SensMod2, 1), numel(SensMod2) / (NbLayers * size(SensMod2, 1)), NbLayers]);

      tmp = SensMod1 - SensMod2;

      Data_ROI.ContSensModContra.WholeROI.MEAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmean(tmp, 3), 2));
      Data_ROI.ContSensModContra.WholeROI.MEDIAN(1:size(tmp, 1), iCdt) = squeeze(nanmean(nanmedian(tmp, 3), 2));

      Data_ROI.ContSensModContra.LayerMean(:, 1:size(tmp, 1), iCdt) = squeeze(nanmean(tmp, 2))';
      Data_ROI.ContSensModContra.LayerMedian(:, 1:size(tmp, 1), iCdt) = squeeze(nanmedian(tmp, 2))';

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

    Data_ROI.Contra.MEAN;

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

    save(fullfile(Results_dir, strcat('Data_Pooled_Surf_Wht_Betas', ROI(iROI).name, ...
                                      '_l-', num2str(NbLayers), '.mat')), 'Data_ROI');

  end
end
