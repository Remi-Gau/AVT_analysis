%%
clear
clc

HS = 'L';
hs = 'l';
inf_hs = 'r';

StartFolder = fullfile(pwd, '..', '..');
cd(StartFolder)
addpath(genpath(fullfile(StartFolder, 'SubFun')));

SubjToInclude = true(13,1);
SubjToInclude([4 11],1) = false;

NbLayers = 6;

Conditions_Names = {...
    'A-Stim_Auditory-Attention', ...
    'V-Stim_Auditory-Attention', ...
    'AV-Stim_Auditory-Attention', ...
    'A-Stim_Visual-Attention', ...
    'V-Stim_Visual-Attention', ...
    'AV-Stim_Visual-Attention'};


DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers,1) DesMat'];
DesMat = spm_orth(DesMat);

for iSubj=1:sum(SubjToInclude)
    sets{iSubj} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j, k] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:), k(:)];
[LIA,LOCB] = ismember( ones(1,sum(SubjToInclude)),ToPermute, 'rows');
ToPermute(LOCB,:) = [];

Suffix = {'cst', 'lin', 'quad'};


for Smooth = 0:1
    
    for Inter = 0
        
        if Inter
            DataFolder = fullfile('/home/rxg243/Documents/GrpAverage/BoldAvgInter');
        else
            DataFolder = fullfile('/home/rxg243/Documents/GrpAverage/BoldAvg');
        end
        
        if Inter
            InfSurfFile = fullfile(DataFolder, ['Surface_sub_16_' hs 'h_inf.vtk']);
        else
            InfSurfFile = fullfile(DataFolder, ['Surface_ls_' inf_hs 'h_inf.vtk']);
        end
        [InfVertex,InfFace,InfMapping] = read_vtk(InfSurfFile, 0, 1);
        
        
        if Smooth
            suffix = '_smoothdata';
        else
            suffix = '';
        end
        
        %% Basic
        cd(fullfile(DataFolder, [HS 'H']))
        
        mkdir(fullfile(DataFolder, [HS 'H'], 'Baseline'))
        
        fprintf('\n Against baseline')
        for iCond = 1:6
            
            clear AllLayers AllLayersNoSmooth
            
            fprintf('\n Reading data\n')
            
            for iLayer = 1:NbLayers
                
                VTK_file = dir(['GrpSurf_' Conditions_Names{iCond} '_' num2str(iLayer) '-Layer_' hs 'h' suffix '.vtk']);
                
                disp(VTK_file.name)
                
                [Vertex,Face,Mapping] = read_vtk(VTK_file.name, 12, 1);
                
                AllLayers(:,:,iLayer) = Mapping; %#ok<SAGROW>
                
                if Smooth
                    VTK_file = dir(['GrpSurf_' Conditions_Names{iCond} '_' num2str(iLayer) '-Layer_' hs 'h.vtk']);
                    [~,~,Mapping] = read_vtk(VTK_file.name, 12, 1);
                    AllLayersNoSmooth(:,:,iLayer) = Mapping; %#ok<SAGROW>
                end
                
            end
            
            AllLayers = AllLayers(SubjToInclude,:,:);
            
            if Smooth
                AllLayersNoSmooth = AllLayersNoSmooth(SubjToInclude,:,:);
                IsZero = AllLayersNoSmooth==0;
            else
                IsZero = AllLayers==0;
            end
            IsZero = any(IsZero,3);
            tabulate(sum(IsZero))
            
            Cst = zeros(1, size(Mapping,2));
            Lin = zeros(1, size(Mapping,2));
            Quad = zeros(1, size(Mapping,2));
            
            for NbSub2Excl = 0%:(sum(SubjToInclude)-4)
                
                fprintf('\nGLM on vertices with %i subjects', sum(SubjToInclude)-NbSub2Excl)
                
                VertOfInt = find(sum(IsZero)==NbSub2Excl);
                
                Y = [];
                parfor iVert = 1:numel(VertOfInt)
                    Subj2Exclu = find(~IsZero(:,VertOfInt(iVert)));
                    Y(:,iVert,:) = AllLayers(Subj2Exclu,VertOfInt(iVert),:);
                end
                
                Y = shiftdim(Y,2);
                Y = reshape(Y, [size(Y,1)*size(Y,2),size(Y,3)] );
                
                X = [];
                for iSubj=1:(sum(SubjToInclude)-NbSub2Excl)
                    X((1:6)+6*(iSubj-1),(1:size(DesMat,2))+size(DesMat,2)*(iSubj-1)) = DesMat; %#ok<SAGROW>
                end
                
                B = pinv(X)*Y;
                
                Cst_tmp = mean(B(1:3:size(X,2),:));
                Cst(VertOfInt) = Cst_tmp;
                
                Lin_tmp = mean(B(2:3:size(X,2),:));
                Lin(VertOfInt) = Lin_tmp;
                
                Quad_tmp = mean(B(3:3:size(X,2),:));
                Quad(VertOfInt) = Quad_tmp;
                
                
                if NbSub2Excl==0
                    fprintf('\nRunning permutations')
                    
                    for i=1:size(DesMat,2)
                        
                        Perms = [];
                        
                        tmp = B(i:3:size(X,2),:);
                        SPM = mean(tmp);
                        
                        parfor iPerm = 1:size(ToPermute,1)
%                             Perms(iPerm,:) = max(abs(mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))))); %#ok<*SAGROW>
                            Perms(iPerm,:) = mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))); %#ok<*SAGROW>
                        end
                        
                        PMaps = sum( abs( Perms-repmat(mean(Perms),size(Perms,1),1) ) > repmat( abs( SPM-mean(Perms) ) ,size(Perms,1),1) ) ...
                            / size(Perms,1);

%                         PMaps = repmat(Perms,[1 size(SPM,2)])>repmat(abs(SPM),[size(Perms,1) 1]);
%                         PMaps = sum(PMaps)/size(PMaps,1);
                        
                        PMaps_final = zeros(1, size(Mapping,2));
                        PMaps_final(VertOfInt) = PMaps;
                        
                        SPM_final = zeros(1, size(Mapping,2));
                        SPM_final(VertOfInt) = SPM;
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                            [Conditions_Names{iCond} '_' hs 'h_' Suffix{i} '_mask' suffix '.vtk']), Vertex, Face, SPM_final')
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask', ...
                            [Conditions_Names{iCond} '_' hs 'h_' Suffix{i} '_inf_mask' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                        
                        SPM(PMaps>0.05) = 0;
                        SPM_final = zeros(1, size(Mapping,2));
                        SPM_final(VertOfInt) = SPM;
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                            [Conditions_Names{iCond} '_' hs 'h_' Suffix{i} '_inf_mask_thres' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                            [Conditions_Names{iCond} '_' hs 'h_' Suffix{i} '_inf_mask_pmap' suffix '.vtk']), InfVertex, InfFace, PMaps_final')
                        
                    end
                end
                
            end
            
            fprintf('\n');
            
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', ...
%                 [Conditions_Names{iCond} '_' hs 'h_lin_inf' suffix '.vtk']), InfVertex, InfFace, Lin')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', ...
%                 [Conditions_Names{iCond} '_' hs 'h_cst_inf' suffix '.vtk']), InfVertex, InfFace, Cst')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', ...
%                 [Conditions_Names{iCond} '_' hs 'h_quad_inf' suffix '.vtk']), InfVertex, InfFace, Quad')
%             
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', ...
%                 [Conditions_Names{iCond} '_' hs 'h_lin' suffix '.vtk']), Vertex, Face, Lin')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', ...
%                 [Conditions_Names{iCond} '_' hs 'h_cst' suffix '.vtk']), Vertex, Face, Cst')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', ...
%                 [Conditions_Names{iCond} '_' hs 'h_quad' suffix '.vtk']), Vertex, Face, Quad')
            
        end
        
        
        %%
        clear AllLayers AllLayersNoSmooth
        
        for iCond = 1:6
            
            fprintf('\n Reading data\n')
            
            for iLayer = 1:NbLayers
                
                VTK_file = dir(['GrpSurf_' Conditions_Names{iCond} '_' num2str(iLayer) '-Layer_' hs 'h' suffix '.vtk']);
                
                disp(VTK_file.name)
                
                [Vertex,Face,Mapping] = read_vtk(VTK_file.name, 12, 1);
                
                AllLayers(:,:,iLayer,iCond) = Mapping;
                
                if Smooth
                    VTK_file = dir(['GrpSurf_' Conditions_Names{iCond} '_' num2str(iLayer) '-Layer_' hs 'h.vtk']);
                    [~,~,Mapping] = read_vtk(VTK_file.name, 12, 1);
                    AllLayersNoSmooth(:,:,iLayer,iCond) = Mapping; %#ok<SAGROW>
                end
                
            end
            
        end
        
        
        %% Cross modal
        fprintf('\n Cross modal')
        mkdir(fullfile(DataFolder, [HS 'H'], 'CrossModal'))
        CrossModal = {[3 6 ; 1 4] , [3 6 ; 2 5]};
        CrossModalName = {'AV-A', 'AV-V'};
        
        for iCrossModal = 1:numel(CrossModal)
            
            CrossModalLayers = ...
                sum(AllLayers(SubjToInclude,:,:,CrossModal{iCrossModal}(1,:)),4) ...
                - sum(AllLayers(SubjToInclude,:,:,CrossModal{iCrossModal}(2,:)),4);
            
            if Smooth
                CrossModalLayersNoSmooth = ...
                    sum(AllLayersNoSmooth(SubjToInclude,:,:,CrossModal{iCrossModal}(1,:)),4) ...
                    - sum(AllLayersNoSmooth(SubjToInclude,:,:,CrossModal{iCrossModal}(2,:)),4);
                IsZero = CrossModalLayersNoSmooth==0;
            else
                IsZero = CrossModalLayers==0;
            end
            IsZero = any(IsZero,3);
            tabulate(sum(IsZero))
            
            Cst = zeros(1, size(Mapping,2));
            Lin = zeros(1, size(Mapping,2));
            Quad = zeros(1, size(Mapping,2));
            
            for NbSub2Excl = 0%:(sum(SubjToInclude)-4)
                
                fprintf('\nGLM on vertices with %i subjects', sum(SubjToInclude)-NbSub2Excl)
                
                VertOfInt = find(sum(IsZero)==NbSub2Excl);
                
                Y = [];
                parfor iVert = 1:numel(VertOfInt)
                    Subj2Exclu = find(~IsZero(:,VertOfInt(iVert)));
                    Y(:,iVert,:) = CrossModalLayers(Subj2Exclu,VertOfInt(iVert),:);
                end
                
                Y = shiftdim(Y,2);
                Y = reshape(Y, [size(Y,1)*size(Y,2),size(Y,3)] );
                
                X = [];
                for iSubj=1:(sum(SubjToInclude)-NbSub2Excl)
                    X((1:6)+6*(iSubj-1),(1:size(DesMat,2))+size(DesMat,2)*(iSubj-1)) = DesMat; %#ok<SAGROW>
                end
                
                B = pinv(X)*Y;
                
                Cst_tmp = mean(B(1:3:size(X,2),:));
                Cst(VertOfInt) = Cst_tmp;
                
                Lin_tmp = mean(B(2:3:size(X,2),:));
                Lin(VertOfInt) = Lin_tmp;
                
                Quad_tmp = mean(B(3:3:size(X,2),:));
                Quad(VertOfInt) = Quad_tmp;
                
                if NbSub2Excl==0
                    
                    fprintf('\nRunning permutations')
                    
                    for i=1:size(DesMat,2)
                        
                        Perms = [];
                        
                        tmp = B(i:3:size(X,2),:);
                        SPM = mean(tmp);
                        
                        parfor iPerm = 1:size(ToPermute,1)
%                             Perms(iPerm,:) = max(abs(mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))))); %#ok<*SAGROW>
                            Perms(iPerm,:) = mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))); %#ok<*SAGROW>
                        end
                        
                        PMaps = sum( abs( Perms-repmat(mean(Perms),size(Perms,1),1) ) > repmat( abs( SPM-mean(Perms) ) ,size(Perms,1),1) ) ...
                            / size(Perms,1);

%                         PMaps = repmat(Perms,[1 size(SPM,2)])>repmat(abs(SPM),[size(Perms,1) 1]);
%                         PMaps = sum(PMaps)/size(PMaps,1);
                        
                        PMaps_final = zeros(1, size(Mapping,2));
                        PMaps_final(VertOfInt) = PMaps;
                        
                        SPM_final = zeros(1, size(Mapping,2));
                        SPM_final(VertOfInt) = SPM;
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', 'mask',...
                            [CrossModalName{iCrossModal} '_' hs 'h_' Suffix{i} '_mask' suffix '.vtk']), Vertex, Face, SPM_final')
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', 'mask', ...
                            [CrossModalName{iCrossModal} '_' hs 'h_' Suffix{i} '_inf_mask' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                        
                        SPM(PMaps>0.05) = 0;
                        SPM_final = zeros(1, size(Mapping,2));
                        SPM_final(VertOfInt) = SPM;
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', 'mask',...
                            [CrossModalName{iCrossModal} '_' hs 'h_' Suffix{i} '_inf_mask_thres' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', 'mask',...
                            [CrossModalName{iCrossModal} '_' hs 'h_' Suffix{i} '_inf_mask_pmap' suffix '.vtk']), InfVertex, InfFace, PMaps_final')
                        
                    end
                    
                end
                
            end
            
            fprintf('\n');
            
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', ...
%                 [CrossModalName{iCrossModal} '_' hs 'h_lin_inf' suffix '.vtk']), InfVertex, InfFace, Lin')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', ...
%                 [CrossModalName{iCrossModal} '_' hs 'h_cst_inf' suffix '.vtk']), InfVertex, InfFace, Cst')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', ...
%                 [CrossModalName{iCrossModal} '_' hs 'h_quad_inf' suffix '.vtk']), InfVertex, InfFace, Quad')
%             
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', ...
%                 [CrossModalName{iCrossModal} '_' hs 'h_lin' suffix '.vtk']), Vertex, Face, Lin')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', ...
%                 [CrossModalName{iCrossModal} '_' hs 'h_cst' suffix '.vtk']), Vertex, Face, Cst')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'CrossModal', ...
%                 [CrossModalName{iCrossModal} '_' hs 'h_quad' suffix '.vtk']), Vertex, Face, Quad')
            
        end
        
        
        %% Attention
        fprintf('\n Attention')
        mkdir(fullfile(DataFolder, [HS 'H'], 'Attention'))
        Att = {[1:3 ; 4:6], [1 ; 4], [2 ; 5], [3 ; 6]};
        AttName = {'Att_A-Att_V', 'Stim_A--Att_A-Att_V', 'Stim_V--Att_A-Att_V', 'Stim_AV--Att_A-Att_V'};
        
        for iAtt = 1:numel(Att)
            
            AttlLayers = ...
                sum(AllLayers(SubjToInclude,:,:,Att{iAtt}(1,:)),4) ...
                - sum(AllLayers(SubjToInclude,:,:,Att{iAtt}(2,:)),4);
            
            if Smooth
                AttlLayersNoSmooth = ...
                    sum(AllLayersNoSmooth(SubjToInclude,:,:,Att{iAtt}(1,:)),4) ...
                    - sum(AllLayersNoSmooth(SubjToInclude,:,:,Att{iAtt}(2,:)),4);
                IsZero = AttlLayersNoSmooth==0;
            else
                IsZero = AttlLayers==0;
            end
            IsZero = any(IsZero,3);
            tabulate(sum(IsZero))
            
            Cst = zeros(1, size(Mapping,2));
            Lin = zeros(1, size(Mapping,2));
            Quad = zeros(1, size(Mapping,2));
            
            for NbSub2Excl = 0%:(sum(SubjToInclude)-4)
                
                fprintf('\nGLM on vertices with %i subjects', sum(SubjToInclude)-NbSub2Excl)
                
                VertOfInt = find(sum(IsZero)==NbSub2Excl);
                
                Y = [];
                parfor iVert = 1:numel(VertOfInt)
                    Subj2Exclu = find(~IsZero(:,VertOfInt(iVert)));
                    Y(:,iVert,:) = AttlLayers(Subj2Exclu,VertOfInt(iVert),:);
                end
                
                Y = shiftdim(Y,2);
                Y = reshape(Y, [size(Y,1)*size(Y,2),size(Y,3)] );
                
                X = [];
                for iSubj=1:(sum(SubjToInclude)-NbSub2Excl)
                    X((1:6)+6*(iSubj-1),(1:size(DesMat,2))+size(DesMat,2)*(iSubj-1)) = DesMat; %#ok<SAGROW>
                end
                
                B = pinv(X)*Y;
                
                Cst_tmp = mean(B(1:3:size(X,2),:));
                Cst(VertOfInt) = Cst_tmp;
                
                Lin_tmp = mean(B(2:3:size(X,2),:));
                Lin(VertOfInt) = Lin_tmp;
                
                Quad_tmp = mean(B(3:3:size(X,2),:));
                Quad(VertOfInt) = Quad_tmp;
                
                if NbSub2Excl==0
                    fprintf('\nRunning permutations')
                    
                    for i=1:size(DesMat,2)
                        
                        Perms = [];
                        
                        tmp = B(i:3:size(X,2),:);
                        SPM = mean(tmp);
                        
                        parfor iPerm = 1:size(ToPermute,1)
%                             Perms(iPerm,:) = max(abs(mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))))); %#ok<*SAGROW>
                            Perms(iPerm,:) = mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))); %#ok<*SAGROW>
                        end
                        
                        PMaps = sum( abs( Perms-repmat(mean(Perms),size(Perms,1),1) ) > repmat( abs( SPM-mean(Perms) ) ,size(Perms,1),1) ) ...
                            / size(Perms,1);

%                         PMaps = repmat(Perms,[1 size(SPM,2)])>repmat(abs(SPM),[size(Perms,1) 1]);
%                         PMaps = sum(PMaps)/size(PMaps,1);
                        
                        PMaps_final = zeros(1, size(Mapping,2));
                        PMaps_final(VertOfInt) = PMaps;
                        
                        SPM_final = zeros(1, size(Mapping,2));
                        SPM_final(VertOfInt) = SPM;
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention', 'mask',...
                            [AttName{iAtt} '_' hs 'h_' Suffix{i} '_mask' suffix '.vtk']), Vertex, Face, SPM_final')
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention', 'mask', ...
                            [AttName{iAtt} '_' hs 'h_' Suffix{i} '_inf_mask' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                        
                        SPM(PMaps>0.05) = 0;
                        SPM_final = zeros(1, size(Mapping,2));
                        SPM_final(VertOfInt) = SPM;
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention', 'mask',...
                            [AttName{iAtt} '_' hs 'h_' Suffix{i} '_inf_mask_thres' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                        
                        write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention', 'mask',...
                            [AttName{iAtt} '_' hs 'h_' Suffix{i} '_inf_mask_pmap' suffix '.vtk']), InfVertex, InfFace, PMaps_final')
                        
                    end
                    
                end
                
            end
            
            fprintf('\n');
            
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention',...
%                 [AttName{iAtt} '_' hs 'h_lin_inf' suffix '.vtk']), InfVertex, InfFace, Lin')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention',...
%                 [AttName{iAtt} '_' hs 'h_cst_inf' suffix '.vtk']), InfVertex, InfFace, Cst')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention',...
%                 [AttName{iAtt} '_' hs 'h_quad_inf' suffix '.vtk']), InfVertex, InfFace, Quad')
%             
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention',...
%                 [AttName{iAtt} '_' hs 'h_lin' suffix '.vtk']), Vertex, Face, Lin')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention',...
%                 [AttName{iAtt} '_' hs 'h_cst' suffix '.vtk']), Vertex, Face, Cst')
%             write_vtk(fullfile(DataFolder, [HS 'H'], 'Attention',...
%                 [AttName{iAtt} '_' hs 'h_quad' suffix '.vtk']), Vertex, Face, Quad')
            
        end
        
    end
end