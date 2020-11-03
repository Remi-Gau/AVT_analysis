clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 2:NbSub % for each subject

  [~, ~, ~] = mkdir(fullfile(StartDir, SubLs(iSub).name, 'anat', 'spm'));
  copyfile(fullfile(StartDir, SubLs(iSub).name, 'anat', 'sub-*_MP2RAGE_T1w.nii.gz'), ...
           fullfile(StartDir, SubLs(iSub).name, 'anat', 'spm'));
  gunzip(fullfile(StartDir, SubLs(iSub).name, 'anat', 'spm', 'sub-*_MP2RAGE_T1w.nii.gz'));
  delete(fullfile(StartDir, SubLs(iSub).name, 'anat', 'spm', 'sub-*_MP2RAGE_T1w.nii.gz'));

end
