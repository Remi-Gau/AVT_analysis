% Smooths the data. They will only be used to create an inclusive mask for
% the subject level GLM

clear;
clc;

% Set do to 0 if you want to run the script but not let SPM run the actual
% job. Can be useful to check that data is unzipped...
Do = 1;

DateFormat = 'yyyy_mm_dd_HH_MM';
diary(['diary_smooth_native_' datestr(now, DateFormat) '.out']);

spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<NUSED>

% To speed things up and use parallel computing
% NbWorkers = 3;
% MatlabVer = version('-release');
% if str2double(MatlabVer(1:4))>2013
%     pool = gcp('nocreate');
%     if isempty(pool)
%         parpool(NbWorkers);
%     end
% else
%     if matlabpool('size') == 0 %#ok<*DPOOL>
%         matlabpool(NbWorkers)
%     elseif matlabpool('size') ~= NbWorkers
%         matlabpool close
%         matlabpool(NbWorkers)
%     end
% end

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'AVT-7T-code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = NbSub % for each subject

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);
  cd(SubDir);

  % Identify the number of sessions
  SesLs = dir('ses*');
  NbSes = numel(SesLs);

  % Defines batch
  matlabbatch = {};
  matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
  matlabbatch{1}.spm.spatial.smooth.dtype = 0;
  matlabbatch{1}.spm.spatial.smooth.im = 0;
  matlabbatch{1}.spm.spatial.smooth.prefix = 's';
  matlabbatch{1}.spm.spatial.smooth.data = {};

  for iSes = 1:NbSes % for each session

    % Gets all the runs for that session
    cd(fullfile(SubDir, SesLs(iSes).name, 'func'));

    % Identify all the EPI files of interest

    % If the file are zipped uncomment the following lines
    %         Runs = spm_select('FPList', fullfile(pwd),...
    %             ['^auv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii.gz$']);
    %         fprintf(' Unzipping files\n')
    %         gunzip(cellstr(Runs))

    Runs = spm_select('FPList', fullfile(pwd), ...
                      ['^auv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii$']);

    for iRuns = 1:size(Runs, 1)

      % Gets all the images in each 4D volume
      Files = spm_vol(Runs(iRuns, :));
      for j = 1:length(Files)
        matlabbatch{1}.spm.spatial.smooth.data{end + 1, 1} = ...
            [Files(j).fname, ',', num2str(j)];
      end
      clear Files;

    end

    % Just display to make sure that we got everything right
    disp(matlabbatch{1}.spm.spatial.smooth.data);

  end

  SaveMatLabBatch(fullfile(SubDir, ['SmoothNat_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch.mat']), matlabbatch);

  fprintf('\n');
  disp('%%%%%%%%%%%%');
  disp('   SMOOTH   ');
  disp('%%%%%%%%%%%%');

  if Do
    spm_jobman('run', matlabbatch);
  end

  fprintf(' Cleaning');
  for iSes = 1:NbSes
    cd(fullfile(SubDir, SesLs(iSes).name, 'func'));
    % Uncomment if you want to remove the slice timed EPIs and only
    % keep the compressed one. Be careful if you have no gunzipped
    % version of the data this might just delete it.
    %         delete(['auv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-*_bold.nii'])
  end

  cd (StartDir);

end

diary off;

% uncomment if you use parallel computing
% if str2double(MatlabVer(1:4))>2013
%     delete(gcp);
% else
%     matlabpool close
% end
