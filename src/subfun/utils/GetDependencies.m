% (C) Copyright 2020 Remi Gau

function Dirs = GetDependencies(Dirs)
    %
    % Adds folders to the path
    %
    % USAGE::
    %
    %   Dirs = GetDependencies(Dirs)
    %

    addpath(genpath(spm_file(fullfile(Dirs.CodeDir, '..', 'lib'), ...
        'cpath')));

end
