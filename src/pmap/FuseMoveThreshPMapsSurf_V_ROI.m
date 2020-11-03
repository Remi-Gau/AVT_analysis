%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

% ROIs={...
%     'V1_Pmap_Ret';...
%     'V2_Pmap_Ret';...
%     'V3_Pmap_Ret';...
%     'V4_Pmap_Ret';...
%     'V5_Pmap_Ret'};
%
% Thresh = 10;

for iSub = 1:NbSub

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);

  cd(fullfile(SubDir, 'pmap'));
  ROI_dir = dir('exp-*');
  NbROI = numel(ROI_dir);

  for iROI = 1:NbROI
    %% unzip files
    cd(fullfile(SubDir, 'pmap', ROI_dir(iROI).name, [ROI_dir(iROI).name '-A'], 'MeshDataToVolume'));
    gunzip('*data.nii.gz');
    movefile(fullfile(SubDir, 'pmap', ROI_dir(iROI).name, [ROI_dir(iROI).name '-A'], 'MeshDataToVolume', '*data.nii'), ...
             fullfile(SubDir, 'pmap', ROI_dir(iROI).name));

    cd(fullfile(SubDir, 'pmap', ROI_dir(iROI).name, [ROI_dir(iROI).name '-B'], 'MeshDataToVolume'));
    gunzip('*data.nii.gz');
    movefile(fullfile(SubDir, 'pmap', ROI_dir(iROI).name, [ROI_dir(iROI).name '-B'], 'MeshDataToVolume', '*data.nii'), ...
             fullfile(SubDir, 'pmap', ROI_dir(iROI).name));

    %% fuse
    Files = spm_select('FPList', fullfile(SubDir, 'pmap', ROI_dir(iROI).name), ...
                       ['^' SubLs(iSub).name '.*data.nii$']);

    hdr = spm_vol(Files);
    vol = spm_read_vols(hdr);

    hdr = hdr(1);
    hdr.fname = strrep(hdr.fname, '_lcr_', '_');

    vol = sum(vol, 4);

    spm_write_vol(hdr, vol);

    movefile(fullfile(SubDir, 'pmap', ROI_dir(iROI).name, '*data.nii'), ...
             fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));
  end

end

cd(StartDir);
