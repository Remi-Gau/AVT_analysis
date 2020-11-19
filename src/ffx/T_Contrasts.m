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

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = NbSub % for each subject

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);
  cd(fullfile(SubDir, 'ffx_nat'));

  %% Get the regressors name
  load SPM.mat;
  TEMP = char(SPM.xX.name');
  TEMP(:, 1:6) = [];
  for i = 1:size(TEMP, 1)
    if TEMP(i, 1) == ' '
      RegNames(i, :) = [TEMP(i, 2:end) ' ']; %#ok<*SAGROW>
    else
      RegNames(i, :) = TEMP(i, :);
    end
  end
  clear SPM;

  %% Define batch
  matlabbatch = {};
  matlabbatch{1}.spm.stats.con.spmmat = {fullfile(SubDir, 'ffx_nat', 'SPM.mat')};
  matlabbatch{1}.spm.stats.con.delete = 1;

  %% Simple contrasts
  % > baseline
  All = zeros(size(RegNames, 1), 1);
  for i = 1:numel(CondNames)
    % Identify the regressors corresponding to that condition
    TEMP = strcmp([CondNames{i} '*bf(1)'], cellstr(RegNames));
    All = All + TEMP;
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.name = strcat(CondNames{i}, ' > Baseline');
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = TEMP * 1; % the *1 is there to get rid of the logical indexing
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';
    clear TEMP;
  end

  matlabbatch{1}.spm.stats.con.consess{end + 1}.tcon.name = 'All > Baseline';
  matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = All;
  matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';

  clear All;

  % < baseline
  All = zeros(size(RegNames, 1), 1);
  for i = 1:numel(CondNames)
    TEMP = strcmp([CondNames{i} '*bf(1)'], cellstr(RegNames));
    All = All + TEMP * -1;
    matlabbatch{1}.spm.stats.con.consess{end + 1}.tcon.name = strcat(CondNames{i}, ' < Baseline');
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = TEMP * -1;
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';
    clear TEMP;
  end

  matlabbatch{1}.spm.stats.con.consess{end + 1}.tcon.name = 'All < Baseline';
  matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = All;
  matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';

  clear All;

  %% Pooled over sides
  for i = 1:size(CondNames, 1)
    % Identify the regressors corresponding to that condition
    TEMP = strcmp([CondNames{i, 1} '*bf(1)'], cellstr(RegNames));
    TEMP2 = strcmp([CondNames{i, 2} '*bf(1)'], cellstr(RegNames));
    TEMP = TEMP + TEMP2;

    matlabbatch{1}.spm.stats.con.consess{end + 1}.tcon.name = strcat(CondNames{i, 1}(1:end - 1), ' > Baseline');
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = TEMP;
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';

    matlabbatch{1}.spm.stats.con.consess{end + 1}.tcon.name = strcat(CondNames{i, 1}(1:end - 1), ' < Baseline');
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = TEMP * -1;
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';
    clear TEMP TEMP2;
  end

  %% Left VS Right
  for i = 1:size(CondNames, 1)
    % Identify the regressors corresponding to that condition
    TEMP = strcmp([CondNames{i, 1} '*bf(1)'], cellstr(RegNames));
    TEMP2 = strcmp([CondNames{i, 2} '*bf(1)'], cellstr(RegNames));
    TEMP = TEMP - TEMP2;

    matlabbatch{1}.spm.stats.con.consess{end + 1}.tcon.name = strcat(CondNames{i, 1}, ' > ', CondNames{i, 2});
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = TEMP;
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';

    matlabbatch{1}.spm.stats.con.consess{end + 1}.tcon.name = strcat(CondNames{i, 1}, ' < ', CondNames{i, 2});
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.weights = TEMP * -1;
    matlabbatch{1}.spm.stats.con.consess{end}.tcon.sessrep = 'none';
    clear TEMP TEMP2;
  end

  %% Evaluate contrasts
  cd(fullfile(SubDir));
  save (strcat('T_Contrast_', SubLs(iSub).name, '_matlabbatch.mat'), 'matlabbatch');

  spm_jobman('run', matlabbatch);

  clear RegNames;

  cd (StartDir);

end
