clc; clear;

StartDir = fullfile(pwd, '..','..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR',...
    'ATargL','ATargR',...
    'VTargL','VTargR',...
    'TTargL','TTargR',...
    };

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers-2,1) DesMat'];
DesMat = spm_orth(DesMat);

iseucnorm = 1;

ToPlot={'Cst','Lin','Quad'};

for iSub = 1:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_rsa');
    Data_dir = fullfile(GLM_dir,'betas','6_surf');
    
    
    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'))
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM
    
    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex')
    
    % Loads which runs happened on which day to set up the CVs
    load(fullfile(StartDir, 'RunsPerSes.mat'))
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    RunPerSes = RunPerSes(Idx).RunsPerSes;
    DayCVs = {...
        1:RunPerSes(1), ...
        RunPerSes(1)+1:RunPerSes(1)+RunPerSes(2),...
        RunPerSes(1)+RunPerSes(2)+1:sum(RunPerSes)};
    clear Idx RunPerSes
    
    %% For the 2 hemispheres
    NbVertices = nan(1,2);
    for hs = 1:2
        
        if hs==1
            fprintf('\n\n Left hemipshere\n')
            HsSufix = 'l';
        else
            fprintf('\n\n Right hemipshere\n')
            HsSufix = 'r';
        end
        
        FeatureSaveFile = fullfile(Data_dir,[SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
            num2str(NbLayers) '_surf.mat']);
        
        InfSurfFile=spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
            ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex,inf_faces,~] = read_vtk(InfSurfFile, 0, 1);
        
        NbVertices(hs)=size(inf_vertex,2);
        
        % Load data or extract them
        fprintf('  Reading VTKs\n')
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile)
            VertexWithDataHS{hs} = VertexWithData; %#ok<*SAGROW>
        else
            error('The features have not been extracted from the VTK files.')
        end
        
        
        %% Run GLMs for basic conditions
        fprintf('\n   All conditions\n')
        
        for iCdt = 1:numel(CondNames) % For each Condition
            fprintf('    %s\n',CondNames{iCdt})
            
            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name,'sub-06') && iSess==17
                else
                    Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                        ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];   %#ok<*AGROW>
                end
            end
            
            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            
            % Extract them
            Features = AllMapping(:,:,Beta2Sel);
            
            if sum(isnan(Features(:)))>0
                warning('We have %i NaNs for %s', sum(isnan(Features(:))), CondNames{iCdt})
            end
            if sum(Features(:)==0)>0
                warning('We have %i zeros for %s', sum(Features(:)==0), CondNames{iCdt})
            end
            
            % Run the "cross-validation"
            for iCV = 1:size(Features,3)
                Sess2Sel = iCV;
                if strcmp(SubLs(iSub).name,'sub-06') && iCdt<3 && iCV==17
%                     BetaCdt{hs,iCV}(:,:,iCdt) = nan(size(DesMat,2),size(Features,1));
                else
                    Y = Features(:,:,Sess2Sel);
                    X=repmat(DesMat,size(Y,3),1);
                    Y = shiftdim(Y,1);
                    B = pinv(X)*Y;
                    BetaCdt{hs,iCV}(:,:,iCdt) = B;
                end
            end
            
            clear Features Beta2Sel X Y B iSess
        end
        
        clear iCdt
        
        %% Run GLMs for contra-ipsi
        fprintf('\n   Contra-Ipsi\n')
        Cond_con_name = {'A','V','T','TargA','TargV','TargT'};
        
        if hs==1
            Cond2Contrast = {...
                2, 1;...
                4, 3;...
                6, 5;...
                8, 7;...
                10, 9;...
                12, 11};
        elseif hs==2
            Cond2Contrast = {...
                1, 2;...
                3, 4;...
                5, 6;...
                7, 8;...
                9, 10;...
                11, 12};
        end
        
        for iCdt=1:size(Cond2Contrast,1)
            
            fprintf('    %s Contra-Ipsi\n',Cond_con_name{iCdt})
            
            Beta2Sel = [];
            Beta2Sel2 = [];
            
            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name,'sub-06') && iSess==17 && (iCdt==1 || iCdt==4)
                else
                    Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                        ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,1}}  '*bf(1)']))];
                    
                    Beta2Sel2 = [Beta2Sel2 ;find(strcmp(cellstr(BetaNames), ...
                        ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,2}}  '*bf(1)']))];
                end
            end
            
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            Beta2Sel2 = find(ismember(BetaOfInterest, Beta2Sel2));
            
            Features = AllMapping(:,:,Beta2Sel) - ...
                AllMapping(:,:,Beta2Sel2);
            
            % Run the "cross-validation"
            for iCV = 1:size(Features,3)
                Sess2Sel = iCV;
                if strcmp(SubLs(iSub).name,'sub-06') && (iCdt==1 || iCdt==4) && iCV==17
%                     BetaCrossSide{hs,iCV}(:,:,iCdt) = nan(size(DesMat,2),size(Features,1));
                else
                    Y = Features(:,:,Sess2Sel);
                    X=repmat(DesMat,size(Y,3),1);
                    Y = shiftdim(Y,1);
                    B = pinv(X)*Y;
                    BetaCrossSide{hs,iCV}(:,:,iCdt) = B;
                end
            end
            clear Features Beta2Sel X Y B iSess
        end
        
        clear iCdt
        
        %% Run GLMs for cross-sensory
        fprintf('\n   Cross sensory\n')
        Cond_con_name = {...
            'Contra_A-V','Contra_A-T','Contra_V-T',...
            'Ipsi_A-V','Ipsi_A-T','Ipsi_V-T',...
            'Targ-Contra_A-V','Targ-Contra_A-T','Targ-Contra_V-T',...
            'Targ-Ipsi_A-V','Targ-Ipsi_A-T','Targ-Ipsi_V-T'};
        
        if hs==1
            Cond2Contrast = {...
                2, 4;...
                2, 6;...
                4, 6;...
                1, 3;...
                1, 5;...
                3, 5;...
                8, 10;...
                8, 12;...
                10, 12;...
                7, 9;...
                7, 11;...
                9, 11};
        elseif hs==2
            Cond2Contrast = {...
                1, 3;...
                1, 5;...
                3, 5;...
                2, 4;...
                2, 6;...
                4, 6;...
                7, 9;...
                7, 11;...
                9, 11;...
                8, 10;...
                8, 12;...
                10, 12};
        end
        
        for iCdt=1:size(Cond2Contrast,1)
            
            fprintf('    %s\n',Cond_con_name{iCdt})
            
            Beta2Sel = [];
            Beta2Sel2 = [];
            
            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name,'sub-06') && iSess==17 && any(iCdt==[1 2 4 5 7 8 10 11])
                else
                    Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                        ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,1}}  '*bf(1)']))];
                    
                    Beta2Sel2 = [Beta2Sel2 ;find(strcmp(cellstr(BetaNames), ...
                        ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,2}}  '*bf(1)']))];
                end
            end
            
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            Beta2Sel2 = find(ismember(BetaOfInterest, Beta2Sel2));
            
            Features = AllMapping(:,:,Beta2Sel) - ...
                AllMapping(:,:,Beta2Sel2);
            
            % Run the "cross-validation"
            for iCV = 1:size(Features,3)
                Sess2Sel = iCV;
                if strcmp(SubLs(iSub).name,'sub-06') && any(iCdt==[1 2 4 5 7 8 10 11])  && iCV==17
%                     BetaCrossSens{hs,iCV}(:,:,iCdt) = nan(size(DesMat,2),size(Features,1));
                else
                    Y = Features(:,:,Sess2Sel);
                    X=repmat(DesMat,size(Y,3),1);
                    Y = shiftdim(Y,1);
                    
                    B = pinv(X)*Y;
                    BetaCrossSens{hs,iCV}(:,:,iCdt) = B;
                end
            end
            
            clear Features Beta2Sel X Y B iSess
            
        end
        
        clear iCdt

        
    end
    
    cd(StartDir)
    
    if any(NbVertex ~= NbVertices)
        NbVertex
        NbVertices %#ok<*NOPTS>
        error('The number of vertices does not match.')
    end
    
    close all
    
    
    fprintf('\n  Running RSA, correlation and regressions\n')
    
    
    %% RSA Stim VS Stim
    fprintf('\n   Stimuli\n')
    
    if strcmp(SubLs(iSub).name,'sub-06')
        Nb_sess = 19;
    end
    
    Cdt_ROI_lhs = 1:12;
    Cdt_ROI_rhs = [2 1 4 3 6 5 8 7 9 11 12 11];
    
    partition_day = repmat(1:3,6,1);
    partition_day = partition_day(:);
    
    conditionVec_day=repmat((1:6)',3,1);
    
    for iToPlot = 1:numel(ToPlot)
        
        X_lh = nan(size(CondNames,2)*Nb_sess,NbVertex(1));
        X_rh = nan(size(CondNames,2)*Nb_sess,NbVertex(2));
        row=1;
        
        for iCV = 1:Nb_sess
            for iCdt = 1:size(CondNames,2)
                X_lh(row,VertexWithDataHS{1}) = BetaCdt{1,iCV}(iToPlot,:,Cdt_ROI_lhs(iCdt));
                X_rh(row,VertexWithDataHS{2}) = BetaCdt{2,iCV}(iToPlot,:,Cdt_ROI_rhs(iCdt));
                row=row+1;
            end
        end
        
        for iROI = 1:numel(ROI)
            
            X = [X_lh(:,ROI(iROI).VertOfInt{1}) X_rh(:,ROI(iROI).VertOfInt{2})];
            
            % Stores data for PCM
            PCM_data{iToPlot,iROI} = X;
            
            for Target = 0:1
                
                if Target==0
                    X_temp = X(1:(size(Cdt_ROI_lhs,2))*Nb_sess/2,:);
                else
                    X_temp = X(1+(size(Cdt_ROI_lhs,2))*Nb_sess/2:end,:);
                end
                
                conditionVec=repmat((1:6)',Nb_sess,1);
                
                partition = repmat(1:Nb_sess,6,1);
                partition = partition(:);
                
                partition(all(isnan(X_temp),2))=[]; conditionVec(all(isnan(X_temp),2))=[];
                X_temp(all(isnan(X_temp),2),:) = [];
                X_temp(:,any(isnan(X_temp))) = [];
                
                row=1;
                for iCV = 1:numel(DayCVs)
                    for iCdt = 1:size(CondNames,2)/2
                        Sess2Sel = all([ismember(partition,DayCVs{iCV}) conditionVec==iCdt],2);
                        X_day_CV(row,:) = nanmean(X_temp(Sess2Sel,:));
                        row=row+1;
                    end
                end
                
                %% Eucledian normalization
                if iseucnorm
                    for i=1:size(X_temp, 1)
                        X_temp(i,:) = X_temp(i,:) / norm(X_temp(i,:));
                    end
                    
                    for i=1:size(X_day_CV, 1)
                        X_day_CV(i,:) = X_day_CV(i,:) / norm(X_day_CV(i,:));
                    end
                end
                
                %% With CV
%                 if strcmp(SubLs(iSub).name,'sub-06')
%                     X_temp(partition==17,:) = [];
%                     conditionVec(partition==17,:) = [];
%                     partition(partition==17,:) = [];
%                 end
                
                A = tabulate(partition);
                A = A(:,1:2);
                if numel(unique(A(:,2)))>1
                    Sess2Remove = find(A(:,2)<numel(unique(conditionVec)));
                    conditionVec(ismember(partition,Sess2Remove)) = [];
                    X_temp(ismember(partition,Sess2Remove),:) = [];
                    partition(ismember(partition,Sess2Remove)) = [];
                end
                clear A Sess2Remove
                
                RDMs_CV{iROI,iToPlot,Target+1,1} = squareform(rsa.distanceLDC(X_temp, partition, conditionVec));
                RDMs_CV{iROI,iToPlot,Target+1,2} = squareform(rsa.distanceLDC(X_day_CV, partition_day, conditionVec_day));
                
                
                clear X_day_CV X_temp
            end
            
        end
        
    end
    

    %% RSA cross side
    fprintf('\n   Cross side\n')
    Cond_con_name = {'A','V','T','TargA','TargV','TargT'};
    
    partition_day = repmat(1:3,3,1);
    partition_day = partition_day(:);
    
    conditionVec_day=repmat((1:3)',3,1);
    
%     if strcmp(SubLs(iSub).name,'sub-06')
%         Nb_sess = 20;
%     end
    
    for iToPlot = 1:numel(ToPlot)
        
        X_lh = nan(size(Cond_con_name,2)*Nb_sess,NbVertex(1));
        X_rh = nan(size(Cond_con_name,2)*Nb_sess,NbVertex(2));
        row=1;
        
        for iCV = 1:Nb_sess
            for iCdt = 1:size(Cond_con_name,2)
                X_lh(row,VertexWithDataHS{1}) = BetaCrossSide{1,iCV}(iToPlot,:,iCdt);
                X_rh(row,VertexWithDataHS{2}) = BetaCrossSide{2,iCV}(iToPlot,:,iCdt);
                row=row+1;
            end
        end
        
        for iROI = 1:numel(ROI)
            
            X = [X_lh(:,ROI(iROI).VertOfInt{1}) X_rh(:,ROI(iROI).VertOfInt{2})];
            
            % Stores data for PCM
            PCM_data_side{iToPlot,iROI} = X;
            
            for Target = 0:1
                
                if Target==0
                    X_temp = X(1:(size(Cond_con_name,2))*Nb_sess/2,:);
                else
                    X_temp = X(1+(size(Cond_con_name,2))*Nb_sess/2:end,:);
                end
                
                partition = repmat(1:Nb_sess,3,1);
                partition = partition(:);
                
                conditionVec=repmat((1:3)',Nb_sess,1);
                
                partition(all(isnan(X_temp),2))=[]; conditionVec(all(isnan(X_temp),2))=[];
                X_temp(all(isnan(X_temp),2),:) = [];
                X_temp(:,any(isnan(X_temp))) = [];
                
                row = 1;
                for iCV = 1:numel(DayCVs)
                    for iCdt = 1:size(Cond_con_name,2)/2
                        Sess2Sel = all([ismember(partition,DayCVs{iCV}) conditionVec==iCdt],2);
                        X_day_CV(row,:) = nanmean(X_temp(Sess2Sel,:));
                        row=row+1;
                    end
                end
                
                %% Eucledian normalization
                if iseucnorm
                    for i=1:size(X_temp, 1)
                        X_temp(i,:) = X_temp(i,:) / norm(X_temp(i,:));
                    end
                    
                    for i=1:size(X_day_CV, 1)
                        X_day_CV(i,:) = X_day_CV(i,:) / norm(X_day_CV(i,:));
                    end
                end
                
                %% With CV
%                 if strcmp(SubLs(iSub).name,'sub-06')
%                     X_temp(partition==17,:) = [];
%                     conditionVec(partition==17,:) = [];
%                     partition(partition==17,:) = [];
%                 end
                
                A = tabulate(partition);
                A = A(:,1:2);
                if numel(unique(A(:,2)))>1
                    Sess2Remove = find(A(:,2)<numel(unique(conditionVec)));
                    conditionVec(ismember(partition,Sess2Remove)) = [];
                    X_temp(ismember(partition,Sess2Remove),:) = [];
                    partition(ismember(partition,Sess2Remove)) = [];
                end
                
                RDMs_CV_side{iROI,iToPlot,Target+1,1} = squareform(rsa.distanceLDC(X_temp, partition, conditionVec));
                RDMs_CV_side{iROI,iToPlot,Target+1,2} = squareform(rsa.distanceLDC(X_day_CV, partition_day, conditionVec_day));
                
                clear X_temp X_day_CV
                
            end
            
        end
        
    end
    
    %% RSA cross-sensory
    fprintf('\n   Cross sensory\n')
    
    Cond_con_name = {...
        'Contra_A-V','Contra_A-T','Contra_V-T',...
        'Ipsi_A-V','Ipsi_A-T','Ipsi_V-T',...
        'Targ-Contra_A-V','Targ-Contra_A-T','Targ-Contra_V-T',...
        'Targ-Ipsi_A-V','Targ-Ipsi_A-T','Targ-Ipsi_V-T'};
    
    conditionVec_day=repmat((1:6)',3,1);
    
    partition_day = repmat(1:3,6,1);
    partition_day = partition_day(:);
    
    for iToPlot = 1:numel(ToPlot)
        
        X_lh = nan(size(Cond_con_name,2)*Nb_sess,NbVertex(1));
        X_rh = nan(size(Cond_con_name,2)*Nb_sess,NbVertex(2));
        row=1;
        
        for iCV = 1:Nb_sess
            for iCdt = 1:size(Cond_con_name,2)
                X_lh(row,VertexWithDataHS{1}) = BetaCrossSens{1,iCV}(iToPlot,:,iCdt);
                X_rh(row,VertexWithDataHS{2}) = BetaCrossSens{2,iCV}(iToPlot,:,iCdt);
                row=row+1;
            end
        end
        
        for iROI = 1:numel(ROI)
            
            X = [X_lh(:,ROI(iROI).VertOfInt{1}) X_rh(:,ROI(iROI).VertOfInt{2})];
            
            % Stores data for PCM
            PCM_data_sens{iToPlot,iROI} = X;
            
            for Target = 0:1
                
                if Target==0
                    X_temp = X(1:(size(Cond_con_name,2))*Nb_sess/2,:);
                else
                    X_temp = X(1+(size(Cond_con_name,2))*Nb_sess/2:end,:);
                end
                
                conditionVec=repmat((1:6)',Nb_sess,1);
                
                partition = repmat(1:Nb_sess,6,1);
                partition = partition(:);
                
                partition(all(isnan(X_temp),2))=[]; conditionVec(all(isnan(X_temp),2))=[];
                X_temp(all(isnan(X_temp),2),:) = [];
                X_temp(:,any(isnan(X_temp))) = [];
                
                row = 1;
                for iCV = 1:numel(DayCVs)
                    for iCdt = 1:size(Cond_con_name,2)/2
                        Sess2Sel = all([ismember(partition,DayCVs{iCV}) conditionVec==iCdt],2);
                        X_day_CV(row,:) = nanmean(X_temp(Sess2Sel,:));
                        row=row+1;
                    end
                end
                
                %% Eucledian normalization
                if iseucnorm
                    for i=1:size(X_temp, 1)
                        X_temp(i,:) = X_temp(i,:) / norm(X_temp(i,:));
                    end
                    
                    for i=1:size(X_day_CV, 1)
                        X_day_CV(i,:) = X_day_CV(i,:) / norm(X_day_CV(i,:));
                    end
                end
                
                %% With CV
%                 if strcmp(SubLs(iSub).name,'sub-06')
%                     X_temp(partition==17,:) = [];
%                     conditionVec(partition==17,:) = [];
%                     partition(partition==17,:) = [];
%                 end
                
                A = tabulate(partition);
                A = A(:,1:2);
                if numel(unique(A(:,2)))>1
                    Sess2Remove = find(A(:,2)<numel(unique(conditionVec)));
                    conditionVec(ismember(partition,Sess2Remove)) = [];
                    X_temp(ismember(partition,Sess2Remove),:) = [];
                    partition(ismember(partition,Sess2Remove)) = [];
                end

                RDMs_CV_sens{iROI,iToPlot,Target+1,1} = squareform(rsa.distanceLDC(X_temp, partition, conditionVec));
                RDMs_CV_sens{iROI,iToPlot,Target+1,2} = squareform(rsa.distanceLDC(X_day_CV, partition_day, conditionVec_day));
                
                clear X_temp X_day_CV
                
            end
            
        end
        
    end

    
    %%
    fprintf('\n   Saving\n')
    mkdir(fullfile(Sub_dir,'results','profiles','surf','RSA'))
    save(fullfile(Sub_dir,'results','profiles','surf','RSA','RSA_mahalanobis_results.mat'),  ...
        'RDMs_CV', 'RDMs_CV_sens', 'RDMs_CV_side')
    
    mkdir(fullfile(Sub_dir,'results','profiles','surf','PCM'))
    save(fullfile(Sub_dir,'results','profiles','surf','PCM','Data_PCM.mat'), '-v7.3',  ...
        'PCM_data_sens', 'PCM_data_side', 'PCM_data')
    
    clear BetaCdt BetaCrossSens BetaCrossSide RDMs_CV RDMs_CV_sens RDMs_CV_side ...
        PCM_data_sens PCM_data_side PCM_data
    
end

cd(StartDir)
