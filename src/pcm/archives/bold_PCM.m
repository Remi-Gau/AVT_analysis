clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox\');

surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0; % only implemented for volume

Do_ind = 0;
Do_group = 1;

Do_additional_models = 1;
if Do_additional_models
    Add_models_suffix = '-More_models';
else
    Add_models_suffix = '';
end

Split_half = 0; % only implemented for surface
if Split_half == 1
    NbSplits = 2;
else
    NbSplits = 1;
end

print_figs = 0;

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

MaxIteration = 50000;
runEffect  = 'fixed';

ColorMap = seismic(1000); %#ok<*NASGU>
FigDim = [100, 100, 1000, 700];

if surf
    ToPlot = {'Cst', 'Lin', 'Avg', 'ROI'};
    Output_dir = 'surf';
else
    ToPlot = {'ROI'}; %#ok<*UNRCH>
    Output_dir = 'vol';
    if raw
        Save_suffix = 'raw_betas';
    else
        Save_suffix = 'whitened_betas';
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
    hs_suffix = {'LRHS'};
end

PCM_dir = fullfile(StartDir, 'figures', 'PCM');
mkdir(PCM_dir);
mkdir(PCM_dir, 'Cdt');

Save_dir = fullfile(StartDir, 'results', 'PCM', Output_dir);
mkdir(Save_dir);

%% Build the models
fprintf('Building models\n');

if Do_additional_models
    M_A = Set_PCM_models_feature_2;
else
    M_A = Set_PCM_models_feature(1);
end

if 1 % print_figs
    fig_h = Plot_PCM_models_feature(M_A);
    for iFig = 1:numel(fig_h)
        print(fig_h(iFig), fullfile(PCM_dir, ...
                                    ['Model-' num2str(iFig) '-' strrep(strrep(fig_h(iFig).Name, 'w/', ''), ' ', '') '_A.tif']), ...
              '-dtiff');
    end
end
close all;

if Do_additional_models
    M_V = Set_PCM_models_feature_2;
else
    M_V = Set_PCM_models_feature(0);
end
if 0 % print_figs
    fig_h = Plot_PCM_models_feature(M_V);
    for iFig = 1:numel(fig_h)
        print(fig_h(iFig), fullfile(PCM_dir, ...
                                    ['Model-' num2str(iFig) '-' strrep(strrep(fig_h(iFig).Name, 'w/', ''), ' ', '') '_V.tif']), ...
              '-dtiff');
    end
end
clear fig_h;
close all;

%% Define ROI
fprintf('Define ROI\n');

% to know how many ROIs we have
if surf
    load(fullfile(StartDir, 'sub-02', 'roi', 'surf', 'sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex');
else
    ROI(1).name = 'V1_thres';
    ROI(2).name = 'V2_thres';
    ROI(3).name = 'V3_thres';
    ROI(4).name = 'V4_thres';
    ROI(5).name = 'V5_thres';
    ROI(6).name = 'A1';
    ROI(7).name = 'PT';
end

%% Start
fprintf('Get started\n');

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

        %% Create partition and condition vector
        for iSub = 1:NbSub

            Sub_dir = fullfile(StartDir, SubLs(iSub).name);

            load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'));
            Nb_sess(iSub) = numel(SPM.Sess);   %#ok<*SAGROW>
            clear SPM;

            conditionVec = repmat(1:numel(CondNames) * 2, Nb_sess(iSub), 1);
            conditionVec = conditionVec(:);

            partitionVec = repmat((1:Nb_sess(iSub))', numel(CondNames) * 2, 1);

            if ~surf && iSub == 5
                % remove lines corresponding to auditory stim and
                % targets for sub-06
                ToRemove = all([any([conditionVec < 3 conditionVec == 7 conditionVec == 8], 2) partitionVec == 17], 2);

                partitionVec(ToRemove) = [];
                conditionVec(ToRemove) = [];
            end

            if surf && iSub == 5 && iToPlot == 4
                % remove lines corresponding to auditory stim and
                % targets for sub-06
                ToRemove = all([any([conditionVec < 3 conditionVec == 7 conditionVec == 8], 2) partitionVec == 17], 2);

                partitionVec(ToRemove) = [];
                conditionVec(ToRemove) = [];
            end

            if Target == 1
                conditionVec(conditionVec > 6) = 0;
            else
                conditionVec(conditionVec < 7) = 0;
                conditionVec(conditionVec > 6) = conditionVec(conditionVec > 6) - 6;
            end

            partitionVec_ori{iSub} = partitionVec;
            conditionVec_ori{iSub} = conditionVec;
        end

        %%
        for iROI =  1:4 % :numel(ROI)

            fprintf('\n %s\n', ROI(iROI).name);

            Y = {};
            condVec = {};
            partVec = {};

            clear G_hat G Gm COORD;

            for ihs = 1:numel(hs_suffix)

                fprintf('\n %s\n', hs_suffix{ihs});

                for iSub = 1:NbSub

                    fprintf(' Loading %s\n', SubLs(iSub).name);

                    Sub_dir = fullfile(StartDir, SubLs(iSub).name);

                    partitionVec =  partitionVec_ori{iSub};
                    conditionVec = conditionVec_ori{iSub};

                    %% load data
                    if surf == 1 && raw == 0 && iToPlot < 4
                        load(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'PCM', 'Data_PCM.mat'), 'PCM_data');
                        tmp = PCM_data{iToPlot, iROI, 2};
                        for i = 1:2:12
                            tmp(conditionVec == i, :) = PCM_data{iToPlot, iROI, 2}(conditionVec == (i + 1), :);
                        end
                        for i = 2:2:12
                            tmp(conditionVec == i, :) = PCM_data{iToPlot, iROI, 2}(conditionVec == (i - 1), :);
                        end
                        Data = [PCM_data{iToPlot, iROI, 1} tmp];
                        clear tmp;

                        if Split_half
                            Nb_vert_L = size(PCM_data{iToPlot, iROI, 1}, 2);
                            Nb_vert_R = size(PCM_data{iToPlot, iROI, 2}, 2);
                        end

                    elseif surf == 1 && raw == 0 && iToPlot == 4
                        load(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'PCM', 'Data_PCM_whole_ROI.mat'), 'PCM_data');
                        tmp = PCM_data{iROI, 2};
                        for i = 1:2:12
                            tmp(conditionVec == i, :) = PCM_data{iROI, 2}(conditionVec == (i + 1), :);
                        end
                        for i = 2:2:12
                            tmp(conditionVec == i, :) = PCM_data{iROI, 2}(conditionVec == (i - 1), :);
                        end
                        Data = [PCM_data{iROI, 1} tmp];

                    elseif surf == 1 && raw == 1
                        error('not implemented');

                    else
                        load(fullfile(Sub_dir, 'results', 'rsa', 'vol', [SubLs(iSub).name '_data_' Save_suffix '.mat']), 'Features');
                        if hs_idpdt
                            Data = Features{iROI, ihs};
                        else
                            tmp = Features{iROI, 2};
                            for i = 1:2:12
                                tmp(conditionVec == i, :) = Features{iROI, 2}(conditionVec == (i + 1), :);
                            end
                            for i = 2:2:12
                                tmp(conditionVec == i, :) = Features{iROI, 2}(conditionVec == (i - 1), :);
                            end
                            Data = [Features{iROI, 1} tmp];
                        end
                        clear Features;
                    end

                    %% Get just the right data
                    X_temp = Data;
                    clear Data;
                    X_temp(conditionVec == 0, :) = [];
                    partitionVec(conditionVec == 0, :) = [];
                    conditionVec(conditionVec == 0, :) = [];

                    %% Remove nans
                    ToRemove = find(any(isnan(X_temp)));
                    X_temp(:, ToRemove) = [];

                    if Split_half
                        Nb_vert_L = Nb_vert_L - numel(ToRemove(ToRemove <= Nb_vert_L));
                        Nb_vert_R = Nb_vert_R - numel(ToRemove(ToRemove > Nb_vert_L));

                        tmp = 1:Nb_vert_L;
                        tmp = tmp(randperm(numel(tmp)));
                        VertL{iSub, 1} = tmp(1:floor(numel(tmp) / 2));
                        VertL{iSub, 2} = tmp((1 + floor(numel(tmp) / 2)):end);
                        clear tmp;

                        tmp = (1:Nb_vert_R) + Nb_vert_L;
                        tmp = tmp(randperm(numel(tmp)));
                        VertR{iSub, 1} = tmp(1:floor(numel(tmp) / 2));
                        VertR{iSub, 2} = tmp((1 + floor(numel(tmp) / 2)):end);
                        clear tmp;
                    end

                    if any(all(isnan(X_temp), 2)) || any(all(X_temp == 0, 2))
                        warning('We have some NaNs issue.');
                        ToRemove = any([all(isnan(X_temp), 2) all(X_temp == 0, 2)], 2);
                        partitionVec(ToRemove) = [];
                        conditionVec(ToRemove) = [];
                        X_temp(ToRemove, :) = [];
                    end

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

                    Y{iSub} = X_temp;
                    condVec{iSub} = conditionVec;
                    partVec{iSub} = partitionVec;

                    % Average across sessions
                    Cdts = unique(conditionVec);
                    X_temp_avg = [];
                    for iCdt = 1:numel(Cdts)
                        X_temp_avg(end + 1, :) = mean(X_temp(conditionVec == Cdts(iCdt), :));
                    end
                    Y_avg{iSub} = X_temp_avg;

                    clear X_temp X_temp_avg;

                    %% plot data
                    if print_figs
                        fprintf('  Plotting data\n');

                        fig_h = figure('name', [SubLs(iSub).name '-' strrep(ROI(iROI).name, '_', ' ') '-' hs_suffix{ihs}], ...
                                       'Position', FigDim, 'Color', [1 1 1]);

                        colormap(ColorMap);

                        Subplot = 1;

                        subplot(1, 2, Subplot);

                        Data = Y{iSub};
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

                        print(fig_h, fullfile(Save_dir, ...
                                              sprintf('Data_%s_%s_%s_%s.tif', ...
                                                      ToPlot{iToPlot}, Stim_suffix, Beta_suffix, strrep(fig_h.Name, ' ', '_'))), ...
                              '-dtiff');

                        clear Data;
                    end
                    clear fig_h;

                    %% Get RSA
                    fprintf('  Computing RDM and empirical G matrices\n\n');

                    for iSplit = 1:NbSplits
                        if Split_half
                            Vert2Take = [VertL{iSub, iSplit} VertR{iSub, iSplit}];
                        else
                            Vert2Take = 1:size(Y{iSub}, 2);
                        end
                        % compute RSA distances (A --> B) in a cross validated fashion
                        A =  rsa.distanceLDC(Y{iSub}(:, Vert2Take), partVec{iSub}, condVec{iSub});

                        % because when doing cross validation distance A --> B can be different
                        % from B-->A we recompute the RSA in the other direction and take the
                        % mean of both directions

                        % compute RSA distances (B --> A) in a cross validated fashion
                        % flipup the data and the partition vector means that condition label
                        % used to be 1:6 is now 6:-1:1
                        B =  rsa.distanceLDC(flipud(Y{iSub}(:, Vert2Take)), flipud(partVec{iSub}), condVec{iSub});
                        % flip the distance back
                        B = fliplr(B);
                        B = [B(1:2) B(4) B(7) B(11) B(3) B(5) B(8) B(12) B(6) B(9) B(13) B(10) B(14:15)];
                        % take the mean
                        RDMs_CV(:, :, iSub, iSplit) = squareform(mean([A; B]));

                        %% Compute CVed G-matrix, do multidimensional scaling
                        G_hat(:, :, iSub, iSplit) = pcm_estGCrossval(Y{iSub}(:, Vert2Take), partVec{iSub}, condVec{iSub});
                        G(:, :, iSub, iSplit) = Y_avg{iSub}(:, Vert2Take) * Y_avg{iSub}(:, Vert2Take)' / size(Y_avg{iSub}(:, Vert2Take), 2); % with no CV.
                    end

                    clear Y_avg;
                end

                %% Run the PCM
                if ROI(iROI).name(1) == 'V'
                    M = M_V;
                else
                    M = M_A;
                end

                Y_ori = Y;

                for iSplit = 1:NbSplits
                    if Split_half
                        clear Y Vert2Take;
                        for iSub = 1:NbSub
                            Vert2Take = [VertL{iSub, iSplit} VertR{iSub, iSplit}];
                            Y{iSub} = Y_ori{iSub}(:, Vert2Take);
                        end
                        Split_suffix = ['Split_' num2str(iSplit)];
                    else
                        Split_suffix = '';
                    end

                    if Do_ind
                        fprintf('\n\n  Running PCM_ind\n\n');
                        try
                            [T_ind, theta_ind, G_pred_ind] = pcm_fitModelIndivid(Y, M, partVec, condVec, 'runEffect', runEffect, 'MaxIteration', MaxIteration);
                            [D, T_ind_cross, theta_ind_cross] = pcm_fitModelIndividCrossval(Y, M, partVec, condVec, 'runEffect', runEffect, 'MaxIteration', MaxIteration);

                            save(fullfile(Save_dir, sprintf('PCM_ind_features_%s_%s_%s_%s_%s_%s_%s%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs}, ...
                                                            ToPlot{iToPlot}, Split_suffix, Add_models_suffix, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                                 'M', 'partVec', 'condVec', 'G', 'G_hat', 'RDMs_CV', ...
                                 'T_ind', 'theta_ind', 'G_pred_ind', ...
                                 'D', 'T_ind_cross', 'theta_ind_cross');
                        catch
                            save(fullfile(Save_dir, sprintf('Failed_PCM_individual_features_%s_%s_%s_%s_%s_%s_%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs}, ...
                                                            ToPlot{iToPlot}, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                                 'M', 'partVec', 'condVec', 'Y');
                        end
                    end

                    if Do_group
                        % Fit the models on the group level
                        fprintf('\n\n  Running PCM_grp\n\n');
                        try
                            [T_group, theta_gr, G_pred_gr] = pcm_fitModelGroup(Y, M, partVec, condVec, 'runEffect', runEffect, 'fitScale', 1);
                            [T_cross, theta_cr, G_pred_cr] = pcm_fitModelGroupCrossval(Y, M, partVec, condVec, 'runEffect', runEffect, 'groupFit', ...
                                                                                       theta_gr, 'fitScale', 1, 'MaxIteration', MaxIteration);

                            % Save
                            save(fullfile(Save_dir, sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs}, ...
                                                            ToPlot{iToPlot}, Split_suffix, Add_models_suffix, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                                 'M', 'partVec', 'condVec', 'G', 'G_hat', 'RDMs_CV', ...
                                 'T_group', 'theta_gr', 'G_pred_gr', ...
                                 'T_cross', 'theta_cr', 'G_pred_cr');

                        catch
                            save(fullfile(Save_dir, sprintf('Failed_PCM_group_features_%s_%s_%s_%s_%s_%s_%s.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs}, ...
                                                            ToPlot{iToPlot}, datestr(now, 'yyyy_mm_dd_HH_MM'))), ...
                                 'M', 'partVec', 'condVec', 'Y');
                        end
                    end

                end

            end

        end
    end

end
