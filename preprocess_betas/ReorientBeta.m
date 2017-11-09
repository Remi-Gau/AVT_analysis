clear; clc;

StartDir = fullfile(pwd, '..','..');
cd (StartDir)

SubLs = dir('sub*');
NbSub = numel(SubLs);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

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

for iSub = 1:NbSub
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    cd(fullfile(SubDir, dest_dir, 'betas'))
    
    Files2Reorient = {}; %#ok<NASGU>
    
    % Get files
    Files2Reorient = cellstr(spm_select('FPList', fullfile(SubDir, dest_dir, 'betas'), ...
            ['^' SubLs(iSub).name '_' prefix 'beta-.*.nii$']));

    M = dir(fullfile(SubDir, 'ffx_nat','betas', 'ReorientMatrix_*.mat'));
    load(fullfile(SubDir, 'ffx_nat','betas', M.name))
    
    matlabbatch{1}.spm.util.reorient.srcfiles = Files2Reorient;
    matlabbatch{1}.spm.util.reorient.transform.transM = M;
    matlabbatch{1}.spm.util.reorient.prefix = '';
    
    M = dir(fullfile(SubDir, 'ffx_nat','betas', 'CoregMatrix_*.mat'));
    load(fullfile(SubDir,  'ffx_nat','betas', M.name))

    matlabbatch{2}.spm.util.reorient.srcfiles = Files2Reorient;
    matlabbatch{2}.spm.util.reorient.transform.transM = M;
    matlabbatch{2}.spm.util.reorient.prefix = '';

    save (fullfile(SubDir, dest_dir, 'betas', strcat('Reorient_', SubLs(iSub).name, '_jobs_', datestr(now, DateFormat), '.mat')));
    
    spm_jobman('run', matlabbatch)

end