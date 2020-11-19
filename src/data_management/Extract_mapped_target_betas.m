% Extract vtk files from a folder tree created by MIPAV/JIST
% and copies it somewhere else

clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

% opt.beta_mapping_pattern = '_target_beta-';
opt.beta_mapping_pattern = '_wbeta-';

for iSub = NbSub % for each subject

  fprintf('Processing %s\n', SubLs(iSub).name);

  SubDir = fullfile(StartDir, SubLs(iSub).name);

  SrcDir = fullfile(SubDir, 'ffx_rsa', 'betas', '6_surf');

  DestDir = fullfile(SubDir, 'ffx_rsa', 'betas', '6_surf');

  Extract_mapped_betas_VTK(SubLs(iSub).name, SrcDir, DestDir, opt, 0);

end
