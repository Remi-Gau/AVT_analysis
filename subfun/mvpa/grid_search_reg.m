function [args, grid] = grid_search_reg(trdata, trlabel, nfold, opt)
% [args, grid] = grid_search(trdata, trlabel, nfold, opt)
% 2-grid search for parameter selection of SVM

% 1st grid search with initial range of estimates
if strcmp(opt.svm.machine, 'epsilon-SVR')
    grid.first.param{1,1} = opt.svm.p;
    grid.first.param{2,1} = opt.svm.log2c;
elseif strcmp(opt.svm.machine, 'nu-SVR')
    grid.first.param{1,1} = opt.svm.nu;
    grid.first.param{2,1} = opt.svm.log2c;
end

% nested CV accuracies for each parameter value
grid.first.MSE = zeros(numel(grid.first.param{1}),numel(grid.first.param{2}));

for i = 1:length(grid.first.param{1})
    
    for j = 1:length(grid.first.param{2})
        
        if strcmp(opt.svm.machine, 'epsilon-SVR')
            args = sprintf('%s -v %d -c %g -p %g', opt.svm.dargs, nfold, 2^grid.first.param{2}(j), grid.first.param{1}(i));
        elseif strcmp(opt.svm.machine, 'nu-SVR')
            args = sprintf('%s -v %d -c %g -n %g', opt.svm.dargs, nfold, 2^grid.first.param{2}(j), grid.first.param{1}(i));
        end

        if opt.svm.kernel
            grid.first.MSE(i,j) = svmtrain(trlabel, [(1:length(trlabel))' trdata], args);
        else
            grid.first.MSE(i,j) = svmtrain(trlabel, trdata, args);
        end
    
    end

end

% Determine better range of estimates
MIN = min(grid.first.MSE(:));
[id_y, id_x, ~] = find(grid.first.MSE==MIN);
id_y = min(id_y);
id_x = min(id_x);


nsteps = 5;

if id_x == 1
    grid.second.param{2,1} = grid.first.param{2}([id_x id_x+2]);
elseif id_x == length(grid.first.param{2})
    grid.second.param{2,1} = grid.first.param{2}([id_x-2 id_x]);
else
    grid.second.param{2,1} = grid.first.param{2}([id_x-1 id_x+1]);
end    
grid.second.param{2} = grid.second.param{2}(1):(grid.second.param{2}(2)-grid.second.param{2}(1))/nsteps:grid.second.param{2}(2);


if id_y == 1
    grid.second.param{1,1} = grid.first.param{1}([id_y id_y+2]);
elseif id_y == length(grid.first.param{1})
    grid.second.param{1,1} = grid.first.param{1}([id_y-2 id_y]);
else
    grid.second.param{1,1} = grid.first.param{1}([id_y-1 id_y+1]);
end    
grid.second.param{1} = grid.second.param{1}(1):(grid.second.param{1}(2)-grid.second.param{1}(1))/nsteps:grid.second.param{1}(2);



% Refined 2nd grid search
grid.second.MSE = zeros(numel(grid.second.param{1}),numel(grid.second.param{2}));
 

for i = 1:length(grid.second.param{1})
    
    for j = 1:length(grid.second.param{2})
        
        if strcmp(opt.svm.machine, 'epsilon-SVR')
            args = sprintf('%s -v %d -c %g -p %g', opt.svm.dargs, nfold, 2^grid.second.param{2}(j), grid.second.param{1}(i));
        elseif strcmp(opt.svm.machine, 'nu-SVR')
            args = sprintf('%s -v %d -c %g -n %g', opt.svm.dargs, nfold, 2^grid.second.param{2}(j), grid.second.param{1}(i));
        end

        if opt.svm.kernel
            grid.second.MSE(i,j) = svmtrain(trlabel, [(1:length(trlabel))' trdata], args);
        else
            grid.second.MSE(i,j) = svmtrain(trlabel, trdata, args);
        end
    
    end

end


% Determine best estimate
MIN = min(grid.second.MSE(:));
[id_y, id_x, ~] = find(grid.second.MSE==MIN);
id_y = min(id_y);
id_x = min(id_x);

grid.bestparam = [grid.second.param{1}(id_y) grid.second.param{2}(id_x)];

if strcmp(opt.svm.machine, 'epsilon-SVR')
    args = sprintf('%s -c %g -p %g', opt.svm.dargs, 2^grid.bestparam(2), grid.bestparam(1));
elseif strcmp(opt.svm.machine, 'nu-SVR')
    args = sprintf('%s -c %g -n %g', opt.svm.dargs, 2^grid.bestparam(2), grid.bestparam(1));
end