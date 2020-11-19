clear;
clc;

CondNames = { ...
             'AStimL', 'AStimR'; ...
             'VStimL', 'VStimR'; ...
             'TStimL', 'TStimR'; ...
             'ATargL', 'ATargR'; ...
             'VTargL', 'VTargR'; ...
             'TTargL', 'TTargR' ...
            };

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

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

for iSub = 1:NbSub % for each subject

  fprintf('Processing %s\n', SubLs(iSub).name);

  [~, ~, ~] = mkdir(fullfile(StartDir, SubLs(iSub).name, dest_dir, 'betas'));

  %% Creates a cell that lists the full names of the different beta images
  load(fullfile(StartDir, SubLs(iSub).name, 'ffx_nat', 'SPM.mat'));

  % Regressor numbers
  RegNumbers = GetRegNb(SPM);

  % Select the right betas to transfer
  BetaOfInterest = GetBOI(SPM, CondNames);

  % Copyfiles
  if ~RSA && ~Trim
    copyfile(fullfile(StartDir, SubLs(iSub).name, 'ffx_nat', 'mask.nii'), ...
             fullfile(StartDir, SubLs(iSub).name, 'ffx_nat', 'betas', [SubLs(iSub).name '_GLM_mask.nii']));

    copyfile(fullfile(StartDir, SubLs(iSub).name, 'ses-1', ...
                      'func', 'meanuvsub-*_ses-*_task-audiovisualtactile_run-*_bold.nii'), ...
             fullfile(StartDir, SubLs(iSub).name));

    copyfile(fullfile(StartDir, SubLs(iSub).name, 'meanuvsub-*_ses-*_task-audiovisualtactile_run-*_bold.nii'), ...
             fullfile(StartDir, SubLs(iSub).name, 'ffx_nat', 'betas'));
  end

  disp(BetaOfInterest);

  for iBeta = 1:size(BetaOfInterest, 1)
    copyfile(fullfile(StartDir, SubLs(iSub).name, dest_dir, [prefix 'beta_' sprintf('%04.0f', BetaOfInterest(iBeta)) '.nii']), ...
             fullfile(StartDir, SubLs(iSub).name, dest_dir, 'betas', [SubLs(iSub).name '_' prefix 'beta-' sprintf('%04.0f', BetaOfInterest(iBeta)) '.nii']));
  end

  clear SPM BetaOfInterest;

end
