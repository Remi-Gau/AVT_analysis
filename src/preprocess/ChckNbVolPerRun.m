clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub % for each subject

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);
  cd(SubDir);

  % Identify the number of sessions
  SesLs = dir('ses*');
  NbSes = numel(SesLs);

  RunInd = 1;
  NbRuns = [];
  NbVols = [];

  for iSes = 1:NbSes % for each session

    % Gets all the runs for that session
    cd(fullfile(SubDir, SesLs(iSes).name, 'func'));

    IMG = dir('sub-*_ses-*_task-audiovisualtactile_run-*_bold.nii');

    NbRuns(iSes) = numel(IMG); %#ok<SAGROW>

    for iRuns = 1:length(IMG)

      % Gets all the images in each 4D volume
      IMG_ls = spm_vol(IMG(iRuns).name);

      NbVols(RunInd) = numel(IMG_ls); %#ok<SAGROW>

      RunInd = RunInd + 1;

    end
  end

  try
    %         movefile(fullfile(SubDir,'GLM_mask.nii'), fullfile(SubDir,[SubLs(iSub).name '-GLM_mask.nii']))
    copyfile(fullfile(SubDir, 'ses-1', 'func', 'mean*.nii'), ...
             fullfile(SubDir));
  catch
  end

  disp(NbRuns);
  disp(NbVols);

end
