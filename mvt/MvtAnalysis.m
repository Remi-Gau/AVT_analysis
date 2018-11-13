% Analyizes realignement parameters and computes / plots several QC results
clear; clc

StartDir = fullfile(pwd, '..','..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

SubLs = dir(fullfile(StartDir,'sub*'));
NbSub = numel(SubLs);

for iSub = 1:NbSub % for each subject
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    Anat_spm_dir = fullfile(SubDir, 'anat', 'spm');
    
    % Compute radius of brain center to surface
    anat_file = spm_select('FPList', Anat_spm_dir, ['^' SubLs(iSub).name  '_ses-[12]_MP2RAGE_T1w.nii$']);
    radius = spmup_comp_dist2surf(anat_file);
    
    %     [FD,RMS,motion] = spmup_FD(realignment_file,radius)
    
    
    
end