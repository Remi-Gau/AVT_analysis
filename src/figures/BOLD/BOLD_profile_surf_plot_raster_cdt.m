clear;
close all;
clc;

StartDir = 'D:\Dropbox\PhD\Experiments\AVT\derivatives';
addpath(genpath(fullfile(StartDir, 'AVT-7T-code', 'subfun')));
Get_dependencies('D:\Dropbox/');

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

[m, n] = OptimizeSubplotNumber(NbSub);

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

% A = repmat(1:6,6,1);
% Cdt = [A(:), repmat((1:6)',6,1)];
% clear A
Cdt = [([1:6 2 1 4 3 6 5])' ([1:6 1:6])'];
Cdt2Plot = [(1:6)' (1:6)'];

ToPlot = {'Constant', 'Linear', 'Quadratic'};

%% Get data

for iSub = 1:NbSub

  fprintf('\n\n\n');

  fprintf('Processing %s\n', SubLs(iSub).name);

  Sub_dir = fullfile(StartDir, SubLs(iSub).name);

  load(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'rasters', ...
                [SubLs(iSub).name '-SurfRasters-HS_Cdt.mat']), ...
       'All_Profiles', 'All_X_sort', 'ROI');

  for iToPlot = 1:size(All_Profiles, 1) %#ok<*USENS>

    for iCdt = 1:size(Cdt2Plot, 1)
      Idx = all(Cdt == Cdt2Plot(iCdt), 2);

      for iROI = 1:size(All_Profiles, 3)

        for ihs = 1:size(All_Profiles, 4)

          All_Subj_All_Profiles{iToPlot, iCdt, iROI, ihs}(:, :, iSub) = ...
              mean(All_Profiles{iToPlot, Idx, iROI, ihs}, 3); %#ok<*AGROW>

          All_Subj_All_X_sort{iToPlot, iCdt, iROI, ihs}(:, iSub) = ...
              mean(All_X_sort{iToPlot, Idx, iROI, ihs}, 2); %#ok<*NASGU>

        end
      end

    end

  end

  clear X_sort_Perc All_Profiles;

end

%% plot raster stim = f(other stim)
ColorMap = seismic(1000);
FigDim = [50, 50, 1400, 700];
Visibility = 'on';
FontSize = 10;

clc;

for iToPlot = 1:size(All_Subj_All_Profiles, 1)

  for iCdt = 1:2:size(All_Subj_All_Profiles, 2)

    close all;

    Get = all(Cdt2Plot == [Cdt2Plot(iCdt, 1) Cdt2Plot(iCdt, 1)], 2);

    for iROI = 1:size(All_Subj_All_Profiles, 3)

      NbBin = MinVert(strcmp(ROI(iROI).name, {MinVert.name}')).MinVert;
      fprintf('    %s\n', ROI(iROI).name);

      % set limits for imagesc realtive to maximum value over both HS
      tmp = All_Subj_All_Profiles{iToPlot, iCdt, iROI, 1};
      tmp2 = All_Subj_All_Profiles{iToPlot, iCdt, iROI, 2};
      MAX = max(abs([tmp(:); tmp2(:)])) / 6;
      CLIM = [-1 * MAX MAX];

      for ihs = 1:size(All_Subj_All_Profiles, 4)
        if ihs == 1
          HS = 'L';
        else
          HS = 'R';
        end

        % Get sorting raster
        Sorting_Raster = All_Subj_All_Profiles{iToPlot, Get, iROI, ihs};
        X_sort = All_Subj_All_X_sort{iToPlot, Get, iROI, ihs};

        % Get sorted raster
        Profiles = All_Subj_All_Profiles{iToPlot, iCdt, iROI, ihs};

        %% Plot all subjects
        FigName = ['Raster_all_subjects_' ToPlot{iToPlot} '_' ROI(iROI).name '_' HS 'HS_'...
                   CondNames{Cdt2Plot(iCdt, 1)} '--f(' CondNames{Cdt2Plot(iCdt, 2)} ...
                   ')-NbBin=' num2str(NbBin)];
        FileName = fullfile(FigureFolder, 'cdt', ...
                            [FigName '.tiff']);

        h = figure('name', FigName, 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility); %#ok<*UNRCH>
        iSubPlot = 1;

        colormap(ColorMap);

        for iSubj = 1:NbSub

          subplot(m, n, iSubPlot);

          Title = sprintf('%s', SubLs(iSubj).name); % CondNames{Cdt2Plot(iCdt,2)});

          Plot_one_raster(Profiles(:, :, iSubj), Title, FontSize, CLIM);

          t = xlabel('cortical depth');
          set(t, 'fontsize', FontSize);

          ax = gca;

          if any(iSubPlot == n:n:NbSub)
            PlotColorBar(ax, ColorMap, CLIM);
          end

          if any(iSubPlot == 1:n:NbSub)
            YLabel = sprintf('Perc %s %s', ToPlot{iToPlot}, CondNames{Cdt2Plot(iCdt, 1)});
          else
            YLabel = '';
          end
          PlotSortedValues(ax, X_sort(:, iSubj)', NbBin, Profiles, ...
                           YLabel, 1, Sorting_Raster(:, :, iSubj), CLIM);

          iSubPlot = iSubPlot + 1;

        end

        mtit(strrep(FigName, '_', ' '), 'fontsize', FontSize + 4, 'xoff', 0, 'yoff', .025);
        print(gcf, FileName, '-dtiff');

        %% Plot group average
        FigName = ['Raster_Group_' ToPlot{iToPlot} '_' ROI(iROI).name '_' HS 'HS_'...
                   CondNames{Cdt2Plot(iCdt, 1)} '--f(' CondNames{Cdt2Plot(iCdt, 2)} ...
                   ')-NbBin=' num2str(NbBin)];
        FileName = fullfile(FigureFolder, 'cdt', ...
                            [FigName '.tiff']);

        h = figure('name', FigName, 'Position', FigDim, 'Color', ...
                   [1 1 1], 'Visible', Visibility); %#ok<*UNRCH>
        iSubPlot = 1;

        colormap(ColorMap);

        Title = '';

        Plot_one_raster(mean(Profiles, 3), Title, FontSize, CLIM);

        t = xlabel('cortical depth');
        set(t, 'fontsize', FontSize);

        ax = gca;

        PlotColorBar(ax, ColorMap, CLIM);

        YLabel = sprintf('Perc %s %s', ToPlot{iToPlot}, CondNames{Cdt2Plot(iCdt, 1)});
        PlotSortedValues(ax, mean(X_sort, 2)', NbBin, Profiles, YLabel, ...
                         1, mean(Sorting_Raster, 3), CLIM);

        mtit(strrep(FigName, '_', ' '), 'fontsize', FontSize + 4, 'xoff', 0, 'yoff', .025);
        print(gcf, FileName, '-dtiff');

      end

    end

  end

end
