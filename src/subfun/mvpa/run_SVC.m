function results = run_SVC(svm, feat, cvmat, trsession, tesession, opt)
    %
    % Trains model for support vector machine - classification
    % Generalizes to test data
    %

    % Separate training and test sets
    tr = ismember(cvmat(:, 1), svm.class) & ismember(cvmat(:, 2), find(trsession));
    te = ismember(cvmat(:, 1), svm.class) & ismember(cvmat(:, 2), find(tesession));

    [trdata, tedata] = deal(feat(tr, :), feat(te, :));
    [trlabel, telabel] = deal(cvmat(tr, 1), cvmat(te, 1));

    if isempty(telabel)
        error('We got no labels for that test set.');
    end

    % vector to keep track of which feature to keep
    keep_feature = true(size(trdata(1, :)));

    % Normalization and scaling (independently for training and test data!)
    if opt.scaling.idpdt
        trdata = norm_calc_tr(trdata, cvmat, tr, opt);

    else
        [trdata, tedata] = norm_calc(trdata, tedata, cvmat, tr, te, opt);

    end

    % Specify final labels
    trlabel(trlabel == min(trlabel)) = 1;
    trlabel(trlabel == max(trlabel)) = -1;
    telabel(telabel == min(telabel)) = 1;
    telabel(telabel == max(telabel)) = -1;

    % Activation based univariate feature selection (see De Martino & Formisano, 2008)
    fs = [];
    if opt.fs.do
        keep_feature = feat_select(trdata, trlabel, opt);
        fs = struct('size', sum(keep_feature), 'idfeat', keep_feature);
    end

    [args, grid] = grid_search(trdata(:, keep_feature), trlabel, cvmat(tr, 2), opt);

    % Recursive feature elinimation (see De Martino & Formisano, 2008)
    rfe = [];
    if opt.rfe.do
        [keep_feature, rfeacc] = rfe_calc( ...
                                          trdata, ...
                                          keep_feature, ...
                                          trlabel, ...
                                          cvmat(tr, 2), ...
                                          sum(sum(trsession)), ...
                                          args, ...
                                          opt);

        %     %takes the best accuracy before it starts dropping - minimize number of
        %     %features while maintaining high accuracy
        %     id = find(diff(mean(rfeacc,2))<0,1,'first');

        id = [];
        if isempty(id)
            [v, ~] = max(mean(rfeacc, 2));
            id = find(mean(rfeacc, 2) == v, 1, 'last');
        end
        keep_feature = keep_feature(id, :);

        rfe = struct('acc', rfeacc, 'size', sum(keep_feature), 'idfeat', keep_feature);

    end

    % Train machine
    if sum(trlabel == -1) ~= sum(trlabel == 1)

        % -wi weight : set the parameter C of class i to weight*C, for C-SVC
        model = svmtrain(trlabel, trdata(:, keep_feature), ...
                         [args ...
                          '-w1 ' num2str(sum(trlabel == 1)) ...
                          ' -w-1 ' num2str(sum(trlabel == -1))]);

    else
        model = svmtrain(trlabel, trdata(:, keep_feature), args);

    end

    % Compute weights of the model (see LIBSVM FAQ)
    w = model.SVs' * model.sv_coef;
    if model.Label(1) == -1
        w = -w;
    end
    w = abs(w);

    % Compute dual objective value (see LIBSVM FAQ)
    dualobj = 0.5 * (w' * w) - ...
      model.sv_coef' * [ ...
                        repmat(model.Label(1), 1, model.nSV(1)) ...
                        repmat(model.Label(2), 1, model.nSV(2))]';

    % Make predictictions
    if opt.scaling.idpdt == 1
        tedata = norm_calc_tr(tedata, cvmat, te, opt);
    end

    [predlabel, ~, decvalue] = svmpredict(telabel, tedata(:, keep_feature),  model);

    % Just to check how good the model is on itself
    [~, acc, ~] = svmpredict(trlabel, trdata(:, keep_feature),  model);
    model.acc = acc(1) / 100;

    % Number of support vectors
    % nsv = model.totalSV;
    model = rmfield(model, 'SVs');

    % Generate output
    if opt.permutation.test
        results = struct( ...
                         'pred', predlabel, ...
                         'label', telabel);

    else
        results = struct( ...
                         'model', model, ...
                         'obj', dualobj, ...
                         'gridsearch', grid, ...
                         'fs', fs, ...
                         'rfe', rfe, ...
                         'pred', predlabel, ...
                         'label', telabel, ...
                         'func', decvalue);

    end

end
