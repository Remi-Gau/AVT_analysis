function results = machine_SVC(svm, feat, cvmat, trsession, tesession, opt)

% Separate training and test sets
if strcmp(opt.svm.machine, 'epsilon-SVR') || strcmp(opt.svm.machine, 'nu-SVR')
    tr = ismember(cvmat(:,1), svm.train_class) & ismember(cvmat(:,2), find(trsession));
    te = ismember(cvmat(:,1), svm.test_class) & ismember(cvmat(:,2), find(tesession));
else
    tr = ismember(cvmat(:,1), svm.class) & ismember(cvmat(:,2), find(trsession));
    te = ismember(cvmat(:,1), svm.class) & ismember(cvmat(:,2), find(tesession));
end

[trdata, tedata] = deal(feat(tr,:), feat(te,:));
[trlabel, telabel] = deal(cvmat(tr,1), cvmat(te,1));

if isempty(telabel)
    error('We got no labels for that test set.')
end

if strcmp(opt.svm.machine, 'epsilon-SVR') || strcmp(opt.svm.machine, 'nu-SVR')
    
    tmp = trlabel;
    for ilabel = 1:numel(svm.train_class)
        tmp(trlabel==svm.train_class(ilabel))=svm.train_labels(ilabel);
    end
    trlabel = tmp;
    clear tmp
    
    tmp = telabel;
    for ilabel = 1:numel(svm.test_class)
        tmp(telabel==svm.test_class(ilabel))=svm.test_labels(ilabel);
    end
    telabel = tmp;
    
end

idfeat = true(size(trdata(1,:)));

% Normalization and scaling (independently for training and test data!)
if strcmp(opt.svm.machine, 'epsilon-SVR') || strcmp(opt.svm.machine, 'nu-SVR')
    
    trdata_ori = trdata;
    trdata = norm_calc_tr(trdata, cvmat, tr, opt);
    
else
    if opt.scaling.idpdt == 1
        trdata = norm_calc_tr(trdata, cvmat, tr, opt);
    else
        [trdata, tedata] = norm_calc(trdata, tedata, cvmat, tr, te, opt);
    end
    
    % Specify final labels
    trlabel(trlabel==min(trlabel)) = 1;
    trlabel(trlabel==max(trlabel)) = -1;
    telabel(telabel==min(telabel)) = 1;
    telabel(telabel==max(telabel)) = -1;
    
    % Activation based univariate feature selection (see De Martino & Formisano, 2008)
    if opt.fs.do
        idfeat = feat_select(trdata, trlabel, opt);
        fs = struct('size', sum(idfeat), 'idfeat', idfeat);
    else
        fs = [];
    end
    
end




% 2-grid search for parameter selection (see LIBSVM guide)
if strcmp(opt.svm.machine, 'epsilon-SVR') || strcmp(opt.svm.machine, 'nu-SVR')
    [args, grid] = grid_search_reg(trdata(:,idfeat), trlabel, sum(sum(trsession)), opt);
else
    [args, grid] = grid_search(trdata(:,idfeat), trlabel, cvmat(tr,2), opt);
end


% Recursive feature elinimation (see De Martino & Formisano, 2008)
if opt.rfe.do
    [idfeat, rfeacc] = rfe_calc(trdata, idfeat, trlabel, cvmat(tr,2), sum(sum(trsession)), args, opt);
    
    %     %takes the best accuracy before it starts dropping - minimize number of
    %     %features while maintaining high accuracy
    %     id = find(diff(mean(rfeacc,2))<0,1,'first');
    
    id = [];
    if isempty(id)
        [v,id] = max(mean(rfeacc,2));
        id = find(mean(rfeacc,2)==v,1,'last');
    end
    idfeat = idfeat(id,:);
    
    rfe = struct('acc', rfeacc, 'size', sum(idfeat), 'idfeat', idfeat);
else
    rfe = [];
end


% Train machine
if strfind(opt.svm.machine,'SVC') && sum(trlabel==-1)~=sum(trlabel==1)
    %-wi weight : set the parameter C of class i to weight*C, for C-SVC
    model = svmtrain(trlabel, trdata(:,idfeat), ...
        [args '-w1 ' num2str(sum(trlabel==1)) ' -w-1 ' num2str(sum(trlabel==-1)) ]);
else
    model = svmtrain(trlabel, trdata(:,idfeat), args);
end

% Compute weights of the model (see LIBSVM FAQ)
if strcmp(opt.svm.machine, 'epsilon-SVR') || strcmp(opt.svm.machine, 'nu-SVR')
else
    % Compute weights of the model (see LIBSVM FAQ)
    w = model.SVs' * model.sv_coef;
    if model.Label(1) == -1
        w = -w;
    end
    w = abs(w);
    
    % Compute dual objective value (see LIBSVM FAQ)
    dualobj = 0.5 * (w' * w) -  model.sv_coef' * [repmat(model.Label(1), 1, model.nSV(1)) repmat(model.Label(2), 1, model.nSV(2))]';
end


% Make predictictions
if strcmp(opt.svm.machine, 'epsilon-SVR') || strcmp(opt.svm.machine, 'nu-SVR')
    
    predlabel = nan(size(tedata,1),1);
    decvalue = nan(size(tedata,1),1);
    
    genscheme = unique(svm.genscheme);
    for i=1:numel(genscheme)
        
        cdt2pred = ismember(cvmat(te,1), svm.test_class(ismember(svm.genscheme,genscheme(i))));
        
        % Normalization and scaling of test data
        if opt.scaling.idpdt == 1
            tedata_tmp = norm_calc_tr(tedata(cdt2pred,:), cvmat, te(cdt2pred,:), opt);
        else
            tedata_tmp = norm_calc_te(trdata_ori, tedata(cdt2pred,:), cvmat, tr, te(cdt2pred,:), opt);
        end
        
        [predlabel(cdt2pred),~, decvalue(cdt2pred)] = svmpredict(telabel(cdt2pred), tedata_tmp(:,idfeat),  model, '-b 0');
        
    end
    
else
    
    if opt.scaling.idpdt == 1
        tedata = norm_calc_tr(tedata, cvmat, te, opt);
    end
    
    [predlabel, ~, decvalue] = svmpredict(telabel, tedata(:,idfeat),  model);
    
    [~, acc, ~] = svmpredict(trlabel, trdata(:,idfeat),  model);
    model.acc = acc(1)/100; clear acc
    
end

% Number of support vectors
% nsv = model.totalSV;
model = rmfield(model, 'SVs');

% Generate output
if strcmp(opt.svm.machine, 'epsilon-SVR') || strcmp(opt.svm.machine, 'nu-SVR')
    results = struct('model', model, 'gridsearch', grid, ...
        'pred', predlabel, 'label', telabel, 'func', decvalue);
elseif opt.permutation.test
    results = struct('pred', predlabel, 'label', telabel);
else
    results = struct('model', model, 'obj', dualobj, 'gridsearch', grid, 'fs', fs, ...
        'rfe', rfe, 'pred', predlabel, 'label', telabel, 'func', decvalue);
end

end
