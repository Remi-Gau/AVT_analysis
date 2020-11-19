% Loads mat file and runs laminar GLM and saves results in another mat file

clc;
clear;

MVNN = true;

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

SubLs = dir(fullfile(Dirs.DerDir, 'sub*'));
NbSub = numel(SubLs);

NbLayers = 6;

DesMat = set_design_mat_lam_GLM(NbLayers);

ToPlot = {'Cst', 'Lin', 'Avg'};

if MVNN
  MVNN_suffix = 'MVNN';

  CondNames = { ...
               'AStimL', 'AStimR', ...
               'VStimL', 'VStimR', ...
               'TStimL', 'TStimR', ...
               'ATargL', 'ATargR', ...
               'VTargL', 'VTargR', ...
               'TTargL', 'TTargR' ...
              };

else
  MVNN_suffix = 'raw';

  CondNames = { ...
               'AStimL', 'AStimR', ...
               'VStimL', 'VStimR', ...
               'TStimL', 'TStimR'};
end

for iSub = 5 % ; 1:NbSub

  fprintf('\n\n\n');

  fprintf('Processing %s\n', SubLs(iSub).name);

  Sub_dir = fullfile(Dirs.DerDir, SubLs(iSub).name);

  if MVNN
    GLM_dir = fullfile(Sub_dir, 'ffx_rsa');
  else
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
  end

  % Get number of sessions, regressors of interest numbers, and names of conditions
  load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'));
  [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
  Nb_sess = numel(SPM.Sess);
  clear SPM;

  conditionVec = repmat(1:numel(CondNames), Nb_sess, 1);
  conditionVec = conditionVec(:);

  partitionVec = repmat((1:Nb_sess)', numel(CondNames), 1);

  % Load Vertices of interest for each ROI;
  load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

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

    Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

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

      % get the data for the targets
      if ~MVNN

        warning('only the beta values will be extracted not those for the targets');

        %                 tmp = AllMapping;
        %
        %                 Data_dir = fullfile(GLM_dir,'betas','6_surf', 'targets');
        %                 FeatureSaveFile = fullfile(Data_dir,[SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
        %                     num2str(NbLayers) '_surf.mat']);
        %
        %                 load(FeatureSaveFile)
        %
        %                 AllMapping = cat(3, tmp, AllMapping);

      end

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

        Y = Features(:, :, Sess2Sel);
        X = repmat(DesMat, size(Y, 3), 1);
        Y = shiftdim(Y, 1);
        B = pinv(X) * Y;
        BetaCdt{hs, iCV}(1:size(DesMat, 2), :, iCdt) = B;
      end

      clear Features Beta2Sel X Y B iSess;
    end

    clear iCdt;

  end

  cd(StartDir);

  if any(NbVertex ~= NbVertices)
    NbVertex;
    NbVertices; %#ok<*NOPTS>
    error('The number of vertices does not match.');
  end

  %%
  if MVNN
    export_dir = fullfile(Dirs.DerDir, 'rsa_toolbox', SubLs(iSub).name, 'extracted_data');
  else
    export_dir = fullfile(Dirs.DerDir, 'spm12', SubLs(iSub).name, 'extracted_data');
  end
  mkdir(export_dir);

  for iToPlot = 1:size(BetaCdt{1, 1}, 1)

    X_lh = nan(size(CondNames, 2) * Nb_sess, NbVertex(1));
    X_rh = nan(size(CondNames, 2) * Nb_sess, NbVertex(2));
    row = 1;

    for iCdt = 1:size(CondNames, 2)
      for iCV = 1:Nb_sess
        X_lh(row, VertexWithDataHS{1}) = BetaCdt{1, iCV}(iToPlot, :, iCdt);
        X_rh(row, VertexWithDataHS{2}) = BetaCdt{2, iCV}(iToPlot, :, iCdt);
        row = row + 1;
      end
    end

    for iROI = 1:numel(ROI)
      % Stores data for PCM
      PCM_data{iToPlot, iROI, 1} = X_lh(:, ROI(iROI).VertOfInt{1});
      PCM_data{iToPlot, iROI, 2} = X_rh(:, ROI(iROI).VertOfInt{2});
    end
  end

  % save data for each ROI, hs and for Cst / Lin / Avg
  for iToPlot = 1:size(BetaCdt{1, 1}, 1)

    for iROI = 1:numel(ROI)

      for hs = 1:2

        if hs == 1
          HsSufix = 'l';
        else
          HsSufix = 'r';
        end

        filename = fullfile(export_dir, ...
                            [SubLs(iSub).name ...
                             '_data-' MVNN_suffix ...
                             '_space-surf'...
                             '_ROI-'  ROI(iROI).name ...
                             '_hs-' HsSufix ...
                             '_param-' lower(ToPlot{iToPlot}) ...
                             '.mat']);

        data = PCM_data{iToPlot, iROI, hs};

        save(filename, '-v7.3',  'data', 'CondNames', 'conditionVec', 'partitionVec');

      end
    end

  end

  %%
  mkdir(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'PCM'));
  save(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'PCM', ['Data_' MVNN_suffix '.mat']), '-v7.3',  ...
       'PCM_data', 'CondNames', 'conditionVec', 'partitionVec');

  clear BetaCdt PCM_data;

end

cd(StartDir);
