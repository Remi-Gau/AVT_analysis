% (C) Copyright 2020 Remi Gau
clear;
clc;

CondNames = { ...
             'AStimL', 'AStimR'; ...
             'VStimL', 'VStimR'; ...
             'TStimL', 'TStimR'; ...
             'ATargL', 'ATargR'; ...
             'VTargL', 'VTargR'; ...
             'TTargL', 'TTargR' ...
            };

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

IsTarget = 0;

RSA = 0;
Trim = 1;

if RSA
    dest_dir = 'ffx_rsa';
    prefix = 'w';
elseif Trim %#ok<*UNRCH>
    dest_dir = 'ffx_trim';
    prefix = '';
else
    dest_dir = 'ffx_nat';
    prefix = '';
end

for iSub = 1:5 % 6:NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    SubDir = fullfile(StartDir, SubLs(iSub).name);

    %% Creates a cell that lists the full names of the different beta images
    load(fullfile(StartDir, SubLs(iSub).name, 'ffx_nat', 'SPM.mat'));

    % Regressor numbers
    RegNumbers = GetRegNb(SPM);

    % Select the right betas to transfer
    BetaOfInterest = GetBOI(SPM, CondNames);
    BetaNames = char(SPM.xX.name');
    %     disp(BetaNames(BetaOfInterest,:))

    cd(fullfile(SubDir, dest_dir, 'betas'));

    for iBeta = 1:size(BetaOfInterest, 1)
        disp(BetaNames(BetaOfInterest(iBeta), :));
        gzip(fullfile(StartDir, ...
                      SubLs(iSub).name, ...
                      dest_dir, ...
                      'betas', ...
                      ['r' SubLs(iSub).name '_' prefix 'beta-' sprintf('%04.0f', BetaOfInterest(iBeta)) '.nii']));
        if IsTarget
            movefile(fullfile(StartDir, ...
                              SubLs(iSub).name, ...
                              ffx_dir, ...
                              'betas', ...
                              ['r' SubLs(iSub).name '_' ...
                               prefix ...
                               'beta-' sprintf('%04.0f', BetaOfInterest(iBeta)) '.nii.gz']), ...
                     fullfile(StartDir, ...
                              SubLs(iSub).name, ...
                              dest_dir, ...
                              'betas', ...
                              ['r' SubLs(iSub).name '_target_' ...
                               prefix ...
                               'beta-' sprintf('%04.0f', BetaOfInterest(iBeta)) '.nii.gz']));
        end
    end

    clear SPM BetaOfInterest;

end
