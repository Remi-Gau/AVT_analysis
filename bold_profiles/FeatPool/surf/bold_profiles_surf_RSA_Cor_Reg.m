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
    'TStimL','TStimR'...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
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
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir,'betas','6_surf');
    
    
    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'))
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
                    BetaCdt{hs,iCV}(:,:,iCdt) = nan(size(DesMat,2),size(Features,1));
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
        Cond_con_name = {'A','V','T'};
        
        if hs==1
            Cond2Contrast = {...
                2, 1;...
                4, 3;...
                6, 5};
        elseif hs==2
            Cond2Contrast = {...
                1, 2;...
                3, 4;...
                5, 6};
        end
        
        for iCdt=1:size(Cond2Contrast,1)
            
            fprintf('    %s Contra-Ipsi\n',Cond_con_name{iCdt})
            
            Beta2Sel = [];
            Beta2Sel2 = [];
            
            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name,'sub-06') && iSess==17 && iCdt==1
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
                if strcmp(SubLs(iSub).name,'sub-06') && iCdt==1 && iCV==17
                    BetaCrossSide{hs,iCV}(:,:,iCdt) = nan(size(DesMat,2),size(Features,1));
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
            'Ipsi_A-V','Ipsi_A-T','Ipsi_V-T'};
        
        if hs==1
            Cond2Contrast = {...
                2, 4;...
                2, 6;...
                4, 6;...
                1, 3;...
                1, 5;...
                3, 5};
        elseif hs==2
            Cond2Contrast = {...
                1, 3;...
                1, 5;...
                3, 5;...
                2, 4;...
                2, 6;...
                4, 6};
        end
        
        for iCdt=1:size(Cond2Contrast,1)
            
            fprintf('    %s\n',Cond_con_name{iCdt})
            
            Beta2Sel = [];
            Beta2Sel2 = [];
            
            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name,'sub-06') && iSess==17 && any(iCdt==[1 2 4 5])
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
                if strcmp(SubLs(iSub).name,'sub-06') && any(iCdt==[1 2 4 5])  && iCV==17
                    BetaCrossSens{hs,iCV}(:,:,iCdt) = nan(size(DesMat,2),size(Features,1));
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
    
    Cdt_ROI_lhs = 1:6;
    Cdt_ROI_rhs = [2 1 4 3 6 5];
    
    A = repmat(1:6,6,1);
    Cdt = [A(:), repmat((1:6)',6,1)];
    clear A
    
    conditionVec_day=repmat((1:6)',3,1);
    
    partition_day = repmat(1:3,6,1);
    partition_day = partition_day(:);
    
    
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
            
            conditionVec=repmat((1:6)',Nb_sess,1);
            
            partition = repmat(1:Nb_sess,6,1);
            partition = partition(:);
            
            X = [X_lh(:,ROI(iROI).VertOfInt{1}) X_rh(:,ROI(iROI).VertOfInt{2})];
            partition(all(isnan(X),2))=[]; conditionVec(all(isnan(X),2))=[];
            X(all(isnan(X),2),:) = [];
            X(:,any(isnan(X))) = [];
            
            row=1;
            for iCV = 1:numel(DayCVs)
                for iCdt = 1:size(CondNames,2)
                    Sess2Sel = all([ismember(partition,DayCVs{iCV}) conditionVec==iCdt],2);
                    X_day_CV(row,:) = nanmean(X(Sess2Sel,:));
                    row=row+1;
                end
            end
            
            for iCdt = 1:size(CondNames,2)
                X_no_CV(iCdt,:) = nanmean(X(conditionVec==iCdt,:));
            end
            
            %% Regressions and simple correlations
            % with no CV first
            Beta = nan(6,6,3);
            for iCdt = 1:size(Cdt,1)
                Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2) = glmfit(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:), 'normal');
                R=corrcoef(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:));
                Beta(Cdt(iCdt,1),Cdt(iCdt,2),3) = R(1,2);
            end
            
            GrpBetaReg{iROI,iToPlot,1}(:,:,iSub) =  Beta(:,:,2);
            GrpBetaReg{iROI,iToPlot,2}(:,:,iSub) =  Beta(:,:,3);
            
            % with CV
            Beta = nan(6,6,3,Nb_sess);
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
            
            GrpBetaReg_cv{iROI,iToPlot,1}(:,:,iSub) =  nanmean(Beta(:,:,2,:),4);
            GrpBetaReg_cv{iROI,iToPlot,2}(:,:,iSub) =  nanmean(Beta(:,:,3,:),4);
            
            % with day CV
            Beta = nan(6,6,3,numel(DayCVs));
            for iCV = 1:numel(DayCVs)
                for iCdt = 1:size(Cdt,1)
                    train = all([ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,1)],2);
                    test =  all([~ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,2)],2);
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2,iCV) = glmfit(nanmean(X(train,:)),nanmean(X(test,:)), 'normal');
                    R=corrcoef(nanmean(X(train,:)),nanmean(X(test,:)));
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),3,iCV) = R(1,2);
                end
            end
            
            GrpBetaReg_day_cv{iROI,iToPlot,1}(:,:,iSub) =  nanmean(Beta(:,:,2,:),4);
            GrpBetaReg_day_cv{iROI,iToPlot,2}(:,:,iSub) =  nanmean(Beta(:,:,3,:),4);
            
            %% Eucledian normalization
            if iseucnorm
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
            subjectRDMs{iROI,iToPlot,1}(:,:,iSub) = squareform((pdist(X_no_CV, 'euclidean').^2)/size(X_no_CV,2));
            subjectRDMs{iROI,iToPlot,2}(:,:,iSub) = squareform(pdist(X_no_CV, 'spearman'));
            
            RDM_euc = nan(6);
            RDM_pear = nan(6);
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
            subjectRDMs{iROI,iToPlot,3}(:,:,iSub) = RDM_euc;
            subjectRDMs{iROI,iToPlot,4}(:,:,iSub) = RDM_pear;
            
            %% With CV
            if strcmp(SubLs(iSub).name,'sub-06')
                X(partition==17,:) = [];
                conditionVec(partition==17,:) = [];
                partition(partition==17,:) = [];
            end
            subjectRDMs_CV{iROI,iToPlot,1}(:,:,iSub) = squareform(rsa.distanceLDC(X, partition, conditionVec));
            subjectRDMs_CV{iROI,iToPlot,2}(:,:,iSub) = squareform(rsa.distanceLDC(X_day_CV, partition_day, conditionVec_day));
            
            
            % whole CV
            RDM_euc = nan(6,6,Nb_sess);
            RDM_pear = nan(6,6,Nb_sess);
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
            
            subjectRDMs_CV{iROI,iToPlot,3}(:,:,iSub) = nanmean(RDM_euc,3);
            subjectRDMs_CV{iROI,iToPlot,4}(:,:,iSub) = nanmean(RDM_pear,3);
            
            % Day CV
            RDM_euc = nan(6,6,numel(DayCVs));
            RDM_pear = nan(6,6,numel(DayCVs));
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
            
            subjectRDMs_CV{iROI,iToPlot,5}(:,:,iSub) = nanmean(RDM_euc,3);
            subjectRDMs_CV{iROI,iToPlot,6}(:,:,iSub) = nanmean(RDM_pear,3);
            
            
            clear X X_day_CV X_no_CV
            
            
            
        end
        
    end
    
    %% RSA cross side
    fprintf('\n   Cross side\n')
    Cond_con_name = {'A','V','T'};
    
    if strcmp(SubLs(iSub).name,'sub-06')
        Nb_sess = 20;
    end
    
    A = repmat(1:3,3,1);
    Cdt = [A(:), repmat((1:3)',3,1)];
    clear A
    
    conditionVec_day=repmat((1:3)',3,1);
    
    partition_day = repmat(1:3,3,1);
    partition_day = partition_day(:);
    
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
            
            partition = repmat(1:Nb_sess,3,1);
            partition = partition(:);
            
            conditionVec=repmat((1:3)',Nb_sess,1);
            
            X = [X_lh(:,ROI(iROI).VertOfInt{1}) X_rh(:,ROI(iROI).VertOfInt{2})];
            partition(all(isnan(X),2))=[]; conditionVec(all(isnan(X),2))=[];
            X(all(isnan(X),2),:) = [];
            X(:,any(isnan(X))) = [];
            
            row = 1;
            for iCV = 1:numel(DayCVs)
                for iCdt = 1:size(Cond_con_name,2)
                    Sess2Sel = all([ismember(partition,DayCVs{iCV}) conditionVec==iCdt],2);
                    X_day_CV(row,:) = nanmean(X(Sess2Sel,:));
                    row=row+1;
                end
            end
            
            for iCdt = 1:size(Cond_con_name,2)
                X_no_CV(iCdt,:) = nanmean(X(conditionVec==iCdt,:));
            end
            
            %% Regressions and simple correlations
            
            % with no CV first
            Beta = nan(3,3,3);
            for iCdt = 1:size(Cdt,1)
                Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2) = glmfit(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:), 'normal');
                R=corrcoef(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:));
                Beta(Cdt(iCdt,1),Cdt(iCdt,2),3) = R(1,2);
            end
            
            GrpBetaReg_side{iROI,iToPlot,1}(:,:,iSub) =  Beta(:,:,2);
            GrpBetaReg_side{iROI,iToPlot,2}(:,:,iSub) =  Beta(:,:,3);
            
            % with CV
            Beta = nan(3,3,3,Nb_sess);
            for iCV = 1:Nb_sess
                for iCdt = 1:size(Cdt,1)
                    if strcmp(SubLs(iSub).name,'sub-06') && iCV==17
                    else
                        train = all([ismember(partition,iCV) conditionVec==Cdt(iCdt,1)],2);
                        test =  all([~ismember(partition,iCV) conditionVec==Cdt(iCdt,2)],2);
                        x = X(train,:);
                        y = nanmean(X(test,:));
                        if all(x==0)
                        else
                            Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2,iCV) = glmfit(x,y, 'normal');
                            R=corrcoef(x,y);
                            Beta(Cdt(iCdt,1),Cdt(iCdt,2),3,iCV) = R(1,2);
                        end
                    end
                end
            end
            
            GrpBetaReg_cv_side{iROI,iToPlot,1}(:,:,iSub) =  nanmean(Beta(:,:,2,:),4);
            GrpBetaReg_cv_side{iROI,iToPlot,2}(:,:,iSub) =  nanmean(Beta(:,:,3,:),4);
            
            % with day CV
            Beta = nan(3,3,3,numel(DayCVs));
            for iCV = 1:numel(DayCVs)
                for iCdt = 1:size(Cdt,1)
                    train = all([ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,1)],2);
                    test =  all([~ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,2)],2);
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2,iCV) = glmfit(nanmean(X(train,:)),nanmean(X(test,:)), 'normal');
                    R=corrcoef(nanmean(X(train,:)),nanmean(X(test,:)));
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),3,iCV) = R(1,2);
                end
            end
            
            GrpBetaReg_day_cv_side{iROI,iToPlot,1}(:,:,iSub) =  nanmean(Beta(:,:,2,:),4);
            GrpBetaReg_day_cv_side{iROI,iToPlot,2}(:,:,iSub) =  nanmean(Beta(:,:,3,:),4);
            
            %% Eucledian normalization
            if iseucnorm
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
            subjectRDMs_side{iROI,iToPlot,1}(:,:,iSub) = squareform((pdist(X_no_CV, 'euclidean').^2)/size(X_no_CV,2));
            subjectRDMs_side{iROI,iToPlot,2}(:,:,iSub) = squareform(pdist(X_no_CV, 'spearman'));
            
            RDM_euc = nan(3);
            RDM_pear = nan(3);
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
            subjectRDMs_side{iROI,iToPlot,3}(:,:,iSub) = RDM_euc;
            subjectRDMs_side{iROI,iToPlot,4}(:,:,iSub) = RDM_pear;
            
            
            %% With CV
            if strcmp(SubLs(iSub).name,'sub-06')
                X(partition==17,:) = [];
                conditionVec(partition==17,:) = [];
                partition(partition==17,:) = [];
            end
            subjectRDMs_CV_side{iROI,iToPlot,1}(:,:,iSub) = squareform(rsa.distanceLDC(X, partition, conditionVec));
            subjectRDMs_CV_side{iROI,iToPlot,2}(:,:,iSub) = squareform(rsa.distanceLDC(X_day_CV, partition_day, conditionVec_day));
            
            % all CV
            RDM_euc = nan(3,3,Nb_sess);
            RDM_pear = nan(3,3,Nb_sess);
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
            
            subjectRDMs_CV_side{iROI,iToPlot,3}(:,:,iSub) = nanmean(RDM_euc,3);
            subjectRDMs_CV_side{iROI,iToPlot,4}(:,:,iSub) = nanmean(RDM_pear,3);
            
            
            % Day CV
            RDM_euc = nan(3,3,numel(DayCVs));
            RDM_pear = nan(3,3,numel(DayCVs));
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
            
            subjectRDMs_CV_side{iROI,iToPlot,5}(:,:,iSub) = nanmean(RDM_euc,3);
            subjectRDMs_CV_side{iROI,iToPlot,6}(:,:,iSub) = nanmean(RDM_pear,3);
            
            
            clear X X_day_CV X_no_CV
            
        end
        
    end
    
    
    %% RSA cross-sensory
    fprintf('\n   Cross sensory\n')
    
    Cond_con_name = {...
        'Contra_A-V','Contra_A-T','Contra_V-T',...
        'Ipsi_A-V','Ipsi_A-T','Ipsi_V-T'};
    
    A = repmat(1:6,6,1);
    Cdt = [A(:), repmat((1:6)',6,1)];
    clear A
    
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
            
            conditionVec=repmat((1:6)',Nb_sess,1);
            
            partition = repmat(1:Nb_sess,6,1);
            partition = partition(:);
            
            X = [X_lh(:,ROI(iROI).VertOfInt{1}) X_rh(:,ROI(iROI).VertOfInt{2})];
            partition(all(isnan(X),2))=[]; conditionVec(all(isnan(X),2))=[];
            X(all(isnan(X),2),:) = [];
            X(:,any(isnan(X))) = [];
            
            row = 1;
            for iCV = 1:numel(DayCVs)
                for iCdt = 1:size(Cond_con_name,2)
                    Sess2Sel = all([ismember(partition,DayCVs{iCV}) conditionVec==iCdt],2);
                    X_day_CV(row,:) = nanmean(X(Sess2Sel,:));
                    row=row+1;
                end
            end
            
            for iCdt = 1:size(Cond_con_name,2)
                X_no_CV(iCdt,:) = nanmean(X(conditionVec==iCdt,:));
            end
            
            %% Regressions and simple correlations
            
            % with no CV first
            Beta = nan(6,6,3);
            for iCdt = 1:size(Cdt,1)
                Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2) = glmfit(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:), 'normal');
                R=corrcoef(X_no_CV(Cdt(iCdt,1),:),X_no_CV(Cdt(iCdt,2),:));
                Beta(Cdt(iCdt,1),Cdt(iCdt,2),3) = R(1,2);
            end
            
            GrpBetaReg_sens{iROI,iToPlot,1}(:,:,iSub) =  Beta(:,:,2);
            GrpBetaReg_sens{iROI,iToPlot,2}(:,:,iSub) =  Beta(:,:,3);
            
            % with CV
            Beta = nan(6,6,3,Nb_sess);
            for iCV = 1:Nb_sess
                for iCdt = 1:size(Cdt,1)
                    if strcmp(SubLs(iSub).name,'sub-06') && iCV==17
                    else
                        train = all([ismember(partition,iCV) conditionVec==Cdt(iCdt,1)],2);
                        test =  all([~ismember(partition,iCV) conditionVec==Cdt(iCdt,2)],2);
                        x = X(train,:);
                        y = nanmean(X(test,:));
                        if all(x==0)
                        else
                            Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2,iCV) = glmfit(x,y, 'normal');
                            R=corrcoef(x,y);
                            Beta(Cdt(iCdt,1),Cdt(iCdt,2),3,iCV) = R(1,2);
                        end
                    end
                end
            end
            
            GrpBetaReg_cv_sens{iROI,iToPlot,1}(:,:,iSub) =  nanmean(Beta(:,:,2,:),4);
            GrpBetaReg_cv_sens{iROI,iToPlot,2}(:,:,iSub) =  nanmean(Beta(:,:,3,:),4);
            
            % with day CV
            Beta = nan(6,6,3,numel(DayCVs));
            for iCV = 1:numel(DayCVs)
                for iCdt = 1:size(Cdt,1)
                    train = all([ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,1)],2);
                    test =  all([~ismember(partition,DayCVs{iCV}) conditionVec==Cdt(iCdt,2)],2);
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),1:2,iCV) = glmfit(nanmean(X(train,:)),nanmean(X(test,:)), 'normal');
                    R=corrcoef(nanmean(X(train,:)),nanmean(X(test,:)));
                    Beta(Cdt(iCdt,1),Cdt(iCdt,2),3,iCV) = R(1,2);
                end
            end
            
            GrpBetaReg_day_cv_sens{iROI,iToPlot,1}(:,:,iSub) =  nanmean(Beta(:,:,2,:),4);
            GrpBetaReg_day_cv_sens{iROI,iToPlot,2}(:,:,iSub) =  nanmean(Beta(:,:,3,:),4);
            
            
            %% Eucledian normalization
            if iseucnorm
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
            subjectRDMs_sens{iROI,iToPlot,1}(:,:,iSub) = squareform((pdist(X_no_CV, 'euclidean').^2)/size(X_no_CV,2));
            subjectRDMs_sens{iROI,iToPlot,2}(:,:,iSub) = squareform(pdist(X_no_CV, 'spearman'));
            
            RDM_euc = nan(6);
            RDM_pear = nan(6);
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
            subjectRDMs_sens{iROI,iToPlot,3}(:,:,iSub) = RDM_euc;
            subjectRDMs_sens{iROI,iToPlot,4}(:,:,iSub) = RDM_pear;
            
            
            %% With CV
            if strcmp(SubLs(iSub).name,'sub-06')
                X(partition==17,:) = [];
                conditionVec(partition==17,:) = [];
                partition(partition==17,:) = [];
            end
            subjectRDMs_CV_sens{iROI,iToPlot,1}(:,:,iSub) = squareform(rsa.distanceLDC(X, partition, conditionVec));
            subjectRDMs_CV_sens{iROI,iToPlot,2}(:,:,iSub) = squareform(rsa.distanceLDC(X_day_CV, partition_day, conditionVec_day));
            
            % all CV
            RDM_euc = nan(6,6,Nb_sess);
            RDM_pear = nan(6,6,Nb_sess);
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
            
            subjectRDMs_CV_sens{iROI,iToPlot,3}(:,:,iSub) = nanmean(RDM_euc,3);
            subjectRDMs_CV_sens{iROI,iToPlot,4}(:,:,iSub) = nanmean(RDM_pear,3);
            
            % Day CV
            RDM_euc = nan(6,6,numel(DayCVs));
            RDM_pear = nan(6,6,numel(DayCVs));
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
            
            subjectRDMs_CV_sens{iROI,iToPlot,5}(:,:,iSub) = nanmean(RDM_euc,3);
            subjectRDMs_CV_sens{iROI,iToPlot,6}(:,:,iSub) = nanmean(RDM_pear,3);
            
            clear X X_day_CV X_no_CV
            
        end
        
    end
    
    clear BetaCdt BetaCrossSens BetaCrossSide
    
    
end

cd(StartDir)

mkdir(fullfile(StartDir,'results','profiles','surf','RSA'))
save(fullfile(StartDir,'results','profiles','surf','RSA','RSA_grp_results.mat'),  ...
    'subjectRDMs_CV', 'subjectRDMs_CV_sens', 'subjectRDMs_CV_side',...
    'subjectRDMs', 'subjectRDMs_sens', 'subjectRDMs_side', ...
    'GrpBetaReg_sens', 'GrpBetaReg_cv_sens', 'GrpBetaReg_day_cv_sens', ...
    'GrpBetaReg_side', 'GrpBetaReg_cv_side', 'GrpBetaReg_day_cv_side', ...
    'GrpBetaReg', 'GrpBetaReg_cv', 'GrpBetaReg_day_cv')
