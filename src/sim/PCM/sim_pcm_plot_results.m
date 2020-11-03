clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox');

FigDim = [100, 100, 1500, 1500];

Save_dir = fullfile(StartDir, 'results', 'sim', 'PCM');
Fig_dir = fullfile(StartDir, 'figures', 'sim', 'PCM');

load(fullfile(Save_dir, sprintf('sim_pcm_models_components_weights.mat')));

plot_subjects = 1;

for iMod = 2:numel(M) - 1

  M{iMod}.name = num2str(iMod - 1); %#ok<*SAGROW>

end

[nVerPan, nHorPan] = rsa.fig.paneling(numel(M) - 2);

for sm = size(Scale_noise, 1)

  %     load(fullfile(Save_dir, sprintf('sim_pcm_output_cv_demean_noise_%i.mat', sm)),'ms_mr');
  load(fullfile(Save_dir, sprintf('sim_pcm_output_cv_demean_noise_%i_with_weird_subjects.mat', sm)), 'ms_mr');
  %
  %     load(fullfile(Save_dir, sprintf('sim_pcm_output_cv_noise_%i.mat', sm)),'ms_mc');
  load(fullfile(Save_dir, sprintf('sim_pcm_output_cv_noise_%i_with_weird_subjects.mat', sm)), 'ms_mc');

  for Mean = 0:1

    if Mean == 0
      mean_suffix = 'mean-corrected';
      tmp = ms_mr;
    else
      mean_suffix = 'mean-present';
      tmp = ms_mc;
    end

    %%
    for iCV = 1

      if iCV == 0
        CV_suffix = 'no ';
      else
        CV_suffix = '';
      end

      figure('name', sprintf('PCM - %sCV - noise=%i - %s', CV_suffix, sm, mean_suffix), ...
             'Position', FigDim, 'Color', [1 1 1]);

      iSubplot = 1;

      for tr = 1:numel(M) - 2

        tmp1 = mat2cell(repmat(Models(tr).Cpts, numel(M) - 2, 1), ones(numel(M) - 2, 1), numel(Models(tr).Cpts));
        tmp1 = cellfun(@ismember, {Models(:).Cpts}', tmp1, 'UniformOutput', 0);
        tmp1 = cellfun(@sum, tmp1);

        colors = repmat('b', numel(M) - 2, 1);
        colors(find(tmp1)) = 'g';
        colors(tr) = 'r';
        colors = cellstr(colors);

        subplot(nVerPan, nHorPan, iSubplot);
        if iCV == 0
          T = pcm_plotModelLikelihood(tmp{tr, sm}.Tgroup, M, 'upperceil', tmp{tr, sm}.Tgroup.likelihood(:, end), 'normalize', 0, ...
                                      'colors', colors, 'style', 'bar', 'varfcn', 'sem');
        else
          T = pcm_plotModelLikelihood(tmp{tr, sm}.Tcross, M, 'upperceil', tmp{tr, sm}.Tgroup.likelihood(:, end), 'normalize', 0, ...
                                      'colors', colors, 'style', 'bar', 'varfcn', 'sem');
        end
        set(gca, 'fontsize', 4);

        t = title(['Model ' num2str(tr)]);
        set(t, 'fontsize', 8);

        if plot_subjects
          binWidth = max(max(T.likelihood_norm(:, 2:end - 1)) - min(T.likelihood_norm(:, 2:end - 1)));

          for iM = 2:numel(M) - 1
            h = plotSpread(T.likelihood_norm(:, iM), 'distributionIdx', ones(size(T.likelihood_norm(:, iM))), ...
                           'distributionMarkers', {'o'}, 'distributionColors', {'w'}, ...
                           'xValues', iM - 1, 'binWidth', binWidth, 'spreadWidth', .6);
            set(h{1}, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1);
            labels{iM - 1} = M{iM}.name;
          end
        end

        ax = axis;
        if plot_subjects
          MIN = min(min(T.likelihood_norm(:, 2:end - 1)));
          MAX = max(max(T.likelihood_norm(:, 2:end - 1)));
        else
          MIN = min(mean(T.likelihood_norm(:, 2:end - 1))); %#ok<*UNRCH>
          MAX = ax(4);
        end

        if MIN < 0
          ax = axis;
          MIN = ceil(abs(MIN));
          axis([ax(1) ax(2) MIN * -1 MAX]);
        end

        if plot_subjects
          set(gca, 'XTick', 1:numel(M) - 2);
          set(gca, 'XTickLabel', labels);
          set(gca, 'fontsize', 4);
        end

        iSubplot = iSubplot + 1;
      end

      mtit(sprintf('PCM - %sCV - noise level=%i - %s', CV_suffix, sm, mean_suffix), 'fontsize', 12, 'xoff', 0, 'yoff', .035);

      print(gcf, fullfile(Fig_dir, sprintf('sim_PCM-%sCV-noise=%i-%s', CV_suffix, sm, mean_suffix)), '-dtiff');

    end

  end

end
