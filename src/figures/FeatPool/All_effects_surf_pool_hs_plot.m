function All_effects_surf_pool_hs_plot
  clc;
  clear;

  if isunix
    CodeDir = '/home/remi/github/AVT_analysis';
    StartDir = '/home/remi';
  elseif ispc
    CodeDir = 'D:\github\AVT-7T-code';
    StartDir = 'D:\';
  else
    disp('Platform not supported');
  end

  addpath(genpath(fullfile(CodeDir, 'subfun')));

  [Dirs] = set_dir();

  Get_dependencies();

  SubLs = dir(fullfile(Dirs.DerDir, 'sub*'));
  NbSub = numel(SubLs);

  NbLayers = 6;

  NbROI = 7;

  ROI_order_BOLD = [1 NbROI 2:NbROI - 1];
  ROI_order_MVPA = [NbROI - 1 NbROI 1:NbROI - 2];

  opt.MVNN = 0;

  opt.svm.log2c = 1;
  opt.svm.dargs = '-s 0';
  opt.fs.do = 0;
  opt.rfe.do = 0;
  opt.permutation.test = 0;
  opt.session.curve = 0;
  opt.session.loro = 0;
  opt.scaling.idpdt = 1;

  opt.scaling.img.eucledian = 0;
  opt.scaling.img.zscore = 1;
  opt.scaling.feat.mean = 1;
  opt.scaling.feat.range = 0;
  opt.scaling.feat.sessmean = 0;

  SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);

  SubSVM = [1:3; 4:6; 7:9];

  for WithPerm = 1

    [ToPermute] = list_permutation(WithPerm, NbSub);

    %% Plot Stim and targets alone
    for IsStim = [1 0]

      close all;

      for iROI = 1:NbROI

        clear ToPlot;

        %% Get BOLD data
        ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');

        if IsStim
          Stim_prefix = 'Stimuli-'; %#ok<*NASGU>
          load(fullfile(ResultsDir, strcat('ResultsSurfPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
        else
          Stim_prefix = 'Target-';
          load(fullfile(ResultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
        end

        ToPlot.Name = [Stim_prefix AllSubjects_Data(ROI_order_BOLD(iROI)).name];

        % Get contra-ipsi data
        ToPlot.profile.MEAN(:, :, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).Contra_VS_Ipsi.MEAN; %#ok<*SAGROW>
        ToPlot.profile.SEM(:, :, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).Contra_VS_Ipsi.SEM;
        ToPlot.ROI.grp(:, :, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).Contra_VS_Ipsi.whole_roi_grp;
        % Do not plot quadratic
        % 1rst dimension: subject
        % 2nd dimension: Cst, Lin
        % 3rd dimension : different conditions (e.g A, V, T)
        % 4th dimension : BOLD, MVPA
        ToPlot.profile.beta(:, :, :, 1) = shiftdim(AllSubjects_Data(ROI_order_BOLD(iROI)).Contra_VS_Ipsi.Beta.DATA(1:2, :, :), 2);

        % Contrast between sensory modalities Ispi
        ToPlot.profile.MEAN(:, end + 1:end + 3, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModIpsi.MEAN; %#ok<*SAGROW>
        ToPlot.profile.SEM(:, end + 1:end + 3, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModIpsi.SEM;
        ToPlot.ROI.grp(:, end + 1:end + 3, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModIpsi.whole_roi_grp;
        ToPlot.profile.beta(:, :, end + 1:end + 3, 1) = shiftdim(AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModIpsi.Beta.DATA(1:2, :, :), 2);

        % Contrast between sensory modalities Contra
        ToPlot.profile.MEAN(:, end + 1:end + 3, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModContra.MEAN; %#ok<*SAGROW>
        ToPlot.profile.SEM(:, end + 1:end + 3, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModContra.SEM;
        ToPlot.ROI.grp(:, end + 1:end + 3, 1) = AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModContra.whole_roi_grp;
        ToPlot.profile.beta(:, :, end + 1:end + 3, 1) = shiftdim(AllSubjects_Data(ROI_order_BOLD(iROI)).ContSensModContra.Beta.DATA(1:2, :, :), 2);

        %% Get MVPA data
        ResultsDir = fullfile(StartDir, 'results', 'SVM');

        if IsStim
          Stim_prefix = 'Stimuli-';
          File2Load = fullfile(ResultsDir, strcat('GrpPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
        else
          Stim_prefix = 'Target-';
          File2Load = fullfile(ResultsDir, strcat('GrpTargetsPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
        end

        if exist(File2Load, 'file')
          load(File2Load, 'SVM', 'opt');
        else
          warning('This file %s does not exist', File2Load);
        end

        for iSubSVM = 1:size(SubSVM, 1)

          for iSVM = SubSVM(iSubSVM, :)
            ToPlot.profile.MEAN(:, iSVM, 2) = flipud(SVM(iSVM).ROI(ROI_order_MVPA(iROI)).layers.MEAN(1:end)');
            ToPlot.profile.SEM(:, iSVM, 2) = flipud(SVM(iSVM).ROI(ROI_order_MVPA(iROI)).layers.SEM(1:end)');

            ToPlot.ROI.grp(:, iSVM, 2) = SVM(iSVM).ROI(ROI_order_MVPA(iROI)).grp;

            ToPlot.profile.beta(:, :, iSVM, 2) = SVM(iSVM).ROI(ROI_order_MVPA(iROI)).layers.Beta.DATA(1:2, :)';
          end

        end

        %% Plot
        ToPlot.Titles = { [Stim_prefix 'BOLD'], [Stim_prefix 'MVPA']};
        ToPlot.Visible = 'on';
        ToPlot.FigureFolder = FigureFolder;
        ToPlot.ToPermute = ToPermute;
        ToPlot.Legend = { ...
                         'contra-ipsi_{A}', 'contra-ipsi_{V}', 'contra-ipsi_{T}', ...
                         'A-V_{ipsi}', 'A-T_{ipsi}', 'V-T_{ipsi}', ...
                         'A-V_{contra}', 'A-T_{contra}', 'V-T_{contra}'};
        ToPlot.LegendShort = { ...
                              'C-I_{A}', 'C-I_{V}', 'C-I_{T}', ...
                              'A-V_{I}', 'A-T_{I}', 'V-T_{I}', ...
                              'A-V_{C}', 'A-T_{C}', 'V-T_{C}'};

        plot_all_effects(ToPlot);

      end

    end

  end
  cd(StartDir);

end
