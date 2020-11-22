function opt = get_mvpa_options(MVNN, Norm)

    % Options for the SVM

    % feature selection
    opt.fs.do = false;
    % recursive feature elimination
    opt.rfe.do = false;
    % scale test and training sets independently
    opt.scaling.idpdt = true;
    % do permutation test
    opt.permutation.test = false;
    % learning curves on a subsample of all the runs
    opt.runs.curve = false;
    % proportion of all runs to keep as a test set
    opt.runs.proptest = 0.2;

    opt.verbose = false;
    opt.layersubsample.do = false;
    opt.runs.loro = true;
    opt.MVNN = MVNN;

    % --------------------------------------------------------- %
    %          Data pre-processing and SVM parameters           %
    % --------------------------------------------------------- %
    % Feature selection (FS)
    opt.fs.threshold = 0.75;
    opt.fs.type = 'ttest2';

    % Recursive feature elminiation (RFE)
    opt.rfe.threshold = 0.01;
    opt.rfe.nreps = 20;

    % SVM C/nu parameters and default arguments
    opt.svm.machine = 'C-SVC';
    if strcmp(opt.svm.machine, 'C-SVC')
        opt.svm.log2c = 1;
        opt.svm.dargs = '-s 0';

    elseif strcmp(opt.svm.machine, 'nu-SVC')
        opt.svm.nu = [0.0001 0.001 0.01 0.1:0.1:1];
        opt.svm.dargs = '-s 1';

    end

    opt.svm.kernel = false;
    if opt.svm.kernel
        % should be implemented
    else
        % inherent linear kernel, quiet mode
        opt.svm.dargs = [opt.svm.dargs ' -t 0 -q'];
    end

    % Randomization options
    if opt.permutation.test
        opt.permutation.nreps = 1000; % nb repetitions for permutation test
    else
        opt.permutation.nreps = 1;
    end

    % Learning curve
    %#nb repetitions for session subsampling if needed
    opt.runs.subsample.nreps = 30;

    % Maximum numbers of CVs
    opt.runs.maxcv = 25;

    % this should be for volume only
    opt.layersubsample.repscheme = [20 2];

    opt = choose_norm(opt, Norm);

    opt = orderfields(opt);

end
