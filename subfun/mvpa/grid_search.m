function [args, grid] = grid_search(trdata, trlabel, sessions, opt)
% [args, grid] = grid_search(trdata, trlabel, nfold, opt)
% 2-grid search for parameter selection of SVM

sessions_list = unique(sessions);

% 1st grid search with initial range of estimates
if strcmp(opt.svm.machine, 'nu-SVC')
    grid.first.param = opt.svm.nu;
elseif strcmp(opt.svm.machine, 'C-SVC')
    grid.first.param = opt.svm.log2c;
end

if numel(grid.first.param)==1
    
    if strcmp(opt.svm.machine, 'nu-SVC')
        args = sprintf('%s -n %g', opt.svm.dargs, grid.first.param);
    elseif strcmp(opt.svm.machine, 'C-SVC')
        args = sprintf('%s -c %g', opt.svm.dargs, grid.first.param);
    end
    
else
    
    % nested CV accuracies for each parameter value
    grid.first.acc = zeros(size(grid.first.param));
    
    
    
    for i = 1:length(grid.first.acc)
        if strcmp(opt.svm.machine, 'nu-SVC')
            args = sprintf('%s -n %g', opt.svm.dargs, grid.first.param(i));
        elseif strcmp(opt.svm.machine, 'C-SVC')
            args = sprintf('%s -c %g', opt.svm.dargs, 2^grid.first.param(i));
        end
        if opt.svm.kernel
            grid.first.acc(i) = svmtrain(trlabel, [(1:length(trlabel))' trdata], args);
        else
            acc = nan(numel(sessions_list),3);
            for i_sess = 1:numel(sessions_list)
                te_sessions = sessions_list(i_sess);
                te_label = trlabel(ismember(sessions,te_sessions));
                te_data = trdata(ismember(sessions,te_sessions),:);
                tr_sessions = setxor(sessions_list, te_sessions);
                tr_label = trlabel(ismember(sessions,tr_sessions));
                tr_data = trdata(ismember(sessions,tr_sessions),:);
                model = svmtrain(tr_label, tr_data, args);
                [~, acc(i_sess,:), ~] = svmpredict(te_label, te_data,  model);
            end
            grid.first.acc(i) = nanmean(acc(:,1));
        end
    end
    
    % Determine better range of estimates
    [val, id] = max(grid.first.acc);
    nsteps = 5;
    if id == 1
        grid.second.param = grid.first.param([id id+2]);
    elseif id == length(grid.first.param)
        grid.second.param = grid.first.param([id-2 id]);
    else
        grid.second.param = grid.first.param([id-1 id+1]);
    end
    grid.second.param = grid.second.param(1):(grid.second.param(2)-grid.second.param(1))/nsteps:grid.second.param(2);
    
    % Refined 2nd grid search
    grid.second.acc = zeros(size(grid.second.param));
    for i = 1:length(grid.second.acc)
        if strcmp(opt.svm.machine, 'nu-SVC')
            args = sprintf('%s -n %g', opt.svm.dargs, grid.second.param(i));
        elseif strcmp(opt.svm.machine, 'C-SVC')
            args = sprintf('%s -c %g', opt.svm.dargs, 2^grid.second.param(i));
        end
        if opt.svm.kernel
            grid.second.acc(i) = svmtrain(trlabel, [(1:length(trlabel))' trdata], args);
        else
            acc = nan(numel(sessions_list),3);
            for i_sess = 1:numel(sessions_list)
                te_sessions = sessions_list(i_sess);
                te_label = trlabel(ismember(sessions,te_sessions));
                te_data = trdata(ismember(sessions,te_sessions),:);
                tr_sessions = setxor(sessions_list, te_sessions);
                tr_label = trlabel(ismember(sessions,tr_sessions));
                tr_data = trdata(ismember(sessions,tr_sessions),:);
                model = svmtrain(tr_label, tr_data, args);
                [~, acc(i_sess,:), ~] = svmpredict(te_label, te_data,  model);
            end
            grid.second.acc(i) = nanmean(acc(:,1));
        end
    end
    
    % Determine best estimate
    [val, id] = max(grid.second.acc);
    grid.bestparam = grid.second.param(id);
    if strcmp(opt.svm.machine, 'nu-SVC')
        args = sprintf('%s -n %g', opt.svm.dargs, grid.bestparam);
    elseif strcmp(opt.svm.machine, 'C-SVC')
        args = sprintf('%s -c %g', opt.svm.dargs, 2^grid.bestparam);
    end
    
end