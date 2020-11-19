function data = grp_stats(data, isMVPA)

  NbLayers = 6;
  X = set_design_mat_lam_GLM(NbLayers);

  for iROI = 1:numel(data)

    for isubj = 1:numel(data(iROI).DATA)

      % compute means over runs
      data(iROI).grp(:, :, isubj) = squeeze(nanmean(data(iROI).DATA{isubj}, 2));

      % compute laminar GLM
      Blocks = data(iROI).DATA{isubj};
      if ~all(isnan(Blocks(:))) || ~isempty(Blocks)

        for i_cdt = 1:size(Blocks, 3)
          Y = Blocks(:, :, i_cdt);
          if isMVPA
            Y = Y - .5;
          end
          [B] = laminar_glm(X, Y);
          data(iROI).Beta.DATA(:, i_cdt, isubj) = B;
        end
      end

    end

    % group stats on profiles
    data(iROI).MEAN = nanmean(data(iROI).grp, 3);
    data(iROI).STD = nanstd(data(iROI).grp, 3);
    data(iROI).SEM = nansem(data(iROI).grp, 3);

    % group stats on betas
    data(iROI).Beta.MEAN = nanmean(data(iROI).Beta.DATA, 3);
    data(iROI).Beta.STD = nanstd(data(iROI).Beta.DATA, 3);
    data(iROI).Beta.SEM = nansem(data(iROI).Beta.DATA, 3);

  end

end
