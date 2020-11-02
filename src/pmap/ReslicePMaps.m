clear;
clc;

spm_get_defaults;
global defaults %#ok<NUSED>

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

DateFormat = 'yyyy_mm_dd_HH_MM';

parfor iSub = 1:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    Anat = spm_select('FPList', fullfile(SubDir, 'anat', 'cbs'), ...
                      ['^' SubLs(iSub).name '.*_bound.nii$']);

    cd(fullfile(SubDir, 'pmap'));

    Files2Reslice = {};
    matlabbatch = {};

    ROIFiles = dir('w*.nii');
    for i = 1:numel(ROIFiles)
        Files2Reslice{i, 1} = fullfile(SubDir, 'pmap', [ROIFiles(i).name ',1']); %#ok<*SAGROW>
    end

    matlabbatch{1}.spm.spatial.coreg.write.ref = {Anat};
    matlabbatch{1}.spm.spatial.coreg.write.source = Files2Reslice;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

    SaveMatLabBatch(fullfile(SubDir, 'pmap', ['Reslice_', SubLs(iSub).name, '_jobs_', datestr(now, DateFormat), '.mat']), matlabbatch);

    spm_jobman('run', matlabbatch);

end
