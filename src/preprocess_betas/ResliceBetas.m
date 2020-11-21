% (C) Copyright 2020 Remi Gau
clear;
clc;

spm_get_defaults;
global defaults %#ok<NUSED>

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

DateFormat = 'yyyy_mm_dd_HH_MM';

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

NbWorkers = 9;
MatlabVer = version('-release');
if str2double(MatlabVer(1:4)) > 2013
    pool = gcp('nocreate');
    if isempty(pool)
        parpool(NbWorkers);
    end
else
    if matlabpool('size') == 0 %#ok<*DPOOL>
        matlabpool(NbWorkers);
    elseif matlabpool('size') ~= NbWorkers
        matlabpool close;
        matlabpool(NbWorkers);
    end
end

parfor iSub = 1:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    Anat = dir(fullfile(SubDir, 'anat', 'cbs', ...
                        [SubLs(iSub).name '*_thresh_clone_transform_strip_clone_transform_bound.nii']));
    Anat = fullfile(SubDir, 'anat', 'cbs', Anat.name);

    cd(fullfile(SubDir, dest_dir, 'betas'));

    Files2Reslice = {}; %#ok<NASGU>
    matlabbatch = {};

    % For betas
    Files2Reslice = cellstr(spm_select('FPList', fullfile(SubDir, dest_dir, 'betas'), ...
                                       ['^' SubLs(iSub).name '_' prefix 'beta-.*.nii$']));

    matlabbatch{1}.spm.spatial.coreg.write.ref = {Anat};
    matlabbatch{1}.spm.spatial.coreg.write.source = Files2Reslice;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

    % For the mask
    if ~RSA && ~Trim
        Files2Reslice = {};
        Files2Reslice{1} = fullfile(SubDir, 'ffx_nat', 'betas', [SubLs(iSub).name '_GLM_mask.nii,1']);

        matlabbatch{2}.spm.spatial.coreg.write.ref = {Anat};
        matlabbatch{2}.spm.spatial.coreg.write.source = Files2Reslice;
        matlabbatch{2}.spm.spatial.coreg.write.roptions.interp = 0;
        matlabbatch{2}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.coreg.write.roptions.mask = 0;
        matlabbatch{2}.spm.spatial.coreg.write.roptions.prefix = 'r';
    else
        copyfile(fullfile(SubDir, 'ffx_nat', 'betas', ['r' SubLs(iSub).name '_GLM_mask.nii']), ...
                 fullfile(SubDir, dest_dir, 'betas'));
    end

    SaveMatLabBatch(fullfile(SubDir, dest_dir, 'betas', ['Reslice_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch.mat']), matlabbatch);

    spm_jobman('run', matlabbatch);

    % Zip files
    %     FileLs = dir('rsub*.nii');
    %     h = waitbar(0,'Compressing files...');
    %     for iFile = 1:numel(FileLs)
    %         waitbar(iFile / numel(FileLs))
    %         gzip(FileLs(iFile).name)
    %         delete(FileLs(iFile).name)
    %     end
    %     close(h)

end
