% (C) Copyright 2020 Remi Gau

function [Dirs] = SetDir(space, MVNN)
    % Function used to define where the code and the data are

    if nargin < 1
        space = 'surf';
    end

    if nargin < 1
        MVNN = false;
    end

    if MVNN
        MVNN = '1';
    else
        MVNN = '0';
    end

    StartDir = spm_file(fullfile(fileparts(mfilename('fullpath')), '..', '..'), 'cpath');

    if isunix
        ExternalHD = '/media/remi/AVT_4TB/derivatives';
    end

    Dirs.DerDir = spm_file(fullfile(StartDir, '..', '..', 'derivatives'), 'cpath');
    if ~exist(Dirs.DerDir, 'dir')
        error('The data directory does not exist: %s', Dirs.DerDir);
    end

    %% DO NOT TOUCH

    Dirs.StartDir = StartDir;

    Dirs.ExternalHD = ExternalHD;

    Dirs.Figures = fullfile(Dirs.DerDir, 'figures');

    Dirs.ExtractedBetas = fullfile(Dirs.DerDir, ['extractedBetas'...
                                                 '_space-', space, ...
                                                 '_MVNN-', MVNN]);

    Dirs.DummyData = fullfile(Dirs.DerDir, ['dummyData'...
                                            '_space-', space, ...
                                            '_MVNN-', MVNN]);

    Dirs.LaminarGlm = fullfile(Dirs.DerDir, ['laminarGlm'...
                                             '_space-', space, ...
                                             '_MVNN-', MVNN]);

    Dirs.PCM = fullfile(Dirs.DerDir, ['pcm'...
                                      '_space-', space]);

    Dirs.RSA = fullfile(Dirs.DerDir, ['rsa'...
                                      '_space-', space]);

    Dirs.MvpaResultsDir = fullfile(Dirs.DerDir, ['libsvm', ...
                                                 '_space-', space, ...
                                                 '_MVNN-', MVNN]);

    Dirs.CodeDir = spm_file(fullfile(fileparts(mfilename('fullpath')),  '..', '..'), ...
                            'cpath');

end
