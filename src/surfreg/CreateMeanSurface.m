% (C) Copyright 2020 Remi Gau
%% Creates one mean surface across sessions for each condition and each layer

clc;
clear;

StartDir = fullfile(pwd, '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

Target = 1;

if Target
    CondNames = { ...
                 'ATargL', 'ATargR', ...
                 'VTargL', 'VTargR', ...
                 'TTargL', 'TTargR'};
else
    CondNames = { ...
                 'AStimL', 'AStimR', ...
                 'VStimL', 'VStimR', ...
                 'TStimL', 'TStimR'}; %#ok<*UNRCH>
end

for iSub = NbSub

    fprintf('Processing %s\n', SubLs(iSub).name);

    % Subject directory
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    if Target
        Data_dir = fullfile(GLM_dir, 'betas', '6_surf', 'targets');
    else
        Data_dir = fullfile(GLM_dir, 'betas', '6_surf');
    end

    %% Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'));
    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM;

    %% Load data or extract them
    NbVertices = nan(1, 2);
    for hs = 1:2

        if hs == 1
            HsSufix = 'l';
            fprintf(' Left HS\n');
        else
            HsSufix = 'r';
            fprintf(' Right HS\n');
        end

        FeatureSaveFile = fullfile(Data_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                              num2str(NbLayers) '_surf.mat']);

        vtk = spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
                         ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg.vtk$']);
        [vertex, faces, ~] = read_vtk(vtk, 0, 1);

        NbVertices(hs) = size(vertex, 2);

        % Load data or extract them
        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile);
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
                                                  ['Sn(' num2str(iSess) ') ' ...
                                                   CondNames{iCdt}  '*bf(1)']))];  %#ok<*AGROW>
            end
            %             fprintf('\n')
            %             disp(BetaNames(Beta2Sel,:))
            %             fprintf('\n')

            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));

            % Extract them
            Features = AllMapping(:, :, Beta2Sel); %#ok<*FNDSB>
            Features = mean(Features, 3);

            fprintf('    Writing VTKs\n');
            for iLayer = 1:size(Features, 2)

                Mapping = zeros(1, size(vertex, 2));
                Mapping(VertexWithData) = Features(:, iLayer);

                write_vtk(fullfile(Data_dir, ...
                                   [SubLs(iSub).name '_' HsSufix 'cr_mean_' CondNames{iCdt} ...
                                    '_layer_' num2str(iLayer) '.vtk']), vertex, faces, Mapping);
            end

        end

    end

end
