clear; clc

StartDir = fullfile(pwd, '..','..');
cd (StartDir)

SubLs = dir('sub*');
NbSub = numel(SubLs);



for iSub = 1:NbSub % for each subject
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    Files2check = spm_vol(spm_select('FPList', fullfile(SubDir, 'ffx_nat', 'betas'), ...
        ['^' SubLs(iSub).name '_beta-.*.nii$']));
    
    Files2check2 = spm_vol(spm_select('FPList', fullfile(SubDir, 'ffx_rsa', 'betas'), ...
        ['^' SubLs(iSub).name '_wbeta-.*.nii$']));
    
    Files2check3 = spm_vol(spm_select('FPList', fullfile(SubDir, 'ffx_trim', 'betas'), ...
        ['^' SubLs(iSub).name '_beta-.*.nii$']));
    
    A = cat(1,Files2check,Files2check2,Files2check3);
    
    spm_check_orientations(A)

    clear A Files2check Files2check2 Files2check3
    
end