clear;
clc;

spm_get_defaults;
global defaults %#ok<NUSED>

StartDir = fullfile(pwd, '..', '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

DateFormat = 'yyyy_mm_dd_HH_MM';

for iSub = NbSub % for each subject

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);

  Anat = dir(fullfile(SubDir, 'anat', 'cbs', ...
                      [SubLs(iSub).name '*_thresh_clone_transform_strip_clone_transform_bound.nii']));
  Anat = fullfile(SubDir, 'anat', 'cbs', Anat.name);

  cd(fullfile(SubDir, 'ffx_nat', 'betas'));

  Files2Reslice = {};
  matlabbatch = {};

  % For betas
  cd(fullfile(SubDir, 'ffx_nat', 'betas'));
  MeanFiles = dir('meanu*.nii');
  for i = 1:numel(MeanFiles)
    Files2Reslice{i, 1} = fullfile(SubDir, 'ffx_nat', 'betas', [MeanFiles(i).name ',1']); %#ok<*SAGROW>
  end

  matlabbatch{1}.spm.spatial.coreg.write.ref = {Anat};
  matlabbatch{1}.spm.spatial.coreg.write.source = Files2Reslice;
  matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
  matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
  matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
  matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

  save (strcat('ResliceMean_', SubLs(iSub).name, '_jobs_', datestr(now, DateFormat), '.mat'));

  spm_jobman('run', matlabbatch);

end
