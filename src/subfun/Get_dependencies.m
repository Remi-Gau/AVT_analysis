function Get_dependencies()

    mpm_folder = fileparts(which('mpm'));
    addpath(genpath(fullfile(mpm_folder, 'mpm-packages', 'mpm-collections', 'AVT')));

end
