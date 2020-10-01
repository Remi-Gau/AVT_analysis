function [Dirs] = set_dir()

    if isunix
        CodeDir = '/home/remi/github/AVT_analysis';
        StartDir = '/home/remi';
    elseif ispc
        CodeDir = 'D:\github\AVT-7T-code';
        StartDir = 'D:\';
    else
        disp('Platform not supported');
    end

    Dirs.CodeDir = CodeDir;
    Dirs.CodeDir = StartDir;

    Dirs.DerDir = fullfile(StartDir, 'Dropbox', 'PhD', 'Experiments', 'AVT', 'derivatives');

    Dirs.FigureFolder = fullfile(Dirs.DerDir, 'figures');

    Dirs.MVPA_resultsDir = fullfile(Dirs.DerDir, 'results', 'SVM');
    Dirs.BOLD_resultsDir = fullfile(Dirs.DerDir, 'results', 'profiles', 'surf');
