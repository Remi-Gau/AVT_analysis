% (C) Copyright 2020 Remi Gau
clear;
clc;

spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<NUSED>

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    % Define batch
    matlabbatch = {};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = NaN * ones(2, 3);
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = NaN * ones(1, 3);
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 0;

    % Get inverse normalization deformation field
    DefField = dir(fullfile(SubDir, 'anat', 'spm', ...
                            'iy_sub-*_ses-*_MP2RAGE_T1w.nii'));
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = {fullfile(SubDir, 'anat', 'spm', DefField.name)};

    % List ROIs to inv-norm
    cd(fullfile(StartDir, 'roi_mni'));

    %     filesdir = dir('S1*.nii');
    %     tmp = dir('V*ProbRet.nii');
    %     tmp2 = dir('HG_STG_*.nii');
    %     tmp3 = dir('Te*L_Cyt.nii');
    %     tmp4 = dir('Te*R_Cyt.nii');
    %     filesdir = [filesdir;tmp;tmp2;tmp3;tmp4]; %#ok<AGROW>

    filesdir = dir('A41-42*.nii');

    clear tmp tmp2 tmp3 tmp4;

    Img2Process = {};
    for iImg = 1:length(filesdir)
        Img2Process{iImg, 1} = fullfile(StartDir, 'roi_mni', strcat(filesdir(iImg).name, ',1')); %#ok<*SAGROW>
    end
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = Img2Process;

    save (fullfile(SubDir, strcat('InvNormPT_', SubLs(iSub).name, '_matlabbatch')), 'matlabbatch');

    spm_jobman('run', matlabbatch);

    % Move files
    mkdir(fullfile(SubDir, 'roi'));
    mkdir(fullfile(SubDir, 'roi', 'vol'));
    mkdir(fullfile(SubDir, 'roi', 'vol', 'mni'));
    movefile(fullfile(StartDir, 'roi_mni', 'w*.nii'), fullfile(SubDir, 'roi', 'vol', 'mni'));

    cd (StartDir);

end
