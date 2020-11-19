%%
clc;
clear;
close all;

StartDir = 'D:\Dropbox\PhD\Experiments\AVT\derivatives';
addpath(genpath(fullfile(StartDir, 'AVT-7T-code', 'subfun')));
Get_dependencies('D:\Dropbox/');

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'rasters');
mkdir(FigureFolder);
mkdir(fullfile(FigureFolder, 'cdt'));

load(fullfile(StartDir, 'results', 'roi', 'MinNbVert.mat'), 'MinVert');

CondNames = { ...
             'AStimL', 'AStimR', ...
             'VStimL', 'VStimR', ...
             'TStimL', 'TStimR'
             %     'ATargL','ATargR';...
             %     'VTargL','VTargR';...
             %     'TTargL','TTargR';...
            };

NbLayers = 6;

DesMat = (1:NbLayers) - mean(1:NbLayers);
% DesMat = [ones(NbLayers,1) DesMat'];
DesMat = [ones(NbLayers, 1) DesMat' (DesMat.^2)'];
DesMat = spm_orth(DesMat);

Folds = { ...
         1, 2:3; ...
         2, [1 3]; ...
         3, 1:2};

% A = repmat(1:6,6,1);
% Cdt = [A(:), repmat((1:6)',6,1)];
% clear A

Cdt = [([1:6 2 1 4 3 6 5])' ([1:6 1:6])'];

ToPlot = {'Constant', 'Linear', 'Quad'};

for iSub = 1:NbSub

  fprintf('\n\n\n');

  fprintf('Processing %s\n', SubLs(iSub).name);

  Sub_dir = fullfile(StartDir, SubLs(iSub).name);
  GLM_dir = fullfile(Sub_dir, 'ffx_nat');
  Data_dir = fullfile(GLM_dir, 'betas', '6_surf');

  Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'rasters');

  % Get number of sessions, regressors of interest numbers, and names of conditions
  load(fullfile(GLM_dir, 'SPM.mat'));
  [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames);
  Nb_sess = numel(SPM.Sess);
  clear SPM;

  % Load Vertices of interest for each ROI;
  load(fullfile(Sub_dir, 'roi', 'surf', [SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex');

  % Loads which runs happened on which day to set up the CVs
  load(fullfile(StartDir, 'RunsPerSes.mat'));
  Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
  RunPerSes = RunPerSes(Idx).RunsPerSes;
  CVs = { ...
         1:RunPerSes(1), ...
         RunPerSes(1) + 1:RunPerSes(1) + RunPerSes(2), ...
         RunPerSes(1) + RunPerSes(2) + 1:sum(RunPerSes)};
  clear Idx RunPerSes;

  %% For the 2 hemispheres
  clear BetaCdt;
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

    % Load data or extract them
    fprintf('  Reading VTKs\n');
    if exist(FeatureSaveFile, 'file')
      load(FeatureSaveFile);
      VertexWithDataHS{hs} = VertexWithData; %#ok<*SAGROW>
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

      % Run the "cross-validation"
      for iCV = 1:numel(CVs)

        Sess2Sel = CVs{iCV};
        if strcmp(SubLs(iSub).name, 'sub-06') && iCdt < 3
          Sess2Sel(Sess2Sel == 17) = [];
          Sess2Sel(Sess2Sel > 16) = Sess2Sel(Sess2Sel > 16) - 1;
        end

        % Change or adapt dimensions for GLM
        Y = Features(:, :, Sess2Sel);

        % Saves mean of all the features across sessions for the raster
        FeaturesCdtion{iCdt, hs, iCV} = mean(Y, 3);

        X = repmat(DesMat, size(Y, 3), 1);

        Y = shiftdim(Y, 1);
        Y = reshape(Y, [size(Y, 1) * size(Y, 2), size(Y, 3)]);

        BetaCdt{hs, iCV}(:, :, iCdt) = pinv(X) * Y;
      end

      clear Features Beta2Sel B X Y Mapping iBeta iSess;
    end

    clear iCdt;

  end

  cd(StartDir);

  %% Profiles Stim = f(Stim)
  fprintf('\n');

  for iToPlot = 1:numel(ToPlot)

    fprintf('\n\n');

    for ihs = 1:2

      for iCV = 1:numel(CVs)

        for iCdt = 1:size(Cdt, 1)

          fprintf('\n\n Rasters %s = f(%s)\n', CondNames{Cdt(iCdt, 1)}, ...
                  CondNames{Cdt(iCdt, 2)});

          % Sorting variables
          X = nan(1, NbVertex(ihs));
          X(1, VertexWithDataHS{ihs}) = BetaCdt{ihs, iCV}(iToPlot, :, Cdt(iCdt, 1));

          % Variables to sort : mean per vertex
          Y = nan(1, NbVertex(ihs));
          Y(1, VertexWithDataHS{ihs}) = mean([ ...
                                              BetaCdt{ihs, Folds{iCV, 2}(1)}(iToPlot, :, Cdt(iCdt, 2)); ...
                                              BetaCdt{ihs, Folds{iCV, 2}(2)}(iToPlot, :, Cdt(iCdt, 2))]);

          % Variables to sort : profile per vertex
          Profiles = nan(NbVertex(ihs), 6);
          Profiles(VertexWithDataHS{ihs}, :) = mean(cat(3, ...
                                                        FeaturesCdtion{Cdt(iCdt, 2), ihs, Folds{iCV, 2}(1)}, ...
                                                        FeaturesCdtion{Cdt(iCdt, 2), ihs, Folds{iCV, 2}(2)}), 3);

          fprintf('  Creating rasters for:');

          for iROI = 1:4

            NbBin = MinVert(strcmp(ROI(iROI).name, {MinVert.name}')).MinVert;

            fprintf(' %s,', ROI(iROI).name);

            X_ROI = [];
            Y_ROI = [];
            X_sort = [];
            Profiles_ROI = [];

            % Sort
            X_ROI = X(ROI(iROI).VertOfInt{ihs});
            [X_sort, I] = sort(X_ROI);

            Y_ROI = Y(ROI(iROI).VertOfInt{ihs});
            Y_ROI = Y_ROI(I);

            Profiles_ROI = Profiles(ROI(iROI).VertOfInt{ihs}, :);
            Profiles_ROI = Profiles_ROI(I, :);

            ToRemove = cat(3, isnan(Profiles_ROI), Profiles_ROI == 0);
            ToRemove = any(ToRemove, 3);
            ToRemove = any(ToRemove, 2);

            Profiles_ROI(ToRemove, :) = [];
            Y_ROI(ToRemove) = [];
            X_sort(ToRemove) = [];

            %% Get correlation/regression on all vertices
            R = corrcoef(X_sort, Y_ROI);
            rho_all_vert = R(1, 2);
            beta = glmfit(X_sort, Y_ROI, 'normal');
            slope_all_vert = beta(2);

            %% bin data
            IdxToAvg = floor(linspace(1, numel(X_sort), NbBin + 1));

            X_sort_Perc = [];
            Profiles_Perc = [];

            for iPerc = 2:numel(IdxToAvg)
              X_sort_Perc(iPerc - 1) = mean(X_sort(IdxToAvg((iPerc - 1):iPerc)));
              Profiles_Perc(iPerc - 1, :) = mean(Profiles_ROI(IdxToAvg((iPerc - 1):iPerc), :));
            end

            %% Store
            All_Profiles{iToPlot, iCdt, iROI, ihs}(:, :, iCV) = Profiles_Perc;
            All_X_sort{iToPlot, iCdt, iROI, ihs}(:, iCV) = X_sort_Perc;

            [rho, slope] = Correlation_regression_raster_ind(Profiles_Perc, DesMat, iToPlot, X_sort_Perc);
            Rho_Stim{iToPlot, iCdt, iROI, ihs}(:, iCV) = rho;
            Slope_Stim{iToPlot, iCdt, iROI, ihs}(:, iCV) = slope;

            Rho_Stim_all_vertices{iToPlot, iCdt, iROI, ihs}(:, iCV) = rho_all_vert;
            Slope_Stim_all_vertices{iToPlot, iCdt, iROI, ihs}(:, iCV) = slope_all_vert;

          end
        end
        clear X_lh Y_rh;

      end
    end
  end

  save(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'rasters', ...
                [SubLs(iSub).name '-SurfRasters-HS_Cdt.mat']), ...
       'ROI', 'Rho_Stim', 'Slope_Stim', ...
       'Rho_Stim_all_vertices', 'Slope_Stim_all_vertices', ...
       'All_X_sort', 'All_Profiles');
end
