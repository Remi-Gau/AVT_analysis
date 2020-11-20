clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

CondNamesStim = { ...
                 'AStimL', 'AStimR'; ...
                 'VStimL', 'VStimR'; ...
                 'TStimL', 'TStimR'};

CondNamesTarg = { ...
                 'ATargL', 'ATargR'; ...
                 'VTargL', 'VTargR'; ...
                 'TTargL', 'TTargR'};

load(fullfile(StartDir, 'results', 'roi', 'MinNbVert.mat'), 'MinVert');

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir, 'betas', '6_surf');
    Data_targets_dir = fullfile(GLM_dir, 'betas', '6_surf', 'targets');

    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf');
    mkdir(Results_dir);

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'));
    [BetaOfInterest, ~] = GetBOI(SPM, CondNamesStim);
    [BetaOfInterestTargets, BetaNames] = GetBOI(SPM, CondNamesTarg);

    Nb_sess = numel(SPM.Sess);
    clear SPM;

    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    %% For the 2 hemispheres
    NbVertices = nan(1, 2);
    for hs = 1:2

        if hs == 1
            fprintf('\n Left hemipshere\n');
            HsSufix = 'l';
        else
            fprintf('\n Right hemipshere\n');
            HsSufix = 'r';
        end

        FeatureSaveFile = fullfile(Data_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                              num2str(NbLayers) '_surf.mat']);
        FeatureTargetsSaveFile = fullfile(Data_targets_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                                             num2str(NbLayers) '_surf.mat']);

        InfSurfFile = spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
                                 ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex, inf_faces, ~] = read_vtk(InfSurfFile, 0, 1);

        NbVertices(hs) = size(inf_vertex, 2);

        % Load data or extract them
        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile, 'VertexWithData', 'AllMapping');
            VertexWithDataHS{hs} = VertexWithData; %#ok<*SAGROW>
            MappingBothHS{hs} = AllMapping;

            load(FeatureTargetsSaveFile, 'VertexWithData', 'AllMapping');
            VertexWithDataTargetsHS{hs} = VertexWithData; %#ok<*SAGROW>
            MappingTargetsBothHS{hs} = AllMapping;
        else
            error('The features have not been extracted from the VTK files.');
        end

    end

    cd(StartDir);

    if any(NbVertex ~= NbVertices)
        NbVertex;
        NbVertices; %#ok<*NOPTS>
        error('The number of vertices does not match.');
    end

    Features_lh = nan(NbVertex(1), NbLayers, size(MappingBothHS{1}, 3));
    Features_lh(VertexWithDataHS{1}, :, :) = MappingBothHS{1};

    Features_rh = nan(NbVertex(2), NbLayers, size(MappingBothHS{2}, 3));
    Features_rh(VertexWithDataHS{2}, :, :) = MappingBothHS{2};

    Features_targets_lh = nan(NbVertex(1), NbLayers, size(MappingTargetsBothHS{1}, 3));
    Features_targets_lh(VertexWithDataTargetsHS{1}, :, :) = MappingTargetsBothHS{1};

    Features_targets_rh = nan(NbVertex(2), NbLayers, size(MappingTargetsBothHS{2}, 3));
    Features_targets_rh(VertexWithDataTargetsHS{2}, :, :) = MappingTargetsBothHS{2};

    %%
    fprintf(' Averaging for ROI:\n');

    for iROI = 1:numel(ROI)

        clear Data_ROI;

        Data_ROI.name = ROI(iROI).name;

        fprintf(['  '  Data_ROI.name '\n']);

        FeaturesL = Features_lh(ROI(iROI).VertOfInt{1}, :, :);
        FeaturesR = Features_rh(ROI(iROI).VertOfInt{2}, :, :);

        FeaturesTargetsL = Features_targets_lh(ROI(iROI).VertOfInt{1}, :, :);
        FeaturesTargetsR = Features_targets_rh(ROI(iROI).VertOfInt{2}, :, :);

        Features = cat(1, FeaturesL, FeaturesR);
        FeaturesTargets = cat(1, FeaturesTargetsL, FeaturesTargetsR);

        fprintf('  NaNs: %i ; Zeros: %i\n', ...
                sum(any(any(any(isnan(Features), 3), 2))), ....
                sum(any(any(any(Features == 0, 3), 2))));
        Data_ROI.NaNorZero = [sum(any(any(any(isnan(Features), 3), 2))) ...
                              sum(any(any(any(Features == 0, 3), 2)))];
        fprintf('  NaNs: %i ; Zeros: %i\n', ...
                sum(any(any(any(isnan(FeaturesTargets), 3), 2))), ....
                sum(any(any(any(FeaturesTargets == 0, 3), 2))));
        Data_ROI.NaNorZeroTargets = [sum(any(any(any(isnan(FeaturesTargets), 3), 2))) ...
                                     sum(any(any(any(FeaturesTargets == 0, 3), 2)))];

        clear Features FeaturesTargets;

        %% For ipsilateral stimulus
        Cdt_ROI_lhs = [1 2 3];
        Cdt_ROI_rhs = [4 5 6];

        Data_ROI.StimTargIpsi.LayerMean = nan(NbLayers, 20, size(Cdt_ROI_lhs, 2));

        for iCdt = 1:size(Cdt_ROI_lhs, 2)

            Stim_Beta2Sel_lhs = [];
            Stim_Beta2Sel_rhs = [];

            Targ_Beta2Sel_lhs = [];
            Targ_Beta2Sel_rhs = [];
            for iSess = 1:Nb_sess
                Stim_Beta2Sel_lhs = [Stim_Beta2Sel_lhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesStim{Cdt_ROI_lhs(iCdt)}  '*bf(1)']))];  %#ok<*AGROW>
                Stim_Beta2Sel_rhs = [Stim_Beta2Sel_rhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesStim{Cdt_ROI_rhs(iCdt)}  '*bf(1)']))];

                Targ_Beta2Sel_lhs = [Targ_Beta2Sel_lhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesTarg{Cdt_ROI_lhs(iCdt)}  '*bf(1)']))];  %#ok<*AGROW>
                Targ_Beta2Sel_rhs = [Targ_Beta2Sel_rhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesTarg{Cdt_ROI_rhs(iCdt)}  '*bf(1)']))];
            end

            Stim_Beta2Sel_lhs = find(ismember(BetaOfInterest, Stim_Beta2Sel_lhs));
            Stim_Beta2Sel_rhs = find(ismember(BetaOfInterest, Stim_Beta2Sel_rhs));

            Targ_Beta2Sel_lhs = find(ismember(BetaOfInterestTargets, Targ_Beta2Sel_lhs));
            Targ_Beta2Sel_rhs = find(ismember(BetaOfInterestTargets, Targ_Beta2Sel_rhs));

            tmpL = shiftdim(FeaturesL(:, :, Stim_Beta2Sel_lhs), 1);
            tmpR = shiftdim(FeaturesR(:, :, Stim_Beta2Sel_rhs), 1);
            tmp_stim = cat(3, tmpL, tmpR);
            clear tmpL tmpR Stim_Beta2Sel_lhs Stim_Beta2Sel_rhs;

            tmpL = shiftdim(FeaturesTargetsL(:, :, Targ_Beta2Sel_lhs), 1);
            tmpR = shiftdim(FeaturesTargetsR(:, :, Targ_Beta2Sel_rhs), 1);
            tmp_target = cat(3, tmpL, tmpR);
            clear tmpL tmpR Targ_Beta2Sel_lhs Targ_Beta2Sel_rhs;

            tmp = tmp_stim - tmp_target;
            Remove = ~(squeeze(any(any(isnan(tmp)), 2)));
            tmp = tmp(:, :, Remove);

            Data_ROI.StimTargIpsi.WholeROI.MEAN(1:size(tmp, 2), iCdt) = squeeze(nanmean(nanmean(tmp, 3), 1));
            Data_ROI.StimTargIpsi.WholeROI.MEDIAN(1:size(tmp, 2), iCdt) = squeeze(nanmedian(nanmean(tmp, 3), 1));

            Data_ROI.StimTargIpsi.LayerMean(:, 1:size(tmp, 2), iCdt) =  nanmean(tmp, 3);
            Data_ROI.StimTargIpsi.LayerMedian(:, 1:size(tmp, 2), iCdt) = nanmedian(tmp, 3);

        end

        %% For contra-lateral stimulus
        Cdt_ROI_lhs = [4 5 6];
        Cdt_ROI_rhs = [1 2 3];

        Data_ROI.StimTargContra.LayerMean = nan(NbLayers, 20, size(Cdt_ROI_lhs, 2));

        for iCdt = 1:size(Cdt_ROI_lhs, 2)

            Stim_Beta2Sel_lhs = [];
            Stim_Beta2Sel_rhs = [];

            Targ_Beta2Sel_lhs = [];
            Targ_Beta2Sel_rhs = [];
            for iSess = 1:Nb_sess
                Stim_Beta2Sel_lhs = [Stim_Beta2Sel_lhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesStim{Cdt_ROI_lhs(iCdt)}  '*bf(1)']))];  %#ok<*AGROW>
                Stim_Beta2Sel_rhs = [Stim_Beta2Sel_rhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesStim{Cdt_ROI_rhs(iCdt)}  '*bf(1)']))];

                Targ_Beta2Sel_lhs = [Targ_Beta2Sel_lhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesTarg{Cdt_ROI_lhs(iCdt)}  '*bf(1)']))];  %#ok<*AGROW>
                Targ_Beta2Sel_rhs = [Targ_Beta2Sel_rhs; find(strcmp(cellstr(BetaNames), ...
                                                                    ['Sn(' num2str(iSess) ') ' CondNamesTarg{Cdt_ROI_rhs(iCdt)}  '*bf(1)']))];
            end

            Stim_Beta2Sel_lhs = find(ismember(BetaOfInterest, Stim_Beta2Sel_lhs));
            Stim_Beta2Sel_rhs = find(ismember(BetaOfInterest, Stim_Beta2Sel_rhs));

            Targ_Beta2Sel_lhs = find(ismember(BetaOfInterestTargets, Targ_Beta2Sel_lhs));
            Targ_Beta2Sel_rhs = find(ismember(BetaOfInterestTargets, Targ_Beta2Sel_rhs));

            tmpL = shiftdim(FeaturesL(:, :, Stim_Beta2Sel_lhs), 1);
            tmpR = shiftdim(FeaturesR(:, :, Stim_Beta2Sel_rhs), 1);
            tmp_stim = cat(3, tmpL, tmpR);
            clear tmpL tmpR Stim_Beta2Sel_lhs Stim_Beta2Sel_rhs;

            tmpL = shiftdim(FeaturesTargetsL(:, :, Targ_Beta2Sel_lhs), 1);
            tmpR = shiftdim(FeaturesTargetsR(:, :, Targ_Beta2Sel_rhs), 1);
            tmp_target = cat(3, tmpL, tmpR);
            clear tmpL tmpR Targ_Beta2Sel_lhs Targ_Beta2Sel_rhs;

            tmp = tmp_stim - tmp_target;
            Remove = ~(squeeze(any(any(isnan(tmp)), 2)));
            tmp = tmp(:, :, Remove);

            Data_ROI.StimTargContra.WholeROI.MEAN(1:size(tmp, 2), iCdt) = squeeze(nanmean(nanmean(tmp, 3), 1));
            Data_ROI.StimTargContra.WholeROI.MEDIAN(1:size(tmp, 2), iCdt) = squeeze(nanmedian(nanmean(tmp, 3), 1));

            Data_ROI.StimTargContra.LayerMean(:, 1:size(tmp, 2), iCdt) =  nanmean(tmp, 3);
            Data_ROI.StimTargContra.LayerMedian(:, 1:size(tmp, 2), iCdt) = nanmedian(tmp, 3);

        end

        %%
        Data_ROI.StimTargIpsi.MEAN = squeeze(nanmean(Data_ROI.StimTargIpsi.LayerMean, 2));
        Data_ROI.StimTargIpsi.MEDIAN = squeeze(nanmean(Data_ROI.StimTargIpsi.LayerMedian, 2));
        Data_ROI.StimTargIpsi.STD = squeeze(nanstd(Data_ROI.StimTargIpsi.LayerMean, 2));
        Data_ROI.StimTargIpsi.SEM = squeeze(nansem(Data_ROI.StimTargIpsi.LayerMean, 2));

        Data_ROI.StimTargContra.MEAN = squeeze(nanmean(Data_ROI.StimTargContra.LayerMean, 2));
        Data_ROI.StimTargContra.MEDIAN = squeeze(nanmean(Data_ROI.StimTargContra.LayerMedian, 2));
        Data_ROI.StimTargContra.STD = squeeze(nanstd(Data_ROI.StimTargContra.LayerMean, 2));
        Data_ROI.StimTargContra.SEM = squeeze(nansem(Data_ROI.StimTargContra.LayerMean, 2));

        save(fullfile(Results_dir, strcat('Data_stims_targets_Pooled_Surf_', ROI(iROI).name, ...
                                          '_l-', num2str(NbLayers), '.mat')), 'Data_ROI');

    end

end

cd(StartDir);
