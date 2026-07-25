% (C) Copyright 2020 Remi Gau
clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..');
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

VTK_sufix = {'Cst', 'Lin', 'Quad'};

for iSub = 1:8 % :NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'));
    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM;

    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    %% For the 2 hemispheres
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

        InfSurfFile = spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
                                 ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex, inf_faces, ~] = read_vtk(InfSurfFile, 0, 1);

        % Load data or extract them
        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile);
            VertexWithDataHS{hs} = VertexWithData; %#ok<*SAGROW>
        else
            error('The features have not been extracted from the VTK files.');
        end

        %% Run GLMs for basic conditions
        for iCdt = 1:numel(CondNames) % For each Condition

            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                Beta2Sel = [Beta2Sel; find(strcmp(cellstr(BetaNames), ...
                                                  ['Sn(' num2str(iSess) ') ' ...
                                                   CondNames{iCdt}  '*bf(1)']))];  %#ok<*AGROW>
            end

            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));

            % Extract them
            Features = AllMapping(:, :, Beta2Sel); %#ok<*FNDSB>

            % Change or adapt dimensions for GLM
            X = repmat(DesMat, size(Features, 3), 1);

            Y = shiftdim(Features, 1);
            Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

            B = pinv(X) * Y;

            Mapping = zeros(1, size(inf_vertex, 2));
            Mapping(VertexWithDataHS{hs}) = B(1, :);
            Mapping(Mapping > 0) = 1;
            Mapping(Mapping < 0) = -1;

            for iROI = 1:4
                tmp = zeros(1, size(inf_vertex, 2));
                tmp(1, ROI(iROI).VertOfInt{hs}) = Mapping(ROI(iROI).VertOfInt{hs});

                write_vtk(fullfile(Sub_dir, 'roi', 'surf', ...
                                   [SubLs(iSub).name '_' HsSufix 'cr_' ROI(iROI).name '_' CondNames{iCdt} ...
                                    '_ActDeact.vtk']), inf_vertex, inf_faces, Mapping);

            end

            clear Features Beta2Sel B X Y Mapping iBeta iSess;
        end

        clear iCdt;

    end

end

cd(StartDir);
