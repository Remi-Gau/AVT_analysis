% (C) Copyright 2020 Remi Gau
clear;
clc;

NbWorkers = 2;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

SubLs = dir('sub*');
NbSub = numel(SubLs);

Sufix = {'', '_L', '_R'};

[KillGcpOnExit] = OpenParWorkersPool(NbWorkers);

parfor iSub = 2:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    cd(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    for i = 1:numel(Sufix)

        % Get header and ROI volumes of STG and TE
        TE_Hdr = spm_vol(['rwTe' Sufix{i} '_Cyt.nii']);
        TE_Vol = spm_read_vols(TE_Hdr);

        STG_Hdr = spm_vol(['rwHG_STG' Sufix{i} '_AAL.nii']);
        STG_Vol = spm_read_vols(STG_Hdr);

        % Exclude TE from STG and create a new ROI
        STG_Vol = logical(STG_Vol);
        STG_Vol(logical(TE_Vol)) = false;

        STG_Hdr.fname = (['rwSTG' Sufix{i} '.nii']);
        spm_write_vol(STG_Hdr, STG_Vol);

        % Create posterior STG by excluding from STG all the voxels that are
        % posterior of the most anterior voxel of TE
        pSTG_Vol = STG_Vol;
        pSTG_Hdr = STG_Hdr;
        pSTG_Hdr.fname = (['rwpSTG' Sufix{i} '.nii']);

        [I] = find(TE_Vol);
        [X, Y, Z] = ind2sub(pSTG_Hdr.dim, I);
        pSTG_Vol(:, 1:min(Y) - 1, :) = false;

        spm_write_vol(pSTG_Hdr, pSTG_Vol);

    end

end

CloseParWorkersPool(KillGcpOnExit);
