clear; clc

DateFormat = 'yyyy_mm_dd_HH_MM';
diary(['diary_realign_' datestr(now, DateFormat) '.out'])

UseVDM = 1;
Do = 1;

spm_jobman('initcfg')
spm_get_defaults;
global defaults %#ok<*NUSED>

StartDir = fullfile(pwd, '..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

SubLs = dir('sub*');
NbSub = numel(SubLs);

% In case you want a speed up you can run a par for loop over subjects
% [KillGcpOnExit] = OpenParWorkersPool(2);

for iSub = NbSub % for each subject
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    
    cd(fullfile(SubDir))
    
    % identify the number of sessions
    SesLs = dir('ses*');
    NbSes = numel(SesLs);
    
    
    %% DEFINES BATCH
    matlabbatch = {};
    matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.quality = 1;
    matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.sep = 2;
    matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.fwhm = 3;
    matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 1 0];
    matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.weight = {''};
    
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 2;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    
    matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 1 0];
    matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.prefix = 'uv';
    
    RunInd = 1;
    for iSes = 1:NbSes % for each session
        
        % Gets all the VDM for that session
        cd(fullfile(SubDir, SesLs(iSes).name, 'fmap'))
        Vdm=spm_select('FPList', fullfile(pwd), '^vdm.*nii$');
        
        % Gets all the runs for that session
        cd(fullfile(SubDir, SesLs(iSes).name, 'func'))
        
        Runs = spm_select('FPList', fullfile(pwd),...
            ['^' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii.gz$']);
        fprintf(' Unzipping files\n')
        gunzip(cellstr(Runs))
        
        Runs = spm_select('FPList', fullfile(pwd),...
            ['^' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii$']);
        
        
        for iRuns=1:size(Runs,1)
            
            % Gets all the images in each 4D volume
            Files = spm_vol(Runs(iRuns,:));
            for iFiles=1:length(Files)
                matlabbatch{1,1}.spm.spatial.realignunwarp.data(1,RunInd).scans{iFiles,1} = ...
                    [Files(iFiles).fname ,',', num2str(iFiles)];
            end
            Files = [];
            
            disp(matlabbatch{1,1}.spm.spatial.realignunwarp.data(1,RunInd).scans)
            
            if UseVDM
                matlabbatch{1,1}.spm.spatial.realignunwarp.data(1,RunInd).pmscan = {[Vdm ',1']};
            else
                matlabbatch{1,1}.spm.spatial.realignunwarp.data(1,RunInd).pmscan = {''};
            end
            
            disp(matlabbatch{1,1}.spm.spatial.realignunwarp.data(1,RunInd).pmscan)
            
            RunInd = RunInd + 1;
            
        end
        
        Runs = [];
    end
    
    cd(fullfile(SubDir))
    fprintf('\n\n')
    disp('%%%%%%%%%%%%%%%%')
    disp('   REALIGNING   ')
    disp('%%%%%%%%%%%%%%%%')
    
    if Do
        spm_jobman('run',matlabbatch)
    end
    
    % Saving
    if UseVDM;
        SaveMatLabBatch(strcat('RealignAndUnwarpVDM_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch'),matlabbatch)
        try
            % in case SPM created a .ps file output we rename it so it is
            % not overwritten later
            PsFile = dir('spm_*.ps');
            move(PsFile.name, ['RealignAndUnwarpVDM_' PsFile.name])
        catch
        end
    else
        SaveMatLabBatch(strcat('RealignAndUnwarp_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch'),matlabbatch) %#ok<*UNRCH>
        try
            PsFile = dir('spm_*.ps');
            move(PsFile.name, ['RealignAndUnwarp_' PsFile.name])
        catch
        end
    end
    
    % To save space we can delete the unzipped raw nitfti files that have
    % been unzipped
%     fprintf(' Cleaning')
%     for iSes = 1:NbSes
%         cd(fullfile(SubDir, SesLs(iSes).name, 'func'))
%         delete([SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-*_bold.nii'])
%     end
    
end

cd (StartDir)

% CloseParWorkersPool(KillGcpOnExit)

diary off