% (C) Copyright 2020 Remi Gau
%% Simulated data dataset for PCM
% Remi Gau adapted from Johanna Zumer, 2017

clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('/home/rxg243/Dropbox/');

Save_dir = fullfile(StartDir, 'results', 'sim', 'PCM');
Fig_dir = fullfile(StartDir, 'figures', 'sim', 'PCM');

NbFeatures = 100;
NbCdt = 6;
NbSess = 20;
NbSubj = 10;

MaxIteration = 50000;

% Z is the design matrix for the activity patterns
% assume 6 conditions with 20 examplars per condition, same for all subjects
Z = zeros(NbSess, NbCdt);
Z(1:NbSess, 1) = 1;
Z(1 + NbSess * 1:NbSess * 2, 2) = 1;
Z(1 + NbSess * 2:NbSess * 3, 3) = 1;
Z(1 + NbSess * 3:NbSess * 4, 4) = 1;
Z(1 + NbSess * 4:NbSess * 5, 5) = 1;
Z(1 + NbSess * 5:NbSess * 6, 6) = 1;

% the desgin matrix for the fixed effects is the same as the one for
% patterns
X = Z;

% B is the beta for the fixed effects (condition means)
% for auditory ROI
B = [5; ... A contra
     5; ... A ipsi
     1; ... V Contra
     1; ... V Ipsi
     2; ... T contra
     2]; % T ipsi

% Average scaling factor (first column) and noise level (second column) for the G matrix
Scale_noise =  [ ...
                100 1; ...
                10 1; ...
                1 1; ...
                0.1 1];

% Generate scaling factor for each subject (distrib around group
% mean)
% take absolute values to make sure we get positive matrices in the end
for sm = 1:size(Scale_noise, 1)
    theta_subj(sm, :, :) =  [ ...
                             abs(Scale_noise(sm, 1) + randn(1, 1, NbSubj) * .1) ...
                             abs(Scale_noise(sm, 2) + rand(1, 1, NbSubj) * 0)];
end

FigDim = [100, 100, 1000, 1500];

%% get the pattern components
%     '1-Sensory modalities'
%     '2-A stim'
%     '3-V stim'
%     '4-T stim'
%     '5-Non Preferred_A'
%     '6-Non Preferred_V'
%     '7-Ipsi Contra'
%     '8-Ipsi Contra_{VT}'
%     '9-Ipsi Contra_{A}'
%     '10-Ipsi Contra_{AT}'
%     '11-Ipsi Contra_{V}'

[Components, h] = Set_PCM_components_RDM(1, FigDim);
if ~isempty(h)
    print(h(1), fullfile(Fig_dir, 'Pattern_components_RDM.tif'), '-dtiff');
    print(h(2), fullfile(Fig_dir, 'Pattern_components_G_matrices.tif'), '-dtiff');
end

%% get the typical models
[Models_A, Models_V, h] = Set_PCM_models(Components, 1, FigDim);
if ~isempty(h)
    print(h(1), fullfile(Fig_dir, 'Models_for_auditory_ROIs.tif'), '-dtiff');
    print(h(2), fullfile(Fig_dir, 'Models_for_visual_ROIs.tif'), '-dtiff');
end

Models = Models_A;

M = {};

colors = {'b'};

% null model
M{1}.type       = 'component';
M{1}.numGparams = 1;
% M{1}.Gc         = eye(NbCdt);
M{1}.Gc         = nearestSPD(zeros(NbCdt));
M{1}.name       = 'null';

% add each model
for iMod = 1:numel(Models)

    M{end + 1}.type       = 'component';

    M{end}.numGparams = numel(Models(iMod).Cpts);

    M{end}.Gc         = cat(3, Components(Models(iMod).Cpts).G);

    tmp = strrep(num2str(Models(iMod).Cpts), '  ', ' ');
    tmp = strrep(tmp, '  ', ' ');
    M{end}.name       = strrep(tmp, ' ', '+');
    clear tmp;

    M{end}.fitAlgorithm = 'minimize';

    colors{end + 1} = 'b';

end

% Free model as Noise ceiling
M{end + 1}.type       = 'freechol';
M{end}.numCond    = NbCdt;
M{end}.name       = 'noiseceiling';
M{end}           = pcm_prepFreeModel(M{end});

%% simulated model weights.
% order of G:
%     '1-Sensory modalities'
%     '2-A stim'
%     '3-V stim'
%     '4-T stim'
%     '5-Non Preferred_A'
%     '6-Non Preferred_V'
%     '7-Ipsi Contra'
%     '8-Ipsi Contra_{VT}'
%     '9-Ipsi Contra_{A}'
%     '10-Ipsi Contra_{AT}'
%     '11-Ipsi Contra_{V}'

theta_real = ones(numel(Models_A), numel(Components)) * -inf;
for iMod = 1:numel(Models_A)
    theta_real(iMod, Models_A(iMod).Cpts) = 0;
end
% stronger correlation between auditory patterns
theta_real(2, 2) = 5;
theta_real(7, 2) = 5;
theta_real(9, 2) = 5;
% theta_real(11,2) = 5;
% theta_real(13,2) = 5;
% theta_real(15,2) = 5;

% stronger ipsi contra between auditory patterns
theta_real(5, 9) = 3;
theta_real(10, 9) = 3;
theta_real(11, 9) = 3;
% theta_real(11,2) = 5;
% theta_real(13,2) = 5;
% theta_real(15,2) = 5;

% Creates G_sum
% Gtotal = SUM_ii [exp(theta_ii)*G_ii]
for tr = 1:size(theta_real, 1)

    tmp = zeros(NbCdt);

    for iG = 1:size(theta_real, 2)
        tmp = tmp + exp(theta_real(tr, iG)) * Components(iG).G;
    end

    G_sum(:, :, tr) = tmp; %#ok<*SAGROW>

end

% Get a G matrix for other participants who will have patterns with only one component
G_null = Components(3).G;

save(fullfile(Save_dir, 'sim_pcm_models_components_weights.mat'), ...
     'M', 'Scale_noise', 'Components', 'B', 'theta_real', 'Models');

%% Generate data
for ss = 1:NbSubj

    for tr = 1:size(theta_real, 1)

        for sm = 1:size(Scale_noise, 1)

            s = theta_subj(sm, 1, ss);
            sig = theta_subj(sm, 2, ss);
            G = G_sum(:, :, tr);

            [Y0{tr, sm}{ss}, Y1{tr, sm}{ss}] = Generate_PCM_data(Z, G, s, sig, NbFeatures, X, B);

        end
    end

end % ss

%% Fit the models on the group level on data with no fixed effect

partVec = repmat((1:NbSess)', [NbCdt 1]);
condVec = repmat(1:NbCdt, [NbSess 1]);
condVec = condVec(:);

fprintf('\n\n\nRunning simulation on demeaned data.\n');
for sm = 1:size(Scale_noise, 1)
    fprintf('\n\n\n Running on noise level %i.\n', sm);
    fprintf('\n\n\n  Running with no CV.\n');
    for tr = 1:size(Y0, 1)
        [ms_mr{tr, sm}.Tgroup, ms_mr{tr, sm}.theta, ms_mr{tr, sm}.G_pred] = ...
            pcm_fitModelGroup(Y0{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', 'fitScale', 1);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_demean_noise_%i.mat', sm)), 'ms_mr');

    fprintf('\n\n\n  Running with CV\n');
    parfor tr = 1:size(Y0, 1)
        [ms_mr{tr, sm}.Tcross, ms_mr{tr, sm}.thetaCr, ms_mr{tr, sm}.G_predcv] = ...
            pcm_fitModelGroupCrossval(Y0{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', ...
                                      'groupFit', ms_mr{tr, sm}.theta, 'fitScale', 1, 'MaxIteration', MaxIteration);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_demean_noise_%i.mat', sm)), 'ms_mr');
end

%% Fit the models on the group level on data with fixed effect

partVec = repmat((1:NbSess)', [NbCdt 1]);
condVec = repmat(1:NbCdt, [NbSess 1]);
condVec = condVec(:);

fprintf('\n\n\nRunning simulation on data with mean.\n');
for sm = 1:size(Scale_noise, 1)
    fprintf('\n\n\n Running on noise level %i.\n', sm);
    fprintf('\n\n\n  Running with no CV.\n');
    for tr = 1:size(Y1, 1)
        [ms_mc{tr, sm}.Tgroup, ms_mc{tr, sm}.theta, ms_mc{tr, sm}.G_pred] = ...
            pcm_fitModelGroup(Y1{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', 'fitScale', 1);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_noise_%i.mat', sm)), 'ms_mc');

    fprintf('\n\n\n  Running with CV.\n');
    parfor tr = 1:size(Y1, 1)
        [ms_mc{tr, sm}.Tcross, ms_mc{tr, sm}.thetaCr, ms_mc{tr, sm}.G_predcv] = ...
            pcm_fitModelGroupCrossval(Y1{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', ...
                                      'groupFit', ms_mc{tr, sm}.theta, 'fitScale', 1, 'MaxIteration', MaxIteration);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_noise_%i.mat', sm)), 'ms_mc');
end

%% replace 2 subjects with a different pattern
for ss = 1:2

    for tr = 1:size(theta_real, 1)

        for sm = 1:size(Scale_noise, 1)

            s = Scale_noise(sm, 1);
            sig = Scale_noise(sm, 2);
            G = G_null;

            [Y0{tr, sm}{end - 2 + ss}, Y1{tr, sm}{end - 2 + ss}] = Generate_PCM_data(Z, G, s, sig, NbFeatures, X, B);
        end
    end

end % ss

%% Fit the models on the group level on data with no fixed effect

partVec = repmat((1:NbSess)', [NbCdt 1]);
condVec = repmat(1:NbCdt, [NbSess 1]);
condVec = condVec(:);

fprintf('\n\n\nRunning simulation on demeaned data.\n');
for sm = 1:size(Scale_noise, 1)
    fprintf('\n\n\n Running on noise level %i.\n', sm);
    fprintf('\n\n\n  Running with no CV.\n');
    for tr = 1:size(Y0, 1)
        [ms_mr{tr, sm}.Tgroup, ms_mr{tr, sm}.theta, ms_mr{tr, sm}.G_pred] = ...
            pcm_fitModelGroup(Y0{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', 'fitScale', 1);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_demean_noise_%i_with_weird_subjects.mat', sm)), 'ms_mr');

    fprintf('\n\n\n  Running with CV\n');
    parfor tr = 1:size(Y0, 1)
        [ms_mr{tr, sm}.Tcross, ms_mr{tr, sm}.thetaCr, ms_mr{tr, sm}.G_predcv] = ...
            pcm_fitModelGroupCrossval(Y0{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', ...
                                      'groupFit', ms_mr{tr, sm}.theta, 'fitScale', 1, 'MaxIteration', MaxIteration);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_demean_noise_%i_with_weird_subjects.mat', sm)), 'ms_mr');
end

%% Fit the models on the group level on data with fixed effect

partVec = repmat((1:NbSess)', [NbCdt 1]);
condVec = repmat(1:NbCdt, [NbSess 1]);
condVec = condVec(:);

fprintf('\n\n\nRunning simulation on data with mean.\n');
for sm = 1:size(Scale_noise, 1)
    fprintf('\n\n\n Running on noise level %i.\n', sm);
    fprintf('\n\n\n  Running with no CV.\n');
    for tr = 1:size(Y1, 1)
        [ms_mc{tr, sm}.Tgroup, ms_mc{tr, sm}.theta, ms_mc{tr, sm}.G_pred] = ...
            pcm_fitModelGroup(Y1{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', 'fitScale', 1);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_noise_%i_with_weird_subjects.mat', sm)), 'ms_mc');

    fprintf('\n\n\n  Running with CV.\n');
    parfor tr = 1:size(Y1, 1)
        [ms_mc{tr, sm}.Tcross, ms_mc{tr, sm}.thetaCr, ms_mc{tr, sm}.G_predcv] = ...
            pcm_fitModelGroupCrossval(Y1{tr, sm}, M, partVec, condVec, 'runEffect', 'fixed', ...
                                      'groupFit', ms_mc{tr, sm}.theta, 'fitScale', 1, 'MaxIteration', MaxIteration);
    end
    save(fullfile(Save_dir, sprintf('sim_pcm_output_cv_noise_%i_with_weird_subjects.mat', sm)), 'ms_mc');
end
