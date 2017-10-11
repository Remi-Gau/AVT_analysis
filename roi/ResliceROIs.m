clear; clc

spm_get_defaults;
global defaults %#ok<NUSED>

StartDir = fullfile(pwd, '..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

SubLs = dir('sub*');
NbSub = numel(SubLs);

DateFormat = 'yyyy_mm_dd_HH_MM';


parfor iSub = 2:NbSub % for each subject
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    
    Anat = dir(fullfile(SubDir, 'anat', 'cbs', ...
    [SubLs(iSub).name '*_thresh_clone_transform_strip_clone_transform_bound.nii']));
    Anat = fullfile(SubDir, 'anat', 'cbs', Anat.name);
    
    cd(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'))
    
    Files2Reslice = {};
    matlabbatch = {};
    
    ROIFiles = dir('wA41*.nii');
    for i=1:numel(ROIFiles)
        Files2Reslice{i,1} = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', [ROIFiles(i).name ',1']); %#ok<*SAGROW>
    end
    
    matlabbatch{1}.spm.spatial.coreg.write.ref = {Anat};
    matlabbatch{1}.spm.spatial.coreg.write.source = Files2Reslice;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
    
    SaveMatLabBatch(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', ['Reslice_', SubLs(iSub).name, '_jobs_', datestr(now, DateFormat), '.mat']), matlabbatch)
    
    spm_jobman('run', matlabbatch)
    
end