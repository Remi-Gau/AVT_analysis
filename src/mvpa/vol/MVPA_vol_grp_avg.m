function MVPA_vol_grp_avg
  % averages MVPA results in volume

  % TODO
  % - fix because this is broken: need to run MVPA in vol to generate input
  % for this

  clc;
  clear;

  [Dirs] = set_dir('vol');
  [SubLs, NbSub] = get_subject_list(Dirs.MVPA_resultsDir);

  NbLayers = 6;

  FWHM = 0;

  % Options for the SVM
  [opt, ~] = get_mvpa_options();
  norm_to_use = 6;
  [opt] = ChooseNorm(norm_to_use, opt);
  disp(opt);

  %% REFACTOR

  % ROI
  ROIs(1) = struct('name', 'V1');
  ROIs(end + 1) = struct('name', 'V2');
  ROIs(end + 1) = struct('name', 'V3');
  % ROIs(end+1) = struct('name', 'V4');
  % ROIs(end+1) = struct('name', 'V5');

  ROIs(end + 1) = struct('name', 'TE');
  ROIs(end + 1) = struct('name', 'PT');
  % ROIs(end+1) = struct('name', 'TE1.0');
  % ROIs(end+1) = struct('name', 'TE1.1');
  % ROIs(end+1) = struct('name', 'TE1.2');

  ROIs(end + 1) = struct('name', 'pSTG');

  ROIs(end + 1) = struct('name', 'S1_cyt');
  ROIs(end + 1) = struct('name', 'S1_aal');

  ROIs(end + 1) = struct('name', 'TE_L');
  ROIs(end + 1) = struct('name', 'PT_L');
  ROIs(end + 1) = struct('name', 'pSTG_L');

  ROIs(end + 1) = struct('name', 'S1_L_cyt');
  ROIs(end + 1) = struct('name', 'S1_L_aal');

  ROIs(end + 1) = struct('name', 'V1_L');
  ROIs(end + 1) = struct('name', 'V2_L');
  ROIs(end + 1) = struct('name', 'V3_L');
  % ROIs(end+1) = struct('name', 'V4_L');
  % ROIs(end+1) = struct('name', 'V5_L');

  ROIs(end + 1) = struct('name', 'TE_R');
  ROIs(end + 1) = struct('name', 'PT_L');
  ROIs(end + 1) = struct('name', 'pSTG_R');

  ROIs(end + 1) = struct('name', 'S1_R_cyt');
  ROIs(end + 1) = struct('name', 'S1_R_aal');

  ROIs(end + 1) = struct('name', 'V1_R');
  ROIs(end + 1) = struct('name', 'V2_R');
  ROIs(end + 1) = struct('name', 'V3_R');
  % ROIs(end+1) = struct('name', 'V4_R');
  % ROIs(end+1) = struct('name', 'V5_R');

  %% REFACTOR
  % Analysis
  SVM(1) = struct('name', 'A VS V', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'A VS T', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'V VS T', 'ROI', 1:length(ROIs));

  SVM(end + 1) = struct('name', 'A left VS A right', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'V left VS V right', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'T left VS T right', 'ROI', 1:length(ROIs));

  SVM(end + 1) = struct('name', 'A left VS V left', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'A left VS T left', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'V left VS T left', 'ROI', 1:length(ROIs));

  SVM(end + 1) = struct('name', 'A right VS V right', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'A right VS T right', 'ROI', 1:length(ROIs));
  SVM(end + 1) = struct('name', 'V right VS T right', 'ROI', 1:length(ROIs));

  for i = 1:numel(SVM)
    SVM(i).ROI = struct('name', {ROIs(SVM(i).ROI).name});
  end

  %%

  SaveSufix = CreateSaveSuffix(opt, FWHM, NbLayers, 'vol');

  NbWorkers = 4;
  [KillGcpOnExit] = OpenParWorkersPool(NbWorkers);

  %% Gets data for each subject
  for iSub = 1:NbSub
    fprintf('\n\nProcessing %s', SubLs(iSub).name);

    SubDir = fullfile(Dirs.DerDir, SubLs(iSub).name);
    SaveDir = fullfile(SubDir, 'results', 'SVM');

    for iSVM = 1:numel(SVM)
      fprintf('\n Running SVM:  %s\n', SVM(iSVM).name);

      for iROI = 1:numel(ROIs)

        File2Load = fullfile( ...
                             SaveDir, ...
                             strcat( ...
                                    'SVM-', SVM(iSVM).name, ...
                                    '_ROI-', SVM(iSVM).ROI(iROI).name, ...
                                    SaveSufix));

        SVM(iSVM).ROI(iROI).grp(iSub, 1:NbLayers + 1) = nan(1, NbLayers + 1);
        SVM(iSVM).ROI(iROI).DATA{iSub} = [];

        if ~exist(File2Load, 'file')
          error('The file %s was not found.', File2Load);

        else

          load(File2Load, 'Results', 'Class_Acc');

          SVM(iSVM).ROI(iROI).grp(iSub, 1:NbLayers + 1) = squeeze(Class_Acc.TotAcc(end, :, :, :));

          for iLayer = 2:(NbLayers + 1)

            NbCV = size(Results.session(end).rand(1).perm(1).SubSamp{1, 1}.CV, 1);

            tmp = Results.session(end).rand(1).perm(1).SubSamp{1, 1}.CV;
            TEMP = [];
            parfor iCV = 1:NbCV
              pred = []; %#ok<*NASGU>
              label = [];
              pred = tmp(iCV, iLayer).pred;
              label = tmp(iCV, iLayer).label;
              TEMP(iCV) = mean(pred == label);
            end

            SVM(iSVM).ROI(iROI).DATA{iSub}(iLayer - 1, 1:NbCV) = TEMP;
          end

        end

        clear Results Class_Acc;

      end

    end
  end

  %% Averages over subjects
  for iSVM = 1:numel(SVM)
    for iROI = 1:numel(ROIs)

      SVM(iSVM).ROI(iROI).MEAN = nanmean(SVM(iSVM).ROI(iROI).grp);
      SVM(iSVM).ROI(iROI).STD = nanstd(SVM(iSVM).ROI(iROI).grp);
      SVM(iSVM).ROI(iROI).SEM = nansem(SVM(iSVM).ROI(iROI).grp);

    end
  end

  %% Betas from profile fits
  fprintf('\n\n GETTING BETA VALUES FOR PROFILE FITS');

  DesMat = set_design_mat_lam_GLM(NbLayers);

  for iSVM = 1:numel(SVM)
    fprintf('\n Running SVM:  %s', SVM(iSVM).name);

    for iROI = 1:numel(ROIs)

      %% Actually compute betas
      for iSub = 1:NbSub

        Blocks = SVM(iSVM).ROI(iROI).DATA{iSub};

        SVM(iSVM).ROI(iROI).Beta.DATA(:, iSub) = nan(size(DesMat, 2), 1);
        if ~all(isnan(Blocks(:))) || ~isempty(Blocks)

          Y = flipud(Blocks - .5);
          [B] = ProfileGLM(DesMat, Y);

          SVM(iSVM).ROI(iROI).Beta.DATA(:, iSub) = B;

          clear Y B;
        end

      end

      %% Group stat on betas
      tmp = SVM(iSVM).ROI(iROI).Beta.DATA;
      SVM(iSVM).ROI(iROI).Beta.MEAN = nanmean(tmp, 2);
      SVM(iSVM).ROI(iROI).Beta.Beta.STD = nanstd(tmp, 2);
      SVM(iSVM).ROI(iROI).Beta.Beta.SEM = nansem(tmp, 2);

      % T-Test
      [~, P] = ttest(tmp');
      SVM(iSVM).ROI(iROI).Beta.P = P;

      clear tmp P;

    end
  end

  return

  %% TODO : save in group folder

  %% Saves
  fprintf('\nSaving\n');

  for iSVM = 1:numel(SVM)
    for iROI = 1:numel(ROIs)
      Results = SVM(iSVM).ROI(iROI);
      Filename = fullfile( ...
                          Dirs.MVPA_resultsDir, ...
                          strcat( ...
                                 'Results_', SVM(iSVM).ROI(iROI).name, ...
                                 '_', strrep(SVM(iSVM).name, ' ', '-'), ...
                                 '_VolQuadGLM', SaveSufix));

      fprintf('\n\nSaving file: %s\n', Filename);
      save(Filename, 'Results');
    end
  end

  Filename = fullfile( ...
                      ResultDirs.MVPA_resultsDirs, ...
                      strcat('ResultsVolQuadGLM', SaveSufix));
  fprintf('\n\nSaving file: %s\n', Filename);
  save(Filename);

  CloseParWorkersPool(KillGcpOnExit);

end

function [B] = ProfileGLM(X, Y)

  if any(isnan(Y(:)))
    [~, y] = find(isnan(Y));
    y = unique(y);
    Y(:, y) = [];
    clear y;
  end

  B = nan(1, size(X, 2));
  if ~isempty(Y)
    X = repmat(X, size(Y, 2), 1);
    Y = Y(:);
    [B, ~, ~] = glmfit(X, Y, 'normal', 'constant', 'off');
  end

end
