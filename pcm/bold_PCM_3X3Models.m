% runs the PCM on the 3 sensory modalities (A, V and T) but separately for
% ipsi and contra
% it has 12 models that represent all the different ways that those 3
% conditions can be either
% - scaled
% - scaled and independent
% - independent


clc; clear; close all


surf = 0; % run of volume whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0; % only implemented for volume

% 1 - '3X3_Ipsi';
% 2 - '3X3_Contra';
% 3 - '3X3_ContraIpsi'; average over ipsi and contra
% 4 - '3X3_ContraIpsiPool'; pool over ipsi and contra with no averaging
analysis_to_run = 3; %1:4

if surf
    rois_to_run = 1:4;
else
    rois_to_run = [1 2 6 7];
end


print_models = 0;

MaxIteration = 50000;
runEffect  = 'fixed';


if isunix
    CodeDir = '/home/remi/github/AVT_analysis';
    StartDir = '/home/remi';
elseif ispc
    CodeDir = 'D:\github\AVT-7T-code';
    StartDir = 'D:\';
else
    disp('Platform not supported')
end

addpath(genpath(fullfile(CodeDir, 'subfun')))

[Dirs] = set_dir();

Get_dependencies()

SubLs = dir(fullfile(Dirs.DerDir,'sub*'));
NbSub = numel(SubLs);


if surf
    % decides on what parameter the PCM is run
    % S parameters:
    % - cst at each vertex
    % - linear at each vertex
    % B parameters:
    % - average at each vertex
    % - all vertices and voxels values for that ROI
    ToPlot={'Cst','Lin','Avg','ROI'};
    Output_dir = 'surf';
    Save_suffix = '';
else
    ToPlot={'ROI'}; %#ok<*UNRCH>
    Output_dir = 'vol';
    if raw
        Save_suffix = 'raw_betas';
    else
        Save_suffix = 'whitened_betas';
    end
end


if raw
    Beta_suffix = 'raw-betas';
else
    Beta_suffix = 'wht-betas';
end


if hs_idpdt
    hs_suffix = {'LHS' 'RHS'};
else
    hs_suffix = {'LRHS'};
end


PCM_dir = fullfile(Dirs.DerDir, 'figures', 'PCM');
mkdir(PCM_dir)
mkdir(PCM_dir, 'Cdt');
mkdir(fullfile(PCM_dir, 'Cdt'), '3X3_models');


Save_dir = fullfile(Dirs.DerDir, 'results', 'PCM', Output_dir);
mkdir(Save_dir)


%% Build the models
fprintf('Building models\n')
M_ori = Set_PCM_3X3_models;

if print_models
    fig_h = Plot_PCM_models_feature(M_ori);
    for iFig = 1:numel(fig_h)
        print(fig_h(iFig), fullfile(Dirs.FigureFolder, 'PCM', 'Cdt', '3X3_models', ...
            ['Model-' num2str(iFig) '-' strrep(strrep(fig_h(iFig).Name ,',',''),' ','') '.tif']),...
            '-dtiff');
    end
end


%% Define ROI
fprintf('Define ROI\n')

% to know how many ROIs we have
if surf
    load(fullfile(Dirs.DerDir, 'sub-02', 'roi', 'surf','sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex')
else
    ROI(1).name ='V1_thres';
    ROI(2).name ='V2_thres';
    ROI(3).name ='V3_thres';
    ROI(4).name ='V4_thres';
    ROI(5).name ='V5_thres';
    ROI(6).name ='A1';
    ROI(7).name ='PT';
end


%% Start
fprintf('Get started\n')


for iToPlot = 1:numel(ToPlot) % decides on what parameter the PCM is run (ToPlot={'Cst','Lin','Avg','ROI'};)
    
    for Target = 1
        
        if Target==2
            Stim_suffix = 'targ';
            CondNames = {...
                'ATargL','ATargR',...
                'VTargL','VTargR',...
                'TTargL','TTargR',...
                };
        else
            Stim_suffix = 'stim';
            CondNames = {...
                'A ipsi','A contra',...
                'V ipsi','V contra',...
                'T ipsi','T contra'...
                };
        end
        
        
        %% Create partition and condition vector
        for iSub = 1:NbSub
            
            Sub_dir = fullfile(Dirs.DerDir, SubLs(iSub).name);
            
            load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'))
            Nb_sess(iSub) = numel(SPM.Sess);   %#ok<*SAGROW>
            clear SPM
            
            conditionVec = repmat(1:numel(CondNames)*2,Nb_sess(iSub),1);
            conditionVec = conditionVec(:);
            
            partitionVec = repmat((1:Nb_sess(iSub))',numel(CondNames)*2,1);
            
            [partitionVec, conditionVec] = partition_condition_vectors(partitionVec, conditionVec, iSub, iToPlot, surf, Target);
            
            partitionVec_ori{iSub} = partitionVec;
            conditionVec_ori{iSub} = conditionVec;
        end
        
        %%
        for iROI =  rois_to_run
            
            fprintf('\n %s\n', ROI(iROI).name)
            
            Y = {}; condVec = {}; partVec = {};
            
            clear G_hat G Gm COORD
            
            for ihs = 1:numel(hs_suffix)
                
                fprintf('\n %s\n', hs_suffix{ihs})
                
                for iSub = 1:NbSub
                    
                    fprintf(' Loading %s\n', SubLs(iSub).name)
                    
                    Sub_dir = fullfile(Dirs.DerDir, SubLs(iSub).name);
                    
                    partitionVec =  partitionVec_ori{iSub};
                    conditionVec = conditionVec_ori{iSub};
                    
                    %% load data
                    X_temp = load_data(Sub_dir, surf, raw, hs_idpdt, iToPlot, iROI, conditionVec, Save_suffix, SubLs, iSub, ihs);
                    
                    %% Get just the right data
                    X_temp(conditionVec==0,:)=[];
                    partitionVec(conditionVec==0,:)=[];
                    conditionVec(conditionVec==0,:)=[];
                    
                    
                    %% Remove nans
                    ToRemove = find(any(isnan(X_temp)));
                    X_temp(:,ToRemove)=[];
                    
                    if any(all(isnan(X_temp),2)) || any(all(X_temp==0,2))
                        warning('We have some NaNs issue.')
                        ToRemove = any([all(isnan(X_temp),2) all(X_temp==0,2)],2);
                        partitionVec(ToRemove)=[];
                        conditionVec(ToRemove)=[];
                        X_temp(ToRemove,:) = [];
                    end
                    
                    %% check that we have the same number of conditions in each  partition
                    A = tabulate(partitionVec);
                    A = A(:,1:2);
                    if numel(unique(A(:,2)))>1
                        warning('We have different numbers of conditions in at least one partition.')
                        Sess2Remove = find(A(:,2)<numel(unique(conditionVec)));
                        conditionVec(ismember(partitionVec,Sess2Remove)) = [];
                        X_temp(ismember(partitionVec,Sess2Remove),:) = [];
                        partitionVec(ismember(partitionVec,Sess2Remove)) = [];
                        Sess2Remove = [];
                    end
                    
                    if any([numel(conditionVec) numel(partitionVec)]~=size(X_temp,1))
                        error('Data matrix or condition or partition vector might be off.')
                    end
                    
                    
                    %% Stores each subject
                    
                    Y{iSub} = X_temp;
                    condVec{iSub} = conditionVec;
                    partVec{iSub} = partitionVec;
                    
                    % Average across sessions
                    Cdts = unique(conditionVec);
                    X_temp_avg = [];
                    for iCdt = 1:numel(Cdts)
                        X_temp_avg(end+1,:) = mean( X_temp(conditionVec==Cdts(iCdt),:) );
                    end
                    Y_avg{iSub} = X_temp_avg;
                    
                    clear X_temp X_temp_avg
                    
                    % Compute G matrix with all conditions
                    G_hat(:,:,iSub)=pcm_estGCrossval(Y{iSub}, partVec{iSub}, condVec{iSub});
                    
                end
                
                %% Save G matrix
                save(fullfile(Save_dir, sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s.mat', ...
                    Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                    ToPlot{iToPlot}, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                    'partVec', 'condVec','G_hat')
                
                clear G_hat
                
                %% Run the PCM
                Y_ori = Y;
                condVec_ori = condVec;
                partVec_ori = partVec;
                
                for iComparison = analysis_to_run

                    Y{iSub} = Y_ori{iSub};
                    
                    switch iComparison
                        
                        case 1
                            Comp_suffix = '3X3_Ipsi';
                            CdtToSelect = 1:2:5;
                        case 2
                            Comp_suffix = '3X3_Contra';
                            CdtToSelect = 2:2:6;
                        case 3
                            Comp_suffix = '3X3_ContraIpsi';
                            CdtToSelect = 1:6;
                        case 4
                            Comp_suffix = '3X3_ContraIpsiPool';
                            CdtToSelect = 1:6;
                    end
                    
                    
                    % loop through subjects and compute G matrices
                    condVec = condVec_ori;
                    for iSub = 1:numel(condVec)
                        
                        condVec{iSub}(~ismember(condVec{iSub},CdtToSelect)) = 0;
                        
                        % collapse across ipsi and contra stimuli by averaging
                        % we loop over partitions and then for each condition (A, V, T) we
                        % average the ipsi and contra data of that partition.
                        
                        if iComparison==3
                            for ipart = 1:max(partVec{iSub})
                                this_part = partVec{iSub} == ipart;
                                if any(this_part) % extra check for subject 06
                                    for iCdt = 1:2:5
                                        Y{iSub}( all([this_part, condVec{iSub}==iCdt],2) , : ) = ...
                                            mean( Y{iSub}(  all([this_part, ismember(condVec{iSub},iCdt:(iCdt+1))],2) , : ) ) ;
                                    end
                                end
                            end
                            
                            % Then we only keep the rows where the data has been averaged
                            condVec{iSub}(condVec{iSub}==2) = 0;
                            condVec{iSub}(condVec{iSub}==4) = 0;
                            condVec{iSub}(condVec{iSub}==6) = 0;
                            
                            partVec{iSub}(condVec{iSub}==0) = [];
                            Y{iSub}(condVec{iSub}==0, :) = [];
                            condVec{iSub}(condVec{iSub}==0) = [];
                            
                        elseif iComparison==4
                            
                            % Then we only keep the rows where the data has been averaged
                            condVec{iSub}(condVec{iSub}==2) = 1;
                            condVec{iSub}(condVec{iSub}==4) = 3;
                            condVec{iSub}(condVec{iSub}==6) = 5;
                            
                        end
                        
                        G_hat(:,:,iSub) = pcm_estGCrossval( Y{iSub}, partVec{iSub}, condVec{iSub} );
                        
                        G(:,:,iSub) = Y_avg{iSub} * Y_avg{iSub}' / size(Y_avg{iSub},2); % with no CV.
                        
                    end
                    
                    M = M_ori;
                    
                    % Fit the models on the group level
                    fprintf('\n\n  Running PCM_grp %s\n\n', Comp_suffix)
                    
                    [T_group,theta_gr,G_pred_gr] = pcm_fitModelGroup(Y, M, partVec, condVec, ...
                        'runEffect', runEffect, ...
                        'fitScale', 1);
                    
                    [T_cross,theta_cr,G_pred_cr] = pcm_fitModelGroupCrossval(Y, M, partVec, condVec, ...
                        'runEffect', runEffect, ...
                        'groupFit', theta_gr, ...
                        'fitScale',1, ...
                        'MaxIteration', MaxIteration);
                    
                    % Save
                    save(fullfile(Save_dir, sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s_%s.mat', ...
                        Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                        ToPlot{iToPlot}, Comp_suffix , datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                        'M', 'partVec', 'condVec','G_hat', 'G',...
                        'T_group','theta_gr','G_pred_gr',...
                        'T_cross','theta_cr','G_pred_cr' )
                    
                end
                
            end
            
        end
    end
    
end


function [partitionVec, conditionVec] = partition_condition_vectors(partitionVec, conditionVec, iSub, iToPlot, surf, target)

if iSub == 5
    
    if surf && iToPlot==4
        % remove lines corresponding to auditory stim and
        % targets for sub-06
        ToRemove = all([any([conditionVec<3 conditionVec==7 conditionVec==8],2) partitionVec==17],2);
        
        partitionVec(ToRemove) = [];
        conditionVec(ToRemove) = [];
        
    elseif ~surf
        % remove lines corresponding to auditory stim and
        % targets for sub-06
        ToRemove = all([any([conditionVec<3 conditionVec==7 conditionVec==8],2) partitionVec==17],2);
        
        partitionVec(ToRemove) = [];
        conditionVec(ToRemove) = [];
        
    end
    
end

if target==1
    conditionVec(conditionVec>6)=0;
else
    conditionVec(conditionVec<7)=0;
    conditionVec(conditionVec>6)=conditionVec(conditionVec>6)-6;
end

end


function Data = load_data(Sub_dir, surf, raw, hs_idpdt, iToPlot, iROI, conditionVec, Save_suffix, SubLs, iSub, ihs)

if surf==1
    
    if raw == 0
        
        if iToPlot < 4
            
            load(fullfile(Sub_dir,'results','profiles','surf','PCM','Data_PCM.mat'), 'PCM_data')
            
            if hs_idpdt
                
                Data = PCM_data{iToPlot,iROI,ihs};
                
            else
                
                tmp = PCM_data{iToPlot,iROI,2};
                
                % we relabel conditions from the right hemipshere
                % so that it matches the contra and ipsi of the
                % left one
                for i=1:2:12
                    tmp(conditionVec==i,:) = PCM_data{iToPlot,iROI,2}(conditionVec==(i+1),:);
                end
                for i=2:2:12
                    tmp(conditionVec==i,:) = PCM_data{iToPlot,iROI,2}(conditionVec==(i-1),:);
                end
                Data = [PCM_data{iToPlot,iROI,1} tmp];
                
            end
            
        elseif iToPlot==4
            
            load(fullfile(Sub_dir,'results','profiles','surf','PCM','Data_PCM_whole_ROI.mat'), 'PCM_data')
            
            if hs_idpdt
                Data = PCM_data{iROI,ihs};
            else
                Data = reorganize_ipsi_contra(PCM_data, iROI, conditionVec);
            end
            
        end
        
    else
        
        error('Raw data for surfaces: not implemented')
        
    end
    
else
    
    load(fullfile(Sub_dir,'results', 'rsa', 'vol', [SubLs(iSub).name '_data_' Save_suffix '.mat']), 'Features')
    
    if hs_idpdt
        Data = Features{iROI,ihs};
    else
        Data = reorganize_ipsi_contra(Features, iROI, conditionVec);
    end
    
    
end


end


function data = reorganize_ipsi_contra(data, iROI, conditionVec)

tmp = data{iROI,2};

for i=1:2:12
    tmp(conditionVec==i,:) = data{iROI,2}(conditionVec==(i+1),:);
end
for i=2:2:12
    tmp(conditionVec==i,:) = data{iROI,2}(conditionVec==(i-1),:);
end

data = [data{iROI,1} tmp];

end