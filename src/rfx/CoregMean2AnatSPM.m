clear;
clc;

spm_get_defaults;
global defaults %#ok<NUSED>

flags = struct( ...
               'sep', [4 2 1 0.75], ...
               'params',  [0 0 0  0 0 0], ...
               'cost_fun', 'nmi', ...
               'tol', [repmat(0.001, 1, 3), repmat(0.0005, 1, 3), repmat(0.005, 1, 3), repmat(0.0005, 1, 3)], ...
               'fwhm', [5, 5], ...
               'graphics', ~spm('CmdLine'));

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = [2 4] % 1:NbSub % for each subject

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);

  Img2Process = {};
  TargetScan = []; %#ok<NASGU>
  SourceScan = []; %#ok<NASGU>

  TargetScan = dir(fullfile(SubDir, 'anat', 'spm', ...
                            'msub-*_ses-*_MP2RAGE_T1w.nii'));
  TargetScan = fullfile(SubDir, 'anat', 'spm', ...
                        TargetScan.name);

  cd(fullfile(SubDir, 'ffx_nat_smooth', 'con'));

  SourceScan = dir(fullfile(SubDir, 'ffx_nat_smooth', 'con', ...
                            'mean*.nii'));
  SourceScan = fullfile(SubDir, 'ffx_nat_smooth', 'con', ...
                        SourceScan.name);

  tmp = dir('con*.nii');
  for FileInd = 1:length(tmp)
    Img2Process{end + 1, 1} = fullfile(SubDir, 'ffx_nat_smooth', 'con', tmp(FileInd).name); %#ok<SAGROW>
  end

  spm_coreg_reorient_save(TargetScan, SourceScan, Img2Process, flags);

end

cd(StartDir);
