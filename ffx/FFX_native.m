%%
clear; clc

Do = 1;
Smooth = 0;
TrimStim = 1; % make sure that there are as many stim as targets in each regressor
Plot = 0;


%%
spm_jobman('initcfg')
spm_get_defaults;
global defaults %#ok<*NUSED>
defaults.stats.maxmem = 2^31;

DateFormat = 'yyyy_mm_dd_HH_MM';

TR = 3;
HPF = 128;
ReferenceSlice = 1;
NbSlices = 48;

RespTimeOut = 5;

Color = 'rgbrgb';

if ~Smooth
    defaults.mask.thresh    = -1;
    suffix = '';
    if TrimStim
        diary(['diary_FFX_trim_' datestr(now, DateFormat) '.out'])
    else
        diary(['diary_FFX_native_' datestr(now, DateFormat) '.out']) %#ok<*UNRCH>
    end
else
    suffix = 's';
    diary(['diary_FFX_smooth_' datestr(now, DateFormat) '.out'])
end


%%
StartDir = fullfile(pwd, '..','..');
cd (StartDir)

SubLs = dir('sub*');
NbSub = numel(SubLs);


for iSub = 1:NbSub % for each subject
    
    fprintf('\n\nProcessing %s\n', SubLs(iSub).name)
    
    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    cd(fullfile(SubDir))
    if TrimStim
        [~,~,~]=mkdir('ffx_trim');
    else
        [~,~,~]=mkdir('ffx_nat');
    end
    
    % identify the number of sessions
    SesLs = dir('ses*');
    NbSes = numel(SesLs);
    
    % --------------------------%
    %     DEFINES    BATCH      %
    % --------------------------%
    matlabbatch={};
    
    
    if Smooth
        matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = fullfile(SubDir, 'ffx_nat_smooth');
    elseif TrimStim
        matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = fullfile(SubDir, 'ffx_trim'); 
    else
        matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = fullfile(SubDir, 'ffx_nat');
    end
    
    matlabbatch{1,1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1,1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t = NbSlices;
    matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0 = ReferenceSlice;
    
    matlabbatch{1,1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});
    
    matlabbatch{1,1}.spm.stats.fmri_spec.bases.hrf.derivs = [1,0]; % First is time derivative, Second is dispersion
    
    matlabbatch{1,1}.spm.stats.fmri_spec.volt = 1;
    
    matlabbatch{1,1}.spm.stats.fmri_spec.global = 'None';
    
    if Smooth
        matlabbatch{1,1}.spm.stats.fmri_spec.mask = {''};
    else
        matlabbatch{1,1}.spm.stats.fmri_spec.mask = {fullfile(SubDir,[SubLs(iSub).name '-GLM_mask.nii'])};
        gunzip(fullfile(SubDir,[SubLs(iSub).name '-GLM_mask.nii.gz']))
    end
    
    matlabbatch{1,1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    
    RunInd = 1;
    for iSes = 1:NbSes % for each session
        
        % Gets all the runs for that session
        cd(fullfile(SubDir, SesLs(iSes).name, 'func'))

        TSV = spm_select('FPList', fullfile(pwd), ...
            ['^' SubLs(iSub).name '_ses-' num2str(iSes) '.*_task-audiovisualtactile_run-.*.tsv$']);
        RP = spm_select('FPList', fullfile(pwd), ...
            ['^rp_' SubLs(iSub).name '_ses-' num2str(iSes) '.*_task-audiovisualtactile_run-.*.txt$']);
        
        IMG = spm_select('FPList', fullfile(pwd),...
            ['^' suffix 'auv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii.gz$']);
        
        if ~isempty(IMG)
            fprintf(' Unzipping files\n')
            gunzip(cellstr(IMG))
        end
        
        IMG = spm_select('FPList', fullfile(pwd),...
            ['^' suffix 'auv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii$']);
        
        for iRuns=1:size(IMG,1)
            
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).multi{1} = '';
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).regress = struct('name',{},'val',{});
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).hpf = HPF;
            
            % Gets all the images in each 4D volume
            IMG_ls = spm_vol(IMG(iRuns,:));
            for j = 1:length(IMG_ls)
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).scans{j,1} = [IMG_ls(j).fname ',' num2str(j)];
            end
            clear IMG_ls
            
            char(matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).scans)
            
            % Adds the realignement parameters file
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).multi_reg{1} = RP(iRuns,:);
            
            % Read the onset file
            IFilefID = fopen(TSV(iRuns,:));
            FileContent = textscan(IFilefID,'%f %s %s %s', 'headerlines', 1, 'Delimiter', '\t', ...
                'returnOnError',0);
            clear IFilefID
            
            % Adds the conditions to the batch
            if Plot; figure(RunInd); end
            
            ConditionNumber = 1;
            for i = 1:2
                switch i
                    case 1
                        Side = 'L';
                    case 2
                        Side = 'R';
                end
                for j=1:6
                    switch j
                        case 1
                            TrialType = 'AStim';
                        case 2
                            TrialType = 'VStim';
                        case 3
                            TrialType = 'TStim';
                        case 4
                            TrialType = 'ATarg';
                        case 5
                            TrialType = 'VTarg';
                        case 6
                            TrialType = 'TTarg';
                    end
                    
                    % No auditory stim for run 17 of sub-06
                    if ~(strcmp(SubLs(iSub).name, 'sub-06') && RunInd==17 && (j==1 || j==4))
                        SOTs = FileContent{1}(ismember(FileContent{3},[TrialType Side]));
                        
                        if j<4
                           Num_targets = numel(FileContent{1}(ismember(FileContent{3},[TrialType(1) 'Targ' Side])));
                           P = randperm(numel(SOTs));
                           SOTs = SOTs(P(1:Num_targets));
                        end
                        
                        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).name = [TrialType Side];
                        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).duration = 0;
                        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).tmod = 0;
                        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).pmod=struct('name',{},'param',{}, 'poly', {});
                        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).onset = SOTs;
                        
                        ConditionNumber=ConditionNumber+1;
                    end
                    
                    if Plot
                        if j<4 
                            subplot(2,1,1)
                            hold on
                        else
                            subplot(2,1,2)
                            hold on
                        end
                        stem(SOTs, ones(size(SOTs)), 'color', Color(j))
                        axis([0 440 0 1.1])
                    end
                    
                    clear SOTs
                end
            end
            clear i j
            
            
            % Adds an extra response vector for responses outside the
            % response window
            tmp = ismember(FileContent{3}, 'AStimL');
            tmp(ismember(FileContent{3}, 'AStimR')) = ones(sum(ismember(FileContent{3}, 'AStimR')),1);
            tmp(ismember(FileContent{3}, 'VStimL')) = ones(sum(ismember(FileContent{3}, 'AStimL')),1);
            tmp(ismember(FileContent{3}, 'VStimR')) = ones(sum(ismember(FileContent{3}, 'AStimR')),1);
            tmp(ismember(FileContent{3}, 'TStimL')) = ones(sum(ismember(FileContent{3}, 'AStimL')),1);
            tmp(ismember(FileContent{3}, 'TStimR')) = ones(sum(ismember(FileContent{3}, 'AStimR')),1);
            
            FileContent{1}(tmp)=[];
            FileContent{3}(tmp)=[];
            
            SOTs = [];
            IsTarget = 0; % Current trial is a target
            OnsetTime = -1*RespTimeOut-1; % Set to that value in case there is a FA very early in the run
            for i = 1:length(FileContent{1})
                IsTarget = strcmp(FileContent{3}{i}(2:end-1),'Targ');
                if IsTarget
                    OnsetTime = FileContent{1}(i);
                else
                    IsOut = (FileContent{1}(i)-OnsetTime)>RespTimeOut;
                    if IsOut
                        SOTs = FileContent{1}(i);
                    end
                end
                
            end
            
            if ~isempty(SOTs)
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).name = 'ExtraResp';
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).duration = 0;
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).tmod = 0;
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).pmod=struct('name',{},'param',{}, 'poly', {});
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,RunInd).cond(1,ConditionNumber).onset = SOTs;
                
                if Plot
                    subplot(2,1,2)
                    hold on
                    stem(SOTs, ones(size(SOTs)), 'color', 'k')
                    axis([0 440 0 1.1])
                end
            end
            
            RunInd = RunInd + 1;
            
        end
        clear IMG RP TSV
        
    end
    clear iSes RunInd

    
    %% fMRI estimation
    matlabbatch{1,end+1}={}; %#ok<SAGROW>
    if Smooth
        matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = fullfile(SubDir, 'ffx_nat_smooth', 'SPM.mat');
    elseif TrimStim
        matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = fullfile(SubDir, 'ffx_trim', 'SPM.mat');
    else
        matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = fullfile(SubDir, 'ffx_nat', 'SPM.mat'); 
    end
    
    matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;
    

    %%
    cd(fullfile(SubDir))
    if Smooth
        save(strcat('FFX_smooth_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch.mat'), 'matlabbatch');
    elseif TrimStim
        save(strcat('FFX_trim_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch.mat'), 'matlabbatch');
    else
        save(strcat('FFX_nat_', SubLs(iSub).name, '_', datestr(now, DateFormat), '_matlabbatch.mat'), 'matlabbatch');
    end
    
    if Do
        spm_jobman('run', matlabbatch)
    end
    
    if Smooth && Do
        copyfile(fullfile(SubDir,'ffx_nat_smooth', 'mask.nii'), ...
            fullfile(SubDir,[SubLs(iSub).name '-GLM_mask.nii']))
    end

    
    %%
    fprintf(' Cleaning')
    for iSes = 1:NbSes
        cd(fullfile(SubDir, SesLs(iSes).name, 'func'))
        IMG = spm_select('FPList', fullfile(pwd),...
            ['^' suffix 'auv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-.*_bold.nii$']);
        for iRuns=1:size(IMG,1)
            gzip(IMG(iRuns,:))
        end
%         delete([suffix 'auv' SubLs(iSub).name '_ses-' num2str(iSes) '_task-audiovisualtactile_run-*_bold.nii'])
    end
    
    cd (StartDir)
    
end


diary off