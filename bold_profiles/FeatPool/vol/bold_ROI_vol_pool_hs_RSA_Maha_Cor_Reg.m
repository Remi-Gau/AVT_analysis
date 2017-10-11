clc; clear;

StartDir = fullfile(pwd, '..','..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')

Whitened_beta = 0;
Trim_beta = 1;

IsEucNorm = 1;

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR',...
    'ATargL','ATargR',...
    'VTargL','VTargR',...
    'TTargL','TTargR',...
    };

ToPlot={'ROI'};

ROIs = {...
    'A1',...
    'PT',...
    'V1_thres',...
    'V2_thres',...
    'V3_thres',...
    'V4_thres',...
    'V5_thres',...
    };

if Whitened_beta
    Save_suffix = 'beta-wht'; %#ok<*UNRCH>
    DoTarget=2;
elseif Trim_beta
    Save_suffix = 'beta-trim';
    DoTarget=1;
else
    Save_suffix = 'beta-raw';
    DoTarget=2;
end

for iSub = 8:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(Sub_dir,'results','PCM','vol');
    Save_dir = fullfile(Sub_dir,'results','profiles','vol','RSA');
    mkdir(Save_dir)
    
    
    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'))
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM
    
    % Loads which runs happened on which day to set up the CVs
    load(fullfile(StartDir, 'RunsPerSes.mat'))
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    RunPerSes = RunPerSes(Idx).RunsPerSes;
    DayCVs = {...
        1:RunPerSes(1), ...
        RunPerSes(1)+1:RunPerSes(1)+RunPerSes(2),...
        RunPerSes(1)+RunPerSes(2)+1:sum(RunPerSes)};
    clear Idx RunPerSes
    
    % load data
    load(fullfile(Data_dir,['Data_PCM_' Save_suffix '.mat']), 'PCM_data', 'ROIs')
    
    fprintf('\n Running RSA, correlation and regressions\n')
    
    %% RSA Stim VS Stim
    fprintf('\n  Stimuli\n')
    
    if strcmp(SubLs(iSub).name,'sub-06')
        Nb_sess = 19;
    end
    
    
    if Trim_beta
        A = repmat(1:numel(CondNames),numel(CondNames),1);
        Cdt = [A(:), repmat((1:numel(CondNames))',numel(CondNames),1)];
        clear A
        
        conditionVec_day=repmat((1:numel(CondNames))',3,1);
        
        partition_day = repmat(1:3,numel(CondNames),1);
        partition_day = partition_day(:);
    else        
        A = repmat(1:6,6,1);
        Cdt = [A(:), repmat((1:6)',6,1)];
        clear A

        conditionVec_day=repmat((1:6)',3,1);

        partition_day = repmat(1:3,6,1);
        partition_day = partition_day(:);
    end
    
    for iToPlot = 1:numel(ToPlot)
        
        for iROI = 1:numel(ROIs)
            
            fprintf('  Processing %s\n', ROIs{iROI})
            
            conditionVec_init = repmat((1:size(CondNames,2)),Nb_sess,1);
            conditionVec_init = conditionVec_init(:);
            
            partition_init = repmat((1:Nb_sess)',size(CondNames,2),1);
            
            Data =  PCM_data{iROI};
            
            % removes rows of zeros or Nans
            ToRemove = any([all(isnan(Data),2) all(Data==0,2)],2);
            partition_init(ToRemove)=[]; conditionVec_init(ToRemove)=[];
            Data(ToRemove,:) = [];
            
            % removes columns of zeros or Nans
            ToRemove = any([all(isnan(Data)); all(Data==0)]);
            Data(:,ToRemove) = [];
            clear ToRemove
            
            row=1;
            for iCV = 1:numel(DayCVs)
                for iCdt = 1:size(CondNames,2)
                    Sess2Sel = all([ismember(partition_init,DayCVs{iCV}) conditionVec_init==iCdt],2);
                    Data_day_CV(row,:) = nanmean(Data(Sess2Sel,:)); %#ok<*SAGROW>
                    row=row+1;
                end
            end
            
            for iCdt = 1:size(CondNames,2)
                Data_no_CV(iCdt,:) = nanmean(Data(conditionVec_init==iCdt,:));
            end
            
            
            
            
            for Target = 1:DoTarget
                
                if Target==2
                    fprintf('   Processing targets\n')
                    Cdt2Sel = 7:12;
                else
                    if Trim_beta
                        fprintf('   Processing stimuli and targets\n')
                        Cdt2Sel = 1:12;
                    else
                        fprintf('   Processing stimuli\n')
                        Cdt2Sel = 1:6;
                    end
                end
                
                X = Data(ismember(conditionVec_init,Cdt2Sel),:);
                conditionVec = conditionVec_init(ismember(conditionVec_init,Cdt2Sel));
                partition = partition_init(ismember(conditionVec_init,Cdt2Sel));
                if Target==2
                    conditionVec = conditionVec-6;
                end
                
                X_no_CV = Data_no_CV(ismember(1:size(CondNames,2),Cdt2Sel),:);
                
                
                tmp = repmat((1:size(CondNames,2))',1,3);
                tmp = tmp(:);
                X_day_CV = Data_day_CV(ismember(tmp,Cdt2Sel),:);
                clear tmp


                %% Regressions and simple correlations
                % with no CV first
                Beta = nan(numel(Cdt2Sel),numel(Cdt2Sel),3);
                for iCdt = 1:size(Cdt,1)
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2) = glmfit(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:), 'normal');
                    R=corrcoef(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:));
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),3) = R(1,2);
                end
                
                % jJst keep the slope and the correlation coefficent
                BetaReg{iROI,iToPlot,Target,1} =  Beta(:,:,2);
                BetaReg{iROI,iToPlot,Target,2} =  Beta(:,:,3);
                
                % with CV
                Beta = nan(numel(Cdt2Sel),numel(Cdt2Sel),3,Nb_sess);
                % we loop "manually" through all the combinations of
                % conditions
                for iCV = 1:Nb_sess
                    for iCdt = 1:size(Cdt,1)
                        if strcmp(SubLs(iSub).name,'sub-06') && iCV==17
                        else
                            train = all([ismember(partition,iCV) conditionVec==Cdt(iCdt,1)],2);
                            test =  all([~ismember(partition,iCV) conditionVec==Cdt(iCdt,2)],2);
                            Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2,iCV) = glmfit(X(train,:),nanmean(X(test,:)), 'normal');
                            R=corrcoef(X(train,:),nanmean(X(test,:)));
                            Beta(Cdt(iCdt,1),Cdt(iCdt,2),3,iCV) = R(1,2);
                        end
                    end
                end
                
                % average across CVs
                BetaReg_CV{iROI,iToPlot,Target,1} =  nanmean(Beta(:,:,2,:),4);
                BetaReg_CV{iROI,iToPlot,Target,2} =  nanmean(Beta(:,:,3,:),4);
                
                % with day CV
                Beta = nan(numel(Cdt2Sel),numel(Cdt2Sel),3,numel(DayCVs));
                for iCV = 1:numel(DayCVs)
                    for iCdt = 1:size(Cdt,1)
                        train = all([ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,1)],2);
                        test =  all([~ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,2)],2);
                        Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2,iCV) = glmfit(nanmean(X(train,:)),nanmean(X(test,:)), 'normal');
                        R=corrcoef(nanmean(X(train,:)),nanmean(X(test,:)));
                        Beta(Cdt(iCdt,1),Cdt(iCdt,2),3,iCV) = R(1,2);
                    end
                end
                
                BetaReg_CV{iROI,iToPlot,Target,3} =  nanmean(Beta(:,:,2,:),4);
                BetaReg_CV{iROI,iToPlot,Target,4} =  nanmean(Beta(:,:,3,:),4);
                
                
                %% Eucledian normalization
                if IsEucNorm
                    for i=1:size(X, 1)
                        X(i,:) = X(i,:) / norm(X(i,:));
                    end
                    
                    for i=1:size(X_day_CV, 1)
                        X_day_CV(i,:) = X_day_CV(i,:) / norm(X_day_CV(i,:));
                    end
                    
                    for i=1:size(X_no_CV, 1)
                        X_no_CV(i,:) = X_no_CV(i,:) / norm(X_no_CV(i,:));
                    end
                end
                
                
                %% No CV
                RDMs{iROI,iToPlot,Target,1} = squareform((pdist(X_no_CV, 'euclidean').^2)/size(X_no_CV,2));
                RDMs{iROI,iToPlot,Target,2} = squareform(pdist(X_no_CV, 'spearman'));
                
                RDM_euc = nan(numel(Cdt2Sel));
                RDM_pear = nan(numel(Cdt2Sel));
                for iCdt = 1:size(Cdt,1)
                    if strcmp(SubLs(iSub).name,'sub-06') && iCV==17
                    else
                        train = Cdt(iCdt,1);
                        test =  Cdt(iCdt,2);
                        
                        x = X_no_CV(train,:);
                        y = X_no_CV(test,:);
                        
                        RDM_euc(Cdt(iCdt,1),Cdt(iCdt,2)) = (pdist([x;y], 'euclidean').^2)/size(X,2);
                        RDM_pear(Cdt(iCdt,1),Cdt(iCdt,2)) = pdist([x;y], 'spearman');
                        
                        clear x y train test
                    end
                end
                RDMs{iROI,iToPlot,Target,3} = RDM_euc;
                RDMs{iROI,iToPlot,Target,4} = RDM_pear;
                
                
                %% With CV
                if strcmp(SubLs(iSub).name,'sub-06')
                    X(partition==17,:) = [];
                    conditionVec(partition==17,:) = [];
                    partition(partition==17,:) = [];
                end
                RDMs_CV{iROI,iToPlot,Target,1} = squareform(rsa.distanceLDC(X, partition, conditionVec));
                RDMs_CV{iROI,iToPlot,Target,2} = squareform(rsa.distanceLDC(X_day_CV, partition_day, conditionVec_day));
                
                
                % whole CV
                RDM_euc = nan(numel(Cdt2Sel),numel(Cdt2Sel),Nb_sess);
                RDM_pear = nan(numel(Cdt2Sel),numel(Cdt2Sel),Nb_sess);
                for iCV = 1:Nb_sess
                    
                    for iCdt = 1:size(Cdt,1)
                        if strcmp(SubLs(iSub).name,'sub-06') && iCV==17
                        else
                            train = all([ismember(partition,iCV) conditionVec==Cdt(iCdt,1)],2);
                            test =  all([~ismember(partition,iCV) conditionVec==Cdt(iCdt,2)],2);
                            
                            x = X(train,:);
                            y = nanmean(X(test,:));
                            
                            RDM_euc(Cdt(iCdt,1),Cdt(iCdt,2),iCV) = (pdist([x;y], 'euclidean').^2)/size(X,2);
                            RDM_pear(Cdt(iCdt,1),Cdt(iCdt,2),iCV) = pdist([x;y], 'spearman');
                            
                            clear x y train test
                        end
                    end
                    
                end
                
                RDMs_CV{iROI,iToPlot,Target,3} = nanmean(RDM_euc,3);
                RDMs_CV{iROI,iToPlot,Target,4} = nanmean(RDM_pear,3);
                
                % Day CV
                RDM_euc = nan(numel(Cdt2Sel),numel(Cdt2Sel),numel(DayCVs));
                RDM_pear = nan(numel(Cdt2Sel),numel(Cdt2Sel),numel(DayCVs));
                for iCV = 1:numel(DayCVs)
                    
                    for iCdt = 1:size(Cdt,1)
                        train = all([ismember(partition_day,iCV) conditionVec_day==Cdt(iCdt,1)],2);
                        test =  all([~ismember(partition_day,iCV) conditionVec_day==Cdt(iCdt,2)],2);
                        
                        x = X_day_CV(train,:);
                        y = nanmean(X_day_CV(test,:));
                        
                        RDM_euc(Cdt(iCdt,1),Cdt(iCdt,2),iCV) = (pdist([x;y], 'euclidean').^2)/size(X,2);
                        RDM_pear(Cdt(iCdt,1),Cdt(iCdt,2),iCV) = pdist([x;y], 'spearman');
                        
                        clear x y train test
                    end
                    
                end
                
                RDMs_CV{iROI,iToPlot,Target,5} = nanmean(RDM_euc,3);
                RDMs_CV{iROI,iToPlot,Target,6} = nanmean(RDM_pear,3);

                clear X X_day_CV X_no_CV

            end
            
            clear Data_day_CV Data_no_CV Data
            
        end
        
    end
    
    %%
    fprintf('\n   Saving\n')
    
    save(fullfile(Save_dir,['RSA_results_' Save_suffix '.mat']),  ...
        'RDMs', 'RDMs_CV', 'BetaReg_CV', 'BetaReg')
    
    clear RDMs RDMs_CV BetaReg_CV BetaReg
    
    
    
end

cd(StartDir)
