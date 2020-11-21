% (C) Copyright 2020 Remi Gau

function Dirs = GetDependencies(Dirs)
  %
  % Adds folders to the path
  %
  
    Dirs.CodeDir = abspath(fullfile(fileparts(mfilename('fullpath')),  '..', '..'));

    addpath(genpath(abspath(fullfile(Dirs.CodeDir, '..', 'lib'))));

    addpath(genpath(fullfile(Dirs.CodeDir, 'subfun')));

end
