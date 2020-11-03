function  fig_h = plot_PCM_ind(M, G, G_hat, T_ind, D, T_ind_cross, theta_ind, theta_ind_cross, G_pred_ind, G_pred_ind_CV, RDMs_CV, opt)

  COLOR_Subject = [
                   31, 120, 180
                   178, 223, 138
                   51, 160, 44
                   251, 154, 153
                   227, 26, 28
                   253, 191, 111
                   255, 127, 0
                   202, 178, 214
                   106, 61, 154
                   0, 0, 130];
  COLOR_Subject = COLOR_Subject / 255;

  ColorMap = brain_colour_maps('hot_increasing');

  c = pcm_indicatorMatrix('allpairs', 1:size(M{1}.Ac, 1));

  fontsize = 6;

  NbSub = numel(T_ind.SN);

  % H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
  H = 1;

  tmp = H * mean(G_hat, 3) * H';
  MIN = min(tmp(:));
  MAX = max(tmp(:));

  %% Plot likelihood of each subject with his empirical and predicted G matrices
  for iSub = 1:NbSub

    fig_h(iSub) = figure('name', [opt.SubLs(iSub).name '-' opt.FigName], 'Position', opt.FigDim, 'Color', [1 1 1]);

    Subplot = numel(M) * 2 + 1;
    % G_{emp}
    subplot(6, numel(M), Subplot:Subplot + 1);
    colormap(ColorMap);
    imagesc(H * G_hat(:, :, iSub) * H');

    set(gca, 'xtick', [], 'ytick', []);
    box off;
    axis square;
    t = xlabel('G_{emp}');
    set(t, 'fontsize', 8);
    t = ylabel('CV');
    set(t, 'fontsize', 12);
    Subplot = Subplot + 2;

    % CVed G_{pred} free model
    subplot(6, numel(M), Subplot:Subplot + 1);
    colormap(ColorMap);
    imagesc(H * mean(G_pred_ind_CV{end}, 3) * H');
    set(gca, 'xtick', [], 'ytick', []);
    box off;
    axis square;
    t = xlabel('G_{pred} free');
    set(t, 'fontsize', 8);
    Subplot = Subplot + 2;

    % plot the CVed G_{pred} of each model
    for iM = 2:numel(M) - 1
      subplot(6, numel(M), Subplot:Subplot + 1);

      colormap(ColorMap);
      imagesc(H * mean(G_pred_ind_CV{iM}, 3) * H');
      box off;
      axis square;
      set(gca, 'xtick', [], 'ytick', []);
      t = xlabel(['G_{pred} ' num2str(M{iM}.name)]);
      set(t, 'fontsize', 9);

      Subplot = Subplot + 2;
    end

    Subplot = numel(M) * 4 + 1;
    % RDM or MDS or non CV G
    subplot(6, numel(M), Subplot:Subplot + 1);

    colormap(ColorMap);
    imagesc(H * G(:, :, iSub) * H');
    set(gca, 'tickdir', 'out', 'xtick', [], 'ytick', []);
    box off;
    axis square;
    t = xlabel('G_{emp}');
    set(t, 'fontsize', 8);
    t = ylabel('No CV');
    set(t, 'fontsize', 12);
    Subplot = Subplot + 2;

    % G_{pred} free model
    subplot(6, numel(M), Subplot:Subplot + 1);
    colormap(ColorMap);
    imagesc(H * G_pred_ind{end}(:, :, iSub) * H');
    set(gca, 'xtick', [], 'ytick', []);
    box off;
    axis square;
    t = xlabel('G_{pred} free');
    set(t, 'fontsize', 8);
    Subplot = Subplot + 2;

    % plot the G_{pred} of each model
    for iM = 2:numel(M) - 1
      subplot(6, numel(M), Subplot:Subplot + 1);

      colormap(ColorMap);
      imagesc(H * G_pred_ind{iM}(:, :, iSub) * H');
      set(gca, 'xtick', [], 'ytick', []);
      box off;
      axis square;

      t = xlabel(['G_{pred} ' num2str(M{iM}.name)]);
      set(t, 'fontsize', 9);

      Subplot = Subplot + 2;

      labels{iM - 1} = M{iM}.name;
    end

    % Provide a plot of the crossvalidated likelihoods
    for i = 1:3

      if i == 1
        Data2Plot = T_ind;
        SubPlotRange = [1:floor(numel(M) / 3) (numel(M) + 1):(numel(M) + (floor(numel(M) / 3)))];
        Title = 'NoCV';
        Upperceil = Data2Plot.likelihood(iSub, end);
      elseif i == 2
        Data2Plot = D;
        SubPlotRange = [floor(numel(M) / 3 + 1):2 * floor(numel(M) / 3) numel(M) + (floor(numel(M) / 3 + 1):2 * floor(numel(M) / 3))];
        Title = 'CV';
        Upperceil = T_ind.likelihood(iSub, end);
      elseif i == 3 %
        Data2Plot = T_ind;
        SubPlotRange = [2 * floor(numel(M) / 3 + 1):3 * floor(numel(M) / 3) numel(M) + (2 * floor(numel(M) / 3 + 1):3 * floor(numel(M) / 3))];
        Title = 'AIC: ln(L_{NoCV})-k';
        for iM = 1:size(Data2Plot.likelihood, 2)
          Data2Plot.likelihood(iSub, iM) = ...
              -1 * ((M{iM}.numGparams + 2) - Data2Plot.likelihood(iSub, iM)); % -AIC/2
        end
        Upperceil = T_ind.likelihood(iSub, end);
      end

      subplot(6, numel(M), SubPlotRange);
      hold on;

      T = pcm_plotModelLikelihood(Data2Plot, M, 'upperceil', Upperceil, 'colors', opt.colors, ...
                                  'normalize', 0, 'subj', iSub);

      set(gca, 'XTick', 1:numel(M) - 2);
      set(gca, 'XTickLabel', labels);

      if i > 1
        ylabel('');
        set(gca, 'yaxislocation', 'right');
      end

      MIN = min(T.likelihood_norm);
      MAX = max(T.likelihood_norm);
      %         MAX = max([MAX Upperceil*-1]);

      ax = axis;
      if MIN > 0
        MIN = 0;
      end

      axis([ax(1) ax(2) MIN MAX]);

      title(Title);
    end

    mtit(fig_h(iSub).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

  end

  %% Plot empirical and predicted G matrices with CV and not and with centering and not
  fig_h(end + 1) = figure('name', ['G_{pred-free}&G_{emp}--' opt.FigName], 'Position', opt.FigDim, 'Color', [1 1 1]);

  Subplot = 1;

  for iSub = 1:NbSub

    for Centering = 0:1

      if ~Centering
        H = 1;
      else
        H = eye(size(M{1}.Ac, 1)) - ones(size(M{1}.Ac, 1)) / size(M{1}.Ac, 1);
      end

      % non CV G_emp
      subplot(NbSub, 8, Subplot);

      colormap(ColorMap);
      imagesc(H * G(:, :, iSub) * H');
      box off;
      axis on;
      axis square;
      set(gca, 'xtick', [], 'ytick', []);

      if iSub == 1
        t = title('G_{emp}');
        set(t, 'fontsize', 6);
      end

      if Centering == 0
        t = ylabel(opt.SubLs(iSub).name);
        set(t, 'fontsize', 6);
      end

      Subplot = Subplot + 1;

      % CV G_emp
      subplot(NbSub, 8, Subplot);
      colormap(ColorMap);
      imagesc(H * G_hat(:, :, iSub) * H');
      box off;
      axis on;
      axis square;
      set(gca, 'xtick', [], 'ytick', []);

      if iSub == 1
        t = title('G_{emp}-CV');
        set(t, 'fontsize', 6);
      end

      Subplot = Subplot + 1;

      % G_{pred} free model
      subplot(NbSub, 8, Subplot);
      colormap(ColorMap);
      imagesc(H * G_pred_ind{end}(:, :, iSub) * H');
      box off;
      axis on;
      axis square;
      set(gca, 'xtick', [], 'ytick', []);

      if iSub == 1
        t = title('free G_{pred}');
        set(t, 'fontsize', 6);
      end

      Subplot = Subplot + 1;

      % G_{pred} free model
      subplot(NbSub, 8, Subplot);
      colormap(ColorMap);
      imagesc(H * G_pred_ind_CV{end}(:, :, iSub) * H');
      box off;
      axis on;
      axis square;
      set(gca, 'xtick', [], 'ytick', []);

      if iSub == 1
        t = title('free G_{pred}-CV');
        set(t, 'fontsize', 6);
      end

      Subplot = Subplot + 1;

    end

  end

  mtit(fig_h(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

  %% Plot likelihood as a group
  fig_h = figure('name', opt.FigName, 'Position', opt.FigDim, 'Color', [1 1 1]);

  subplot(121);

  T = pcm_plotModelLikelihood(T_ind, M, 'upperceil', T_ind.likelihood(:, end), 'colors', opt.colors, ...
                              'normalize', 0);

  set(gca, 'fontsize', 6);

  plot_pcm_subjects(M, T, opt, mean(T_ind.likelihood(:, end) - T_ind.likelihood(:, 1)));

  title('no CV');

  subplot(122);

  T = pcm_plotModelLikelihood(D, M, 'upperceil', T_ind.likelihood(:, end), 'colors', opt.colors, ...
                              'normalize', 0);
  set(gca, 'fontsize', 6);

  plot_pcm_subjects(M, T, opt, mean(T_ind.likelihood(:, end) - T_ind.likelihood(:, 1)));

  title('CV');

  mtit(strrep(opt.FigName, '_', ' '), 'fontsize', 12, 'xoff', 0, 'yoff', .035);

  for iM = 2:numel(M) - 1

    %% Plot RDM estimated from G_{emp} and results from the RSA toolbox

    if iM == 2

      [nVerPan, nHorPan] = rsa.fig.paneling(NbSub);

      for i = 1:2

        if i == 1
          Rank_trans = 'ranktrans-';
        else
          Rank_trans = 'raw-';
        end

        fig_h(end + 1) = figure('name', ['RDM_{PCM}-' Rank_trans  opt.FigName], 'Position', opt.FigDim, 'Color', [1 1 1]);

        iSubplot = 1;
        for iSub = 1:NbSub
          subplot(nVerPan, nHorPan, iSubplot);
          RDM = squareform(diag(c * G_hat(:, :, iSub) * c'));
          if i == 1
            RDM = rsa.util.rankTransform_equalsStayEqual(RDM, 1);
          end
          imagesc(RDM);
          colorbar;
          iSubplot = SetAxis(iSubplot, ColorMap);
          t = title(opt.SubLs(iSub).name);
          set(t, 'fontsize', fontsize + 2);
        end
        mtit(fig_h(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

        fig_h(end + 1) = figure('name', ['RDM_{RSA}-' Rank_trans opt.FigName], 'Position', opt.FigDim, 'Color', [1 1 1]);

        iSubplot = 1;
        for iSub = 1:NbSub
          subplot(nVerPan, nHorPan, iSubplot);
          RDM = RDMs_CV(:, :, iSub);
          if i == 1
            RDM = rsa.util.rankTransform_equalsStayEqual(RDM, 1);
          end
          imagesc(RDM);
          colorbar;
          iSubplot = SetAxis(iSubplot, ColorMap);
          t = title(opt.SubLs(iSub).name);
          set(t, 'fontsize', fontsize + 2);
        end

        mtit(fig_h(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

      end
    end

    %% Plot RDM estimated from G_{pred}
    [nVerPan, nHorPan] = rsa.fig.paneling(NbSub);

    NbSub = numel(T.SN);

    fig_h(end + 1) = figure('name', ['RDMs_{pred}-Model-' M{iM}.name  '--'  opt.FigName], 'Position', opt.FigDim, 'Color', [1 1 1]);

    iSubplot = 1;
    for iSub = 1:NbSub
      subplot(nVerPan, nHorPan, iSubplot);
      RDM = squareform(diag(c * G_pred_ind{iM}(:, :, iSub) * c'));
      RDM = rsa.util.rankTransform_equalsStayEqual(RDM, 1);
      imagesc(RDM);
      iSubplot = SetAxis(iSubplot, ColorMap);
      t = title(opt.SubLs(iSub).name);
      set(t, 'fontsize', fontsize + 2);
    end
    mtit(fig_h(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

    %% Plot theta estimates and each subject's empirical G matrix, as well as the predicted one and the free model one
    H = 1;
    % H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);

    fig_h(end + 1) = figure('name', ['Model-' M{iM}.name  '--'  opt.FigName], 'Position', opt.FigDim, 'Color', [1 1 1]);

    Val2Plot = 1:M{iM}.numGparams;
    MEAN = mean(theta_ind{iM}(Val2Plot, :), 2);
    SEM = nansem(theta_ind{iM}(Val2Plot, :), 2);

    subplot(NbSub, 6, repmat([1:3], NbSub, 1) + repmat(6 * (0:NbSub - 1)', 1, 3));
    hold on;
    t = errorbar(Val2Plot - .1, MEAN, SEM, ' .k');
    set(t, 'MarkerSize', 10);

    for iVal = Val2Plot
      for iSub = 1:NbSub
        plot(iVal + .1 + opt.scatter(iSub), theta_ind{iM}(iVal, iSub), 'linestyle', 'none', ...
             'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(iSub, :), ...
             'MarkerFaceColor', COLOR_Subject(iSub, :), 'MarkerSize', 28);
      end
    end

    plot([0.5 M{iM}.numGparams + .5], [0 0], '-- k');

    axis tight;
    grid on;
    set(gca, 'Xtick', 1:M{iM}.numGparams, 'Xticklabel', 1:M{iM}.numGparams);

    xlabel('Features');
    title('theta estimages (No CV)');

    iSubplot = 4;
    for iSub = 1:NbSub

      subplot(NbSub, 6, iSubplot);
      imagesc(H * G_hat(:, :, iSub) * H');
      iSubplot = SetAxis(iSubplot, ColorMap);
      if iSub == 1
        t = title('G_{emp}');
        set(t, 'fontsize', fontsize + 2);
      end
      t = ylabel(opt.SubLs(iSub).name);
      set(t, 'fontsize', fontsize);

      subplot(NbSub, 6, iSubplot);
      imagesc(H * G_pred_ind_CV{iM}(:, :, iSub) * H');
      iSubplot = SetAxis(iSubplot, ColorMap);
      if iSub == 1
        t = title('G_{pred} CV');
        set(t, 'fontsize', fontsize + 2);
      end

      subplot(NbSub, 6, iSubplot);
      %         RDM = squareform(diag(c*G_pred_ind{iM}(:,:,iSub)*c'));
      %         RDM = rsa.util.rankTransform_equalsStayEqual(RDM,1);
      %         imagesc(RDM)
      imagesc(H * G_pred_ind_CV{end}(:, :, iSub) * H');
      iSubplot = SetAxis(iSubplot, ColorMap);
      if iSub == 1
        %             t=title('RDM_{pred}');
        t = title('G_{free CV}');
        set(t, 'fontsize', fontsize + 2);
      end

      iSubplot = iSubplot + 3;
    end

    mtit(fig_h(end).Name, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

  end

end

function plot_pcm_subjects(M, T, opt, upperceil)

  hold on;

  COLOR_Subject = [
                   31, 120, 180
                   178, 223, 138
                   51, 160, 44
                   251, 154, 153
                   227, 26, 28
                   253, 191, 111
                   255, 127, 0
                   202, 178, 214
                   106, 61, 154
                   0, 0, 130];
  COLOR_Subject = COLOR_Subject / 255;

  for iM = 2:numel(M) - 1
    %     h = plotSpread(T.likelihood_norm(:,iM), 'distributionIdx', ones(size(T.likelihood_norm(:,iM))), ...
    %         'distributionMarkers',{'o'},'distributionColors',{'w'}, ...
    %         'xValues', iM-0.8, 'binWidth', 1, 'spreadWidth', .2);
    %     set(h{1}, 'MarkerSize', 5, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
    labels{iM - 1} = M{iM}.name;

    for iSubj = 1:numel(T.SN)
      plot(iM - 0.8 + opt.scatter(iSubj), T.likelihood_norm(iSubj, iM), 'linestyle', 'none', ...
           'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(iSubj, :), ...
           'MarkerFaceColor', COLOR_Subject(iSubj, :), 'MarkerSize', 28);
    end

  end

  MIN = min(min(T.likelihood_norm(:, 2:end - 1)));
  MAX = max(max(T.likelihood_norm(:, 2:end - 1)));
  MAX = max([MAX upperceil]);

  ax = axis;
  if MIN > 0
    MIN = 0;
  end

  axis([ax(1) ax(2) MIN MAX]);

  set(gca, 'XTick', 1:numel(M) - 2);
  set(gca, 'XTickLabel', labels);
  set(gca, 'fontsize', 8);

end

function SubPlot = SetAxis(SubPlot, ColorMap)
  axis square;
  set(gca, 'Xtick', [], 'Ytick', []);
  colormap(ColorMap);
  % colorbar
  SubPlot = SubPlot + 1;
end
