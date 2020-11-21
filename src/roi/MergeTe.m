% (C) Copyright 2020 Remi Gau
clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

NbWorkers = 2;

SubLs = dir('sub*');
NbSub = numel(SubLs);

Sufix = {'', '_L', '_R'};

[KillGcpOnExit] = OpenParWorkersPool(NbWorkers);

parfor iSub = 1:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    cd(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    for i = 1:numel(Sufix)
        Files = dir(['rwTe1*' Sufix{i} '_Cyt.nii']);

        Hdr = spm_vol(char({Files.name}'));
        Vol = spm_read_vols(Hdr);

        Vol = sum(Vol, 4);

        Hdr = Hdr(1);

        Hdr.fname = (['rwTe' Sufix{i} '_Cyt.nii']);

        spm_write_vol(Hdr, Vol);
    end

end

CloseParWorkersPool(KillGcpOnExit);
