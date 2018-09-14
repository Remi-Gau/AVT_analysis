function bold_profiles_surf_rasters_CV()
% Compute cross validated rasters

StartDir = 'D:\Dropbox\PhD\Experiments\AVT\derivatives';
addpath(genpath(fullfile(StartDir, 'AVT-7T-code','subfun')))
Get_dependencies('D:\Dropbox/')

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

DoCrossSens = 0;
DoCrossSensfCrossSens = 1;
DoCrossSide = 0;

SaveSuffix = '';
if DoCrossSens
    SaveSuffix = [SaveSuffix '-CrossSens'];
end
if DoCrossSide
    SaveSuffix = [SaveSuffix '-CrossSide'];
end
if DoCrossSensfCrossSens
    SaveSuffix = [SaveSuffix '-CrossSensfCrossSens'];
end


CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR'...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
    };


opt.NbROI = 5;

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers-2,1) DesMat'];
opt.DesMat = spm_orth(DesMat);

opt.ToPlot={'Cst','Lin','Quad'};

% Daily folds for the CV
opt. Folds = {...
    1,2:3;...
    2,[1 3];...
    3,1:2};

load(fullfile(StartDir,'results','roi','MinNbVert.mat'),'MinVert')

opt.MinVert = MinVert;


for iSub = 4:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir,'betas','6_surf');
    
    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'rasters');
    [~,~,~]=mkdir(Results_dir);
    
    
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
    CVs = {...
        1:RunPerSes(1), ...
        RunPerSes(1)+1:RunPerSes(1)+RunPerSes(2),...
        RunPerSes(1)+RunPerSes(2)+1:sum(RunPerSes)};
    clear Idx RunPerSes
    
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
            ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf_qT1.vtk$']);
        [inf_vertex,~,~] = read_vtk(InfSurfFile, 0, 1);
        
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
        fprintf('\n  Running GLMs all conditions\n')
        for iCdt = 1:numel(CondNames) % For each Condition
            fprintf('   %s\n',CondNames{iCdt})
            
            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];  %#ok<*AGROW>
            end
            
            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            
            % Extract them
            Features = AllMapping(:,:,Beta2Sel); %#ok<*FNDSB>
            
            if sum(isnan(Features(:)))>0
                warning('We have %i NaNs for %s', sum(isnan(Features(:))), CondNames{iCdt})
            end
            if sum(Features(:)==0)>0
                warning('We have %i zeros for %s', sum(Features(:)==0), CondNames{iCdt})
            end
            
            % Run the "cross-validation"
            for iCV = 1:numel(CVs)
                
                Sess2Sel = CVs{iCV};
                if strcmp(SubLs(iSub).name,'sub-06') && iCdt<3
                    Sess2Sel(Sess2Sel==17)=[];
                    Sess2Sel(Sess2Sel>16)=Sess2Sel(Sess2Sel>16)-1;
                end
                
                % Change or adapt dimensions for GLM
                Y = Features(:,:,Sess2Sel);
                
                % Saves mean of all the features across sessions for the raster
                FeaturesCdtion{iCdt,hs,iCV} = mean(Y,3);
                
                X=repmat(DesMat,size(Y,3),1);
                
                Y = shiftdim(Y,1);
                Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
                
                BetaCdt{hs,iCV}(:,:,iCdt) = pinv(X)*Y;
            end
            
            clear Features Beta2Sel B X Y Mapping iBeta iSess
        end
        
        clear iCdt
        
        
        
        %% Run GLMs for contra-ipsi
        if DoCrossSide
            fprintf('\n  Contra-Ipsi\n')
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
                
                fprintf('   %s Contra-Ipsi\n',Cond_con_name{iCdt})
                
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
                for iCV = 1:numel(CVs)
                    
                    Sess2Sel = CVs{iCV};
                    if strcmp(SubLs(iSub).name,'sub-06') && iCdt==1
                        Sess2Sel(Sess2Sel==17)=[];
                        Sess2Sel(Sess2Sel>16)=Sess2Sel(Sess2Sel>16)-1;
                    end
                    
                    % Change or adapt dimensions for GLM
                    Y = Features(:,:,Sess2Sel);
                    
                    % Saves mean of all the features across sessions for the raster
                    FeaturesCrossSide{iCdt,hs,iCV} = mean(Y,3);
                    
                    X=repmat(DesMat,size(Y,3),1);
                    
                    Y = shiftdim(Y,1);
                    Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
                    
                    BetaCrossSide{hs,iCV}(:,:,iCdt) = pinv(X)*Y;
                end
                
                clear Features Beta2Sel X Y Mapping iBeta iSess
                
            end
            
            clear iCdt
            
        end
        
        
        %% Run GLMs for cross-sensory
        if DoCrossSens || DoCrossSensfCrossSens
            fprintf('\n  Cross sensory\n')
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
                
                fprintf('   %s\n',Cond_con_name{iCdt})
                
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
                for iCV = 1:numel(CVs)
                    
                    Sess2Sel = CVs{iCV};
                    if strcmp(SubLs(iSub).name,'sub-06') && any(iCdt==[1 2 4 5])
                        Sess2Sel(Sess2Sel==17)=[];
                        Sess2Sel(Sess2Sel>16)=Sess2Sel(Sess2Sel>16)-1;
                    end
                    
                    % Laminar GLM
                    % Change or adapt dimensions for GLM
                    Y = Features(:,:,Sess2Sel);
                    
                    % Saves mean of all the features across sessions for the raster
                    FeaturesCrossSens{iCdt,hs,iCV} = mean(Y,3);
                    X=repmat(DesMat,size(Y,3),1);
                    
                    Y = shiftdim(Y,1);
                    Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
                    
                    BetaCrossSens{hs,iCV}(:,:,iCdt) = pinv(X)*Y;
                end
                
                clear Features Beta2Sel B X Y Mapping iBeta iSess
                
            end
            
            clear iCdt
            
        end
        
        
    end
    
    cd(StartDir)
    
    if any(NbVertex ~= NbVertices)
        NbVertex
        NbVertices %#ok<*NOPTS>
        error('The number of vertices does not match.')
    end
    
    
    if DoCrossSide
        %% Raster Contra-Ipsi = f(Stim)
        sets = {1:6,1:3};
        [x, y] = ndgrid(sets{:});
        Cdt = [x(:) y(:)]; clear x y sets
        
        fprintf('\n')
        
        fprintf('\n Rasters: Contra-Ipsi = f(Stim)\n')
        
        [Rho_all_CrossSide_fStim,Slope_all_CrossSide_fStim,...
            All_Profiles_CrossSide_fStim,All_X_sort_CrossSide_fStim,...
            Rho_CrossSide_fStim,Slope_CrossSide_fStim] = ...
            ComputeRasters(opt,CVs,ROI,Cdt,NbVertex,VertexWithDataHS,BetaCdt,BetaCrossSide,FeaturesCrossSide);
        
        
        %% Raster (cross-sensory)_ipsi = f(cross-sensory)_contra
        A = repmat(1:3,3,1);
        Cdt = [A(:), repmat((1:3)',3,1)];
        
        fprintf('\n')
        
        fprintf('\n Rasters: cross-sensory ipsi = f(cross-sensory contra)\n')
        
        [Rho_all_CrossSide_fCrossSide,Slope_all_CrossSide_fCrossSide,...
            All_Profiles_CrossSide_fCrossSide,All_X_sort_CrossSide_fCrossSide,...
            Rho_CrossSide_fCrossSide,Slope_CrossSide_fCrossSide] = ...
            ComputeRasters(opt,CVs,ROI,Cdt,NbVertex,VertexWithDataHS,BetaCrossSide,BetaCrossSide,FeaturesCrossSide);
    end
    
    
    
    if DoCrossSens 
        %% Raster Cross Sens = f(Stim)
        A = repmat(1:6,6,1);
        Cdt = [A(:), repmat((1:6)',6,1)];
        
        fprintf('\n')
        
        fprintf('\n Rasters: Sens = f(Stim)\n')
        
        [Rho_all_CrossSens_fStim,Slope_all_CrossSens_fStim,...
            All_Profiles_CrossSens_fStim,All_X_sort_CrossSens_fStim,...
            Rho_CrossSens_fStim,Slope_CrossSens_fStim] = ...
            ComputeRasters(opt,CVs,ROI,Cdt,NbVertex,VertexWithDataHS,BetaCdt,BetaCrossSens,FeaturesCrossSens);
        
        
        %% Rasters:  (ipsi-contra)_sense A = f(ipsi-contra)_sense B
        A = repmat(1:6,6,1);
        Cdt = [A(:), repmat((1:6)',6,1)];
        
        fprintf('\n')
        
        fprintf('\n Rasters: ipsi-contra sense A = f(ipsi-contra sense B)\n')
        
        [Rho_all_CrossSens_fCrossSens,Slope_all_CrossSens_fCrossSens,...
            All_Profiles_CrossSens_fCrossSens,All_X_sort_CrossSens_fCrossSens,...
            Rho_CrossSens_fCrossSens,Slope_CrossSens_fCrossSens] = ...
            ComputeRasters(opt,CVs,ROI,Cdt,NbVertex,VertexWithDataHS,BetaCrossSens,BetaCrossSens,FeaturesCrossSens);
    end

    if DoCrossSensfCrossSens
        %% Raster Cross Sens = f(Cross Sens)
        Cdt = repmat((1:6)',1,2);
        
        fprintf('\n')
        
        fprintf('\n Rasters: Cross Sens = f(Cross Sens)\n')
        
        [Rho_all_CrossSens_fCrossSens,Slope_all_CrossSens_fCrossSens,...
            All_Profiles_CrossSens_fCrossSens,All_X_sort_CrossSens_fCrossSens,...
            Rho_CrossSens_fCrossSens,Slope_CrossSens_fCrossSens] = ...
            ComputeRasters(opt,CVs,ROI,Cdt,NbVertex,VertexWithDataHS,BetaCrossSens,BetaCrossSens,FeaturesCrossSens);
        
    end
    
    %% Save
    SaveName = fullfile(Sub_dir,'results','profiles','surf','rasters',...
        [SubLs(iSub).name '-SurfRasters-HS' SaveSuffix '.mat']);
    
    if DoCrossSens && DoCrossSide
        save(SaveName, ...
            'ROI', ...
            'All_X_sort_CrossSens_fCrossSens', 'All_Profiles_CrossSens_fCrossSens',...
            'All_X_sort_CrossSide_fCrossSide', 'All_Profiles_CrossSide_fCrossSide',...
            'All_X_sort_CrossSens_fStim', 'All_Profiles_CrossSens_fStim',...
            'All_X_sort_CrossSide_fStim', 'All_Profiles_CrossSide_fStim', ...
            'Rho_CrossSide_fStim', 'Slope_CrossSide_fStim', ...
            'Rho_CrossSens_fStim', 'Slope_CrossSens_fStim', ...
            'Rho_CrossSide_fCrossSide', 'Slope_CrossSide_fCrossSide', ...
            'Rho_CrossSens_fCrossSens', 'Slope_CrossSens_fCrossSens', '-v7.3')
    end
    
    if DoCrossSens
        save(SaveName, ...
            'ROI', ...
            'All_X_sort_CrossSens_fCrossSens', 'All_Profiles_CrossSens_fCrossSens',...
            'All_X_sort_CrossSens_fStim', 'All_Profiles_CrossSens_fStim',...
            'Rho_CrossSens_fStim', 'Slope_CrossSens_fStim', ...
            'Rho_CrossSens_fCrossSens', 'Slope_CrossSens_fCrossSens', '-v7.3')
    end
    
    if DoCrossSensfCrossSens
        save(SaveName, ...
            'ROI', ...
            'All_X_sort_CrossSens_fCrossSens', 'All_Profiles_CrossSens_fCrossSens',...
            'Rho_CrossSens_fCrossSens', 'Slope_CrossSens_fCrossSens', '-v7.3')
    end
    
    if DoCrossSide
        save(SaveName, ...
            'ROI', ...
            'All_X_sort_CrossSide_fCrossSide', 'All_Profiles_CrossSide_fCrossSide',...
            'All_X_sort_CrossSide_fStim', 'All_Profiles_CrossSide_fStim', ...
            'Rho_CrossSide_fStim', 'Slope_CrossSide_fStim', ...
            'Rho_CrossSide_fCrossSide', 'Slope_CrossSide_fCrossSide', '-v7.3')
    end
    
    
    clear FeaturesCdtion BetaCdt BetaCrossSide FeaturesCrossSide BetaCrossSens FeaturesCrossSens ...
        All_X_sort_CrossSens_fCrossSens All_Profiles_CrossSens_fCrossSens...
        All_X_sort_CrossSide_fCrossSide All_Profiles_CrossSide_fCrossSide...
        All_X_sort_CrossSens_fStim All_Profiles_CrossSens_fStim...
        All_X_sort_CrossSide_fStim All_Profiles_CrossSide_fStim...
        Rho_CrossSide_fStim Slope_CrossSide_fStim...
        Rho_CrossSens_fStim Slope_CrossSens_fStim...
        Rho_CrossSide_fCrossSide Slope_CrossSide_fCrossSide...
        Rho_CrossSens_fCrossSens Slope_CrossSens_fCrossSens
end

cd(StartDir)


end



function [Rho_all,Slope_all,All_Profiles,All_X_sort,Rho,Slope] = ...
    ComputeRasters(opt,CVs,ROI,Cdt,NbVertex,VertexWithDataHS,Beta,Beta2Sort,Features)

NbROI = opt.NbROI;
DesMat = opt.DesMat;
ToPlot=opt.ToPlot;
Folds = opt.Folds;
MinVert = opt.MinVert;

for iToPlot = 1:numel(ToPlot)
    
    fprintf('\n\n')
    
    for ihs = 1:2
        
        for iCV = 1:numel(CVs)
            
            for iCdt = 1:size(Cdt,1)
                
                % Sorting variables
                X = nan(1,NbVertex(ihs));
                X(1,VertexWithDataHS{ihs}) = Beta{ihs,iCV}(iToPlot,:,Cdt(iCdt,1));
                
                % Variables to sort : per vertex
                % this is done so we can compute the vertex wise
                % correlation/regression instead of the bin wise ones
                Y = nan(1,NbVertex(ihs));
                Y(1,VertexWithDataHS{ihs}) = mean(cat(3,...
                    Beta2Sort{ihs,Folds{iCV,2}(1)}(iToPlot,:,Cdt(iCdt,2)),...
                    Beta2Sort{ihs,Folds{iCV,2}(2)}(iToPlot,:,Cdt(iCdt,2))),3); % Results are averaged across the 2 left over days
                
                % Variables to sort
                % Same but we do it on the B parameters values along each vertex so
                % we can plot the rasters in the end
                Profiles = nan(NbVertex(ihs),6);
                Profiles(VertexWithDataHS{ihs},:) = mean(cat(3,...
                    Features{Cdt(iCdt,2),ihs,Folds{iCV,2}(1)},...
                    Features{Cdt(iCdt,2),ihs,Folds{iCV,2}(2)}),3);
                
                fprintf('\n  Creating rasters for:')
                
                for iROI = 1:4 %NbROI
                    
                    % number of bins based on the minimum number of vertices
                    % for that ROI across subjects
                    NbBin = MinVert(strcmp(ROI(iROI).name,{MinVert.name}')).MinVert;
                    
                    fprintf(' %s,',ROI(iROI).name)
                    
                    X_ROI = [];
                    Y_ROI = [];
                    X_sort = [];
                    Profiles_ROI = [];
                    
                    
                    %% Pool over hemisphere and sort
                    X_ROI = X(ROI(iROI).VertOfInt{ihs});
                    [X_sort,I] = sort(X_ROI);
                    
                    % Applying the sorting to the S parameters
                    Y_ROI = Y(ROI(iROI).VertOfInt{ihs});
                    Y_ROI = Y_ROI(I);
                    
                    % Applying the vertex wise sorting sorting to the B parameters across along
                    % vertex
                    Profiles_ROI = Profiles(ROI(iROI).VertOfInt{ihs},:);
                    Profiles_ROI = Profiles_ROI(I,:);
                    
                    
                    %% remove NaNs and zeros
                    ToRemove = cat(3,isnan(Profiles_ROI), Profiles_ROI==0);
                    ToRemove = any(ToRemove,3);
                    ToRemove = any(ToRemove,2);
                    
                    Profiles_ROI(ToRemove,:)=[];
                    Y_ROI(ToRemove)=[];
                    X_sort(ToRemove)=[];
                    
                    
                    %% Get correlation/regression on all vertices
                    R=corrcoef(X_sort,Y_ROI);
                    rho_all_vert = R(1,2);
                    beta = glmfit(X_sort, Y_ROI, 'normal');
                    slope_all_vert = beta(2);
                    
                    
                    %% bin data
                    IdxToAvg = floor(linspace(1,numel(X_sort),NbBin+1)); %Determine how many vertices go in each bin
                    
                    X_sort_Perc=[];
                    Profiles_Perc=[];
                    
                    % average values across vertices for each bin
                    for iPerc = 2:numel(IdxToAvg)
                        X_sort_Perc(iPerc-1) = mean(X_sort(IdxToAvg((iPerc-1):iPerc)));
                        Profiles_Perc(iPerc-1,:) = mean(Profiles_ROI(IdxToAvg((iPerc-1):iPerc),:));
                    end
                    
                    % get the bin wise correlation and regression coeff
                    [rho,slope]=Correlation_regression_raster_ind(Profiles_Perc,DesMat,iToPlot,X_sort_Perc);
                    
                    
                    %% Store for that CV
                    Rho_all{iToPlot, iCdt, iROI, ihs}(:,iCV) = rho_all_vert;
                    Slope_all{iToPlot, iCdt, iROI, ihs}(:,iCV) = slope_all_vert;
                    
                    Rho{iToPlot, iCdt, iROI, ihs}(:,iCV) = rho;
                    Slope{iToPlot, iCdt, iROI, ihs}(:,iCV) = slope;
                    
                    All_Profiles{iToPlot, iCdt, iROI, ihs}(:,:,iCV) = Profiles_Perc;
                    All_X_sort{iToPlot, iCdt, iROI, ihs}(:,iCV) = X_sort_Perc;
                    
                    clear X_sort_Perc Profiles_Perc
                    
                end
                
            end
            
        end
        
    end
    
end

end