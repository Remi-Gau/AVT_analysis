% (C) Copyright 2020 Remi Gau
clear;
clc;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = 1:NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    SubDir = fullfile(StartDir, SubLs(iSub).name);

    cd(fullfile(SubDir, 'roi', 'vol', 'mni', 'upsamp'));

    Files2Compress = dir('*.nii');

    for iFile = 1:size(Files2Compress, 1)
        disp(Files2Compress(iFile).name);
        gzip(Files2Compress(iFile).name);
        delete(Files2Compress(iFile).name);
    end

    clear SPM BetaOfInterest;

end
