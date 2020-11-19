function PlotLayersForFig(DATA)

  if nargin < 1
    error('No data to plot');
    return  %#ok<UNRCH>
  end

  Fontsize = 12;

  Transparent = 1;

  % Color for Subjects
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

  %%

  Name = strrep(DATA.Name, ' ', '_');
  Name = strrep(Name, '_', '-');
  Visible = DATA.Visible;

  Mean = DATA.Data.MEAN;
  ErrorBar = DATA.Data.SEM;

  NbLayers = size(Mean, 1);
  NbCdts = size(Mean, 2);

  switch NbCdts
    case 9
      m = 3;
      n = 3;
    case 6
      m = 9;
      n = 2;
      SubplotGroup = [ ...
                      1 3; 2 4
                      7 9; 8 10
                      13 15; 14 16];
    case 3
      m = 3;
      n = 3;
      SubplotGroup = [ ...
                      1 4
                      2 5
                      3 6];
  end
  SubPlotOrder = DATA.SubPlotOrder;
  Legend = DATA.Legend;

  if DATA.PlotSub
    Subjects = DATA.Data.grp;
    NbSubjects = size(Subjects, 3);
  end

  if DATA.MVPA
    Beta = DATA.Data.Beta;
    Marker = 'x';
    MarkerSize = 8;
    LineStyle = '--';
  else
    Beta = DATA.Data.Beta.DATA;
    Marker = '.';
    MarkerSize = 25;
    LineStyle = '-';
  end

  ToPermute = DATA.ToPermute;
  if isempty(ToPermute)
    suffix = '_ttest';
  else
    suffix = '_perm';
  end

  % WithQuad = DATA.WithQuad;
  % Scatter = linspace(0,.4,NbSubjects);

  if DATA.PlotSub
    MAX = max(Subjects(:));
    MIN = min(Subjects(:));
  else
    MAX = max(Mean(:) + ErrorBar(:));
    MIN = min(Mean(:) + ErrorBar(:));
  end

  switch NbCdts
    case 3
      XYs = [ ...
             0.13 0.14; ...
             0.41 0.14; ...
             0.69 0.14 ...
            ];
    case 6
      XYs = [ ...
             0.13 0.65; ...
             0.57 0.65; ...
             0.13 0.37; ...
             0.57 0.37; ...
             0.13 0.09; ...
             0.57 0.09 ...
            ];
    case 9
      XYs = [ ...
             0.18 0.71; ...
             0.465 0.71; ...
             0.74 0.71; ...
             0.18 0.61; ...
             0.465 0.61; ...
             0.74 0.61; ...
             0.18 0.145; ...
             0.465 0.145; ...
             0.74 0.145 ...
            ];
  end

  %%
  fig = figure('Name', Name, 'Position', [100, 100, 1500, 600], 'Color', [1 1 1], 'Visible', Visible);

  box off;

  set(gca, 'units', 'centimeters');
  pos = get(gca, 'Position');
  ti = get(gca, 'TightInset');

  set(fig, 'PaperUnits', 'centimeters');
  set(fig, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
  set(fig, 'PaperPositionMode', 'manual');
  set(fig, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

  set(fig, 'Visible', Visible);

  for iCdt = 1:NbCdts
    %% Plot main data
    subplot(m, n, SubplotGroup(iCdt, :));
    PlotRectangle(NbLayers, Fontsize);
    subplot(m, n, SubplotGroup(iCdt, :));

    hold on;
    grid on;

    shadedErrorBar(1:NbLayers, Mean(:, SubPlotOrder(iCdt)), ErrorBar(:, SubPlotOrder(iCdt)), ...
                   {'Marker', Marker, 'MarkerSize', MarkerSize, 'LineStyle', LineStyle, 'LineWidth', 3, 'Color', 'k'}, Transparent);
    for SubjInd = 1:NbSubjects
      %         plot(1:NbLayers, Subjects(:,SubPlotOrder(iCdt),SubjInd), '-', ...
      %             'LineWidth', 1, 'Color', COLOR_Subject(SubjInd,:));
      plot(1:NbLayers, Subjects(:, SubPlotOrder(iCdt), SubjInd), '-', ...
           'LineWidth', 1, 'Color', [.7 .7 .7]);
    end
    shadedErrorBar(1:NbLayers, Mean(:, SubPlotOrder(iCdt)), ErrorBar(:, SubPlotOrder(iCdt)), ...
                   {'Marker', Marker, 'MarkerSize', MarkerSize, 'LineStyle', LineStyle, 'LineWidth', 3, 'Color', 'k'}, Transparent);

    if DATA.MVPA
      plot([1 NbLayers], [0.5 0.5], '--k', 'LineWidth', 1.5);
    else
      plot([1 NbLayers], [0 0], '--k', 'LineWidth', 1.5);
    end

    set(gca, 'tickdir', 'out', 'xtick', 1:NbLayers, ...
        'xticklabel', ' ', 'ticklength', [0.01 0.01], ...
        'xgrid', 'off', 'fontsize', Fontsize);

    t = ylabel(Legend{SubPlotOrder(iCdt)}{1});
    set(t, 'fontsize', Fontsize + 2);

    t = title(Legend{SubPlotOrder(iCdt)}{2});
    set(t, 'fontsize', Fontsize);

    axis tight;
    tmp = axis;
    axis([0.5 NbLayers + .5 tmp(3) tmp(4)]);
    %     axis([0.5 NbLayers+.5 MIN MAX])

    if DATA.PlotBeta

      %% Inset with betas
      tmp = squeeze(Beta(:, SubPlotOrder(iCdt), :));

      if ~DATA.MVPA
        tmp(2, :) = tmp(2, :) * -1;
      end

      if ~isempty(ToPermute)
        for iPerm = 1:size(ToPermute, 1)
          tmp2 = ToPermute(iPerm, :);
          Perms(:, iPerm) = mean(tmp .* repmat(tmp2, size(tmp, 1), 1), 2); %#ok<*SAGROW>
        end
      end

      BetaMax = max(max(abs(Beta), [], 3), [], 2);

      for i = 1:size(tmp, 1)

        Lim = round(BetaMax(i) + .1 * BetaMax(i), 2);

        switch NbCdts
          case 6
            XY = XYs(iCdt, :);
            axes('Position', [XY(1) + 0.13 * (i - 1) XY(2) .075 .05]);
          case 3
            XY = XYs(iCdt, :);
            axes('Position', [XY(1) + 0.09 * (i - 1) XY(2) .05 .2]);
        end

        box off;
        hold on;

        if isfield(DATA, 'OneSideTTest')

          if ~isempty(ToPermute)

            if strcmp(DATA.OneSideTTest{i}, 'left')
              P(i) = sum(Perms(i, :) < mean(tmp(i, :))) / numel(Perms(i, :));
            elseif strcmp(DATA.OneSideTTest{i}, 'right')
              P(i) = sum(Perms(i, :) > mean(tmp(i, :))) / numel(Perms(i, :));
            elseif strcmp(DATA.OneSideTTest{i}, 'both')
              P(i) = sum(abs(Perms(i, :) - mean(Perms(i, :))) > abs(mean(tmp(i, :)) - mean(Perms(i, :)))) / numel(Perms(i, :));
            end

          else

            [~, P(i)] = ttest(tmp(i, :), 0, 'alpha', 0.05, 'tail', DATA.OneSideTTest{i});

          end

        else

          if ~isempty(ToPermute)
            P(i) = sum(abs(Perms(i, :) - mean(Perms(i, :))) > abs(mean(tmp(i, :)) - mean(Perms(i, :)))) / numel(Perms(i, :));
          else
            [~, P(i)] = ttest(tmp(i, :), 0, 'alpha', 0.05);
          end

        end

        distributionPlot({tmp(i, :)}, 'xValues', 1.3, 'color', [0.8 0.8 0.8], ...
                         'distWidth', 0.4, 'showMM', 0, ...
                         'globalNorm', 2);

        h = plotSpread(tmp(i, :), 'distributionIdx', ones(size(tmp(i, :))), ...
                       'distributionMarkers', {'o'}, 'distributionColors', {'w'}, ...
                       'xValues', 1.3, 'binWidth', .05, 'spreadWidth', 1.5);
        set(h{1}, 'MarkerSize', 5, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1);

        plot([0 1.55], [0 0], ':k', 'LineWidth', .5);

        errorbar(1, nanmean(tmp(i, :), 2), nansem(tmp(i, :), 2), '.k');

        Sig = []; %#ok<NASGU>
        if P(i) < 0.001
          %             Sig = sprintf('ES=%.2f \np<0.001 ',...
          %                 abs(nanmean(tmp(i,:))/nanstd(tmp(i,:))));
          Sig = sprintf('p<0.001 ');
        else
          %             Sig = sprintf('ES=%.2f \np=%.3f ',...
          %                 abs(nanmean(tmp(i,:))/nanstd(tmp(i,:))), P(i));
          Sig = sprintf('p=%.3f ', P(i));
        end

        t = text(1.15, Lim * -1 + Lim * .1, sprintf(Sig));
        set(t, 'fontsize', Fontsize - 4.5);

        if P(i) < 0.05
          set(t, 'color', 'r');
        end

        clear Sig;

        switch i
          case 1
            xTickLabel = 'C';
          case 2
            xTickLabel = 'L';
          case 3
            xTickLabel = 'Q';
        end

        set(gca, 'tickdir', 'in', 'xtick', 1.3, 'xticklabel', xTickLabel, ...
            'ytick', linspace(Lim * -1, Lim, 5), 'yticklabel', linspace(Lim * -1, Lim, 5), ...
            'ticklength', [0.03 0.03], 'fontsize', Fontsize - 4);
        if i == 1
          t = ylabel('Param. est. [a u]');
          set(t, 'fontsize', Fontsize - 3);
        end

        axis([0.9 1.8 Lim * -1 Lim]);

      end
    end

  end

  mtit(sprintf(Name), 'xoff', 0, 'yoff', +0.03, 'fontsize', 12);
  set(fig, 'Visible', Visible);

  % print(fig, fullfile(DATA.FigureFolder, strcat(strrep(Name,'\n','-'), '_', num2str(NbLayers), 'Layers', suffix, '.pdf')), '-dpdf')
  print(fig, fullfile(DATA.FigureFolder, strcat(strrep(Name, '\n', '-'), '_', num2str(NbLayers), 'Layers', suffix, '.tif')), '-dtiff');

end
