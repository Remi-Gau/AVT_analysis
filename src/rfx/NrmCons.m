clear;
clc;

spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<NUSED>

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = [2 4] % 1:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    cd(SubDir);

    % Defines batch
    matlabbatch = {};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

    % Get deformation field
    DefField = dir(fullfile(SubDir, 'anat', 'spm', 'y_sub*.nii'));
    DefField = fullfile(SubDir, 'anat', 'spm', DefField.name);
    matlabbatch{1}.spm.spatial.normalise.write.subj.def{1} = DefField;

    % Get the con images to normalize
    cd(fullfile(SubDir, 'ffx_nat_smooth', 'con'));

    Mean =  dir(fullfile(SubDir, 'ffx_nat_smooth', 'con', 'mean*.nii'));
    tmp{1, 1} = fullfile(SubDir, 'ffx_nat_smooth', 'con', Mean.name);

    Imgs = dir('con*.nii');
    for j = 1:length(Imgs)
        tmp{1 + j, 1} = fullfile(SubDir, 'ffx_nat_smooth', 'con', [Imgs(j).name ',1']);
    end
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = tmp;

    SaveMatLabBatch(fullfile(SubDir, ['NrmCons_', SubLs(iSub).name, '_matlabbatch.mat']), matlabbatch);

    spm_jobman('run', matlabbatch);

    cd (StartDir);

end
