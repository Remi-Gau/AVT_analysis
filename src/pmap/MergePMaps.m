clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

%% Visual
cd(fullfile(StartDir, 'pmap', 'ret'));

ROIs = {
        '1', '2'
        '3', '4'
        '5', '6'
        '7', ''
        '13', ''};

for i = 1:size(ROIs, 1)

    Files1 = spm_select('FPList', fullfile(StartDir, 'pmap', 'ret'), ...
                        ['^perc_VTPM_vol_roi' ROIs{i, 1} '_.h.nii$']);
    Files2 = spm_select('FPList', fullfile(StartDir, 'pmap', 'ret'), ...
                        ['^perc_VTPM_vol_roi' ROIs{i, 2} '_.h.nii$']);

    Files = cat(1, Files1, Files2);

    Files;

    Hdr = spm_vol(Files);
    Vol = spm_read_vols(Hdr);

    Vol = sum(Vol, 4);

    Hdr = Hdr(1);

    disp(['V' num2str(i) '_Pmap_Ret.nii']);

    Hdr.fname = (['V' num2str(i) '_Pmap_Ret.nii']);

    spm_write_vol(Hdr, Vol);

end

%% Visual
cd(fullfile(StartDir, 'pmap', 'BT'));

ROIs = { ...
        '1.25mm_IPL_._6_6.nii'; ...
        '1.25mm_PoG_._4_2.nii'; ...
        '1.25mm_PrG_._6_5.nii'; ...
        '1.25mm_STG_._6_1.nii'; ...
        '1.25mm_STG_._6_2.nii'; ...
        '1.25mm_STG_._6_3.nii'; ...
        '1.25mm_STG_._6_4.nii'; ...
        '1.25mm_STG_._6_5.nii'; ...
        '1.25mm_STG_._6_6.nii'};

for i = 1:size(ROIs, 1)

    Files = spm_select('FPList', fullfile(StartDir, 'pmap', 'BT'), ...
                       ['^' ROIs{i} '$']);

    Files;

    Hdr = spm_vol(Files);
    Vol = spm_read_vols(Hdr);

    Vol = sum(Vol, 4);

    Hdr = Hdr(1);

    disp([ROIs{i}(8:10) ROIs{i}(13:end)]);

    Hdr.fname = ([ROIs{i}(8:10) ROIs{i}(13:end)]);

    spm_write_vol(Hdr, Vol);

end
