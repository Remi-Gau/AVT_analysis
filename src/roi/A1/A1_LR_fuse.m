% (C) Copyright 2020 Remi Gau
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

    copyfile(fullfile(StartDir, 'A1_ROI_Def', [SubLs(iSub).name '_A1_*cr_RG_UN_data.nii']), ...
             fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    Files = spm_select('FPList', fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'), ...
                       ['^' SubLs(iSub).name '_A1_.*cr_RG_UN_data.nii$']);

    Files;

    Hdr = spm_vol(Files);
    A1_vol = spm_read_vols(Hdr);

    unique(A1_vol(:, :, :, 1));
    unique(A1_vol(:, :, :, 2));

    if ~sum(A1_vol(:) == 2) == 0
        A1_vol(A1_vol(:) == 1) = 0;
        A1_vol(A1_vol(:) == 2) = 1;
    end

    Hdr = Hdr(1);
    Hdr.fname = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', [SubLs(iSub).name '_A1_lcr.nii']);
    spm_write_vol(Hdr, A1_vol(:, :, :, 1));

    Hdr.fname = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', [SubLs(iSub).name '_A1_rcr.nii']);
    spm_write_vol(Hdr, A1_vol(:, :, :, 2));

    A1_vol = sum(A1_vol, 4);
    Hdr.fname = fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp', [SubLs(iSub).name '_A1.nii']);
    spm_write_vol(Hdr, A1_vol);

end
