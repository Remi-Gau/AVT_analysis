function Interactions_profile_surf_pool_hs_plot
  clc;
  clear;

  StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
  cd (StartDir);

  addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
  Get_dependencies('D:\Dropbox/', 'D:\github/');

  ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
  FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf');

  SubLs = dir('sub*');
  NbSub = numel(SubLs);

  NbLayers = 6;

  for WithPerm = 1

    sets = {};
    for iSub = 1:NbSub
      sets{iSub} = [-1 1];
    end
    [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
    ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];

    if ~WithPerm
      ToPermute = [];
    end

    load(fullfile(ResultsDir, strcat('ResultsSurfPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
    Stimuli_data = AllSubjects_Data;

    load(fullfile(ResultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
    Target_data = AllSubjects_Data;

    NbROI = length(Stimuli_data);
    ROI_order = [1 NbROI 2:4]; % [1 NbROI 2:NbROI-1];

    ROI_idx = 1;
    for iROI = ROI_order
      ToPlot.ROIs_name{ROI_idx} = Stimuli_data(iROI).name;
      ROI_idx = ROI_idx + 1;
    end

    %% plot contrast against baseline only
    close all;
    ToPlot.Visible = 'on';
    ToPlot.FigureFolder = FigureFolder;

    f = figure('Name', 'StimVsTargets', 'Position', [50, 50, 1400, 700], 'Color', [1 1 1], 'Visible', ToPlot.Visible);

    set(gca, 'units', 'centimeters');
    pos = get(gca, 'Position');
    ti = get(gca, 'TightInset');

    set(f, 'PaperUnits', 'centimeters');
    set(f, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
    set(f, 'PaperPositionMode', 'manual');
    set(f, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

    set(f, 'Visible', ToPlot.Visible);

    %% Contra
    ToPlot.Legend = {'Audio_{contra}', 'Visual_{contra}', 'Tactile_{contra}'};
    ToPlot.SubplotNumber = 1:3;
    Data_stim = cat(1, Stimuli_data(:).Contra);
    Data_target = cat(1, Target_data(:).Contra);
    ToPlot = GetData(ToPlot, Data_stim, Data_target, ROI_order);
    ToPlot.Xlabel = 1;

    get(f);
    Plot_interaction_XY(ToPlot);

    %% Ipsi
    %     ToPlot.Legend = {'Audio_{ipsi}', 'Visual_{ipsi}','Tactile_{ipsi}'};
    %     ToPlot.SubplotNumber = 4:6;
    %     Data_stim = cat(1,Stimuli_data(:).Ispi);
    %     Data_target = cat(1,Target_data(:).Ispi);
    %     ToPlot = GetData(ToPlot,Data_stim,Data_target,ROI_order);
    %     ToPlot.Xlabel = 1;
    %
    %     get(f)
    %     Plot_interaction_XY(ToPlot)

    mtit('Stim VS targets', 'xoff', 0, 'yoff', +0.05, 'fontsize', 12);
    print(f, fullfile(ToPlot.FigureFolder, 'All_ROIs_stim_VS_targets.tif'), '-dtiff');

    %%
    close all;

    ToPlot.Visible = 'on';
    ToPlot.FigureFolder = FigureFolder;
    ToPlot.ToPermute = ToPermute;

    f = figure('Name', 'Interactions', 'Position', [50, 50, 1400, 700], 'Color', [1 1 1], 'Visible', ToPlot.Visible);

    set(gca, 'units', 'centimeters');
    pos = get(gca, 'Position');
    ti = get(gca, 'TightInset');

    set(f, 'PaperUnits', 'centimeters');
    set(f, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
    set(f, 'PaperPositionMode', 'manual');
    set(f, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

    set(f, 'Visible', ToPlot.Visible);

    %% Contra-Ipsi
    ToPlot.Legend = {'(Contra-Ipsi)_A', '(Contra-Ipsi)_V', '(Contra-Ipsi)_T'};
    ToPlot.SubplotNumber = 1:3;
    Data_stim = cat(1, Stimuli_data(:).Contra_VS_Ipsi);
    Data_target = cat(1, Target_data(:).Contra_VS_Ipsi);
    ToPlot = GetData(ToPlot, Data_stim, Data_target, ROI_order);

    get(f);
    Plot_interaction(ToPlot);
    %     Plot_interaction_XY(ToPlot)

    %% Contrast between sensory modalities Ispi
    ToPlot.Legend = {'(Audio-Visual)_{ipsi}', '(Audio-Tactile)_{ipsi}', '(Visual-Tactile)_{ipsi}'};
    ToPlot.SubplotNumber = 4:6;
    Data_stim = cat(1, Stimuli_data(:).ContSensModIpsi);
    Data_target = cat(1, Target_data(:).ContSensModIpsi);
    ToPlot = GetData(ToPlot, Data_stim, Data_target, ROI_order);

    get(f);
    Plot_interaction(ToPlot);
    %     Plot_interaction_XY(ToPlot)

    %% Contrast between sensory modalities Contra
    ToPlot.Legend = {'(Audio-Visual)_{contra}', '(Audio-Tactile)_{contra}', '(Visual-Tactile)_{contra}'};
    ToPlot.SubplotNumber = 7:9;
    Data_stim = cat(1, Stimuli_data(:).ContSensModContra);
    Data_target = cat(1, Target_data(:).ContSensModContra);
    ToPlot = GetData(ToPlot, Data_stim, Data_target, ROI_order);
    ToPlot.Xlabel = 1;

    get(f);
    Plot_interaction(ToPlot);
    %     Plot_interaction_XY(ToPlot)

    %%
    get(f);
    mtit('Interactions', 'xoff', 0, 'yoff', +0.05, 'fontsize', 12);
    print(f, fullfile(ToPlot.FigureFolder, 'All_ROIs_interactions.tif'), '-dtiff');

  end
  cd(StartDir);

end

function ToPlot = GetData(ToPlot, Data_stim, Data_target, ROI_order)
  ROI_idx = 1;
  for iROI = ROI_order
    ToPlot.ROI.grp(1, :, :, ROI_idx) = Data_stim(iROI).whole_roi_grp;
    ToPlot.ROI.grp(2, :, :, ROI_idx) = Data_target(iROI).whole_roi_grp;
    ROI_idx = ROI_idx + 1;
  end
end

function Plot_interaction(ToPlot)

  Xpos = [1 3 7:2:11];

  Alpha = 0.05;

  for iCdt = 1:size(ToPlot.ROI.grp, 3)

    subplot(3, 3, ToPlot.SubplotNumber(iCdt));
    hold on;

    for iROI = 1:size(ToPlot.ROI.grp, 4)
      A = ToPlot.ROI.grp(:, :, iCdt, iROI);
      % plot each subject
      plot(repmat([Xpos(iROI) - .25; Xpos(iROI) + 0.25], 1, size(A, 2)), A, '.-', ...
           'color', [.6 .6 .6]);
      % plot group mean
      plot([Xpos(iROI) - .25; Xpos(iROI) + 0.25], mean(A, 2), '.-k', ...
           'linewidth', 1.5, 'markersize', 8);
    end

    plot([-20 20], [0 0], '--k');

    set(gca, 'tickdir', 'out', 'xtick', Xpos, 'xticklabel', ToPlot.ROIs_name, ...
        'ticklength', [0.01 0.01], 'fontsize', 10);

    t = title(ToPlot.Legend{iCdt});
    set(t, 'fontsize', 10);

    t = ylabel(sprintf('Param. est. [a u]'));
    set(t, 'fontsize', 10);

    axis tight;
    ax = axis;
    axis([0.5 11.5 ax(3) ax(4) + ax(4) * .25]);

    tmp = squeeze(ToPlot.ROI.grp(1, :, iCdt, :) - ToPlot.ROI.grp(2, :, iCdt, :));

    for iPerm = 1:size(ToPlot.ToPermute, 1)
      tmp2 = ToPlot.ToPermute(iPerm, :);
      tmp2 = repmat(tmp2', 1, size(tmp, 2));
      Perms(iPerm, :) = mean(tmp .* tmp2); %#ok<*SAGROW>
    end

    P = sum( ...
            abs(Perms) > ...
            repmat(abs(mean(tmp)), size(Perms, 1), 1)) ...
        / size(Perms, 1);

    for iP = 1:numel(P)
      Sig = [];
      if P(iP) < 0.001
        Sig = sprintf('p<0.001 ');
      else
        Sig = sprintf('p=%.3f ', P(iP));
      end

      t = text(Xpos(iP) - .25, ax(4) + ax(4) * .2, sprintf(Sig));
      set(t, 'fontsize', 5);

      if P(iP) < Alpha
        set(t, 'color', 'r');
      end
    end

  end

end

function Plot_interaction_XY(ToPlot)

  line_colors = [ ...
                 37, 52, 148; ...
                 65, 182, 196; ...
                 0, 94, 45; ...
                 89, 153, 74; ...
                 110, 188, 111; ...
                 184, 220, 143; ...
                 235, 215, 184 ...
                ] / 255;

  for iCdt = 1:size(ToPlot.ROI.grp, 3)

    subplot(1, 3, ToPlot.SubplotNumber(iCdt));
    hold on;

    for iROI = 1:size(ToPlot.ROI.grp, 4)
      A = ToPlot.ROI.grp(:, :, iCdt, iROI);
      errorbar(mean(A(1, :)), mean(A(2, :)), ...
               nansem(A(2, :)), nansem(A(2, :)), ...
               nansem(A(1, :)), nansem(A(1, :)), ...
               'color', line_colors(iROI, :), 'linewidth', 2);
    end

    axis tight;
    ax = axis;
    if ax(1) > 0
      ax(1) = -0.15;
    end
    if ax(2) < 0
      ax(2) = 0.15;
    end
    if ax(3) > 0
      ax(3) = -0.15;
    end
    if ax(4) < 0
      ax(4) = 0.15;
    end

    plot([-10 10], [-10 10], '--k');
    plot([0 0], [-10 10], '-k');
    plot([-10 10], [0 0], '-k');

    axis(ax * 1.2);

    t = title(ToPlot.Legend{iCdt});
    set(t, 'fontsize', 10);

    if isfield(ToPlot, 'Xlabel')
      if ToPlot.Xlabel
        t = xlabel(sprintf('Stimuli\nParam. est. [a u]'));
        set(t, 'fontsize', 10);
      end
    end

    if iCdt == 1
      t = ylabel(sprintf('Target\nParam. est. [a u]'));
      set(t, 'fontsize', 10);
    end

  end

end
