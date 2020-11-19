function [Dirs] = set_dir(space)
  % Function used to define where the code and the data are
  %

  if isunix
    StartDir = '/home/remi';
    ExternalHD = '/media/remi/AVT_4TB/derivatives';
  elseif ispc
    StartDir = 'D:\';
  else
    disp('Platform not supported');
  end

  % Derivatives Data
  %     Dirs.DerDir = fullfile(StartDir, 'Dropbox', 'PhD', 'Experiments', 'AVT', 'derivatives');
  
  Dirs.DerDir = fullfile(StartDir, 'gin', 'AVT', 'derivatives');
  if ~exist(Dirs.DerDir, 'dir')
    error('The data directory does not exist: %s', Dirs.DerDir);
  end

  %% DO NOT TOUCH

  Dirs.StartDir = StartDir;
  
  Dirs.ExternalHD = ExternalHD;

  Dirs.CodeDir = fullfile(fileparts(mfilename('fullpath')), '..');

  Dirs.FigureFolder = fullfile(Dirs.DerDir, 'figures');

  Dirs.MVPA_resultsDir = fullfile(Dirs.DerDir, ['libsvm-' space]);

  %     Dirs.BOLD_resultsDir = fullfile(Dirs.DerDir, 'results', 'profiles', 'surf');

  [~, ~, ~] = mkdir(fullfile(Dirs.DerDir, ['libsvm-' space], 'group'));
  [~, ~, ~] = mkdir(Dirs.FigureFolder);

  Get_dependencies(Dirs);

end
