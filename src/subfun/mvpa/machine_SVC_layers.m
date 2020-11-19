function [acc, weight, results] = machine_SVC_layers(svm, feat, featlay, cvmat, trsession, tesession, opt)

  % Separate training and test sets
  tr = ismember(cvmat(:, 1), svm.class) & ismember(cvmat(:, 2), find(trsession));
  te = ismember(cvmat(:, 1), svm.class) & ismember(cvmat(:, 2), find(tesession));

  [trdata_all, tedata_all] = deal(feat(tr, :), feat(te, :));
  [trlabel, telabel] = deal(cvmat(tr, 1), cvmat(te, 1));

  % Specify final labels
  trlabel(trlabel == min(trlabel)) = 1;
  trlabel(trlabel == max(trlabel)) = -1;
  telabel(telabel == min(telabel)) = 1;
  telabel(telabel == max(telabel)) = -1;

  weight = nan(1, size(featlay, 2));

  results = {};

  acc = nan(max(featlay));

  if opt.verbose
    fprintf('\n      Running on %i layers: training on layer ', max(featlay));
  end

  for ilayertr = 1:max(featlay)

    if opt.verbose
      fprintf('%i ', ilayertr);
    end

    ver = find(featlay == ilayertr);

    trdata = trdata_all(:, ver);

    % Keep a copy of the original training data set to reuse it to
    % normalize the test data later on
    trdata_ori = trdata; %#ok<NASGU>

    % Normalization and scaling of training data
    trdata = norm_calc_tr(trdata, cvmat, tr, opt);

    idfeat = logical(ones(size(trdata(1, :)))); %#ok<LOGL>

    % Activation based univariate feature selection (see De Martino & Formisano, 2008)
    if opt.fs.do
      idfeat = feat_select(trdata, trlabel, opt);
      fs = struct('size', sum(idfeat), 'idfeat', idfeat);
    else
      fs = [];
    end

    % 2-grid search for parameter selection (see LIBSVM guide)
    [args, grid] = grid_search_layers(trdata(:, idfeat), trlabel, cvmat(tr, 2), opt);

    % Recursive feature elinimation (see De Martino & Formisano, 2008)
    if opt.rfe.do
      [idfeat, rfeacc] = rfe_calc(trdata, idfeat, trlabel, cvmat(tr, 2), sum(sum(trsession)), args, opt);
      rfe = struct('acc', rfeacc, 'size', sum(idfeat), 'idfeat', idfeat);
    else
      rfe = [];
    end

    % Train machine
    model = svmtrain(trlabel, trdata(:, idfeat), args);

    % Compute weights of the model (see LIBSVM FAQ)
    w = model.SVs' * model.sv_coef;
    if model.Label(1) == -1
      w = -w;
    end
    w = abs(w);

    weight(1, ver(idfeat)) = w / sum(w);

    % Compute dual objective value (see LIBSVM FAQ)
    dualobj = 0.5 * (w' * w) -  model.sv_coef' * [repmat(model.Label(1), 1, model.nSV(1)) repmat(model.Label(2), 1, model.nSV(2))]';

    % Number of support vectors
    % nsv = model.totalSV;

    % Generalize in turn to each layer of the test data
    predlabel = nan(size(telabel, 1), max(featlay));
    decvalue = nan(size(telabel, 1), max(featlay));

    for ilayerte = 1:max(featlay)

      tedata = tedata_all(:, featlay == ilayerte);

      % Normalization and scaling of test data
      if opt.scaling.idpdt == 1
        tedata = norm_calc_tr(tedata, cvmat, te, opt);
      else
        error('check non idpdt scaling');
        tedata = norm_calc_te(trdata_ori, tedata, opt);
      end

      if size(tedata(:, idfeat), 2) ~= size(trdata(:, idfeat), 2)

        error('Different numbers of features in the training set and the test set');

      else

        % Make predictictions
        [predlabel(:, ilayerte), ~, decvalue(:, ilayerte)] = svmpredict(telabel, tedata(:, idfeat),  model);

        clear tedata;

        acc(ilayertr, ilayerte) = mean(predlabel(:, ilayerte) == telabel);
      end

    end

    % Just to check how good the model is on itself
    [~, acc_tr, ~] = svmpredict(trlabel, trdata(:, idfeat),  model);
    model.acc = acc_tr(1) / 100;
    clear acc_tr;

    model = rmfield(model, 'SVs');

    if opt.permutation.test
      results{ilayertr} = struct('pred', predlabel, 'label', telabel); %#ok<AGROW>
    else
      results{ilayertr} = struct( ...
                                 'model', model, 'obj', dualobj, 'gridsearch', grid, 'fs', fs, ...
                                 'rfe', rfe, 'pred', predlabel, 'label', telabel, 'func', decvalue); %#ok<AGROW>
    end

  end

end
