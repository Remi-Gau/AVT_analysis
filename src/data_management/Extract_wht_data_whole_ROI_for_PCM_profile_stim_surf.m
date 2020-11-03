clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox\');

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

CondNames = { ...
             'AStimL', 'AStimR', ...
             'VStimL', 'VStimR', ...
             'TStimL', 'TStimR', ...
             'ATargL', 'ATargR', ...
             'VTargL', 'VTargR', ...
             'TTargL', 'TTargR' ...
            };

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_rsa');
    %     Data_dir = fullfile('E:\derivatives', SubLs(iSub).name, 'ffx_rsa', 'betas','6_surf');
    Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'));
    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM;

    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

    % Loads which runs happened on which day to set up the CVs
    load(fullfile(StartDir, 'RunsPerSes.mat'));
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    RunPerSes = RunPerSes(Idx).RunsPerSes;
    DayCVs = { ...
              1:RunPerSes(1), ...
              RunPerSes(1) + 1:RunPerSes(1) + RunPerSes(2), ...
              RunPerSes(1) + RunPerSes(2) + 1:sum(RunPerSes)};
    clear Idx RunPerSes;

    %% For the 2 hemispheres

    NbVertices = nan(1, 2);

    for hs = 1:2

        row = 1;

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
                                 ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg.vtk$']);
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
                if strcmp(SubLs(iSub).name, 'sub-06') && iSess == 17 && (iCdt < 3 || iCdt == 7 || iCdt == 8)
                else
                    Beta2Sel = [Beta2Sel; find(strcmp(cellstr(BetaNames), ...
                                                      ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];   %#ok<*AGROW>
                end
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
            for iCV = 1:size(Features, 3)

                Sess2Sel = iCV;

                %                 if strcmp(SubLs(iSub).name,'sub-06') && iSess==17 && (iCdt<3 || iCdt==7 || iCdt==8)
                %                     Y = nan(size(Features,1),NbLayers);
                %                 else
                Y = Features(:, :, Sess2Sel);
                %                 end

                if hs == 1
                    X = nan(NbVertex(1), NbLayers);
                else
                    X = nan(NbVertex(2), NbLayers);
                end

                X(VertexWithDataHS{hs}, :) = Y;

                for iROI = 1:numel(ROI)
                    Z = X(ROI(iROI).VertOfInt{hs}, :);
                    Z = Z(:);
                    PCM_data{iROI, hs}(row, :) = Z;
                end

                row = row + 1;

            end

            clear Features Beta2Sel X Y B iSess;
        end

        clear iCdt;

    end

    cd(StartDir);

    %%
    save(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'PCM', 'Data_PCM_whole_ROI.mat'), '-v7.3',  ...
         'PCM_data');

    clear BetaCdt PCM_data;

end

cd(StartDir);
