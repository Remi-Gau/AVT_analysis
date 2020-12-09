% (C) Copyright 2020 Remi Gau
clear;
clc;

% Set do to 0 if you want to run the script but not let SPM run the actual
% job. Can be useful to check that data is unzipped...
Do = 1;

DateFormat = 'yyyy_mm_dd_HH_MM';

spm_jobman('initcfg');

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

for iSub = NbSub % for each subject

    fprintf('Processing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    cd(fullfile(SubDir));

    % identify the number of sessions
    SesLs = dir('ses*');
    NbSes = numel(SesLs);

    % --------------------------%
    %     DEFINES    BATCH      %
    % --------------------------%
    matlabbatch = {};
    matlabbatch{1}.spm.temporal.st.nslices = 48;
    matlabbatch{1}.spm.temporal.st.tr = 3;
    matlabbatch{1}.spm.temporal.st.ta = 3 - (3 / 48);
    matlabbatch{1}.spm.temporal.st.so = 48:-1:1;
    matlabbatch{1}.spm.temporal.st.refslice = 24;
    matlabbatch{1}.spm.temporal.st.prefix = 'a';

    RunInd = 1;
    for iSes = 1:NbSes % for each session

        % Gets all the runs for that session
        cd(fullfile(SubDir, SesLs(iSes).name, 'func'));

        Runs = spm_select('FPList', fullfile(pwd), ...
                          ['^uv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii.gz$']);
        fprintf(' Unzipping files\n');
        gunzip(cellstr(Runs));

        Runs = spm_select('FPList', fullfile(pwd), ...
                          ['^uv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii$']);

        for iRuns = 1:size(Runs, 1)

            % Gets all the images in each 4D volume
            Files = spm_vol(Runs(iRuns, :));
            for iFiles = 1:length(Files)
                matlabbatch{1}.spm.temporal.st.scans{RunInd}{iFiles, 1} = ...
                    [Files(iFiles).fname, ',', num2str(iFiles)];
            end
            clear Files;

            disp(matlabbatch{1}.spm.temporal.st.scans{RunInd});

            RunInd = RunInd + 1;
        end

        clear Runs;
    end

    cd(fullfile(SubDir));
    save (strcat('SliceTiming_', SubLs(iSub).name, '_', datestr(now, DateFormat),  '_matlabbatch'), 'matlabbatch');

    fprintf('\n\n');
    disp('%%%%%%%%%%%%%%%%%%');
    disp('   SLICE TIMING   ');
    disp('%%%%%%%%%%%%%%%%%%');

    if Do
        spm_jobman('run', matlabbatch);
    end

    fprintf(' Cleaning');
    for iSes = 1:NbSes
        cd(fullfile(SubDir, SesLs(iSes).name, 'func'));
        %         delete(['uv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-*_bold.nii'])
    end

end

cd (StartDir);
