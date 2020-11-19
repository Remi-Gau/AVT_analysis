clear;
clc;

StartDir = fullfile(pwd, '..', '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

DateFormat = 'yyyy_mm_dd_HH_MM';

for iSub = 1:NbSub - 1

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);

  cd(fullfile(SubDir, 'ffx_nat', 'betas'));

  Files2Reorient = {};

  % Get files
  Files2Reorient{1} = fullfile(SubDir, 'ffx_nat', 'betas', [SubLs(iSub).name '_GLM_mask.nii,1']);
  M = dir('CoregMatrix_*.mat');
  load(fullfile(SubDir, 'ffx_nat', 'betas', M.name));

  matlabbatch{1}.spm.util.reorient.srcfiles = Files2Reorient;
  matlabbatch{1}.spm.util.reorient.transform.transM = M;
  matlabbatch{1}.spm.util.reorient.prefix = '';

  save (strcat('ReorientMasks_', SubLs(iSub).name, '_jobs_', datestr(now, DateFormat), '.mat'));

  spm_jobman('run', matlabbatch);

end
