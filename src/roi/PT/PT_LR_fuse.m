%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub

  fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

  % Subject directory
  SubDir = fullfile(StartDir, SubLs(iSub).name);

  copyfile(fullfile(StartDir, 'PT_ROI_Def', [SubLs(iSub).name '*cr_gm_avg_data_data.nii']), fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

  Files = spm_select('FPList', fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'), ...
                     ['^' SubLs(iSub).name '.*cr_gm_avg_data_data.nii$']);

  Files;

  Hdr = spm_vol(Files);
  PT_vol = spm_read_vols(Hdr);

  unique(PT_vol(:, :, :, 1));
  unique(PT_vol(:, :, :, 2));

  if ~sum(PT_vol(:) == 2) == 0
    PT_vol(PT_vol(:) == 1) = 0;
    PT_vol(PT_vol(:) == 2) = 1;
  end

  Hdr = Hdr(1);
  Hdr.fname = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', [SubLs(iSub).name '_PT_lcr.nii']);
  spm_write_vol(Hdr, PT_vol(:, :, :, 1));

  Hdr.fname = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', [SubLs(iSub).name '_PT_rcr.nii']);
  spm_write_vol(Hdr, PT_vol(:, :, :, 2));

  PT_vol = sum(PT_vol, 4);
  Hdr.fname = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', [SubLs(iSub).name '_PT.nii']);
  spm_write_vol(Hdr, PT_vol);

end
