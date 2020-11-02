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
DesMat = [ones(NbLayers, 1) DesMat'];
DesMat = spm_orth(DesMat);

% Daily folds for the CV
Folds = { ...
         1, 2:3; ...
         2, [1 3]; ...
         3, 1:2};

ToPlot = {'Cst', 'Lin'};

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'rasters');
    [~, ~, ~] = mkdir(Results_dir);

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'));
    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM;

    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');
    ROI(6:7) = []; % remove V4 and V5

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
            fprintf('\n Left hemipshere\n');
            HsSufix = 'l';
        else
            fprintf('\n Right hemipshere\n');
            HsSufix = 'r';
        end

        FeatureSaveFile = fullfile(Data_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                              num2str(NbLayers) '_surf.mat']);

        % Load data or extract them
        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile);
            VertexWithDataHS{hs} = VertexWithData; %#ok<*SAGROW>
        else
            error('The features have not been extracted from the VTK files.');
        end

        %% Run GLMs for basic conditions
        fprintf('\n  Running GLMs all conditions\n');
        for iCdt = 1:numel(CondNames) % For each Condition
            fprintf('   %s\n', CondNames{iCdt});

            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                Beta2Sel = [Beta2Sel; find(strcmp(cellstr(BetaNames), ...
                                                  ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];  %#ok<*AGROW>
            end

            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));

            % Extract them
            Features = AllMapping(:, :, Beta2Sel); %#ok<*FNDSB>

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

            clear Features Beta2Sel B X Y Mapping iBeta iSess;
        end

        clear iCdt;

        %% Run GLMs for contra-ipsi
        fprintf('\n  Contra-Ipsi\n');
        Cond_con_name = {'A', 'V', 'T'};

        if hs == 1
            Cond2Contrast = { ...
                             2, 1; ...
                             4, 3; ...
                             6, 5};
        elseif hs == 2
            Cond2Contrast = { ...
                             1, 2; ...
                             3, 4; ...
                             5, 6};
        end

        for iCdt = 1:size(Cond2Contrast, 1)

            fprintf('   %s Contra-Ipsi\n', Cond_con_name{iCdt});

            Beta2Sel = [];
            Beta2Sel2 = [];

            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name, 'sub-06') && iSess == 17 && iCdt == 1
                else
                    Beta2Sel = [Beta2Sel; find(strcmp(cellstr(BetaNames), ...
                                                      ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt, 1}}  '*bf(1)']))];

                    Beta2Sel2 = [Beta2Sel2; find(strcmp(cellstr(BetaNames), ...
                                                        ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt, 2}}  '*bf(1)']))];
                end
            end

            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            Beta2Sel2 = find(ismember(BetaOfInterest, Beta2Sel2));

            Features = AllMapping(:, :, Beta2Sel) - ...
                AllMapping(:, :, Beta2Sel2);

            % Run the "cross-validation"
            for iCV = 1:numel(CVs)

                Sess2Sel = CVs{iCV};
                if strcmp(SubLs(iSub).name, 'sub-06') && iCdt == 1
                    Sess2Sel(Sess2Sel == 17) = [];
                    Sess2Sel(Sess2Sel > 16) = Sess2Sel(Sess2Sel > 16) - 1;
                end

                % Change or adapt dimensions for GLM
                Y = Features(:, :, Sess2Sel);
                X = repmat(DesMat, size(Y, 3), 1);

                Y = shiftdim(Y, 1);
                Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

                BetaCrossSide{hs, iCV}(:, :, iCdt) = pinv(X) * Y;
            end

            clear Features Beta2Sel X Y Mapping iBeta iSess;

        end

        clear iCdt;

        %% Run GLMs for cross-sensory
        fprintf('\n  Cross sensory\n');
        Cond_con_name = { ...
                         'Contra_A-V', 'Contra_A-T', 'Contra_V-T', ...
                         'Ipsi_A-V', 'Ipsi_A-T', 'Ipsi_V-T'};

        if hs == 1
            Cond2Contrast = { ...
                             2, 4; ...
                             2, 6; ...
                             4, 6; ...
                             1, 3; ...
                             1, 5; ...
                             3, 5};
        elseif hs == 2
            Cond2Contrast = { ...
                             1, 3; ...
                             1, 5; ...
                             3, 5; ...
                             2, 4; ...
                             2, 6; ...
                             4, 6};
        end

        for iCdt = 1:size(Cond2Contrast, 1)

            fprintf('   %s\n', Cond_con_name{iCdt});

            Beta2Sel = [];
            Beta2Sel2 = [];

            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name, 'sub-06') && iSess == 17 && any(iCdt == [1 2 4 5])
                else
                    Beta2Sel = [Beta2Sel; find(strcmp(cellstr(BetaNames), ...
                                                      ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt, 1}}  '*bf(1)']))];

                    Beta2Sel2 = [Beta2Sel2; find(strcmp(cellstr(BetaNames), ...
                                                        ['Sn(' num2str(iSess) ') ' CondNames{Cond2Contrast{iCdt, 2}}  '*bf(1)']))];
                end
            end

            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            Beta2Sel2 = find(ismember(BetaOfInterest, Beta2Sel2));

            Features = AllMapping(:, :, Beta2Sel) - ...
                AllMapping(:, :, Beta2Sel2);

            % Run the "cross-validation"
            for iCV = 1:numel(CVs)

                Sess2Sel = CVs{iCV};
                if strcmp(SubLs(iSub).name, 'sub-06') && any(iCdt == [1 2 4 5])
                    Sess2Sel(Sess2Sel == 17) = [];
                    Sess2Sel(Sess2Sel > 16) = Sess2Sel(Sess2Sel > 16) - 1;
                end

                % Change or adapt dimensions for GLM
                Y = Features(:, :, Sess2Sel);
                X = repmat(DesMat, size(Y, 3), 1);

                Y = shiftdim(Y, 1);
                Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

                BetaCrossSens{hs, iCV}(:, :, iCdt) = pinv(X) * Y;
            end

            clear Features Beta2Sel B X Y Mapping iBeta iSess;

        end

        clear iCdt;

    end

    cd(StartDir);

    %% Profiles Stim = f(Stim)
    Cdt_ROI_lhs = 1:6;
    Cdt_ROI_rhs = [2 1 4 3 6 5];

    Cdt = combnk(1:6, 2);

    fprintf('\n Stim = f(Stim)\n');

    for iToPlot = 1:numel(ToPlot)
        for iCdt = 1:size(Cdt, 1)
            for iCV = 1:numel(CVs)

                % Sorting varibles
                X_lh = nan(1, NbVertex(1));
                X_lh(1, VertexWithDataHS{1}) = BetaCdt{1, iCV}(iToPlot, :, Cdt(iCdt, 1));
                X_rh = nan(1, NbVertex(2));
                X_rh(1, VertexWithDataHS{2}) = BetaCdt{2, iCV}(iToPlot, :, Cdt(iCdt, 1));

                % Variables to sort
                Y_lh = nan(1, NbVertex(1));
                Y_lh(1, VertexWithDataHS{1}) = mean([ ...
                                                     BetaCdt{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCdt{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);
                Y_rh = nan(1, NbVertex(2));
                Y_rh(1, VertexWithDataHS{2}) = mean([ ...
                                                     BetaCdt{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCdt{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);

                for iROI = 1:numel(ROI)

                    X = [X_lh(ROI(iROI).VertOfInt{1}) X_rh(ROI(iROI).VertOfInt{2})];
                    Y = [Y_lh(ROI(iROI).VertOfInt{1}) Y_rh(ROI(iROI).VertOfInt{2})];

                    ToRemove = cat(1, isnan(X), X == 0, isnan(Y), Y == 0);
                    ToRemove = any(ToRemove);
                    X(ToRemove) = [];
                    Y(ToRemove) = [];

                    R = corrcoef(X, Y);
                    Rho_Stim{iToPlot, iCdt, iROI}(iCV) = R(1, 2);
                    beta = glmfit(X, Y, 'normal');
                    Slope_Stim{iToPlot, iCdt, iROI}(iCV) = beta(2);

                    clear X Y;
                end
                clear Y_rh Y_lh X_rh X_lh;
            end
        end
    end

    %% Raster Contra-Ipsi = f(Stim)
    sets = {1:6, 1:3};
    [x, y] = ndgrid(sets{:});
    Cdt = [x(:) y(:)];
    clear x y sets;

    fprintf(' Contra-Ipsi = f(Stim)\n');

    for iToPlot = 1:numel(ToPlot)
        for iCdt = 1:size(Cdt, 1)
            for iCV = 1:numel(CVs)

                % Sorting varibles
                X_lh = nan(1, NbVertex(1));
                X_lh(1, VertexWithDataHS{1}) = BetaCdt{1, iCV}(iToPlot, :, Cdt_ROI_lhs(Cdt(iCdt, 1))); %#ok<*PFBNS>
                X_rh = nan(1, NbVertex(2));
                X_rh(1, VertexWithDataHS{2}) = BetaCdt{2, iCV}(iToPlot, :, Cdt_ROI_rhs(Cdt(iCdt, 1)));

                % Variables to sort
                Y_lh = nan(1, NbVertex(1));
                Y_lh(1, VertexWithDataHS{1}) = mean([ ...
                                                     BetaCrossSide{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSide{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);
                Y_rh = nan(1, NbVertex(2));
                Y_rh(1, VertexWithDataHS{2}) = mean([ ...
                                                     BetaCrossSide{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSide{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);

                for iROI = 1:numel(ROI)

                    X = [X_lh(ROI(iROI).VertOfInt{1}) X_rh(ROI(iROI).VertOfInt{2})];
                    Y = [Y_lh(ROI(iROI).VertOfInt{1}) Y_rh(ROI(iROI).VertOfInt{2})];

                    ToRemove = cat(1, isnan(X), X == 0, isnan(Y), Y == 0);
                    ToRemove = any(ToRemove);
                    X(ToRemove) = [];
                    Y(ToRemove) = [];

                    R = corrcoef(X, Y);
                    Rho_CrossSide_fStim{iToPlot, iCdt, iROI}(iCV) = R(1, 2);
                    beta = glmfit(X, Y, 'normal');
                    Slope_CrossSide_fStim{iToPlot, iCdt, iROI}(iCV) = beta(2);

                    clear X Y;
                end
                clear Y_rh Y_lh X_rh X_lh;
            end
        end
    end

    %% Raster Cross Sens = f(Stim)
    A = repmat(1:6, 6, 1);
    Cdt = [A(:), repmat((1:6)', 6, 1)];

    fprintf(' Sens = f(Stim)\n');

    for iToPlot = 1:numel(ToPlot)
        for iCdt = 1:size(Cdt, 1)
            for iCV = 1:numel(CVs)

                % Sorting variables
                X_lh = nan(1, NbVertex(1));
                X_lh(1, VertexWithDataHS{1}) = BetaCdt{1, iCV}(iToPlot, :, Cdt_ROI_lhs(Cdt(iCdt, 1))); %#ok<*PFBNS>
                X_rh = nan(1, NbVertex(2));
                X_rh(1, VertexWithDataHS{2}) = BetaCdt{2, iCV}(iToPlot, :, Cdt_ROI_rhs(Cdt(iCdt, 1)));

                % Variables to sort
                Y_lh = nan(1, NbVertex(1));
                Y_lh(1, VertexWithDataHS{1}) = mean([ ...
                                                     BetaCrossSens{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSens{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);
                Y_rh = nan(1, NbVertex(2));
                Y_rh(1, VertexWithDataHS{2}) = mean([ ...
                                                     BetaCrossSens{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSens{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);

                for iROI = 1:numel(ROI)

                    X = [X_lh(ROI(iROI).VertOfInt{1}) X_rh(ROI(iROI).VertOfInt{2})];
                    Y = [Y_lh(ROI(iROI).VertOfInt{1}) Y_rh(ROI(iROI).VertOfInt{2})];

                    ToRemove = cat(1, isnan(X), X == 0, isnan(Y), Y == 0);
                    ToRemove = any(ToRemove);
                    X(ToRemove) = [];
                    Y(ToRemove) = [];

                    R = corrcoef(X, Y);
                    Rho_CrossSens_fStim{iToPlot, iCdt, iROI}(iCV) = R(1, 2);
                    beta = glmfit(X, Y, 'normal');
                    Slope_CrossSens_fStim{iToPlot, iCdt, iROI}(iCV) = beta(2);

                    clear X Y;
                end
                clear Y_rh Y_lh X_rh X_lh;
            end
        end
    end

    %% ipsi-contra sense A = f(ipsi-contra sense B)
    A = repmat(1:3, 3, 1);
    Cdt = [A(:), repmat((1:3)', 3, 1)];

    fprintf(' ipsi-contra sense A = f(ipsi-contra sense B)\n');

    for iToPlot = 1:numel(ToPlot)
        for iCdt = 1:size(Cdt, 1)
            for iCV = 1:numel(CVs)

                % Sorting variables
                X_lh = nan(1, NbVertex(1));
                X_lh(1, VertexWithDataHS{1}) = BetaCrossSide{1, iCV}(iToPlot, :, Cdt(iCdt, 1));
                X_rh = nan(1, NbVertex(2));
                X_rh(1, VertexWithDataHS{2}) = BetaCrossSide{2, iCV}(iToPlot, :, Cdt(iCdt, 1));

                % Variables to sort
                Y_lh = nan(1, NbVertex(1));
                Y_lh(1, VertexWithDataHS{1}) = mean([ ...
                                                     BetaCrossSide{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSide{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);
                Y_rh = nan(1, NbVertex(2));
                Y_rh(1, VertexWithDataHS{2}) = mean([ ...
                                                     BetaCrossSide{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSide{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);

                for iROI = 1:numel(ROI)

                    X = [X_lh(ROI(iROI).VertOfInt{1}) X_rh(ROI(iROI).VertOfInt{2})];
                    Y = [Y_lh(ROI(iROI).VertOfInt{1}) Y_rh(ROI(iROI).VertOfInt{2})];

                    ToRemove = cat(1, isnan(X), X == 0, isnan(Y), Y == 0);
                    ToRemove = any(ToRemove);
                    X(ToRemove) = [];
                    Y(ToRemove) = [];

                    R = corrcoef(X, Y);
                    Rho_CrossSide_fCrossSide{iToPlot, iCdt, iROI}(iCV) = R(1, 2);
                    beta = glmfit(X, Y, 'normal');
                    Slope_CrossSide_fCrossSide{iToPlot, iCdt, iROI}(iCV) = beta(2);

                    clear X Y;
                end
                clear Y_rh Y_lh X_rh X_lh;
            end
        end
    end

    %% cross-sensory = f(cross-sensory)
    A = repmat(1:6, 6, 1);
    Cdt = [A(:), repmat((1:6)', 6, 1)];

    fprintf(' cross-sensory ipsi = f(cross-sensory contra)\n');

    for iToPlot = 1:numel(ToPlot)
        for iCdt = 1:size(Cdt, 1)
            for iCV = 1:numel(CVs)

                % Sorting varibles
                X_lh = nan(1, NbVertex(1));
                X_lh(1, VertexWithDataHS{1}) = BetaCrossSens{1, iCV}(iToPlot, :, Cdt(iCdt, 1));
                X_rh = nan(1, NbVertex(2));
                X_rh(1, VertexWithDataHS{2}) = BetaCrossSens{2, iCV}(iToPlot, :, Cdt(iCdt, 1));

                % Varibles to sort
                Y_lh = nan(1, NbVertex(1));
                Y_lh(1, VertexWithDataHS{1}) = mean([ ...
                                                     BetaCrossSens{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSens{1, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);
                Y_rh = nan(1, NbVertex(2));
                Y_rh(1, VertexWithDataHS{2}) = mean([ ...
                                                     BetaCrossSens{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                                     BetaCrossSens{2, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2))]);

                for iROI = 1:numel(ROI)

                    X = [X_lh(ROI(iROI).VertOfInt{1}) X_rh(ROI(iROI).VertOfInt{2})];
                    Y = [Y_lh(ROI(iROI).VertOfInt{1}) Y_rh(ROI(iROI).VertOfInt{2})];

                    ToRemove = cat(1, isnan(X), X == 0, isnan(Y), Y == 0);
                    ToRemove = any(ToRemove);
                    X(ToRemove) = [];
                    Y(ToRemove) = [];

                    R = corrcoef(X, Y);
                    Rho_CrossSens_fCrossSens{iToPlot, iCdt, iROI}(iCV) = R(1, 2);
                    beta = glmfit(X, Y, 'normal');
                    Slope_CrossSens_fCrossSens{iToPlot, iCdt, iROI}(iCV) = beta(2);

                    clear X Y;
                end
                clear Y_rh Y_lh X_rh X_lh;
            end
        end
    end

    %%
    save(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'correlations', [SubLs(iSub).name '-SurfCorrelation.mat']), ...
         'ROI', ...
         'Rho_Stim', 'Slope_Stim', 'Rho_CrossSide_fStim', ...
         'Slope_CrossSide_fStim', 'Rho_CrossSens_fStim', ....
         'Slope_CrossSens_fStim', 'Rho_CrossSide_fCrossSide', ...
         'Slope_CrossSide_fCrossSide', 'Rho_CrossSens_fCrossSens', 'Slope_CrossSens_fCrossSens');

    clear BetaCdt BetaCrossSide BetaCrossSens ...
        Rho_Stim Slope_Stim Rho_CrossSide_fStim ...
        Slope_CrossSide_fStim Rho_CrossSens_fStim ...
        Slope_CrossSens_fStim Rho_CrossSide_fCrossSide ...
        Slope_CrossSide_fCrossSide Rho_CrossSens_fCrossSens Slope_CrossSens_fCrossSens;
end

cd(StartDir);
