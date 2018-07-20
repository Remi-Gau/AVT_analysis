% computes for each subject the correlation between one session and all the
% others for all ROIs

clc; clear;

StartDir = fullfile(pwd, '..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))
Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

load(fullfile(StartDir,'RunsPerSes.mat'))

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
DesMat = [ones(NbLayers,1) DesMat'];
DesMat = spm_orth(DesMat);

%%
for iSub =  5:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir,'betas','6_surf');
    
    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'correlations');
    [~,~,~]=mkdir(Results_dir);
    
    
    %% Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex')
    
    
    %% Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'))
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM
    
    
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
        
        
        %% Get T1 maps on surfaces
        InfSurfFile=spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
            ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf_qT1.vtk$']);
        [inf_vertex,~,~] = read_vtk(InfSurfFile, 0, 1);
        
        
        %% Load BOLD data or extract them
        FeatureSaveFile = fullfile(Data_dir,[SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
            num2str(NbLayers) '_surf.mat']);
        
        fprintf('  Reading VTKs\n')
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile)
        else
            error('The features have not been extracted from the VTK files.')
        end
        
        %% Laminar GLM on each beta image
        Mapping = zeros(size(inf_vertex,2), size(AllMapping,3));
        
        Column = 1;
        
        for iCdt = 1:numel(CondNames) % For each Condition
            
            fprintf('    %s\n',CondNames{iCdt})
            
            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];  %#ok<*AGROW>
            end
            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            
            for iBeta = 1:numel(Beta2Sel)
                Features = AllMapping(:,:,Beta2Sel(iBeta)); %
                
                % keep track of the Beta selected to reorder the betaimages
                % at the end of this loop
                Beta_New_Order(Column) = Beta2Sel(iBeta);
                
                % Change or adapt dimensions for GLM
                X = repmat(DesMat,size(Features,3),1);
                Y = shiftdim(Features,1);
                
                B = pinv(X)*Y;
                
                Mapping(VertexWithData,Column) = B(1,:);
                Column = Column + 1;
            end
            clear Features Beta2Sel B X Y iBeta iSess
            
        end
        
        % we keep all the profiles for each session/condition for the next
        % loop
        ToRemove = setxor(Beta_New_Order,1:size(AllMapping,3));
        AllMapping(:,:,ToRemove) = [];
        Mapping(:,ToRemove) = [];
        AllProfiles = zeros(size(inf_vertex,2), NbLayers, size(AllMapping,3));
        AllProfiles(VertexWithData,:,:) = AllMapping(:,:,Beta_New_Order);
        clear Beta_New_Order AllMapping ToRemove
        
        %% Session to session and Day to day correlation
        for iROI = 1:5
            
            clear BOLD_Data
            
            Data_ROI.name = ROI(iROI).name;
            
            fprintf(['  '  Data_ROI.name '\n'])
            
            Profiles = AllProfiles(ROI(iROI).VertOfInt{hs},:,:);
            BOLD_Data_session = Mapping(ROI(iROI).VertOfInt{hs},:);
            
            % removing NAN and zero values
            ToRemove = cat(2,isnan(BOLD_Data_session), BOLD_Data_session==0);
            ToRemove = any(ToRemove,2);
            
            BOLD_Data_session(ToRemove,:) = [];
            Profiles(ToRemove,:,:) = [];
            
            % Get median and mean for each layer
            Profile_Mean(:,:,hs,iROI) = squeeze(mean(Profiles));
            Profile_Median(:,:,hs,iROI) = squeeze(median(Profiles));
            
            clear Profiles ToRemove
            
            
            %% session to session correlation
            RHO_session(:,:,hs,iROI) = corr(BOLD_Data_session);
            
            
            %% day to day correlation
            
            %to know which columns to avg
            Col2Avg = cumsum(RunPerSes(iSub).RunsPerSes);
            for i=2:numel(CondNames)
                Col2Avg(end+1,:) = Col2Avg(1,:)+sum(RunPerSes(iSub).RunsPerSes)*(i-1);
            end
            if iSub==5
                Col2Avg(1,end) = 19;
                Col2Avg(2,:) = Col2Avg(2,:)-1;
                Col2Avg(2,end) = Col2Avg(2,end)-1;
                Col2Avg(3:end,:) = Col2Avg(3:end,:)-2;
            end
            Col2Avg=Col2Avg'; Col2Avg=Col2Avg(:);
            
            % average
            FirstCol = 1;
            for iCol=1:numel(Col2Avg)
                BOLD_Data_day(:,iCol) = mean(...
                    BOLD_Data_session(:,FirstCol:Col2Avg(iCol)), 2);
                FirstCol = Col2Avg(iCol)+1;
            end
            
            RHO_day(:,:,hs,iROI) = corr(BOLD_Data_day);
            
            clear BOLD_Data BOLD_Data_day
            
        end
        
        clear Mapping AllProfiles
        
    end
    
    %%
    save(fullfile(Results_dir,[SubLs(iSub).name '-Day2DayCorrelation.mat']), ...
        'RHO_day', 'RHO_session', 'Profile_Mean', 'Profile_Median')

    clear RHO_session RHO_day Profile_Mean Profile_Median
end

