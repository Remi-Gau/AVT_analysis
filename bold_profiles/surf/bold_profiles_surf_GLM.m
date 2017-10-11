clc; clear;

StartDir = fullfile(pwd, '..','..','..');
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

VTK_sufix = {'Cst', 'Lin', 'Quad'};

for iSub = 9:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir,'betas','6_surf');
    
    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf');
    [~,~,~]=mkdir(Results_dir);
    
    mkdir(fullfile(Results_dir,'cdt'))
    mkdir(fullfile(Results_dir,'side'))
    mkdir(fullfile(Results_dir,'cross_sens'))
    
    
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
                Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];  %#ok<*AGROW>
            end
%             fprintf('\n')
%             disp(BetaNames(Beta2Sel,:))
%             fprintf('\n')
            
            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            
            % Extract them
            Features = AllMapping(:,:,Beta2Sel); %#ok<*FNDSB>
            
            % Change or adapt dimensions for GLM
            X=repmat(DesMat,size(Features,3),1);
            
            Y = shiftdim(Features,1);
            Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
            
            B = pinv(X)*Y;
            
            fprintf('    Writing VTKs\n')
            for iBeta = 1:size(B,1)
                Mapping = zeros(1,size(inf_vertex,2));
                Mapping(VertexWithData) = B(iBeta,:);
                write_vtk(fullfile(Results_dir,'cdt',...
                    [SubLs(iSub).name '_' HsSufix 'cr_' CondNames{iCdt} ...
                    '_' VTK_sufix{iBeta} '.vtk']), inf_vertex, inf_faces, Mapping)
            end
            
            clear Features Beta2Sel B X Y Mapping iBeta iSess
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
                Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,1}}  '*bf(1)']))];
                
                Beta2Sel2 = [Beta2Sel2 ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,2}}  '*bf(1)']))];
            end
            
%             fprintf('\n')
%             disp(BetaNames(Beta2Sel,:))
%             fprintf('\n')
%             disp(BetaNames(Beta2Sel2,:))
%             fprintf('\n')
            
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            Beta2Sel2 = find(ismember(BetaOfInterest, Beta2Sel2));
            
            Features = AllMapping(:,:,Beta2Sel) - ...
                AllMapping(:,:,Beta2Sel2);
            
            X=repmat(DesMat,size(Features,3),1);
            
            Y = shiftdim(Features,1);
            Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
            
            B = pinv(X)*Y;
            
            fprintf('    Writing VTKs\n')
            for iBeta = 1:size(B,1)
                Mapping = zeros(1,size(inf_vertex,2));
                Mapping(VertexWithData) = B(iBeta,:);
                write_vtk(fullfile(Results_dir,'side',[SubLs(iSub).name '_' HsSufix 'cr_' ...
                    Cond_con_name{iCdt} '_contra-ipsi'...
                    '_' VTK_sufix{iBeta} '.vtk']), inf_vertex, inf_faces, Mapping)
            end
            
            clear Features Beta2Sel B X Y Mapping iBeta iSess
            
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
                if strcmp(SubLs(iSub).name,'sub-06') && iSess==17 && iCdt~=3
                else
                Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,1}}  '*bf(1)']))];
                
                Beta2Sel2 = [Beta2Sel2 ;find(strcmp(cellstr(BetaNames), ...
                    ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt,2}}  '*bf(1)']))];
                end
            end
            
%             fprintf('\n')
%             disp(BetaNames(Beta2Sel,:))
%             fprintf('\n')
%             disp(BetaNames(Beta2Sel2,:))
%             fprintf('\n')
            
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            Beta2Sel2 = find(ismember(BetaOfInterest, Beta2Sel2));
            
            Features = AllMapping(:,:,Beta2Sel) - ...
                AllMapping(:,:,Beta2Sel2);
            
            X=repmat(DesMat,size(Features,3),1);
            
            Y = shiftdim(Features,1);
            Y = reshape(Y, [size(Y,1)*size(Y,2), size(Y,3)] );
            
            B = pinv(X)*Y;
            
            fprintf('    Writing VTKs\n')
            for iBeta = 1:size(B,1)
                Mapping = zeros(1,size(inf_vertex,2));
                Mapping(VertexWithData) = B(iBeta,:);
                write_vtk(fullfile(Results_dir,'cross_sens',[SubLs(iSub).name '_' HsSufix 'cr_' ...
                    Cond_con_name{iCdt} '_' VTK_sufix{iBeta} '.vtk']), inf_vertex, inf_faces, Mapping)
            end
            
            clear Features Beta2Sel B X Y Mapping iBeta iSess
            
        end
        
        clear iCdt

    end
    
end

cd(StartDir)