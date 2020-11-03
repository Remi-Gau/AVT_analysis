function [opt, file2load_suffix] = get_mvpa_options()

    % Options for the SVM
    opt.fs.do = false; % feature selection
    opt.rfe.do = false; % recursive feature elimination
    opt.scaling.idpdt = true; % scale test and training sets independently
    opt.permutation.test = false;  % do permutation test
    opt.session.curve = false; % learning curves on a subsample of all the sessions
    opt.session.proptest = 0.2; % proportion of all sessions to keep as a test set
    opt.verbose = false;
    opt.layersubsample.do = false;
    opt.session.loro = true;
    opt.MVNN = false;

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

    opt.svm.kernel = 0;
    if opt.svm.kernel
        % should be implemented
    else
        opt.svm.dargs = [opt.svm.dargs ' -t 0 -q']; % inherent linear kernel, quiet mode
    end

    % Randomization options
    if opt.permutation.test
        opt.permutation.nreps = 1000; %#repetitions for permutation test
    else
        opt.permutation.nreps = 1;
    end

    % Learning curve
    %#repetitions for session subsampling if needed
    opt.session.subsample.nreps = 30;

    % Maximum numbers of CVs
    opt.session.maxcv = 25;

    % Multivariate noise normalization
    if opt.MVNN
        file2load_suffix = 'MVNN';
    else
        file2load_suffix = 'raw';
    end

    % this should be for volume only
    opt.layersubsample.repscheme = [20 2];

end
