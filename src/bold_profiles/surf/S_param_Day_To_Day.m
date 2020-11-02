% print vtk files of daily averaged S-parameters surface mapping for each
% subject

% computes for each subject the correlation between one session and all the
% others for all ROIs

clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox/');

load(fullfile(StartDir, 'RunsPerSes.mat'));

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

HS = 'lr';

for iSub = 5 % 1:10

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
        [inf_vertex, inf_face, ~] = read_vtk(InfSurfFile, 0, 1);

        %% Load BOLD data or extract them
        FeatureSaveFile = fullfile(Data_dir, [SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
                                              num2str(NbLayers) '_surf.mat']);

        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile);
        else
            error('The features have not been extracted from the VTK files.');
        end

        %% Laminar GLM on each beta image
        Mapping = zeros(size(inf_vertex, 2), size(AllMapping, 3));

        Column = 1;

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

            for iBeta = 1:numel(Beta2Sel)
                Features = AllMapping(:, :, Beta2Sel(iBeta)); %

                % Change or adapt dimensions for GLM
                X = repmat(DesMat, size(Features, 3), 1);
                Y = shiftdim(Features, 1);

                B = pinv(X) * Y;

                Mapping(VertexWithData, Column) = B(1, :);
                Column = Column + 1;
            end
            clear Features Beta2Sel B X Y iBeta iSess;

        end

        % to know which columns to avg
        Col2Avg = cumsum(RunPerSes(iSub).RunsPerSes);
        if iSub == 5 % one session for this subject did not have auditory stimuli
            Col2Avg(end) = Col2Avg(end) - 1;
        end
        for i = 2:numel(CondNames)
            if iSub == 5
                if i == 2 % one session for this subject did not have auditory stimuli
                    Col2Avg(end + 1, :) = Col2Avg(1, :) + sum(RunPerSes(iSub).RunsPerSes) - 1;
                else
                    Col2Avg(end + 1, :) = Col2Avg(2, :) + sum(RunPerSes(iSub).RunsPerSes) * (i - 2);
                end
            else
                Col2Avg(end + 1, :) = Col2Avg(1, :) + sum(RunPerSes(iSub).RunsPerSes) * (i - 1);
            end
        end
        Col2Avg = Col2Avg';
        Col2Avg = Col2Avg(:);

        % average per day
        FirstCol = 1;
        for iCol = 1:numel(Col2Avg)
            S_Param_day(:, iCol) = mean( ...
                                        Mapping(:, FirstCol:Col2Avg(iCol)), 2);
            FirstCol = Col2Avg(iCol) + 1;
        end

        % write each condition for each day
        Col = 1;
        for iCdt = 1:numel(CondNames)
            for iDay = 1:3
                Data = S_Param_day(:, Col);
                Filename = fullfile(StartDir, SubLs(iSub).name, 'ffx_nat', 'betas', '6_surf', ...
                                    [SubLs(iSub).name '_' CondNames{iCdt} '_day-' num2str(iDay) '_' HS(hs) 'h_cst_inf.vtk']);
                write_vtk(Filename, inf_vertex, inf_face, Data');
                Col = Col + 1;
                clear Data;
            end
        end

        % write each condition
        Col = reshape(1:18, 3, 6)';

        for iCdt = 1:numel(CondNames)
            Data = mean(S_Param_day(:, Col(iCdt, :)), 2);
            Filename = fullfile(StartDir, SubLs(iSub).name, 'ffx_nat', 'betas', '6_surf', ...
                                [SubLs(iSub).name '_' CondNames{iCdt} '_' HS(hs) 'h_cst_inf.vtk']);
            write_vtk(Filename, inf_vertex, inf_face, Data');
            clear Data;
        end

        clear S_Param_day;

    end

end
