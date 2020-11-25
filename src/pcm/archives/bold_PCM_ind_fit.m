clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox\');

surf = 0; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 1;

print = 0;

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

MaxIteration = 50000;

if surf
    %     ToPlot={'Cst','Lin','Quad'};
    ToPlot = {'Cst'};
    Output_dir = 'surf';
else
    ToPlot = {'ROI'}; %#ok<*UNRCH>
    Output_dir = 'vol';
    if raw
        if hs_idpdt
            Save_suffix = 'raw_betas';
        else
            Save_suffix = 'beta-raw';
        end
    else
        if hs_idpdt
            Save_suffix = 'whitened_betas';
        else
            Save_suffix = 'beta-wht';
        end
    end
end

if raw
    Beta_suffix = 'raw-betas';
else
    Beta_suffix = 'wht-betas';
end

if hs_idpdt
    hs_suffix = {'LHS' 'RHS'};
else
    hs_suffix = {''};
end

ColorMap = brain_colour_maps('hot_increasing'); %#ok<*NASGU>
FigDim = [100, 100, 1000, 1500];

PCM_dir = fullfile(StartDir, 'figures', 'PCM');
mkdir(PCM_dir);
mkdir(PCM_dir, 'Cdt');

Save_dir = fullfile(StartDir, 'results', 'PCM', Output_dir);
mkdir(Save_dir);

%% Build the models
close all;
M_A = Set_PCM_models_feature(1);
if print
    fig_h = Plot_PCM_models_feature(M_A);
    for iFig = 1:numel(fig_h)
        print(fig_h(iFig), fullfile(PCM_dir, ...
                                    ['Model-' num2str(iFig) '-' strrep(strrep(fig_h(iFig).Name, 'w/', ''), ' ', '') '_A.tif']), ...
              '-dtiff');
    end
end

close all;
M_V = Set_PCM_models_feature(2);
if print
    fig_h = Plot_PCM_models_feature(M_V);
    for iFig = 1:numel(fig_h)
        print(fig_h(iFig), fullfile(PCM_dir, ...
                                    ['Model-' num2str(iFig) '-' strrep(strrep(fig_h(iFig).Name, 'w/', ''), ' ', '') '_V.tif']), ...
              '-dtiff');
    end
end

clear fig_h;

%% Loading data

fprintf('Loading data\n');

% Loads which runs happened on which day to set up the CVs
load(fullfile(StartDir, 'RunsPerSes.mat'));
% to know how many ROIs we have
if surf
    load(fullfile(StartDir, 'sub-02', 'roi', 'surf', 'sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex');
else
    if hs_idpdt
        ROI(1).name = 'V1_thres';
        ROI(2).name = 'V2_thres';
        ROI(3).name = 'V3_thres';
        ROI(4).name = 'V4_thres';
        ROI(5).name = 'V5_thres';
        ROI(6).name = 'A1';
        ROI(7).name = 'PT';
    else
        ROI(1).name = 'A1';
        ROI(2).name = 'PT';
        ROI(3).name = 'V1_thres';
        ROI(4).name = 'V2_thres';
        ROI(5).name = 'V3_thres';
        ROI(6).name = 'V4_thres';
        ROI(7).name = 'V5_thres';
    end
end

for iSub = 1:NbSub

    fprintf(' Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);

    load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'));
    Nb_sess(iSub) = numel(SPM.Sess);   %#ok<*SAGROW>
    clear SPM;

    % Which session belings to which day (for day based CV)
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    tmp = RunPerSes(Idx).RunsPerSes;
    DayCVs{iSub} = { ...
                    1:tmp(1), ...
                    tmp(1) + 1:tmp(1) + tmp(2), ...
                    tmp(1) + tmp(2) + 1:sum(tmp)};
    clear Idx;

    % load data
    if surf == 1 && raw == 0
        load(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'PCM', 'Data_PCM.mat'), 'PCM_data');
    else
        if hs_idpdt
            load(fullfile(Sub_dir, 'results', 'rsa', 'vol', [SubLs(iSub).name '_data_' Save_suffix '.mat']), 'Features');
            for iROI = 1:numel(ROI)
                for ihs = 1:numel(hs_suffix)
                    PCM_data{1, iROI, ihs} = Features{iROI, ihs};
                end
            end
            clear Features;
        else
            load(fullfile(Sub_dir, 'results', 'PCM', 'vol', ['Data_PCM_' Save_suffix '.mat']), 'PCM_data');
        end
    end

    for iToPlot = 1:numel(ToPlot)
        for iROI = 1:numel(ROI)
            for ihs = 1:numel(hs_suffix)
                Grp_PCM_data{iToPlot, iROI, iSub, ihs} = PCM_data{iToPlot, iROI, ihs};
            end
        end
    end
end

%% Stim VS Stim
fprintf('Running PCM\n');

for iToPlot = 1:numel(ToPlot)

    for Target = 1

        if Target == 2
            Stim_suffix = 'targ';
            CondNames = { ...
                         'ATargL', 'ATargR', ...
                         'VTargL', 'VTargR', ...
                         'TTargL', 'TTargR' ...
                        };
        else
            Stim_suffix = 'stim';
            CondNames = { ...
                         'A ipsi', 'A contra', ...
                         'V ipsi', 'V contra', ...
                         'T ipsi', 'T contra' ...
                        };
        end

        for iROI = 2:numel(ROI)

            fprintf('\n %s\n', ROI(iROI).name);

            Y = {};
            condVec = {};
            partVec = {};

            %% Preparing data
            for iSub = 1:NbSub

                for ihs = 1:numel(hs_suffix)

                    Data = Grp_PCM_data{iToPlot, iROI, iSub, ihs};

                    %% Create partition and condition vector
                    if surf
                        conditionVec = repmat((1:numel(CondNames))', Nb_sess(iSub), 1);

                        partitionVec = repmat(1:Nb_sess(iSub), numel(CondNames), 1);
                        partitionVec = partitionVec(:);
                        if iSub == 5
                            error('Not implemented');
                        end

                    else

                        if ~hs_idpdt
                            conditionVec = repmat(1:size(CondNames, 2), Nb_sess(iSub), 1);
                            conditionVec = conditionVec(:);

                            partitionVec = repmat((1:Nb_sess(iSub))', size(CondNames, 2), 1);

                            if iSub == 5
                                ToRemove = all([conditionVec < 3 partitionVec == 17], 2);

                                partitionVec(ToRemove) = [];
                                conditionVec(ToRemove) = [];
                            end

                        else
                            conditionVec = repmat(1:numel(CondNames) * 2, Nb_sess(iSub), 1);
                            conditionVec = conditionVec(:);

                            partitionVec = repmat((1:Nb_sess(iSub))', numel(CondNames) * 2, 1);

                            if iSub == 5
                                ToRemove = all([any([conditionVec < 3 conditionVec == 6 conditionVec == 7], 2) partitionVec == 17], 2);

                                partitionVec(ToRemove) = [];
                                conditionVec(ToRemove) = [];
                            end

                            if Target == 1
                                conditionVec(conditionVec > 6) = 0;
                            else
                                conditionVec(conditionVec < 7) = 0;
                                conditionVec(conditionVec > 6) = conditionVec(conditionVec > 6) - 6;
                            end

                        end

                    end

                    %% Get just the right data
                    if surf
                        error('not implemented');
                    else
                        if ~hs_idpdt
                            if iSub == 5 % subject 06 has some condition missing for one session
                                if Target == 1
                                    X_temp = Data(1:(numel(CondNames) * Nb_sess(iSub) - 2), :);
                                else
                                    X_temp = Data(1 + (numel(CondNames) * Nb_sess(iSub) - 2):end, :);
                                end
                            else
                                if Target == 1
                                    X_temp = Data(1:numel(CondNames) * Nb_sess(iSub), :);
                                else
                                    X_temp = Data(1 + numel(CondNames) * Nb_sess(iSub):end, :);
                                end
                            end

                        else
                            % remove condition of no interests
                            X_temp = Data;
                            clear Data;
                            X_temp(conditionVec == 0, :) = [];
                            partitionVec(conditionVec == 0, :) = [];
                            conditionVec(conditionVec == 0, :) = [];

                        end
                    end

                    %% Remove nans
                    if any(all(isnan(X_temp), 2))
                        warning('We have some NaNs issue.');
                        partitionVec(all(isnan(X_temp), 2)) = [];
                        conditionVec(all(isnan(X_temp), 2)) = [];
                        X_temp(all(isnan(X_temp), 2), :) = [];
                    end
                    X_temp(:, any(isnan(X_temp))) = [];

                    %% check that we have the same number of conditions in each  partition
                    A = tabulate(partitionVec);
                    A = A(:, 1:2);
                    if numel(unique(A(:, 2))) > 1
                        warning('We have different numbers of conditions in at least one partition.');
                        Sess2Remove = find(A(:, 2) < numel(unique(conditionVec)));
                        conditionVec(ismember(partitionVec, Sess2Remove)) = [];
                        X_temp(ismember(partitionVec, Sess2Remove), :) = [];
                        partitionVec(ismember(partitionVec, Sess2Remove)) = [];
                        Sess2Remove = [];
                    end

                    if any([numel(conditionVec) numel(partitionVec)] ~= size(X_temp, 1))
                        error('Data matrix or condition or partition vector might be off.');
                    end

                    %% Stores each subject
                    Y{iSub, ihs} = X_temp;
                    condVec{iSub} = conditionVec;
                    partVec{iSub} = partitionVec;

                    % Average across sessions
                    Cdts = unique(conditionVec);
                    X_temp_avg = [];
                    for iCdt = 1:numel(Cdts)
                        X_temp_avg(end + 1, :) = mean(X_temp(conditionVec == Cdts(iCdt), :));
                    end
                    Y_avg{iSub, ihs} = X_temp_avg;

                end
            end

            %% plot data, compute CVed G-matrix, do multidimensional scaling
            fprintf('\n  Plotting data and computing G matrices\n');

            G_hat = [];

            close all;

            for iSub = 1:size(Y, 1)

                for ihs = 1:numel(hs_suffix)

                    %%
                    if print
                        fig_h = figure('name', [SubLs(iSub).name '-' strrep(ROI(iROI).name, '_', ' ') '-' hs_suffix{ihs}], ...
                                       'Position', FigDim, 'Color', [1 1 1]);

                        colormap(seismic(1000));

                        Subplot = 1;

                        subplot(1, 2, Subplot);

                        Data = Y{iSub, ihs};
                        [~, I] = sort(mean(Data));
                        Data = Data(:, I);
                        imagesc(imgaussfilt(Data, [.001 50]), [-.5 .5]);
                        title('Y as f(mean(act))');
                        colorbar;
                        set(gca, 'Xtick', [], 'Yticklabel', [], 'tickdir', 'out');

                        Subplot = Subplot + 1;

                        subplot(1, 2, Subplot);
                        YY = Data * Data';
                        MAX = min(abs([max(YY(:)) min(YY(:))]));
                        imagesc(YY, [MAX * -1 MAX]);
                        hold on;
                        title('Y*Y^T');
                        colorbar;
                        set(gca, 'Xtick', [], 'Yticklabel', [], 'tickdir', 'out');

                        Subplot = Subplot + 1;

                        mtit(fig_h.Name, 'fontsize', 12, 'xoff', 0, 'yoff', .05);

                        clear Data;
                    end
                    %%
                    G_hat(:, :, iSub, ihs) = pcm_estGCrossval(Y{iSub, ihs}, partVec{iSub}, condVec{iSub});

                    G(:, :, iSub, ihs) = Y_avg{iSub, ihs} * Y_avg{iSub, ihs}' / size(Y_avg{iSub, ihs}, 2); % with no CV.

                end

                Gm = mean(G_hat(:, :, :, ihs), 3); % Mean estimate

                C = pcm_indicatorMatrix('allpairs', (1:numel(CondNames))');

                COORD(:, :, ihs) = pcm_classicalMDS(Gm, 'contrast', C);

            end

            %% Get RSA
            fprintf('\n  Computing RDM\n');

            for iSub = 1:size(Y, 1)
                for ihs = 1:numel(hs_suffix)

                    %%
                    % compute RSA distances (A --> B) in a cross validated fashion
                    A =  rsa.distanceLDC(Y{iSub, ihs}, partVec{iSub}, condVec{iSub});

                    % because when doing cross validation distance A --> B can be different
                    % from B-->A we recompute the RSA in the other direction and take the
                    % mean of both directions

                    % compute RSA distances (B --> A) in a cross validated fashion
                    % flipup the data and the partition vector means that condition label
                    % used to be 1:6 is now 6:-1:1
                    B =  rsa.distanceLDC(flipud(Y{iSub, ihs}), flipud(partVec{iSub}), condVec{iSub});
                    % flip the distance back
                    B = fliplr(B);
                    B = [B(1:2) B(4) B(7) B(11) B(3) B(5) B(8) B(12) B(6) B(9) B(13) B(10) B(14:15)];
                    % take the mean
                    RDMs_CV(:, :, iSub, ihs) = squareform(mean([A; B]));

                    RDMs(:, :, iSub, ihs) = squareform(pdist(Y_avg{iSub, ihs}));

                end
            end

            %% Run the PCM
            %             try

            if ROI(iROI).name(1) == 'V'
                M = M_V;
            else
                M = M_A;
            end

            % Treat the run effect as random or fixed?
            % We are using a fixed run effect here, as we are not interested in the
            % activity relative the the baseline (rest) - so as in RSA, we simply
            % subtract out the mean patttern across all conditions.
            runEffect  = 'fixed';

            for ihs = 1:numel(hs_suffix)

                fprintf('\n\n  Running %s\n\n', hs_suffix{ihs});

                for iSub = 1:size(Y, 1)
                    Data{1, iSub} = Y{iSub, ihs};
                end

                fprintf('\n\n  Running PCM_ind\n\n');
                [T_ind{ihs}, theta_ind{ihs}, G_pred_ind{ihs}] = pcm_fitModelIndivid(Data, M, partVec, condVec, 'runEffect', runEffect, 'MaxIteration', MaxIteration);

                [D{ihs}, T_ind_cross{ihs}, theta_ind_cross{ihs}] = pcm_fitModelIndividCrossval(Data, M, partVec, condVec, 'runEffect', runEffect, 'MaxIteration', MaxIteration);

                % Fit the models on the group level
                fprintf('\n\n  Running PCM_grp\n\n');
                [T_group{ihs}, theta_gr{ihs}, G_pred_gr{ihs}] = pcm_fitModelGroup(Data, M, partVec, condVec, 'runEffect', runEffect, 'fitScale', 1);

                % Fit the models through cross-subject crossvalidation
                fprintf('\n\n  Running PCM_grp_cv\n\n');
                [T_cross{ihs}, theta_cr{ihs}, G_pred_cr{ihs}] = pcm_fitModelGroupCrossval(Data, M, partVec, condVec, 'runEffect', runEffect, 'groupFit', ...
                                                                                          theta_gr{ihs}, 'fitScale', 1, 'MaxIteration', MaxIteration);

            end

            %% Save
            save(fullfile('/data', sprintf('PCM_features_%s_%s_%s_%s_%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, ...
                                           ToPlot{iToPlot}, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                 'M', 'partVec', 'condVec', 'G', 'G_hat', 'COORD', 'RDMs_CV', 'RDMs', ...
                 'T_ind', 'theta_ind', 'G_pred_ind', ...
                 'D', 'T_ind_cross', 'theta_ind_cross', ...
                 'T_group', 'theta_gr', 'G_pred_gr', ...
                 'T_cross', 'theta_cr', 'G_pred_cr');

            %                 save(fullfile(Save_dir, sprintf('PCM_features_%s_%s_%s_%s_%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, ...
            %                     ToPlot{iToPlot}, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
            %                     'M', 'partVec', 'condVec', 'G', 'G_hat', 'COORD', 'RDMs_CV', 'RDMs',...
            %                     'T_group','theta_gr','G_pred_gr',...
            %                     'T_cross','theta_cr','G_pred_cr' )

            subject = sprintf('Analysis PCM %s %s done', ToPlot{iToPlot}, ROI(iROI).name);
            matlabmail('remi_gau@hotmail.com', 'Analysis done', subject);

            %             catch ME
            %                 save(fullfile(Save_dir,['ME_' ROI(iROI).name '.mat']),'ME')
            %                 subject = sprintf('Analysis PCM %s %s failed', ToPlot{iToPlot}, ROI(iROI).name);
            %                 matlabmail('remi_gau@hotmail.com', 'Analysis failed', subject, fullfile(Save_dir,['ME_' ROI(iROI).name '.mat']));
            %             end

        end

    end
end
