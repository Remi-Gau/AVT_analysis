% (C) Copyright 2020 Agah Karakuzu
% (C) Copyright 2020 Remi Gau

function InitEnv()
    % initEnv()
    %
    % 1 - Check if version requirements
    % are satisfied and the packages are
    % are installed/loaded:
    %   Octave > 4
    %       - image
    %       - statistics
    %
    %   MATLAB >= R2017a
    %
    % 2 - Add project to the O/M path

    %
    matlabVersion = '9.2.0';

    % required package list
    octaveVersion = '4.0.3';
    installlist = {'io', 'statistics', 'image'};

    if IsOctave()

        % Exit if min version is not satisfied
        if ~compare_versions(OCTAVE_VERSION, octaveVersion, '>=')
            error('Minimum required Octave version: %s', octaveVersion);
        end

        for ii = 1:length(installlist)

            packageName = installlist{ii};

            try
                % Try loading Octave packages
                disp(['loading ' packageName]);
                pkg('load', packageName);

            catch
                tryInstallFromForge(packageName);
            end
        end

    else % MATLAB ----------------------------

        if verLessThan('matlab', matlabVersion)
            error('Sorry, minimum required version is R2017b. :(');
        end

    end

    % If external dir is empty throw an exception
    % and ask user to update submodules.
    AddDependencies();

    pth = fileparts(mfilename('fullpath'));

    run(fullfile(pth, 'lib', 'laminar_tools', 'InitLaminarTools'));
    if IsOctave
        addpath(genpath(fullfile(pth, 'lib', 'CPP_BIDS_SPM_pipeline', 'src')));
        addpath(genpath(fullfile(pth, 'lib', 'CPP_BIDS_SPM_pipeline', 'lib')));
    else
        run(fullfile(pth, 'lib', 'CPP_BIDS_SPM_pipeline', 'initCppSpm'));
    end

    disp('Correct matlab/octave verions and added to the path!');

end

%%
%% Return: true if the environment is Octave.
%%
function retval = IsOctave
    persistent cacheval   % speeds up repeated calls

    if isempty (cacheval)
        cacheval = (exist ("OCTAVE_VERSION", "builtin") > 0);
    end

    retval = cacheval;
end

function tryInstallFromForge(packageName)

    errorcount = 1;
    while errorcount % Attempt twice in case installation fails
        try
            pkg('install', '-forge', packageName);
            pkg('load', packageName);
            errorcount = 0;
        catch err
            errorcount = errorcount + 1;
            if errorcount > 2
                error(err.message);
            end
        end
    end

end

function AddDependencies()

    pth = fileparts(mfilename('fullpath'));

    addpath(genpath(fullfile(pth, 'lib', 'libsvm-3.21', 'matlab')));

    librairies = { ...
                  'matlab_for_cbs_tools'; ...
                  'herrorbar'};

    for iLib = 1:size(librairies, 1)
        addpath(genpath(fullfile(pth, 'lib', librairies{iLib})));
    end

    librairies = { ...
                  'pcm_toolbox'; ...
                  'rsatoolbox'};

    for iLib = 1:size(librairies, 1)
        addpath(fullfile(pth, 'lib', librairies{iLib}));
    end

    addpath(genpath(fullfile(pth, 'src', 'subfun')));
    addpath(genpath(fullfile(pth, 'src', 'settings')));

    spm('defaults', 'fmri');
    spm_jobman('initcfg');

end
