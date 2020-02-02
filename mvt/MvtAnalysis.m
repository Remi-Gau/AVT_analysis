% Analyizes realignement parameters and computes / plots several QC results
clear; clc; close all

StartDir = fullfile(pwd, '..', '..');
addpath(genpath(fullfile(StartDir, 'AVT-7T-code', 'subfun')))

SubLs = dir(fullfile(StartDir,'sub*'));
NbSub = numel(SubLs);

OutputMat = fullfile(StartDir,'results','MvtRecap.mat');
OutputTSV = fullfile(StartDir,'results','MvtRecap.csv');

FD_threshold = .4; % mm

idx = 1;

for iSub = 1:NbSub % for each subject
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    Anat_spm_dir = fullfile(SubDir, 'anat', 'spm');
    
    % Compute radius of brain center to surface
    anat_file = spm_select('FPList', Anat_spm_dir, ['^' SubLs(iSub).name  '_ses-[12]_MP2RAGE_T1w.nii$']);
    radius = spmup_comp_dist2surf(anat_file);
    

    % Plots results
    RP_files = spm_select('FPList', fullfile(SubDir,'mvt') , '^rp.*.txt$');
    for iRP_file = 1:size(RP_files,1)
        [FD,RMS,motion] = spmup_FD(RP_files(iRP_file,:),radius, FD_threshold);
        
        MovementRecap(idx,1:2) = [iSub iRP_file];  %#ok<*SAGROW>
        % mean framewise displacement for this run
        MovementRecap(idx,3) = mean(FD(:,1)); 
        % number of time points with FD above threshold
        MovementRecap(idx,4) = sum(FD(:,3)); 
        % proportion of time points with FD above threshold
        MovementRecap(idx,5) = sum(FD(:,3))/size(FD,1); 
        % mean root mean square of mvt 
        MovementRecap(idx,6) = mean(RMS(:,1));
        % number of outlier time points for RMS
        MovementRecap(idx,7) = sum(RMS(:,2)); 
        % proportion of outlier time points for RMS
        MovementRecap(idx,8) = sum(RMS(:,2))/size(RMS,1); 
        
        idx =  idx +1;
    end
    
end




%%
Legends = {...
     'subject - run', ...
     'mean FD', 'FD outliers #time points' 'FD outliers %time points',...
     'mean RMS', 'RMS outliers #time points' 'RMS outliers %time points'};

save(OutputMat, 'Legends', 'MovementRecap', 'SubLs')

fid = fopen (OutputTSV, 'w');

for i=1:length(Legends)
    fprintf (fid, '%s,', Legends{i});
end

for iRow=1:size(MovementRecap,1)
    fprintf (fid, '\n');
    fprintf (fid, [SubLs(MovementRecap(iRow,1)).name '_run-' num2str(MovementRecap(iRow,2)) ',']);
    for iCol=3:size(MovementRecap,2)
        fprintf (fid, '%f,', MovementRecap(iRow,iCol));  
    end
end


fprintf (fid, '\n\n\n\n');

Legends = {...
     'subject', ...
     'mean FD', 'FD outliers #time points' 'FD outliers %time points',...
     'mean RMS', 'RMS outliers #time points' 'RMS outliers %time points'};

 for i=1:length(Legends)
    fprintf (fid, '%s,', Legends{i});
end

 for iSub = 1:NbSub
    fprintf (fid, '\n');
    fprintf (fid, [SubLs(iSub).name ',']);
    row_to_select = MovementRecap(:,1)==iSub;
    for iCol=3:size(MovementRecap,2)
        MovementRecapSubj(iSub,iCol-2) =  mean(MovementRecap(row_to_select,iCol));
        fprintf (fid, '%f,', mean(MovementRecap(row_to_select,iCol)));  
    end
 end

fprintf (fid, '\n\n\nMEAN,'); 
for iCol=1:size(MovementRecapSubj,2)
    fprintf (fid, '%f,', mean(MovementRecapSubj(:,iCol)));
end
fprintf (fid, '\nSTD,'); 
for iCol=1:size(MovementRecapSubj,2)
    fprintf (fid, '%f,', std(MovementRecapSubj(:,iCol)));
end

fclose (fid);