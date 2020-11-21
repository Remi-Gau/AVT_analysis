% (C) Copyright 2020 Remi Gau
clear;
clc;

spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<NUSED>

SPM_dir = '/home/rxg243/Programs/SPM/spm12/';

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 5:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    cd(SubDir);

    tmp = dir(fullfile(SubDir, 'anat', 'spm', [SubLs(iSub).name '_ses-*_MP2RAGE_T1w.nii']));
    StructuralScan = fullfile(SubDir, 'anat', 'spm', tmp.name);
    clear tmp;

    % --------------------------%
    %     DEFINES    BATCH      %
    % --------------------------%

    matlabbatch = {};

    matlabbatch{1, 1}.spm.spatial.preproc.channel.vols = {StructuralScan};
    matlabbatch{1, 1}.spm.spatial.preproc.channel.biasreg = 1.0000e-03;
    matlabbatch{1, 1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1, 1}.spm.spatial.preproc.channel.write = [1 1];

    matlabbatch{1, 1}.spm.spatial.preproc.tissue(1).tpm = {[fullfile(SPM_dir, 'tpm', 'TPM.nii') ',1']};
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(1).warped = [0 0];

    matlabbatch{1, 1}.spm.spatial.preproc.tissue(2).tpm = {[fullfile(SPM_dir, 'tpm', 'TPM.nii') ',2']};
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(2).warped = [0 0];

    matlabbatch{1, 1}.spm.spatial.preproc.tissue(3).tpm = {[fullfile(SPM_dir, 'tpm', 'TPM.nii') ',3']};
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(3).warped = [0 0];

    matlabbatch{1, 1}.spm.spatial.preproc.tissue(4).tpm = {[fullfile(SPM_dir, 'tpm', 'TPM.nii') ',4']};
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(4).warped = [0 0];

    matlabbatch{1, 1}.spm.spatial.preproc.tissue(5).tpm = {[fullfile(SPM_dir, 'tpm', 'TPM.nii') ',5']};
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(5).warped = [0 0];

    matlabbatch{1, 1}.spm.spatial.preproc.tissue(6).tpm = {[fullfile(SPM_dir, 'tpm', 'TPM.nii') ',6']};
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(6).native = [1 0];
    matlabbatch{1, 1}.spm.spatial.preproc.tissue(6).warped = [0 0];

    matlabbatch{1, 1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1, 1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1, 1}.spm.spatial.preproc.warp.reg = [0 1.0000e-03 0.5000 0.0500 0.2000];
    matlabbatch{1, 1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1, 1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1, 1}.spm.spatial.preproc.warp.samp = 2;
    matlabbatch{1, 1}.spm.spatial.preproc.warp.write = [1 1];

    save(fullfile(SubDir, ['Segment_', SubLs(iSub).name, '_matlabbatch.mat']), 'matlabbatch');

    fprintf('\n\n');
    disp('%%%%%%%%%%%%%%%');
    disp('    SEGMENT    ');
    disp('%%%%%%%%%%%%%%%');

    spm_jobman('run', matlabbatch);

    cd (StartDir);

end
