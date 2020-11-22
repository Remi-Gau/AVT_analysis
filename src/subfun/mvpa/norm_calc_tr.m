function trdata = norm_calc_tr(trdata, cvmat, tr, opt)

    % Eucledian image normalization
    if opt.scaling.img.eucledian
        trdata = euclidian_normalization(trdata);
    end

    % Image mean centering and normalization (std=1)
    if opt.scaling.img.zscore
        trdata = zscore(trdata, 0, 2);
    end

    % Feature mean centering
    if opt.scaling.feat.mean
        mnval = mean(trdata);
        trdata = mean_centering(trdata, mnval);
    end

    % Feature scaling into [-1 1] range
    if opt.scaling.feat.range
        minval = min(trdata);
        maxval = max(trdata);
        trdata = range_scaling(trdata, maxval, minval);
    end

    % Feature session specific mean centering
    if opt.scaling.feat.sessmean
        sess = cvmat(tr, 2);
        sess_list = unique(sess);
        trdata = fold_mean_centering(trdata, sess_list, sess);
    end

end
