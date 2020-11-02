clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    cd(fullfile(SubDir, 'roi', 'vol', 'mni'));

    % Combine left and right for TE ROIs
    %     try
    %         Ls = dir('wTe10_*_Cyt.nii');
    %         Hdr = spm_vol(char({Ls.name}'));
    %         Vols = spm_read_vols(Hdr);
    %         Hdr=Hdr(1);
    %         Hdr.fname = 'wTe10_Cyt.nii';
    %         spm_write_vol(Hdr, sum(Vols,4));
    %         clear Hdr Vols Ls
    % %         delete('wTe10_*_Cyt.nii')
    %     catch
    %     end

    %     try
    %         Ls = dir('wTe11_*_Cyt.nii');
    %         Hdr = spm_vol(char({Ls.name}'));
    %         Vols = spm_read_vols(Hdr);
    %         Hdr=Hdr(1);
    %         Hdr.fname = 'wTe11_Cyt.nii';
    %         spm_write_vol(Hdr, sum(Vols,4));
    %         clear Hdr Vols Ls
    % %         delete('wTe11_*_Cyt.nii')
    %     catch
    %     end

    %     try
    %         Ls = dir('wTe12_*_Cyt.nii');
    %         Hdr = spm_vol(char({Ls.name}'));
    %         Vols = spm_read_vols(Hdr);
    %         Hdr=Hdr(1);
    %         Hdr.fname = 'wTe12_Cyt.nii';
    %         spm_write_vol(Hdr, sum(Vols,4));
    %         clear Hdr Vols Ls
    % %         delete('wTe12_*_Cyt.nii')
    %     catch
    %     end

    % Copy files
    mkdir(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    %     copyfile(fullfile(SubDir, 'roi','vol','mni', 'w*.nii'), ...
    %         fullfile(SubDir, 'roi','vol','mni','upsamp'))

    copyfile(fullfile(SubDir, 'roi', 'vol', 'mni', 'wA41*.nii'), ...
             fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    %     copyfile(fullfile(SubDir, 'anat','spm','msub-*_MP2RAGE_T1w.nii'), ...
    %         fullfile(SubDir, 'roi','vol','mni','upsamp'))
end
