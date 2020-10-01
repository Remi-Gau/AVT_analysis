%%
% This script gets data from the beta values from the whole brain surface at the different depth
% for each condition, block, ROI, subject

clc;
clear;

ROIs = {
        'A1'
        'PT'
        'V1'
        'V2'};

%% set up directories and get dependencies
if isunix
    CodeDir = '/home/remi/github/AVT_analysis';
    StartDir = '/home/remi';
elseif ispc
    CodeDir = 'D:\github\AVT-7T-code';
    StartDir = 'D:\';
else
    disp('Platform not supported');
end

addpath(genpath(fullfile(CodeDir, 'subfun')));

[Dirs] = set_dir();

Get_dependencies();

Results_dir = fullfile(Dirs.DerDir, 'DataToExport', 'extracted_betas');
mkdir(Results_dir);

%%
% to decide if we extract the data from the base sitmuli (1) or from the
% target stimuli (0)
Stim = 0;

NbLayers = 6;
LayerInd = NbLayers:-1:1;

if Stim
    CondNames = { ...
                 'AStimL', 'AStimR', ...
                 'VStimL', 'VStimR', ...
                 'TStimL', 'TStimR'};
    label = 'stim';
else
    CondNames = { ...
                 'ATargL', 'ATargR', ...
                 'VTargL', 'VTargR', ...
                 'TTargL', 'TTargR' ...
                };
    label = 'target';
end

SubLs = dir(fullfile(Dirs.DerDir, 'sub*'));
NbSub = numel(SubLs);

for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(Dirs.DerDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    if Stim
        Data_dir = fullfile(GLM_dir, 'betas', '6_surf');
    else
        Data_dir = fullfile(GLM_dir, 'betas', '6_surf', 'targets');
    end

    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'));
    [~, BetaNames] = GetBOI(SPM, CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM;

    % create vectors that identidy which condition and sessions of the data matrix
    CdtVect = zeros(size(BetaNames, 1), 1);
    SessVect = zeros(size(BetaNames, 1), 1);
    for iSess = 1:Nb_sess
        for iCdt = 1:numel(CondNames)
            row_idx = find(strcmp(cellstr(BetaNames), ...
                                  ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']));
            CdtVect(row_idx) = iCdt;
            SessVect(row_idx) = iSess;
        end
    end

    BetaNames(CdtVect < 1, :) = [];
    CdtVect(CdtVect < 1) = [];
    SessVect(SessVect < 1) = [];

    clear SPM row_idx iSess iCdt;

    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

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

        InfSurfFile = spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
                                 ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf_qT1.vtk$']);
        [inf_vertex, inf_faces, ~] = read_vtk(InfSurfFile, 0, 1);

        NbVertices(hs) = size(inf_vertex, 2);

        % Load data or extract them
        fprintf('  Reading VTKs\n');
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile, 'VertexWithData', 'AllMapping');
        else
            error('The features have not been extracted from the VTK files.');
        end

        if NbVertex ~= NbVertices
            NbVertex;
            NbVertices; %#ok<*NOPTS>
            error('The number of vertices does not match.');
        end

        % initialize variables that stores data for the whole cortex but only
        % allocate data for vertices with have some data for
        Features = nan(NbVertex(hs), NbLayers, size(AllMapping, 3));
        Features(VertexWithData, :, :) = AllMapping;

        fprintf(' Saving for ROI:\n');

        for iROI = 1:numel(ROIs)

            fprintf(['  '  ROI(iROI).name '\n']);

            FileName = strcat( ...
                              'sub-', SubLs(iSub).name, ...
                              '_data-surf_cdt-', label, '_ROI-', ROI(iROI).name, ...
                              '_hs-', HsSufix);

            Features_ROI = Features(ROI(iROI).VertOfInt{hs}, :, :);

            % remove any vertices with one zero at any depth (CBS tools
            % gives a 0 value when no data was available)
            Vert2Rm = any(any(Features_ROI == 0, 3), 2);
            Features_ROI(Vert2Rm, :, :) = [];

            Features_ROI = shiftdim(Features_ROI, 2);

            % create a variable to know which column belongs to which depth
            LayerLabel = repmat(LayerInd, [size(Features_ROI, 2) 1]);
            LayerLabel = LayerLabel(:);

            % reorganize data to have a 2D table
            Features_ROI = reshape(Features_ROI, ...
                                   [size(Features_ROI, 1), size(Features_ROI, 2) * size(Features_ROI, 3)]);

            % saves to mat, csv and h5 format
            save(fullfile(Results_dir, [FileName '.mat']), ...
                 'Features_ROI', 'BetaNames', 'LayerLabel', ...
                 'CdtVect', 'SessVect');

            csvwrite(fullfile(Results_dir, [FileName '.csv']), ...
                     Features_ROI);
            csvwrite(fullfile(Results_dir, [FileName '_CdtVect' '.csv']), ...
                     CdtVect);
            csvwrite(fullfile(Results_dir, [FileName '_SessVect' '.csv']), ...
                     SessVect);
            csvwrite(fullfile(Results_dir, [FileName '_LayerLabel' '.csv']), ...
                     LayerLabel);

            clear Features_ROI LayerLabel;

        end

    end

    clear BetaNames CdtVect SessVect;

end
