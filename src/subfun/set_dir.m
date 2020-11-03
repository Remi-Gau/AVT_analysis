function [Dirs, SubLs, NbSub] = set_dir()
    % Function used to define where the code and the data are
    %

    if isunix
        StartDir = '/home/remi';
    elseif ispc
        StartDir = 'D:\';
    else
        disp('Platform not supported');
    end

    % Derivatives Data
    Dirs.DerDir = fullfile(StartDir, 'Dropbox', 'PhD', 'Experiments', 'AVT', 'derivatives');
    if ~exist(Dirs.DerDir, 'dir')
        error('The data directory does not exist: %s', Dirs.DerDir);
    end

    %% DO NOT TOUCH
    
    Dirs.StartDir = StartDir;
    
    Dirs.CodeDir = fullfile(fileparts(mfilename('fullpath')), '..');

    Dirs.FigureFolder = fullfile(Dirs.DerDir, 'figures');

    Dirs.MVPA_resultsDir = fullfile(Dirs.DerDir, 'results', 'SVM');
    Dirs.BOLD_resultsDir = fullfile(Dirs.DerDir, 'results', 'profiles', 'surf');
    
    [~, ~, ~] = mkdir(Dirs.FigureFolder);
    [~, ~, ~] = mkdir(Dirs.MVPA_resultsDir);
    [~, ~, ~] = mkdir(Dirs.BOLD_resultsDir);
    
    SubLs = dir(fullfile(Dirs.DerDir, 'sub*'));
    NbSub = numel(SubLs);
    
    Get_dependencies(Dirs);

end
