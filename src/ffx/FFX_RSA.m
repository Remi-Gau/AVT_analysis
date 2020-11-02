%%
clear;
clc;

ismultinorm = 1;
normmode = 'overall';
distfun = 'Mahalanobis'; % Euclidean Mahalanobis Correlation cvEuclidean cvMahalanobis

%%
spm_jobman('initcfg');
spm_get_defaults;
global defaults %#ok<*NUSED>
defaults.stats.maxmem = 2^31;

DateFormat = 'yyyy_mm_dd_HH_MM';
% diary(['diary_FFX_RSA_' datestr(now, DateFormat) '.out'])

%%
StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

ROIs = {
        'wA41-42.nii'
        'wTe10_Cyt.nii'
        'wTe11_Cyt.nii'
        'wTe12_Cyt.nii'
        'wV1_ProbRet.nii'
        'wV2_ProbRet.nii'
        'wV3_ProbRet.nii'
        'wV4_ProbRet.nii'
        'wV5_ProbRet.nii'};

for iSub = 1:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    cd(fullfile(SubDir));

    [~, ~, ~] = mkdir('ffx_rsa');

    FFX_nat_dir = fullfile(SubDir, 'ffx_nat');

    %% ROIs: creates a mask of all the ROIs
    for iROI = 1:numel(ROIs)
        ROI{iROI, 1} = spm_select('FPList', fullfile(SubDir, 'roi', 'vol', 'mni'), ...
                                  ['^' ROIs{iROI} '$']); %#ok<*SAGROW>
    end

    ROI_hdr = spm_vol(char(ROI));
    ROI_vol = any(spm_read_vols(ROI_hdr), 4);

    cd(fullfile(SubDir, 'ffx_rsa'));

    ROI_hdr = ROI_hdr(1);
    ROI_hdr.fname = fullfile(SubDir, 'ffx_rsa', 'mask_all_rois.nii');
    spm_write_vol(ROI_hdr, ROI_vol);

    TargetScan = spm_select('FPList', fullfile(SubDir, 'ses-1', 'func'), ...
                            '^meanuvsub-.*_task-audiovisualtactile_run-01_bold.nii$');

    SourceScan  = spm_select('FPList', fullfile(SubDir, 'anat', 'spm'), ...
                             '^msub-.*_MP2RAGE_T1w.nii$');
    copyfile(SourceScan, fullfile(SubDir, 'ffx_rsa'));
    SourceScan  = spm_select('FPList', fullfile(SubDir, 'ffx_rsa'), ...
                             '^msub-.*_MP2RAGE_T1w.nii$');

    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {TargetScan};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {SourceScan};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {fullfile(SubDir, 'ffx_rsa', 'mask_all_rois.nii')};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2 1 .8];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [5 5];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

    spm_jobman('run', matlabbatch);

    spm_smooth(fullfile(SubDir, 'ffx_rsa', 'rmask_all_rois.nii'), ...
               fullfile(SubDir, 'ffx_rsa', 'srmask_all_rois.nii'), 12);

    %% Mask info
    mask.global.hdr = spm_vol(fullfile(FFX_nat_dir, 'mask.nii'));
    mask.global.img = logical(spm_read_vols(mask.global.hdr));
    mask.ROI.hdr = spm_vol(fullfile(SubDir, 'ffx_rsa', 'srmask_all_rois.nii'));
    mask.ROI.img = logical(spm_read_vols(mask.ROI.hdr));
    mask.comb.img = mask.ROI.img .* mask.global.img;

    [X, Y, Z] = ind2sub(size(mask.comb.img), find(mask.comb.img));
    mask.comb.XYZ = [X'; Y'; Z'];
    clear X Y Z;

    ROI_hdr = mask.ROI.hdr;
    ROI_hdr.fname = fullfile(SubDir, 'ffx_rsa', 'combined_mask.nii');
    spm_write_vol(ROI_hdr, mask.comb.img);

    %% Get SPM.mat
    load(fullfile(FFX_nat_dir, 'SPM.mat'));

    %% Get fullpaths of preprocessed images
    VolIn = SPM.xY.VY;
    for i = 1:numel(VolIn)
        % Backward compatibility: propagate scaling (see spm_fmri_spm_ui.m)
        VolIn(i).private.dat.scl_slope = VolIn(i).pinfo(1);
        VolIn(i).private.dat.scl_inter = VolIn(i).pinfo(2);
    end
    VolIn = spm_changepath(VolIn, ...
                           '/data', '/home/rxg243/Documents/Data'); % the files have been moved

    %% Decompressing images
    fprintf('\n Decompressing images (if necessary)\n');
    fprintf(' [');
    for i = 1:numel(VolIn)
        if mod(i, numel(VolIn) / 20) == 0
            fprintf('.');
        end
        if ~exist(VolIn(i).fname, 'file')
            try
                gunzip([VolIn(i).fname '.gz']);
            catch
                error('file %s does not seem to exist', VolIn(i).fname);
            end
        end
    end
    fprintf(']\n');

    %% Reading data
    fprintf('\n Reading data');

    xY = spm_get_data(VolIn, mask.comb.XYZ);
    fprintf(' - DONE\n');

    %% Whitening and writing
    fprintf('\n Whitening betas\n');
    fprintf(' [');

    num_vox = size(xY, 2);
    Splits = round(linspace(0, num_vox, 5001));

    u_hat_all = nan(size(SPM.xX.X, 2), num_vox);
    for iSplit = 1:(numel(Splits) - 1)
        if mod(iSplit, (numel(Splits) - 1) / 20) == 0
            fprintf('.');
        end
        u_hat = rsa.spm.noiseNormalizeBeta( ...
                                           xY(:, 1 + Splits(iSplit):Splits(iSplit + 1)), ...
                                           SPM, 'normmode', normmode);
        u_hat_all(:, 1 + Splits(iSplit):Splits(iSplit + 1)) = u_hat;
    end
    fprintf(']\n');

    fprintf('\n Writing betas\n');
    fprintf(' [');
    for iBeta = 1:size(u_hat_all, 1)
        if any(iBeta == Splits)
            fprintf('.');
        end

        hdr = SPM.Vbeta(iBeta);
        hdr.fname = fullfile(SubDir, 'ffx_rsa', ['w' hdr.fname]);
        hdr.descrip = [hdr.descrip ' - whitened with RSA toolbox'];

        vol = nan(hdr.dim);

        vol(find(mask.comb.img)) = u_hat_all(iBeta, :); %#ok<FNDSB>

        spm_write_vol(hdr, vol);

    end
    fprintf(']\n');

    cd (StartDir);

end
