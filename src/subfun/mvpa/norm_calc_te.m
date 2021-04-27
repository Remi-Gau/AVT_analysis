function tedata = norm_calc_te(trdata_ori, tedata, cvmat, te, opt)
    %
    % (C) Copyright 2020 Remi Gau

    % Eucledian image normalization
    if opt.scaling.img.eucledian
        trdata_ori = euclidian_normalization(trdata_ori);
        tedata = euclidian_normalization(tedata);
    end

    % Image mean centering and normalization (std=1)
    if opt.scaling.img.zscore
        trdata_ori = zscore(trdata_ori, 0, 2);
        tedata = zscore(tedata, 0, 2);
    end

    % Feature mean centering
    if opt.scaling.feat.mean
        mnval = mean(trdata_ori);
        tedata = mean_centering(tedata, mnval);
    end

    % Feature scaling into [-1 1] range
    if opt.scaling.feat.range
        minval = min(trdata_ori);
        maxval = max(trdata_ori);
        tedata = range_scaling(tedata, maxval, minval);
    end

    % Feature session specific mean centering
    if opt.scaling.feat.sessmean
        sess = cvmat(te);
        sess_list = unique(sess);
        tedata = fold_mean_centering(tedata, sess_list, sess);
    end

end
