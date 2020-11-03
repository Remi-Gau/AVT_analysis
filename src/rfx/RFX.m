clear;
clc;

spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<NUSED>

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(fullfile(StartDir, 'code', 'subfun'));

mkdir(fullfile(StartDir, 'rfx'));

SubLs = dir('sub*');
NbSub = numel(SubLs);

% load an SPM.mat to get the details about all the 1rst level contrasts
load(fullfile(StartDir, SubLs(1).name, 'ffx_nat_smooth', 'SPM.mat'));

for iCon = 1:numel(SPM.xCon)

  Name = SPM.xCon(iCon).name;
  if any(ismember(Name, '>'))
    [~, ~, ~] = mkdir(fullfile(StartDir, 'rfx', Name));
    cd(fullfile(StartDir, 'rfx', Name));
    delete *.mat;

    % Define batch
    matlabbatch = {};

    % Model
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    matlabbatch{1}.spm.stats.factorial_design.dir = {fullfile(StartDir, 'rfx', Name)};

    % Get the normalized con images
    tmp = {};
    for iSub = 1:NbSub
      tmp{end + 1, 1} = fullfile(StartDir, SubLs(iSub).name, 'ffx_nat_smooth', 'con', ...
                                 ['wcon_' sprintf('%04.0f', iCon) '.nii,1']); %#ok<*SAGROW>
    end
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = tmp;

    % Estimation
    matlabbatch{1, end + 1} = {};
    matlabbatch{1, end}.spm.stats.fmri_est.spmmat{1, 1} = fullfile(StartDir, 'rfx', Name, 'SPM.mat');     % set the spm file to be estimated
    matlabbatch{1, end}.spm.stats.fmri_est.method.Classical = 1;

    % Contrast
    matlabbatch{1, end + 1} = {};
    matlabbatch{1, end}.spm.stats.con.spmmat = {fullfile(StartDir, 'rfx', Name, 'SPM.mat')};
    matlabbatch{1, end}.spm.stats.con.delete = 1;
    matlabbatch{1, end}.spm.stats.con.consess{1}.tcon.name = '1';
    matlabbatch{1, end}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{1, end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{1, end}.spm.stats.con.consess{2}.tcon.name = '-1';
    matlabbatch{1, end}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{1, end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

    % Save
    SaveMatLabBatch(fullfile(StartDir, 'rfx', Name, 'matlabbatch.mat'), matlabbatch);

    % Run
    spm_jobman('run', matlabbatch);
  end

end
