clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

CondNames = { ...
             'AStimL', 'AStimR', ...
             'VStimL', 'VStimR', ...
             'TStimL', 'TStimR'
             %     'ATargL','ATargR';...
             %     'VTargL','VTargR';...
             %     'TTargL','TTargR';...
            };

DesMat = (1:NbLayers) - mean(1:NbLayers);
DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers-2,1) DesMat'];
DesMat = spm_orth(DesMat);

Folds = { ...
         1, 2:3; ...
         2, [1 3]; ...
         3, 1:2};

ismultinorm = 1;
normmode = 'overall'; % runwise  overall
iseucnorm = 1;
issubranktrans = 1;
isplotranktrans = 1;

ToPlot = {'Cst', 'Lin', 'Quad'};

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'correlations');
    [~, ~, ~] = mkdir(Results_dir);

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'));
    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM;

    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    % Loads which runs happened on which day to set up the CVs
    load(fullfile(StartDir, 'RunsPerSes.mat'));
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    RunPerSes = RunPerSes(Idx).RunsPerSes;
    CVs = { ...
           1:RunPerSes(1), ...
           RunPerSes(1) + 1:RunPerSes(1) + RunPerSes(2), ...
           RunPerSes(1) + RunPerSes(2) + 1:sum(RunPerSes)};
    clear Idx RunPerSes;

    %% For the 2 hemispheres
    NbVertices = nan(1, 2);
    for hs = 1:2

        if hs == 1
            fprintf('\n\n Left hemipshere\n');
            HsSufix = 'l';
        else
            fprintf('\n\n Right hemipshere\n');
            HsSufix = 'r';
        end

        FeatureSaveFile = fullfile(Data_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                              num2str(NbLayers) '_surf.mat']);

        InfSurfFile = spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
                                 ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex, inf_faces, ~] = read_vtk(InfSurfFile, 0, 1);

        NbVertices(hs) = size(inf_vertex, 2);

        % Load data or extract them
        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile);
            VertexWithDataHS{hs} = VertexWithData; %#ok<*SAGROW>
        else
            error('The features have not been extracted from the VTK files.');
        end

        %% Run GLMs for basic conditions
        fprintf('\n   All conditions\n');
        for iCdt = 1:numel(CondNames) % For each Condition
            fprintf('    %s\n', CondNames{iCdt});

            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                Beta2Sel = [Beta2Sel; find(strcmp(cellstr(BetaNames), ...
                                                  ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];   %#ok<*AGROW>
            end

            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));

            % Extract them
            Features = AllMapping(:, :, Beta2Sel);

            if sum(isnan(Features(:))) > 0
                warning('We have %i NaNs for %s', sum(isnan(Features(:))), CondNames{iCdt});
            end
            if sum(Features(:) == 0) > 0
                warning('We have %i zeros for %s', sum(Features(:) == 0), CondNames{iCdt});
            end

            % Run the "cross-validation"
            for iCV = 1:numel(CVs)

                Sess2Sel = CVs{iCV};
                if strcmp(SubLs(iSub).name, 'sub-06') && iCdt < 3
                    Sess2Sel(Sess2Sel == 17) = [];
                    Sess2Sel(Sess2Sel > 16) = Sess2Sel(Sess2Sel > 16) - 1;
                end

                % Change or adapt dimensions for GLM
                Y = Features(:, :, Sess2Sel);

                X = repmat(DesMat, size(Y, 3), 1);

                Y = shiftdim(Y, 1);
                Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

                BetaCdt{hs, iCV}(:, :, iCdt) = pinv(X) * Y;
            end

            % Same but with no CVs
            Sess2Sel = cat(2, CVs{:});
            if strcmp(SubLs(iSub).name, 'sub-06') && iCdt < 3
                Sess2Sel(Sess2Sel == 17) = [];
                Sess2Sel(Sess2Sel > 16) = Sess2Sel(Sess2Sel > 16) - 1;
            end

            Y = Features(:, :, Sess2Sel);

            X = repmat(DesMat, size(Y, 3), 1);

            Y = shiftdim(Y, 1);
            Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

            BetaCdt_no_cv{hs, 1}(:, :, iCdt) = pinv(X) * Y;

            clear Features Beta2Sel B X Y Mapping iBeta iSess;
        end

        clear iCdt;

    end

    cd(StartDir);

    if any(NbVertex ~= NbVertices)
        NbVertex;
        NbVertices; %#ok<*NOPTS>
        error('The number of vertices does not match.');
    end

    close all;

    fprintf('\n  Running RSA\n');

    %% RSA Stim VS Stim
    fprintf('\n   Stimuli\n');

    Cdt_ROI_lhs = 1:6;
    Cdt_ROI_rhs = [2 1 4 3 6 5];

    conditionVec = repmat((1:6)', 3, 1);
    partition = repmat([1 2 3], 6, 1);
    partition = partition(:);

    for iToPlot = 1:numel(ToPlot)

        X_lh = nan(size(CondNames, 2), NbVertex(1));
        X_rh = nan(size(CondNames, 2), NbVertex(2));
        for iCdt = 1:size(CondNames, 2)
            X_lh(iCdt, VertexWithDataHS{1}) = BetaCdt_no_cv{1}(iToPlot, :, Cdt_ROI_lhs(iCdt));
            X_rh(iCdt, VertexWithDataHS{2}) = BetaCdt_no_cv{2}(iToPlot, :, Cdt_ROI_rhs(iCdt));
        end

        X_lh_CV = nan(size(CondNames, 2) * numel(CVs), NbVertex(1));
        X_rh_CV = nan(size(CondNames, 2) * numel(CVs), NbVertex(2));
        row = 1;
        for iCV = 1:numel(CVs)
            for iCdt = 1:size(CondNames, 2)
                X_lh_CV(row, VertexWithDataHS{1}) = BetaCdt{1, iCV}(iToPlot, :, Cdt_ROI_lhs(iCdt));
                X_rh_CV(row, VertexWithDataHS{2}) = BetaCdt{2, iCV}(iToPlot, :, Cdt_ROI_rhs(iCdt));
                row = row + 1;
            end
        end

        for iROI = 1:numel(ROI)

            X = [X_lh(:, ROI(iROI).VertOfInt{1}) X_rh(:, ROI(iROI).VertOfInt{2})];
            X(:, any(isnan(X))) = [];

            X_CV = [X_lh_CV(:, ROI(iROI).VertOfInt{1}) X_rh_CV(:, ROI(iROI).VertOfInt{2})];
            X_CV(:, any(isnan(X_CV))) = [];

            %             if strcmp(distfun, 'Mahalanobis') && ismultinorm == 0
            %                 [Sw_reg, res, beta_hat] = get_res_covmatrix(xY, SPM);
            %             else
            %                 [u_hat,resMS,Sw_hat,beta_hat] = rsa.spm.noiseNormalizeBeta(xY, SPM, 'normmode', normmode);
            %             end

            %%
            close all;
            figure(1);
            for i = 1:size(X, 1)
                subplot(size(X, 1), 1, i);
                plot(X(i, :));
                axis([1 size(X, 2) min(X(:)) max(X(:))]);
            end

            %% Eucledian normalization
            if iseucnorm
                for i = 1:size(X, 1)
                    X(i, :) = X(i, :) / norm(X(i, :));
                end

                for i = 1:size(X_CV, 1)
                    X_CV(i, :) = X_CV(i, :) / norm(X_CV(i, :));
                end
            end

            %%
            subjectRDMs{iROI, iToPlot, 1}(:, :, iSub) = squareform(pdist(X, 'euclidean'));
            subjectRDMs{iROI, iToPlot, 2}(:, :, iSub) = squareform(pdist(X, 'spearman'));

            %             subjectRDMs{iROI,iToPlot,2}(:,:,iSub) = squareform(pdist(X, 'mahalanobis'));
            %             subjectRDMs{rr}(:,:,ss) =
            %             squareform(pdist(rsa_data, lower(distfun), Sw_reg)); spearman

            subjectRDMs_CV{iROI, iToPlot, 1}(:, :, iSub) = squareform(rsa.distanceLDC(X_CV, partition, conditionVec));

            %%
            RDM_final_euc = zeros(size(CondNames, 2));
            RDM_final_pear = zeros(size(CondNames, 2));
            for iCdt = 1:size(CondNames, 2)
                for iCV = 1:numel(CVs)
                    take_train = all([partition == iCV, conditionVec == iCdt], 2);
                    take_test = all([partition ~= iCV, conditionVec ~= iCdt], 2);
                    tmp = X_CV(take_test, :);
                    tmp = mean(cat(3, tmp(1:5, :), tmp(6:10, :)), 3);
                    tmp = cat(1, X_CV(take_train, :), tmp);

                    RDM_euc(:, :, iCV) = squareform(pdist(tmp, 'euclidean'));
                    RDM_pear(:, :, iCV) = squareform(pdist(tmp, 'spearman'));
                end
                RDM_final_euc(iCdt, iCdt:end) = mean(RDM_euc(iCdt, iCdt:end, :), 3);
                RDM_final_pear(iCdt, iCdt:end) = mean(RDM_pear(iCdt, iCdt:end, :), 3);

                clear RDM_euc RDM_pear;
            end

            subjectRDMs_CV{iROI, iToPlot, 2}(:, :, iSub) = RDM_final_euc;
            subjectRDMs_CV{iROI, iToPlot, 3}(:, :, iSub) = RDM_final_pear;

            clear X;

        end

    end

    %% RSA cross side
    fprintf('\n   Cross side\n');
    Cond_con_name = {'A', 'V', 'T'};

    conditionVec = repmat((1:3)', 3, 1);
    partition = repmat([1 2 3], 3, 1);
    partition = partition(:);

    for iToPlot = 1:numel(ToPlot)

        X_lh = nan(size(Cond_con_name, 2), NbVertex(1));
        X_rh = nan(size(Cond_con_name, 2), NbVertex(2));
        for iCdt = 1:size(Cond_con_name, 2)
            X_lh(iCdt, VertexWithDataHS{1}) = BetaCrossSide_no_cv{1}(iToPlot, :, iCdt);
            X_rh(iCdt, VertexWithDataHS{2}) = BetaCrossSide_no_cv{2}(iToPlot, :, iCdt);
        end

        X_lh_CV = nan(size(Cond_con_name, 2) * numel(CVs), NbVertex(1));
        X_rh_CV = nan(size(Cond_con_name, 2) * numel(CVs), NbVertex(2));
        row = 1;
        for iCV = 1:numel(CVs)
            for iCdt = 1:size(Cond_con_name, 2)
                X_lh_CV(row, VertexWithDataHS{1}) = BetaCrossSide{1, iCV}(iToPlot, :, iCdt);
                X_rh_CV(row, VertexWithDataHS{2}) = BetaCrossSide{2, iCV}(iToPlot, :, iCdt);
                row = row + 1;
            end
        end

        for iROI = 1:numel(ROI)

            X = [X_lh(:, ROI(iROI).VertOfInt{1}) X_rh(:, ROI(iROI).VertOfInt{2})];
            X(:, any(isnan(X))) = [];

            X_CV = [X_lh_CV(:, ROI(iROI).VertOfInt{1}) X_rh_CV(:, ROI(iROI).VertOfInt{2})];
            X_CV(:, any(isnan(X_CV))) = [];

            %             if strcmp(distfun, 'Mahalanobis') && ismultinorm == 0
            %                 [Sw_reg, res, beta_hat] = get_res_covmatrix(xY, SPM);
            %             else
            %                 [u_hat,resMS,Sw_hat,beta_hat] = rsa.spm.noiseNormalizeBeta(xY, SPM, 'normmode', normmode);
            %             end

            % Eucledian normalization
            if iseucnorm
                for i = 1:size(X, 1)
                    X(i, :) = X(i, :) / norm(X(i, :));
                end

                for i = 1:size(X_CV, 1)
                    X_CV(i, :) = X_CV(i, :) / norm(X_CV(i, :));
                end
            end

            subjectRDMs_cross_side{iROI, iToPlot, 1}(:, :, iSub) = squareform(pdist(X, 'euclidean'));
            subjectRDMs_cross_side{iROI, iToPlot, 2}(:, :, iSub) = squareform(pdist(X, 'spearman'));

            %             subjectRDMs{iROI,iToPlot,2}(:,:,iSub) = squareform(pdist(X, 'mahalanobis'));
            %             subjectRDMs{rr}(:,:,ss) =
            %             squareform(pdist(rsa_data, lower(distfun), Sw_reg)); spearman

            subjectRDMs_CV_cross_side{iROI, iToPlot, 1}(:, :, iSub) = squareform(rsa.distanceLDC(X_CV, partition, conditionVec));

            RDM_final_euc = zeros(size(Cond_con_name, 2));
            RDM_final_pear = zeros(size(Cond_con_name, 2));
            for iCdt = 1:size(Cond_con_name, 2)
                for iCV = 1:numel(CVs)
                    take_train = all([partition == iCV, conditionVec == iCdt], 2);
                    take_test = all([partition ~= iCV, conditionVec ~= iCdt], 2);
                    tmp = X_CV(take_test, :);
                    tmp = mean(cat(3, tmp(1:2, :), tmp(3:4, :)), 3);
                    tmp = cat(1, X_CV(take_train, :), tmp);

                    RDM_euc(:, :, iCV) = squareform(pdist(tmp, 'euclidean'));
                    RDM_pear(:, :, iCV) = squareform(pdist(tmp, 'spearman'));
                end
                RDM_final_euc(iCdt, iCdt:end) = mean(RDM_euc(iCdt, iCdt:end, :), 3);
                RDM_final_pear(iCdt, iCdt:end) = mean(RDM_pear(iCdt, iCdt:end, :), 3);

                clear RDM_euc RDM_pear;
            end

            subjectRDMs_CV_cross_side{iROI, iToPlot, 2}(:, :, iSub) = RDM_final_euc;
            subjectRDMs_CV_cross_side{iROI, iToPlot, 3}(:, :, iSub) = RDM_final_pear;

        end

    end

    %% RSA cross-sensory
    fprintf('\n   Cross sensory\n');

    Cond_con_name = { ...
                     'Contra_A-V', 'Contra_A-T', 'Contra_V-T', ...
                     'Ipsi_A-V', 'Ipsi_A-T', 'Ipsi_V-T'};

    conditionVec = repmat((1:6)', 3, 1);

    partition = repmat([1 2 3], 6, 1);
    partition = partition(:);

    for iToPlot = 1:numel(ToPlot)

        X_lh = nan(size(Cond_con_name, 2), NbVertex(1));
        X_rh = nan(size(Cond_con_name, 2), NbVertex(2));
        for iCdt = 1:size(Cond_con_name, 2)
            X_lh(iCdt, VertexWithDataHS{1}) = BetaCrossSens_no_cv{1}(iToPlot, :, iCdt);
            X_rh(iCdt, VertexWithDataHS{2}) = BetaCrossSens_no_cv{2}(iToPlot, :, iCdt);
        end

        X_lh_CV = nan(size(Cond_con_name, 2) * numel(CVs), NbVertex(1));
        X_rh_CV = nan(size(Cond_con_name, 2) * numel(CVs), NbVertex(2));
        row = 1;
        for iCV = 1:numel(CVs)
            for iCdt = 1:size(Cond_con_name, 2)
                X_lh_CV(row, VertexWithDataHS{1}) = BetaCrossSens{1, iCV}(iToPlot, :, iCdt);
                X_rh_CV(row, VertexWithDataHS{2}) = BetaCrossSens{2, iCV}(iToPlot, :, iCdt);
                row = row + 1;
            end
        end

        for iROI = 1:numel(ROI)

            X = [X_lh(:, ROI(iROI).VertOfInt{1}) X_rh(:, ROI(iROI).VertOfInt{2})];
            X(:, any(isnan(X))) = [];

            X_CV = [X_lh_CV(:, ROI(iROI).VertOfInt{1}) X_rh_CV(:, ROI(iROI).VertOfInt{2})];
            X_CV(:, any(isnan(X_CV))) = [];

            %             if strcmp(distfun, 'Mahalanobis') && ismultinorm == 0
            %                 [Sw_reg, res, beta_hat] = get_res_covmatrix(xY, SPM);
            %             else
            %                 [u_hat,resMS,Sw_hat,beta_hat] = rsa.spm.noiseNormalizeBeta(xY, SPM, 'normmode', normmode);
            %             end

            % Eucledian normalization
            if iseucnorm
                for i = 1:size(X, 1)
                    X(i, :) = X(i, :) / norm(X(i, :));
                end

                for i = 1:size(X_CV, 1)
                    X_CV(i, :) = X_CV(i, :) / norm(X_CV(i, :));
                end
            end

            subjectRDMs_cross_sens{iROI, iToPlot, 1}(:, :, iSub) = squareform(pdist(X, 'euclidean'));
            subjectRDMs_cross_sens{iROI, iToPlot, 2}(:, :, iSub) = squareform(pdist(X, 'spearman'));

            %             subjectRDMs{iROI,iToPlot,2}(:,:,iSub) = squareform(pdist(X, 'mahalanobis'));
            %             subjectRDMs{rr}(:,:,ss) =
            %             squareform(pdist(rsa_data, lower(distfun), Sw_reg)); spearman

            subjectRDMs_CV_cross_sens{iROI, iToPlot, 1}(:, :, iSub) = squareform(rsa.distanceLDC(X_CV, partition, conditionVec));

            RDM_final_euc = zeros(size(Cond_con_name, 2));
            RDM_final_pear = zeros(size(Cond_con_name, 2));
            for iCdt = 1:size(Cond_con_name, 2)
                for iCV = 1:numel(CVs)
                    take_train = all([partition == iCV, conditionVec == iCdt], 2);
                    take_test = all([partition ~= iCV, conditionVec ~= iCdt], 2);
                    tmp = X_CV(take_test, :);
                    tmp = mean(cat(3, tmp(1:5, :), tmp(6:10, :)), 3);
                    tmp = cat(1, X_CV(take_train, :), tmp);

                    RDM_euc(:, :, iCV) = squareform(pdist(tmp, 'euclidean'));
                    RDM_pear(:, :, iCV) = squareform(pdist(tmp, 'spearman'));
                end
                RDM_final_euc(iCdt, iCdt:end) = mean(RDM_euc(iCdt, iCdt:end, :), 3);
                RDM_final_pear(iCdt, iCdt:end) = mean(RDM_pear(iCdt, iCdt:end, :), 3);

                clear RDM_euc RDM_pear;
            end

            subjectRDMs_CV_cross_sens{iROI, iToPlot, 2}(:, :, iSub) = RDM_final_euc;
            subjectRDMs_CV_cross_sens{iROI, iToPlot, 3}(:, :, iSub) = RDM_final_pear;

        end

    end

    clear BetaCdt BetaCrossSens BetaCrossSide BetaCdt_no_cv BetaCrossSens_no_cv BetaCrossSide_no_cv;

end

cd(StartDir);
