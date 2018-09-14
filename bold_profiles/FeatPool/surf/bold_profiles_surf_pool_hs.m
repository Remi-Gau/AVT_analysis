clc; clear;

StartDir = fullfile(pwd, '..','..','..','..');
addpath(genpath(fullfile(StartDir, 'AVT-7T-code','subfun')))
Get_dependencies('D:\Dropbox/')

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

load(fullfile(StartDir,'results','roi','MinNbVert.mat'),'MinVert')

for iSub = 1:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir,'betas','6_surf');
    
    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf');    
    mkdir(Results_dir)
    
    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'))
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM
    
    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex')
    
    
    %% For the 2 hemispheres
    NbVertices = nan(1,2);
    for hs = 1:2
        
        if hs==1
            fprintf('\n Left hemipshere\n')
            HsSufix = 'l';
        else
            fprintf('\n Right hemipshere\n')
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
            load(FeatureSaveFile, 'VertexWithData','AllMapping')
            VertexWithDataHS{hs} = VertexWithData;
            MappingBothHS{hs} = AllMapping;
        else
            error('The features have not been extracted from the VTK files.')
        end
        
    end
    
    cd(StartDir)
    
    if any(NbVertex ~= NbVertices)
        NbVertex
        NbVertices %#ok<*NOPTS>
        error('The number of vertices does not match.')
    end
    
    
    Features_lh = nan(NbVertex(1),NbLayers,size(MappingBothHS{1},3));
    Features_lh(VertexWithDataHS{1},:,:) = MappingBothHS{1};
    
    Features_rh = nan(NbVertex(2),NbLayers,size(MappingBothHS{2},3));
    Features_rh(VertexWithDataHS{2},:,:) = MappingBothHS{2};
    
    
    
    %%
    fprintf(' Averaging for ROI:\n')
    
    for iROI = 1:numel(ROI)
        
        clear Data_ROI
        
        Data_ROI.name = ROI(iROI).name;
        
        fprintf(['  '  Data_ROI.name '\n'])
        
        FeaturesL = Features_lh(ROI(iROI).VertOfInt{1},:,:);
        FeaturesR = Features_rh(ROI(iROI).VertOfInt{2},:,:);

        Features = cat(1,FeaturesL,FeaturesR);
        
        fprintf('  NaNs: %i ; Zeros: %i\n',...
            sum(any(any(any(isnan(Features),3),2))),....
            sum(any(any(any(Features==0,3),2))))
        Data_ROI.NaNorZero = [sum(any(any(any(isnan(Features),3),2))) ...
            sum(any(any(any(Features==0,3),2)))];
        
        
        %% For ipsi-lateral stimulus
        Cdt_ROI_lhs = [1 3 5];
        Cdt_ROI_rhs = [2 4 6];
        
        Data_ROI.Ispi.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.Ispi.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        
        Data_ROI.Ispi.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.Ispi.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        
        for iCdt = 1:numel(Cdt_ROI_lhs)
            
            Contra_Beta2Sel_lhs = [];
            Contra_Beta2Sel_rhs = [];
            for iSess = 1:Nb_sess
                Contra_Beta2Sel_lhs = [Contra_Beta2Sel_lhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs(iCdt)}  '*bf(1)']))];  %#ok<*AGROW>
                Contra_Beta2Sel_rhs = [Contra_Beta2Sel_rhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs(iCdt)}  '*bf(1)']))];  
            end
            
            Contra_Beta2Sel_lhs = find(ismember(BetaOfInterest, Contra_Beta2Sel_lhs));
            Contra_Beta2Sel_rhs = find(ismember(BetaOfInterest, Contra_Beta2Sel_rhs));
            
            tmpL = shiftdim(FeaturesL(:,:,Contra_Beta2Sel_lhs),1);
            tmpR = shiftdim(FeaturesR(:,:,Contra_Beta2Sel_rhs),1);
            tmp = cat(3,tmpL,tmpR);
            
            Data_ROI.Ispi.WholeROI.MEAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmean(tmp,3),1));
            Data_ROI.Ispi.WholeROI.MEDIAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmedian(tmp,3),1));
            
            Data_ROI.Ispi.LayerMean(:,1:size(tmp,2),iCdt) = nanmean(tmp,3);
            Data_ROI.Ispi.LayerMedian(:,1:size(tmp,2),iCdt) = nanmedian(tmp,3);

        end
        
        
        %% For contra-lateral stimulus
        Cdt_ROI_lhs = [2 4 6];
        Cdt_ROI_rhs = [1 3 5];

        Data_ROI.Contra.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.Contra.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        
        Data_ROI.Contra.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.Contra.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        
        for iCdt = 1:numel(Cdt_ROI_lhs)
            
            Contra_Beta2Sel_lhs = [];
            Contra_Beta2Sel_rhs = [];
            for iSess = 1:Nb_sess
                Contra_Beta2Sel_lhs = [Contra_Beta2Sel_lhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs(iCdt)}  '*bf(1)']))];  %#ok<*AGROW>
                Contra_Beta2Sel_rhs = [Contra_Beta2Sel_rhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs(iCdt)}  '*bf(1)']))];  
            end
            
            Contra_Beta2Sel_lhs = find(ismember(BetaOfInterest, Contra_Beta2Sel_lhs));
            Contra_Beta2Sel_rhs = find(ismember(BetaOfInterest, Contra_Beta2Sel_rhs));
            
            tmpL = shiftdim(FeaturesL(:,:,Contra_Beta2Sel_lhs),1);
            tmpR = shiftdim(FeaturesR(:,:,Contra_Beta2Sel_rhs),1);
            tmp = cat(3,tmpL,tmpR);
            
            Data_ROI.Contra.WholeROI.MEAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmean(tmp,3),1));
            Data_ROI.Contra.WholeROI.MEDIAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmedian(tmp,3),1));
            
            Data_ROI.Contra.LayerMean(:,1:size(tmp,2),iCdt) = nanmean(tmp,3);
            Data_ROI.Contra.LayerMedian(:,1:size(tmp,2),iCdt) = nanmedian(tmp,3);

        end
        
        
        %% For contra - ipsi 
        Cdt_ROI_lhs = {...
            2 1;
            4 3;
            6 5};
        Cdt_ROI_rhs = {...
            1 2;
            3 4;
            5 6};
        
        Data_ROI.Contra_VS_Ipsi.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.Contra_VS_Ipsi.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        
        Data_ROI.Contra_VS_Ipsi.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.Contra_VS_Ipsi.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        
        for iCdt = 1:size(Cdt_ROI_lhs,1)
            
            Contra_Beta2Sel_lhs = [];
            Contra_Beta2Sel_rhs = [];
            Ipsi_Beta2Sel_lhs = [];
            Ipsi_Beta2Sel_rhs = [];
            for iSess = 1:Nb_sess
                Contra_Beta2Sel_lhs = [Contra_Beta2Sel_lhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs{iCdt,1}}  '*bf(1)']))]; 
                Contra_Beta2Sel_rhs = [Contra_Beta2Sel_rhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs{iCdt,1}}  '*bf(1)']))];  
                Ipsi_Beta2Sel_lhs = [Ipsi_Beta2Sel_lhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs{iCdt,2}}  '*bf(1)']))]; 
                Ipsi_Beta2Sel_rhs = [Ipsi_Beta2Sel_rhs ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs{iCdt,2}}  '*bf(1)']))];  
            end
            
            Contra_Beta2Sel_lhs = find(ismember(BetaOfInterest, Contra_Beta2Sel_lhs));
            Contra_Beta2Sel_rhs = find(ismember(BetaOfInterest, Contra_Beta2Sel_rhs));
            
            Ipsi_Beta2Sel_lhs = find(ismember(BetaOfInterest, Ipsi_Beta2Sel_lhs));
            Ipsi_Beta2Sel_rhs = find(ismember(BetaOfInterest, Ipsi_Beta2Sel_rhs));
            
            Contra_L = shiftdim(FeaturesL(:,:,Contra_Beta2Sel_lhs),1);
            Contra_R = shiftdim(FeaturesR(:,:,Contra_Beta2Sel_rhs),1);
            Contra = cat(3,Contra_L,Contra_R);
            
            Ipsi_L = shiftdim(FeaturesL(:,:,Ipsi_Beta2Sel_lhs),1);
            Ipsi_R = shiftdim(FeaturesR(:,:,Ipsi_Beta2Sel_rhs),1);
            Ipsi = cat(3,Ipsi_L,Ipsi_R);
            
            tmp = Contra-Ipsi;
            Remove = ~(squeeze(any(any(isnan(tmp)),2)));
            tmp = tmp(:,:,Remove);
            
            Data_ROI.Contra_VS_Ipsi.WholeROI.MEAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmean(tmp,3),1));
            Data_ROI.Contra_VS_Ipsi.WholeROI.MEDIAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmedian(tmp,3),1));
            
            Data_ROI.Contra_VS_Ipsi.LayerMean(:,1:size(tmp,2),iCdt) = nanmean(tmp,3);
            Data_ROI.Contra_VS_Ipsi.LayerMedian(:,1:size(tmp,2),iCdt) = nanmedian(tmp,3);
            
        end
        
        
        %% Contrast between sensory modalities Ipsi
        Cdt_ROI_lhs = {...
            1 3;
            1 5;
            3 5};
        Cdt_ROI_rhs = {...
            2 4;
            2 6;
            4 6};
        
        Data_ROI.ContSensModIpsi.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.ContSensModIpsi.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        
        Data_ROI.ContSensModIpsi.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.ContSensModIpsi.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        
        for iCdt = 1:size(Cdt_ROI_lhs,1)
            
            SensMod1_Beta2Sel_lhs = [];
            SensMod1_Beta2Sel_rhs = [];
            SensMod2_Beta2Sel_lhs = [];
            SensMod2_Beta2Sel_rhs = [];
            for iSess = 1:Nb_sess
                
                A = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs{iCdt,1}}  '*bf(1)']));
                B = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs{iCdt,1}}  '*bf(1)']));
                C = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs{iCdt,2}}  '*bf(1)']));
                D = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs{iCdt,2}}  '*bf(1)']));
                
                if any(cellfun('isempty',{A B C D}))
                else
                    SensMod1_Beta2Sel_lhs = [SensMod1_Beta2Sel_lhs ; A]; 
                    SensMod1_Beta2Sel_rhs = [SensMod1_Beta2Sel_rhs ; B];  
                    SensMod2_Beta2Sel_lhs = [SensMod2_Beta2Sel_lhs ; C];  
                    SensMod2_Beta2Sel_rhs = [SensMod2_Beta2Sel_rhs ; D]; 
                end
                
            end
            
            SensMod1_Beta2Sel_lhs = find(ismember(BetaOfInterest, SensMod1_Beta2Sel_lhs));
            SensMod1_Beta2Sel_rhs = find(ismember(BetaOfInterest, SensMod1_Beta2Sel_rhs));
            
            SensMod2_Beta2Sel_lhs = find(ismember(BetaOfInterest, SensMod2_Beta2Sel_lhs));
            SensMod2_Beta2Sel_rhs = find(ismember(BetaOfInterest, SensMod2_Beta2Sel_rhs));
            
            SensMod1_L = shiftdim(FeaturesL(:,:,SensMod1_Beta2Sel_lhs),1);
            SensMod1_R = shiftdim(FeaturesR(:,:,SensMod1_Beta2Sel_rhs),1);
            SensMod1 = cat(3,SensMod1_L,SensMod1_R);
            
            SensMod2_L = shiftdim(FeaturesL(:,:,SensMod2_Beta2Sel_lhs),1);
            SensMod2_R = shiftdim(FeaturesR(:,:,SensMod2_Beta2Sel_rhs),1);
            SensMod2 = cat(3,SensMod2_L,SensMod2_R);
            
            tmp = SensMod1-SensMod2;
            Remove = ~(squeeze(any(any(isnan(tmp)),2)));
            tmp = tmp(:,:,Remove);
            
            Data_ROI.ContSensModIpsi.WholeROI.MEAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmean(tmp,3),1));
            Data_ROI.ContSensModIpsi.WholeROI.MEDIAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmedian(tmp,3),1));
            
            Data_ROI.ContSensModIpsi.LayerMean(:,1:size(tmp,2),iCdt) = nanmean(tmp,3);
            Data_ROI.ContSensModIpsi.LayerMedian(:,1:size(tmp,2),iCdt) = nanmedian(tmp,3);
            
        end
        
        
        
        %% Contrast between sensory modalities Contra
        Cdt_ROI_lhs = {...
            2 4;
            2 6;
            4 6};
        Cdt_ROI_rhs = {...
            1 3;
            1 5;
            3 5};
        
        Data_ROI.ContSensModContra.LayerMean = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.ContSensModContra.LayerMedian = nan(NbLayers, Nb_sess, size(Cdt_ROI_lhs,1));
        
        Data_ROI.ContSensModContra.WholeROI.MEAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        Data_ROI.ContSensModContra.WholeROI.MEDIAN = nan(Nb_sess, size(Cdt_ROI_lhs,1));
        
        for iCdt = 1:size(Cdt_ROI_lhs,1)
            
            SensMod1_Beta2Sel_lhs = [];
            SensMod1_Beta2Sel_rhs = [];
            SensMod2_Beta2Sel_lhs = [];
            SensMod2_Beta2Sel_rhs = [];
            for iSess = 1:Nb_sess
                A = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs{iCdt,1}}  '*bf(1)']));
                B = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs{iCdt,1}}  '*bf(1)']));
                C = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_lhs{iCdt,2}}  '*bf(1)']));
                D = find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cdt_ROI_rhs{iCdt,2}}  '*bf(1)']));
                
                if any(cellfun('isempty',{A B C D}))
                else
                    SensMod1_Beta2Sel_lhs = [SensMod1_Beta2Sel_lhs ; A]; 
                    SensMod1_Beta2Sel_rhs = [SensMod1_Beta2Sel_rhs ; B];  
                    SensMod2_Beta2Sel_lhs = [SensMod2_Beta2Sel_lhs ; C];  
                    SensMod2_Beta2Sel_rhs = [SensMod2_Beta2Sel_rhs ; D]; 
                end
            end
            
            SensMod1_Beta2Sel_lhs = find(ismember(BetaOfInterest, SensMod1_Beta2Sel_lhs));
            SensMod1_Beta2Sel_rhs = find(ismember(BetaOfInterest, SensMod1_Beta2Sel_rhs));
            
            SensMod2_Beta2Sel_lhs = find(ismember(BetaOfInterest, SensMod2_Beta2Sel_lhs));
            SensMod2_Beta2Sel_rhs = find(ismember(BetaOfInterest, SensMod2_Beta2Sel_rhs));
            
            SensMod1_L = shiftdim(FeaturesL(:,:,SensMod1_Beta2Sel_lhs),1);
            SensMod1_R = shiftdim(FeaturesR(:,:,SensMod1_Beta2Sel_rhs),1);
            SensMod1 = cat(3,SensMod1_L,SensMod1_R);
            
            SensMod2_L = shiftdim(FeaturesL(:,:,SensMod2_Beta2Sel_lhs),1);
            SensMod2_R = shiftdim(FeaturesR(:,:,SensMod2_Beta2Sel_rhs),1);
            SensMod2 = cat(3,SensMod2_L,SensMod2_R);
            
            tmp = SensMod1-SensMod2;
            Remove = ~(squeeze(any(any(isnan(tmp)),2)));
            tmp = tmp(:,:,Remove);
            
            Data_ROI.ContSensModContra.WholeROI.MEAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmean(tmp,3),1));
            Data_ROI.ContSensModContra.WholeROI.MEDIAN(1:size(tmp,2),iCdt) = squeeze(nanmean(nanmedian(tmp,3),1));
            
            Data_ROI.ContSensModContra.LayerMean(:,1:size(tmp,2),iCdt) = nanmean(tmp,3);
            Data_ROI.ContSensModContra.LayerMedian(:,1:size(tmp,2),iCdt) = nanmedian(tmp,3);
            
        end
        
        
        
        %%
        Data_ROI.Ispi.MEAN=squeeze(nanmean(Data_ROI.Ispi.LayerMean,2));
        Data_ROI.Ispi.MEDIAN=squeeze(nanmean(Data_ROI.Ispi.LayerMedian,2));        
        Data_ROI.Ispi.STD=squeeze(nanstd(Data_ROI.Ispi.LayerMean,2));
        Data_ROI.Ispi.SEM=squeeze(nansem(Data_ROI.Ispi.LayerMean,2));
        
        Data_ROI.Contra.MEAN=squeeze(nanmean(Data_ROI.Contra.LayerMean,2));
        Data_ROI.Contra.MEDIAN=squeeze(nanmean(Data_ROI.Contra.LayerMedian,2));
        Data_ROI.Contra.STD=squeeze(nanstd(Data_ROI.Contra.LayerMean,2));
        Data_ROI.Contra.SEM=squeeze(nansem(Data_ROI.Contra.LayerMean,2));
        
        Data_ROI.Contra_VS_Ipsi.MEAN=squeeze(nanmean(Data_ROI.Contra_VS_Ipsi.LayerMean,2));
        Data_ROI.Contra_VS_Ipsi.MEDIAN=squeeze(nanmean(Data_ROI.Contra_VS_Ipsi.LayerMedian,2));        
        Data_ROI.Contra_VS_Ipsi.STD=squeeze(nanstd(Data_ROI.Contra_VS_Ipsi.LayerMean,2));
        Data_ROI.Contra_VS_Ipsi.SEM=squeeze(nansem(Data_ROI.Contra_VS_Ipsi.LayerMean,2));       
        
        Data_ROI.ContSensModIpsi.MEAN=squeeze(nanmean(Data_ROI.ContSensModIpsi.LayerMean,2));
        Data_ROI.ContSensModIpsi.MEDIAN=squeeze(nanmean(Data_ROI.ContSensModIpsi.LayerMedian,2));        
        Data_ROI.ContSensModIpsi.STD=squeeze(nanstd(Data_ROI.ContSensModIpsi.LayerMean,2));
        Data_ROI.ContSensModIpsi.SEM=squeeze(nansem(Data_ROI.ContSensModIpsi.LayerMean,2));
        
        Data_ROI.ContSensModContra.MEAN=squeeze(nanmean(Data_ROI.ContSensModContra.LayerMean,2));
        Data_ROI.ContSensModContra.MEDIAN=squeeze(nanmean(Data_ROI.ContSensModContra.LayerMedian,2));        
        Data_ROI.ContSensModContra.STD=squeeze(nanstd(Data_ROI.ContSensModContra.LayerMean,2));
        Data_ROI.ContSensModContra.SEM=squeeze(nansem(Data_ROI.ContSensModContra.LayerMean,2));
            
        
        save(fullfile(Results_dir, strcat('Data_Pooled_Surf_', ROI(iROI).name, ...
            '_l-', num2str(NbLayers), '.mat')), 'Data_ROI')        
        
        
        
    end
    
    
end

cd(StartDir)
