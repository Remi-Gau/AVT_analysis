clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..', '..');
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

load(fullfile(StartDir, 'results', 'roi', 'MinNbVert.mat'), 'MinVert');

% First column: sorting condition; second column: condition to sort
% we need different ones for the left and right ROIs becuase of the ipsi
% and contra pooling
A = repmat(1:6, 6, 1);
Cdt_ROI_lhs = [A(:), repmat([1:6]', 6, 1)]; %#ok<*NBRAK>
clear A;

A = repmat([2 1 4 3 6 5], 6, 1);
Cdt_ROI_rhs = [A(:), repmat([2 1 4 3 6 5]', 6, 1)];
clear A;

for iSub = 1:NbSub

  fprintf('\n\n\n');

  fprintf('Processing %s\n', SubLs(iSub).name);

  Sub_dir = fullfile(StartDir, SubLs(iSub).name);
  GLM_dir = fullfile(Sub_dir, 'ffx_nat');
  Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

  Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'rasters');
  [~, ~, ~] = mkdir(Results_dir);

  % Get number of sessions, regressors of interest numbers, and names of conditions
  load(fullfile(GLM_dir, 'SPM.mat'));
  [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
  Nb_sess = numel(SPM.Sess);
  clear SPM;

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
                             ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
    [inf_vertex, inf_faces, ~] = read_vtk(InfSurfFile, 0, 1);

    NbVertices(hs) = size(inf_vertex, 2);

    % Load data or extract them
    fprintf('  Reading VTKs\n');
    if exist(FeatureSaveFile, 'file')
      load(FeatureSaveFile);
      VertexWithDataHS{hs} = VertexWithData;
    else
      error('The features have not been extracted from the VTK files.');
    end

    %% Run GLMs for basic conditions
    fprintf('\n  Running GLMs all conditions\n');
    for iCdt = 1:numel(CondNames) % For each Condition
      fprintf('   %s\n', CondNames{iCdt});

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

      if sum(isnan(Features(:))) > 0
        warning('We have %i NaNs for %s', sum(isnan(Features(:))), CondNames{iCdt});
      end
      if sum(Features(:) == 0) > 0
        warning('We have %i zeros for %s', sum(Features(:) == 0), CondNames{iCdt});
      end

      % Saves mean of all the features across sessions for the raster
      FeaturesCdtion{iCdt, hs} = mean(Features, 3);

      % Change or adapt dimensions for GLM
      X = repmat(DesMat, size(Features, 3), 1);

      Y = shiftdim(Features, 1);
      Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

      B = pinv(X) * Y;

      BetaCdt{hs}(:, :, iCdt) = pinv(X) * Y; %#ok<*SAGROW>

      clear Features Beta2Sel B X Y Mapping iBeta iSess;
    end

    clear iCdt;

  end

  cd(StartDir);

  if any(NbVertex ~= NbVertices)
    NbVertex;
    NbVertices; %#ok<*NOPTS>
    error('The number of vertices does not match.');
  end

  %% Profiles stim = f(other stim)
  ToPlot = {'Cst', 'Lin', 'Quad'};

  fprintf('\n');

  for iToPlot = 1 % :numel(ToPlot)

    for iROI = 1:numel(ROI)

      NbBin = MinVert(strcmp(ROI(iROI).name, {MinVert.name}')).MinVert;

      fprintf(' Creating rasters for %s\n', ROI(iROI).name);

      parfor iCdt = 1:size(Cdt_ROI_lhs, 1)

        % Sorting varibles
        X_lh = nan(1, NbVertex(1));
        X_lh(1, VertexWithDataHS{1}) = BetaCdt{1}(iToPlot, :, Cdt_ROI_lhs(iCdt, 1)); %#ok<*PFBNS>
        X_rh = nan(1, NbVertex(2));
        X_rh(1, VertexWithDataHS{2}) = BetaCdt{2}(iToPlot, :, Cdt_ROI_rhs(iCdt, 1));

        % Varibles to sort
        Profiles_lh = nan(NbVertex(1), 6);
        Profiles_lh(VertexWithDataHS{1}, :) = FeaturesCdtion{Cdt_ROI_lhs(iCdt, 2), 1};
        Profiles_rh = nan(NbVertex(2), 6);
        Profiles_rh(VertexWithDataHS{2}, :) = FeaturesCdtion{Cdt_ROI_rhs(iCdt, 2), 2};

        % Sort
        X = [X_lh(ROI(iROI).VertOfInt{1}) X_rh(ROI(iROI).VertOfInt{2})];
        [X_sort, I] = sort(X);

        Profiles = [ ...
                    Profiles_lh(ROI(iROI).VertOfInt{1}, :); ...
                    Profiles_rh(ROI(iROI).VertOfInt{2}, :)];
        Profiles = Profiles(I, :);

        ToRemove = cat(3, isnan(Profiles), Profiles == 0);
        ToRemove = any(ToRemove, 3);
        ToRemove = any(ToRemove, 2);

        Profiles(ToRemove, :) = [];
        X_sort(ToRemove) = [];

        IdxToAvg = floor(linspace(1, numel(X_sort), NbBin + 1));

        X_sort_Perc = [];
        Profiles_Perc = [];

        for iPerc = 2:numel(IdxToAvg)
          X_sort_Perc(iPerc - 1) = mean(X_sort(IdxToAvg((iPerc - 1):iPerc)));
          Profiles_Perc(iPerc - 1, :) = mean(Profiles(IdxToAvg((iPerc - 1):iPerc), :));
        end

        X_sort = []; %#ok<*NASGU>
        Profiles = [];

        X_sort = X_sort_Perc;
        Profiles = Profiles_Perc;

        All_Profiles{iSub, iToPlot, iCdt, iROI} = Profiles;
        All_X_sort{iSub, iToPlot, iCdt, iROI} = X_sort;

        X = [];

      end

      clear X_lh Y_rh;

    end

  end

  clear BetaCdt FeaturesCdtion;

end

cd(StartDir);

mkdir(fullfile(StartDir, 'results', 'profiles', 'surf', 'rasters'));

save(fullfile(StartDir, 'results', 'profiles', 'surf', 'rasters', 'RasterAllCdt.mat'), ...
     'ROI', 'All_X_sort', 'All_Profiles');
