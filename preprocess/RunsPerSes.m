clear; clc

StartDir = fullfile(pwd, '..','..');
cd (StartDir)

SubLs = dir('sub*');
NbSub = numel(SubLs);



for iSub = 1:NbSub % for each subject
    
    RunPerSes(iSub) = struct('Subject', SubLs(iSub).name, 'RunsPerSes', []); %#ok<SAGROW>
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    
    cd(fullfile(SubDir))
    
    % identify the number of sessions
    SesLs = dir('ses*');
    NbSes = numel(SesLs);

    for iSes = 1:NbSes % for each session
        cd(fullfile(SubDir, SesLs(iSes).name, 'func'))
        NbRun = numel(dir('sub-*_ses-*_task-audiovisualtactile_run-*_bold.nii.gz'));
        RunPerSes(iSub).RunsPerSes(iSes) = NbRun;
    end
    
end

save(fullfile(StartDir,'RunsPerSes.mat'), 'RunPerSes')


cd (StartDir)