% (C) Copyright 2020 Remi Gau

function Dirs = GetDependencies(Dirs)
    %
    % Adds folders to the path
    %
    % USAGE::
    %
    %   Dirs = GetDependencies(Dirs)
    %

    addpath(genpath(abspath(fullfile(Dirs.CodeDir, '..', 'lib'))));

end


