clear;
clc;

hs = 'lr';

StartDir = fullfile(pwd, '..', '..');
cd(StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

SubLs = dir('sub*');
NbSub = numel(SubLs);

DataFolder = fullfile(StartDir, 'surfreg', 'GrpAvgBOLD');

NbLayers = 6;

CondNames = { ...
             'AStimL', 'AStimR', ...
             'VStimL', 'VStimR', ...
             'TStimL', 'TStimR'
             %     'ATargL','ATargR',...
             %     'VTargL','VTargR',...
             %     'TTargL','TTargR',...
            };

DesMat = (1:NbLayers) - mean(1:NbLayers);
DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers,1) DesMat'];
DesMat = spm_orth(DesMat);

% for iSubj=1:NbSub
%     sets{iSubj} = [-1 1];
% end
% [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
% ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];

for Smooth = 1

    for ihs = 1:numel(hs)

        clear AllLayers AllLayersNoSmooth;

        cd(fullfile(DataFolder, [upper(hs(ihs)) 'H']));

        InfSurfFile = fullfile(DataFolder, ['Surface_ls_low_res_' hs(ihs) 'h_inf.vtk']);
        [InfVertex, InfFace, Mapping] = read_vtk(InfSurfFile, 0, 1);

        if Smooth
            suffix = '_smoothdata';
        else
            suffix = '';
        end

        fprintf('\n Reading data\n');
        for iCond = 1:numel(CondNames)
            for iLayer = 1:NbLayers

                VTK_file = dir(['GrpSurf_' CondNames{iCond} '_layer_' num2str(iLayer) '_' hs(ihs) 'h' suffix '.vtk']); %#ok<*PFBNS>
                disp(VTK_file.name);

                [~, ~, Mapping] = read_vtk(VTK_file.name, 9, 1); %#ok<PFTUS>

                AllLayers(:, :, iLayer, iCond) = Mapping;

                if Smooth
                    VTK_file = dir(['GrpSurf_' CondNames{iCond} '_layer_' num2str(iLayer) '_' hs(ihs) 'h.vtk']); %#ok<*PFBNS>
                    [~, ~, Mapping] = read_vtk(VTK_file.name, 9, 1);
                    AllLayersNoSmooth(:, :, iLayer, iCond) = Mapping;
                end
            end
        end

        %% Cross side for each modality
        fprintf('\n Contra-Ipsi');

        if ihs == 1
            CrossSide = {[2 1], [4 3], [6 5]};
        else
            CrossSide = {[1 2], [3 4], [5 6]};
        end

        CrossSideName = {'A_Contra-Ipsi', 'V_Contra-Ipsi', 'T_Contra-Ipsi'};

        mkdir('CrossSide');

        for iCond = 1:numel(CrossSide)

            clear CrossSidelLayers;

            CrossSidelLayers = ...
                AllLayers(:, :, :, CrossSide{iCond}(1)) ...
                - AllLayers(:, :, :, CrossSide{iCond}(2));

            if Smooth
                CrossSidelLayersNoSmooth = ...
                    AllLayersNoSmooth(:, :, :, CrossSide{iCond}(1)) ...
                    - AllLayersNoSmooth(:, :, :, CrossSide{iCond}(2));
                IsZero = CrossSidelLayersNoSmooth == 0;
            else
                IsZero = CrossSidelLayers == 0;
            end

            IsZero = any(IsZero, 3);
            fprintf('\n');
            tabulate(sum(IsZero));

            Cst = zeros(1, size(Mapping, 2));
            Lin = zeros(1, size(Mapping, 2));
            %             Quad = zeros(1, size(Mapping,2));
            %             Mean = zeros(1, size(Mapping,2));
            %             T_map = zeros(1, size(Mapping,2));

            for NbSub2Excl = 0:(NbSub - 5)

                fprintf('\nGLM on vertices with %i subjects', NbSub - NbSub2Excl);

                VertOfInt = find(sum(IsZero) == NbSub2Excl);

                Y = [];
                parfor iVert = 1:numel(VertOfInt)
                    Subj2Exclu = find(~IsZero(:, VertOfInt(iVert)));
                    Y(:, iVert, :) = CrossSidelLayers(Subj2Exclu, VertOfInt(iVert), :);
                end

                %                 Mean_tmp = mean(mean(Y,3));
                %                 T_map_temp = nanmean(mean(Y,3))./nansem(mean(Y,3));

                Y = shiftdim(Y, 2);
                Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

                X = [];
                for iSubj = 1:(NbSub - NbSub2Excl)
                    X((1:NbLayers) + NbLayers * (iSubj - 1), (1:size(DesMat, 2)) + size(DesMat, 2) * (iSubj - 1)) = DesMat; %#ok<*SAGROW>
                end

                B = pinv(X) * Y;

                Cst_tmp = mean(B(1:3:size(X, 2), :));
                Cst(VertOfInt) = Cst_tmp;

                Lin_tmp = mean(B(2:3:size(X, 2), :));
                Lin(VertOfInt) = Lin_tmp;

                %                 Quad_tmp = mean(B(3:3:size(X,2),:));
                %                 Quad(VertOfInt) = Quad_tmp;

                %
                %                 if NbSub2Excl==0
                %
                %                     fprintf('\nRunning permutations')
                %
                %                     for i=1:size(DesMat,2)
                %
                %                         Perms = [];
                %
                %                         tmp = B(i:3:size(X,2),:);
                %                         SPM = mean(tmp);
                %
                %                         parfor iPerm = 1:size(ToPermute,1)
                %                             %                             Perms(iPerm,:) = max(abs(mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))))); %#ok<*SAGROW>
                %                             Perms(iPerm,:) = mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))); %#ok<*SAGROW>
                %                         end
                %
                %                         PMaps = sum( abs( Perms-repmat(mean(Perms),size(Perms,1),1) ) > repmat( abs( SPM-mean(Perms) ) ,size(Perms,1),1) ) ...
                %                             / size(Perms,1);
                %
                %                         PMaps = repmat(Perms,[1 size(SPM,2)])>repmat(abs(SPM),[size(Perms,1) 1]);
                %                         PMaps = sum(PMaps)/size(PMaps,1);
                %
                %                         PMaps_final = zeros(1, size(Mapping,2));
                %                         PMaps_final(VertOfInt) = PMaps;
                %
                %                         SPM_final = zeros(1, size(Mapping,2));
                %                         SPM_final(VertOfInt) = SPM;
                %
                %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_mask' suffix '.vtk']), Vertex, Face, SPM_final')
                %
                %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask', ...
                %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_inf_mask' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                %
                %                         SPM(PMaps>0.05) = 0;
                %                         SPM_final = zeros(1, size(Mapping,2));
                %                         SPM_final(VertOfInt) = SPM;
                %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_inf_mask_thres' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                %
                %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_inf_mask_pmap' suffix '.vtk']), InfVertex, InfFace, PMaps_final')
                %
                %                     end
                %
                %                 end
                %
                %             end

                fprintf('\n');

                write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSide', ...
                                   [CrossSideName{iCond} '_' hs(ihs) 'h_lin_inf' suffix '.vtk']), InfVertex, InfFace, Lin');
                write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSide', ...
                                   [CrossSideName{iCond} '_' hs(ihs) 'h_cst_inf' suffix '.vtk']), InfVertex, InfFace, Cst');
                %                 write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSide', ...
                %                     [CrossSideName{iCond} '_' hs(ihs) 'h_quad_inf' suffix '.vtk']), InfVertex, InfFace, Quad')

                %                 write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSide',...
                %                     [CrossSideName{iCond} '_' hs(ihs) 'h_mean_inf' suffix '.vtk']), InfVertex, InfFace, Mean');
                %                 write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSide',...
                %                     [CrossSideName{iCond} '_' hs(ihs) 'h_T_map_inf' suffix '.vtk']), InfVertex, InfFace, T_map');

            end

        end

        %% Cross sens for each side
        if 0
            fprintf('\n Cross sens');

            if ihs == 1
                CrossSens = {[1 3], [1 5], [3 5], [2 4], [2 6], [4 6]};
            else
                CrossSens = {[2 4], [2 6], [4 6], [1 3], [1 5], [3 5]};
            end

            CrossSensName = {'A-V_Ipsi', 'A-T_Ipsi', 'V-T_Ipsi', ...
                             'A-V_Contra', 'A-T_Contra', 'V-T_Contra'};

            mkdir('CrossSens');

            for iCond = 1:numel(CrossSens)

                clear CrossSenslLayers;

                CrossSenslLayers = ...
                    AllLayers(:, :, :, CrossSens{iCond}(1)) ...
                    - AllLayers(:, :, :, CrossSens{iCond}(2));

                if Smooth
                    CrossSenslLayersNoSmooth = ...
                        AllLayersNoSmooth(:, :, :, CrossSens{iCond}(1)) ...
                        - AllLayersNoSmooth(:, :, :, CrossSens{iCond}(2));
                    IsZero = CrossSenslLayersNoSmooth == 0;
                else
                    IsZero = CrossSenslLayers == 0;
                end

                IsZero = any(IsZero, 3);
                fprintf('\n');
                tabulate(sum(IsZero));

                %             Cst = zeros(1, size(Mapping,2));
                %             Lin = zeros(1, size(Mapping,2));
                %             Quad = zeros(1, size(Mapping,2));
                Mean = zeros(1, size(Mapping, 2));
                T_map = zeros(1, size(Mapping, 2));

                for NbSub2Excl = 0:(NbSub - 5)

                    fprintf('\nGLM on vertices with %i subjects', NbSub - NbSub2Excl);

                    VertOfInt = find(sum(IsZero) == NbSub2Excl);

                    Y = [];
                    parfor iVert = 1:numel(VertOfInt)
                        Subj2Exclu = find(~IsZero(:, VertOfInt(iVert)));
                        Y(:, iVert, :) = CrossSenslLayers(Subj2Exclu, VertOfInt(iVert), :);
                    end

                    Mean_tmp = mean(mean(Y, 3));
                    T_map_temp = nanmean(mean(Y, 3)) ./ nansem(mean(Y, 3));

                    %                 Y = shiftdim(Y,2);
                    %                 Y = reshape(Y, [size(Y,1)*size(Y,2),size(Y,3)] );
                    %
                    %                 X = [];
                    %                 for iSubj=1:(NbSub-NbSub2Excl)
                    %                     X((1:NbLayers)+NbLayers*(iSubj-1),(1:size(DesMat,2))+size(DesMat,2)*(iSubj-1)) = DesMat; %#ok<*SAGROW>
                    %                 end
                    %
                    %                 B = pinv(X)*Y;
                    %
                    %                 Cst_tmp = mean(B(1:3:size(X,2),:));
                    %                 Cst(VertOfInt) = Cst_tmp;
                    %
                    %                 Lin_tmp = mean(B(2:3:size(X,2),:));
                    %                 Lin(VertOfInt) = Lin_tmp;
                    %
                    %                 Quad_tmp = mean(B(3:3:size(X,2),:));
                    %                 Quad(VertOfInt) = Quad_tmp;

                    %
                    %                 if NbSub2Excl==0
                    %
                    %                     fprintf('\nRunning permutations')
                    %
                    %                     for i=1:size(DesMat,2)
                    %
                    %                         Perms = [];
                    %
                    %                         tmp = B(i:3:size(X,2),:);
                    %                         SPM = mean(tmp);
                    %
                    %                         parfor iPerm = 1:size(ToPermute,1)
                    %                             %                             Perms(iPerm,:) = max(abs(mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))))); %#ok<*SAGROW>
                    %                             Perms(iPerm,:) = mean(tmp.*repmat(ToPermute(iPerm,:)',1,size(tmp,2))); %#ok<*SAGROW>
                    %                         end
                    %
                    %                         PMaps = sum( abs( Perms-repmat(mean(Perms),size(Perms,1),1) ) > repmat( abs( SPM-mean(Perms) ) ,size(Perms,1),1) ) ...
                    %                             / size(Perms,1);
                    %
                    %                         PMaps = repmat(Perms,[1 size(SPM,2)])>repmat(abs(SPM),[size(Perms,1) 1]);
                    %                         PMaps = sum(PMaps)/size(PMaps,1);
                    %
                    %                         PMaps_final = zeros(1, size(Mapping,2));
                    %                         PMaps_final(VertOfInt) = PMaps;
                    %
                    %                         SPM_final = zeros(1, size(Mapping,2));
                    %                         SPM_final(VertOfInt) = SPM;
                    %
                    %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                    %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_mask' suffix '.vtk']), Vertex, Face, SPM_final')
                    %
                    %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask', ...
                    %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_inf_mask' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                    %
                    %                         SPM(PMaps>0.05) = 0;
                    %                         SPM_final = zeros(1, size(Mapping,2));
                    %                         SPM_final(VertOfInt) = SPM;
                    %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                    %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_inf_mask_thres' suffix '.vtk']), InfVertex, InfFace, SPM_final')
                    %
                    %                         write_vtk(fullfile(DataFolder, [HS 'H'], 'Baseline', 'mask',...
                    %                             [CondName{iCond} '_' hs 'h_' Suffix{i} '_inf_mask_pmap' suffix '.vtk']), InfVertex, InfFace, PMaps_final')
                    %
                    %                     end
                    %
                    %                 end
                    %
                    %             end

                    fprintf('\n');

                    %                 write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSens', ...
                    %                     [CrossSensName{iCond} '_' hs(ihs) 'h_lin_inf' suffix '.vtk']), InfVertex, InfFace, Lin')
                    %                 write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSens', ...
                    %                     [CrossSensName{iCond} '_' hs(ihs) 'h_cst_inf' suffix '.vtk']), InfVertex, InfFace, Cst')
                    %                 write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSens', ...
                    %                     [CrossSensName{iCond} '_' hs(ihs) 'h_quad_inf' suffix '.vtk']), InfVertex, InfFace, Quad')

                    write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSens', ...
                                       [CrossSensName{iCond} '_' hs(ihs) 'h_mean_inf' suffix '.vtk']), InfVertex, InfFace, Mean');
                    write_vtk(fullfile(DataFolder, [upper(hs(ihs)) 'H'], 'CrossSens', ...
                                       [CrossSensName{iCond} '_' hs(ihs) 'h_T_map_inf' suffix '.vtk']), InfVertex, InfFace, T_map');
                end
            end

        end

    end

end
