% (C) Copyright 2020 Remi Gau
clear;
clc;

spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<*NUSED>

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

DateFormat = 'yyyy_mm_dd_HH_MM';

for iSub = 1:NbSub

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    cd(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    Files2Reorient = {};

    % Get files
    ROIFiles = dir('wA41*.nii');
    for i = 1:numel(ROIFiles)
        Files2Reorient{end + 1, 1} = fullfile(SubDir, ...
                                              'roi', ...
                                              'vol', ...
                                              'mni', ...
                                              'upsamp', ...
                                              [ROIFiles(i).name ',1']); %#ok<SAGROW>
    end

    M = dir('ReorientMatrix_*.mat');
    load(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', M.name));

    matlabbatch{1}.spm.util.reorient.srcfiles = Files2Reorient;
    matlabbatch{1}.spm.util.reorient.transform.transM = M;
    matlabbatch{1}.spm.util.reorient.prefix = '';

    M = dir('CoregMatrix_*.mat');
    load(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', M.name));

    matlabbatch{2}.spm.util.reorient.srcfiles = Files2Reorient;
    matlabbatch{2}.spm.util.reorient.transform.transM = M;
    matlabbatch{2}.spm.util.reorient.prefix = '';

    spm_jobman('run', matlabbatch);

    save (strcat('Reorient_', SubLs(iSub).name, '_jobs_', datestr(now, DateFormat), '.mat'));

end
