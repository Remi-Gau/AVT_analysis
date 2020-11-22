function [trdata, tedata] =  norm_calc(trdata, tedata, cvmat, tr, te, opt)

    % Eucledian image normalization
    if opt.scaling.img.eucledian
        trdata = euclidian_normalization(trdata);
        tedata = euclidian_normalization(tedata);
    end

    % Image mean centering and normalization (std=1)
    if opt.scaling.img.zscore
        trdata = zscore(trdata, 0, 2);
        tedata = zscore(tedata, 0, 2);
    end

    % Feature mean centering
    if opt.scaling.feat.mean
        mnval = mean(trdata);
        trdata = mean_centering(trdata, mnval);
        tedata = mean_centering(tedata, mnval);
    end

    % Feature scaling into [-1 1] range
    if opt.scaling.feat.range
        minval = min(trdata);
        maxval = max(trdata);
        trdata = range_scaling(trdata, maxval, minval);
        tedata = range_scaling(tedata, maxval, minval);
    end

    % Feature session mean centering
    if opt.scaling.feat.sessmean

        tr_sess =  cvmat(tr, 2);
        tr_sess_list = unique(tr_sess);

        trdata = fold_mean_centering(trdata, tr_sess_list, tr_sess);

        te_sess = cvmat(te, 2);
        te_sess_list = unique(te_sess);

        tedata = fold_mean_centering(tedata, te_sess_list, te_sess);
    end

end
