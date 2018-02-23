% Gets the file from the BIDS and unzips some of them

clear; clc

StartDir = fullfile(pwd, '..','..');

cd(fullfile(StartDir, '..', 'sourcedata'))

SubLs = dir('sub*');
NbSub = numel(SubLs);


for iSub = NbSub % for each subject
    
    cd(fullfile(StartDir, '..', 'sourcedata'))
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    [~,~,~]=mkdir(fullfile(StartDir, SubLs(iSub).name));
    [~,~,~]=mkdir(fullfile(StartDir, SubLs(iSub).name), 'anat');
    cd(fullfile(SubLs(iSub).name))
    
    % identify the number of sessions
    SesLs = dir('ses*');
    NbSes = numel(SesLs);
    
    for iSes = 1:NbSes % for each session
        
        fprintf('\tProcessing %s\n', SesLs(iSes).name)
        
        [~,~,~]=mkdir(fullfile(StartDir, SubLs(iSub).name, SesLs(iSes).name));
        [~,~,~]=mkdir(fullfile(StartDir, SubLs(iSub).name, SesLs(iSes).name, 'fmap'));
        [~,~,~]=mkdir(fullfile(StartDir, SubLs(iSub).name, SesLs(iSes).name, 'func'));
        
        cd(fullfile(StartDir, '..', 'sourcedata', SubLs(iSub).name, SesLs(iSes).name))
        
        %% Move folders
        
        % Anatomy folders
        if exist('anat','dir')
            cd('anat')
            copyfile('*T1map.nii.gz' , fullfile(StartDir, SubLs(iSub).name, 'anat'))
            copyfile('*T1w.nii.gz' , fullfile(StartDir, SubLs(iSub).name, 'anat'))
            copyfile('*inv2.nii.gz' , fullfile(StartDir, SubLs(iSub).name, 'anat'))
            cd ..
        end

        % Field Map
        cd('fmap')
        copyfile('*.nii.gz' , fullfile(StartDir, SubLs(iSub).name, SesLs(iSes).name, 'fmap'))
        cd ..
        
        % BOLD series
        cd('func')
        copyfile('sub-*_ses-*_task-audiovisualtactile_run-*_bold.nii.gz' , ...
            fullfile(StartDir, SubLs(iSub).name, SesLs(iSes).name, 'func'))
        cd ..
        
        
        %% Unzips files
        cd(fullfile(StartDir, SubLs(iSub).name, SesLs(iSes).name, 'fmap'))
        gunzip('*.gz');
        delete('*.gz');
        
        cd(fullfile(StartDir, SubLs(iSub).name, SesLs(iSes).name, 'func'))
        gunzip('*.gz');
        delete('*.gz');

        
    end
end