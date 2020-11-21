% (C) Copyright 2020 Remi Gau
clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox/');

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
% DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
DesMat = [ones(NbLayers, 1) DesMat'];
DesMat = spm_orth(DesMat);

VTK_sufix = {'Cst', 'Lin', 'Quad'};

for iSub =  1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf');
    [~, ~, ~] = mkdir(Results_dir);

    %% Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    %% Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'));
    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM;

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

        %% Get T1 maps on surfaces
        InfSurfFile = spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
                                 ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf_qT1.vtk$']);
        [inf_vertex, ~, T1_mapping{hs}] = read_vtk(InfSurfFile, 0, 1);

        %% Load BOLD data or extract them
        FeatureSaveFile = fullfile(Data_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                              num2str(NbLayers) '_surf.mat']);

        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile);
        else
            error('The features have not been extracted from the VTK files.');
        end

        %% Run GLMs for basic conditions
        Mapping{hs} = zeros(size(inf_vertex, 2), 6, 2);

        fprintf('\n   All conditions\n');
        for iCdt = 1:numel(CondNames) % For each Condition
            fprintf('    %s\n', CondNames{iCdt});

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

            % Change or adapt dimensions for GLM
            X = repmat(DesMat, size(Features, 3), 1);

            Y = shiftdim(Features, 1);
            Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

            if sum(isnan(Features(:))) > 0
                warning('We have %i NaNs for %s', sum(isnan(Features(:))), CondNames{iCdt});
            end
            if sum(Features(:) == 0) > 0
                warning('We have %i zeros for %s', sum(Features(:) == 0), CondNames{iCdt});
            end

            B = pinv(X) * Y;

            Mapping{hs}(VertexWithData, iCdt, hs) = B(1, :);

            clear Features Beta2Sel B X Y iBeta iSess;
        end
    end
    clear iCdt;

    for hs = 1:2
        %%

        for iROI = 1:2
            clear BOLD_Data;

            Data_ROI.name = ROI(iROI).name;

            fprintf(['  '  Data_ROI.name '\n']);

            T1_Data(:, 1) =  T1_mapping{hs}(ROI(iROI).VertOfInt{hs});
            for iCdt = 1:numel(CondNames)
                BOLD_Data(:, iCdt) = Mapping{hs}(ROI(iROI).VertOfInt{hs}, iCdt, hs);
            end

            ToRemove = cat(2, isnan(BOLD_Data), BOLD_Data == 0);
            ToRemove = any(ToRemove, 2);

            BOLD_Data(ToRemove, :) = [];
            T1_Data(ToRemove, :) = [];

            for iCdt = 1:numel(CondNames)
                RHO(iCdt, hs, iSub, iROI) = corr(T1_Data, BOLD_Data(:, iCdt));
                %                 scatter(T1_Data,BOLD_Data(:,iCdt),'.')
            end

            clear BOLD_Data T1_Data;

        end

    end

end

%%
save(fullfile(StartDir, 'results', 'profiles', 'surf', 'T1_BOLD_cor.mat'), ...
     'RHO');

cd(StartDir);

%%
StartDir = 'D:\Dropbox\PhD\Experiments\AVT\derivatives\';
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox/');

load(fullfile(StartDir, 'results', 'profiles', 'surf', 'T1_BOLD_cor.mat'), ...
     'RHO');

%%
clc;
close all;

FigureFolder = fullfile(StartDir, 'figures', 'T1');

CondNames = { ...
             'AStimL', 'AStimR', ...
             'VStimL', 'VStimR', ...
             'TStimL', 'TStimR'
             %     'ATargL','ATargR';...
             %     'VTargL','VTargR';...
             %     'TTargL','TTargR';...
            };

FigDim = [50, 50, 1000, 800];

FigName = 'T1 to profile Cst correlation';
figure('name', FigName, 'Position', FigDim, 'Color', [1 1 1]);

for iSubplot = 1:4
    switch iSubplot
        case 1
            ROI = 1;
            hs = 1;
        case 2
            ROI = 1;
            hs = 2;
        case 3
            ROI = 2;
            hs = 1;
        case 4
            ROI = 2;
            hs = 2;
    end

    Data = atanh(squeeze(RHO(:, hs, :, ROI)));

    subplot(2, 2, iSubplot);
    grid on;
    hold on;
    plot(repmat((1:6)', 1, 10), Data, 'color', [.5 .5 .5]);
    errorbar(1:6, mean(Data, 2), nansem(Data, 2), ...
             'o k', 'linewidth', 2);
    plot([1 6], [0 0], '--k');
    axis([0.5 6.5 -0.28 0.28]);

    set(gca, 'tickdir', 'out', 'xtick', 1:6, 'xticklabel', ...
        CondNames, ...
        'ticklength', [0.01 0], 'fontsize', 8);

    switch iSubplot
        case 1
            t = title('left');
            set(t, 'fontsize', 12);
            t = ylabel('A1');
            set(t, 'fontsize', 12);
        case 2
            t = title('right');
            set(t, 'fontsize', 12);
        case 3
            t = ylabel('PT');
            set(t, 'fontsize', 12);
    end

end

mtit(sprintf([FigName '\nFisher transformed correlation coefficient']), ...
     'fontsize', 12, 'xoff', 0, 'yoff', .035);

print(gcf, fullfile(FigureFolder, 'T1_BOLD_Correlation.tif'), '-dtiff');
