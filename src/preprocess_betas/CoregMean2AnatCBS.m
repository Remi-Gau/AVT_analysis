% (C) Copyright 2020 Remi Gau
clear;
clc;

spm_get_defaults;
global defaults %#ok<NUSED>

flags = struct( ...
               'sep', [4 2 1 0.7 0.4], ...
               'params',  [0 0 0  0 0 0], ...
               'cost_fun', 'nmi', ...
               'tol', [repmat(0.001, 1, 3), repmat(0.0005, 1, 3), repmat(0.005, 1, 3), repmat(0.0005, 1, 3)], ...
               'fwhm', [5, 5], ...
               'graphics', ~spm('CmdLine'));

StartDir = fullfile(pwd, '..', '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    Img2Process = {};
    TargetScan = []; %#ok<NASGU>
    SourceScan = []; %#ok<NASGU>

    TargetScan = dir(fullfile(SubDir, 'anat', 'cbs', ...
                              [SubLs(iSub).name '*_bound.nii']));
    TargetScan = fullfile(SubDir, 'anat', 'cbs', ...
                          TargetScan.name);

    cd(fullfile(SubDir, 'ffx_nat', 'betas'));

    SourceScan = dir(fullfile(SubDir, 'ffx_nat', 'betas', ...
                              'mean*.nii'));
    SourceScan = fullfile(SubDir, 'ffx_nat', 'betas', ...
                          SourceScan.name);

    tmp = dir([SubLs(iSub).name  '_beta-*.nii']);
    for FileInd = 1:length(tmp)
        Img2Process{end + 1, 1} = fullfile(SubDir, 'ffx_nat', 'betas', tmp(FileInd).name); %#ok<SAGROW>
    end

    spm_coreg_reorient_save(TargetScan, SourceScan, Img2Process, flags);

end

cd(StartDir);
