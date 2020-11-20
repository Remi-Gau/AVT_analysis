%%
Ls = dir('ROI_auditory_Te*_MNI.nii');
for iROI = 1:numel(Ls)
    movefile(Ls(iROI).name, [Ls(iROI).name(14:end - 8) '.nii']);
end

%%
Ls = dir('TE_*_p>.6_lh.nii');
for iROI = 1:numel(Ls)
    movefile(Ls(iROI).name, ['Te' Ls(iROI).name(4) Ls(iROI).name(6) '_L' Ls(iROI).name(7:11) '_Cyt.nii']);
end

%%
Ls = dir('TE_*_p>.6_rh.nii');
for iROI = 1:numel(Ls)
    movefile(Ls(iROI).name, ['Te' Ls(iROI).name(4) Ls(iROI).name(6) '_R' Ls(iROI).name(7:11) '_Cyt.nii']);
end

%%
for iROI = 2:5
    Ls = dir(['ROI_Visual_hOc' num2str(iROI) '*MNI.nii']);
    Hdr = spm_vol(char({Ls.name}'));
    Vols = spm_read_vols(Hdr);
    Hdr = Hdr(1);
    Hdr.fname = ['V' num2str(iROI) '_Cyt.nii'];
    spm_write_vol(Hdr, sum(Vols, 4));
    clear Hdr Vols Ls;
end
