% this script will that the mid-cortical depth level sets of all the
% subject and for each hemisphere identify which subject is the median
% subject and should be used as a target for the first round of surface
% registration

clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd(StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  SubDir = fullfile(StartDir, SubLs(iSub).name, 'anat', 'cbs');

  for hs = 1:2

    if hs == 1
      suffix = 'l';
    else
      suffix = 'r';
    end

    % identify the level set for that subject
    LevelSetFile = spm_select('FPList', SubDir, ...
                              ['^*MP2RAGE_T1map_thresh_clone_transform_strip_clone_transform_bound_mems_' suffix 'cr_gm_avg.nii$']);

    % unzip it if necessary
    if isempty(LevelSetFile)
      gunzip(spm_select('FPList', SubDir, ...
                        ['^*MP2RAGE_T1map_thresh_clone_transform_strip_clone_transform_bound_mems_' suffix 'cr_gm_avg.nii.gz$']));

      LevelSetFile = spm_select('FPList', SubDir, ...
                                ['^*MP2RAGE_T1map_thresh_clone_transform_strip_clone_transform_bound_mems_' suffix 'cr_gm_avg.nii$']);
    end

    % store it in vector form for each hemipshere
    tmp = spm_read_vols(spm_vol(LevelSetFile));
    LevetSetVols(:, iSub, hs) = tmp(:); %#ok<SAGROW>

  end

  clear LevelSetFile SubjectFolder SubjID tmp;

end
clear SubjInd;

for hs = 1:2

  % compute a mean level set across subjects
  MeanLevetSet = mean(LevetSetVols(:, :, hs), 2);

  if hs == 1
    suffix = 'l';
  else
    suffix = 'r';
  end

  fprintf(['\n' suffix 'hs\n']);
  % Compute the absolute distance of each subject to the mean level set
  MAD = abs(LevetSetVols(:, :, hs) - repmat(MeanLevetSet, [1, size(LevetSetVols, 2)]));
  % compute the mean absolute distance to the mean level set and the
  % subject with the minimum mean distance is taken as target
  MAD = mean(MAD);
  [MIN, I] = min(MAD);

  disp(SubLs(I).name);

end
