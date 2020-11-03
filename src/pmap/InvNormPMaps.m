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
  matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;

  % Get inverse normalization deformation field
  DefField = dir(fullfile(SubDir, 'anat', 'spm', ...
                          'iy_sub-*_ses-*_MP2RAGE_T1w.nii'));
  matlabbatch{1}.spm.spatial.normalise.write.subj.def = {fullfile(SubDir, 'anat', 'spm', DefField.name)};

  % List ROIs to inv-norm
  Img2Process = {};

  %     cd(fullfile(StartDir, 'pmap', 'cyt'))
  %     filesdir = dir('m*.nii');
  %     for iImg=1:length(filesdir)
  %         Img2Process{iImg,1} = fullfile(StartDir, 'pmap', 'cyt', strcat(filesdir(iImg).name, ',1')); %#ok<*SAGROW>
  %     end

  cd(fullfile(StartDir, 'pmap', 'ret'));
  filesdir = dir('V*.nii');
  for iImg = 1:length(filesdir)
    Img2Process{end + 1, 1} = fullfile(StartDir, 'pmap', 'ret', strcat(filesdir(iImg).name, ',1')); %#ok<*SAGROW>
  end

  cd(fullfile(StartDir, 'pmap', 'BT'));
  filesdir = dir('*.nii');
  for iImg = 1:length(filesdir)
    Img2Process{end + 1, 1} = fullfile(StartDir, 'pmap', 'BT', strcat(filesdir(iImg).name, ',1')); %#ok<*SAGROW>
  end

  matlabbatch{1}.spm.spatial.normalise.write.subj.resample = Img2Process;

  save (fullfile(SubDir, strcat('InvNormPMap_', SubLs(iSub).name, '_matlabbatch')), 'matlabbatch');

  spm_jobman('run', matlabbatch);

  % Move files
  mkdir(fullfile(SubDir, 'pmap'));

  %     movefile(fullfile(StartDir, 'pmap', 'cyt', 'w*.nii'), fullfile(SubDir,'pmap'))

  movefile(fullfile(StartDir, 'pmap', 'ret', 'w*.nii'), fullfile(SubDir, 'pmap'));

  movefile(fullfile(StartDir, 'pmap', 'BT', 'w*.nii'), fullfile(SubDir, 'pmap'));

  copyfile(fullfile(SubDir, 'anat', 'spm', 'msub-*_MP2RAGE_T1w.nii'), ...
           fullfile(SubDir, 'pmap'));

  cd (StartDir);

end
