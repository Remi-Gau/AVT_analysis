function results = run_SVR(svm, feat, cvmat, trsession, tesession, opt)
    %
    % Trains model for support vector machine - regression and
    % Generalizes to test data
    %
    %
    % (C) Copyright 2020 Remi Gau

    % Separate training and test sets
    tr = ismember(cvmat(:, 1), svm.train_class) & ismember(cvmat(:, 2), find(trsession));
    te = ismember(cvmat(:, 1), svm.test_class) & ismember(cvmat(:, 2), find(tesession));

    [trdata, tedata] = deal(feat(tr, :), feat(te, :));
    [trlabel, telabel] = deal(cvmat(tr, 1), cvmat(te, 1));

    if isempty(telabel)
        error('We got no labels for that test set.');
    end

    % assign classes
    tmp = trlabel;
    for ilabel = 1:numel(svm.train_class)
        tmp(trlabel == svm.train_class(ilabel)) = svm.train_labels(ilabel);
    end
    trlabel = tmp;
    clear tmp;

    tmp = telabel;
    for ilabel = 1:numel(svm.test_class)
        tmp(telabel == svm.test_class(ilabel)) = svm.test_labels(ilabel);
    end
    telabel = tmp;

    % vector to keep track of which feature to keep
    keep_feature = true(size(trdata(1, :)));

    % Normalization
    trdata_ori = trdata;
    trdata = norm_calc_tr(trdata, cvmat, tr, opt);

    [args, grid] = grid_search_reg(trdata(:, keep_feature), trlabel, sum(sum(trsession)), opt);

    % Train machine
    model = svmtrain(trlabel, trdata(:, keep_feature), args);

    % Make predictictions
    predlabel = nan(size(tedata, 1), 1);
    decvalue = nan(size(tedata, 1), 1);

    genscheme = unique(svm.genscheme);
    for i = 1:numel(genscheme)

        cdt2pred = ismember( ...
                            cvmat(te, 1), ...
                            svm.test_class( ...
                                           ismember( ...
                                                    svm.genscheme, ...
                                                    genscheme(i))));

        % Normalization and scaling of test data
        if opt.scaling.idpdt == 1
            tedata_tmp = norm_calc_tr(tedata(cdt2pred, :), cvmat, te(cdt2pred, :), opt);
        else
            tedata_tmp = norm_calc_te(trdata_ori, tedata(cdt2pred, :), cvmat, te(cdt2pred, :), opt);
        end

        [predlabel(cdt2pred), ~, decvalue(cdt2pred)] = svmpredict( ...
                                                                  telabel(cdt2pred), ...
                                                                  tedata_tmp(:, keep_feature), ...
                                                                  model, '-b 0');

    end

    % Number of support vectors
    % nsv = model.totalSV;
    model = rmfield(model, 'SVs');

    % Generate output
    results = struct( ...
                     'model', model, ...
                     'gridsearch', grid, ...
                     'pred', predlabel, ...
                     'label', telabel, ...
                     'func', decvalue);

end
