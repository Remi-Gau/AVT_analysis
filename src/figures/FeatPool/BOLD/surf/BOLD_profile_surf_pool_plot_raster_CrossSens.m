% Plot rasters of cross-sensrory  = f(cross-sensory)

%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('D:\Dropbox\');

SubLs = dir('sub*');
NbSub = numel(SubLs);

FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'rasters');
mkdir(FigureFolder);
mkdir(fullfile(FigureFolder, 'CrossSens'));

load(fullfile(StartDir, 'results', 'roi', 'MinNbVert.mat'), 'MinVert');

NbLayers = 6;

DesMat = (1:NbLayers) - mean(1:NbLayers);
DesMat = [ones(NbLayers, 1) DesMat'];
% DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
DesMat = spm_orth(DesMat);

% sets{1} = 1:4; %#ok<*AGROW>
% sets{2} = 1:6;
% [a, b] = ndgrid(sets{:});
% Cdt = [a(:), b(:)];
% clear sets a b

A = repmat(1:6, 6, 1);
Cdt = [A(:), repmat((1:6)', 6, 1)];
clear A;

ToPlot = {'Constant', 'Linear', 'Quad'};

CondNames = { ...
             'A Stim Ipsi', 'A Stim Contra', ...
             'V Stim Ipsi', 'V Stim Contra', ...
             'T Stim Ipsi', 'T Stim Contra'
             %     'ATargL','ATargR';...
             %     'VTargL','VTargR';...
             %     'TTargL','TTargR';...
            };

% Permutation
for iSubj = 1:NbSub
    sets{iSubj} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
% ToPermute = [];

%% load data
for iSub = 1:NbSub

    fprintf('\n\n\n');

    fprintf('Processing %s\n', SubLs(iSub).name);

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);

    %     All_Profiles_CrossSide_fCrossSide{iToPlot, iCdt, iROI} = mean(Profiles_CV,3);
    %     All_X_sort_CrossSide_fCrossSide{iToPlot, iCdt, iROI} = mean(X_sort_CV,2);
    %
    %     Rho_CrossSide_fCrossSide{iToPlot, iCdt, iROI} = mean(rho_CV);
    %     Slope_CrossSide_fCrossSide{iToPlot, iCdt, iROI} = mean(slope_CV);

    load(fullfile(Sub_dir, 'results', 'profiles', 'surf', 'rasters', ...
                  [SubLs(iSub).name '-SurfRasters.mat']), ...
         'ROI', 'Rho_CrossSide_fCrossSide', 'Slope_CrossSide_fCrossSide', ...
         'All_X_sort_CrossSide_fCrossSide', 'All_Profiles_CrossSide_fCrossSide');

    X_Sort{iSub} = All_X_sort_CrossSide_fCrossSide;
    Profiles{iSub} = All_Profiles_CrossSide_fCrossSide;
    Rho_Stim_all_subjects{iSub} = Rho_CrossSide_fCrossSide;
    Slope_Stim_all_subjects{iSub} = Slope_CrossSide_fCrossSide;

    clear All_X_sort_CrossSide_fCrossSide ...
        All_Profiles_CrossSide_fCrossSide Rho_CrossSide_fCrossSide ...
        Slope_CrossSide_fCrossSide;
end

All_X_sort = X_Sort;
All_Profiles = Profiles;
Rho_Stim_all_subjects;
Slope_Stim_all_subjects;

clear Profiles X_Sort;

%% Grp level  ;
clc;
close all;

A = repmat(1:6, 6, 1);
Cdt = [A(:), repmat((1:6)', 6, 1)];
clear A;

% Color map
ColorMap = seismic(1000);

FigDim = [50, 50, 1200, 650];
Visibility = 'on';

CLIM = [-1.5 1.5];
CLIM2 = [-3 3];

SubPlots = {1 2:3 4:5, ...
            6 7:8 9:10};

for iToPlot = 2 % 1:numel(ToPlot)

    for iROI = 1:5

        if iROI < 3
            Cdt1 = 1:2;
            Cdt2 = [4 3 6 5];
        else
            Cdt1 = 3:4;
            Cdt2 = [2 1 6 5];
        end

        NbBin = MinVert(strcmp(ROI(iROI).name, {MinVert.name}')).MinVert;

        fprintf('    %s\n', ROI(iROI).name);

        for iCdt1 = Cdt1

            FileName = fullfile(FigureFolder, 'cdt', ...
                                ['GrpLvl_raster_AllCdt_' CondNames{iCdt1} '_' ToPlot{iToPlot} '_' ROI(iROI).name '.tif']);

            fig = figure('name', [strrep(ROI(iROI).name, ' ', '_') '-' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility); %#ok<*UNRCH>

            set(gca, 'units', 'centimeters');
            pos = get(gca, 'Position');
            ti = get(gca, 'TightInset');

            set(fig, 'PaperUnits', 'centimeters');
            set(fig, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
            set(fig, 'PaperPositionMode', 'manual');
            set(fig, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

            colormap(ColorMap);

            iSubPlot = 1;

            for iCdt2 = Cdt2

                clear X_sort Profiles Sorting_Raster;

                for iSubj = 1:size(All_Profiles, 2)
                    Get = all(Cdt == repmat([iCdt1 iCdt2], size(Cdt, 1), 1), 2);
                    Get2 = all(Cdt == repmat([iCdt1 iCdt1], size(Cdt, 1), 1), 2);

                    X_sort(iSubj, :) = mean(All_X_sort{iSubj}{iToPlot, Get, iROI}, 2);
                    Profiles(:, :, iSubj) = mean(All_Profiles{iSubj}{iToPlot, Get, iROI}, 3);
                    Sorting_Raster(:, :, iSubj) = mean(All_Profiles{iSubj}{iToPlot, Get2, iROI}, 3);

                    slope_all_vertices(iSubj, :) = mean( ...
                                                        Slope_Stim_all_vertices_all_subjects{iSubj}{iToPlot, Get, iROI}, 2);
                end

                %% plot sorting raster
                if numel(SubPlots{iSubPlot}) == 1
                    subplot(2, 5, SubPlots{iSubPlot});
                    PlotRectangle(NbLayers, 6, 0);
                    set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
                        'ytick', [], 'yticklabel', []);

                    subplot(2, 5, SubPlots{iSubPlot});
                    colormap(ColorMap);
                    MeanProfiles = mean(imgaussfilt(Sorting_Raster, [NbBin / 250 .0001]), 3);
                    imagesc(flipud(MeanProfiles), CLIM2);
                    set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
                        'ytick', [], 'yticklabel', []);

                    ax = gca;
                    YLabel = sprintf('Perc %s %s', ...
                                     ToPlot{iToPlot}, CondNames{iCdt1});

                    PlotSortedValues(ax, X_sort, NbBin, Profiles, YLabel, 1, [], [], 0);

                    iSubPlot = iSubPlot + 1;
                end

                %% Plot the main raster
                subplot(2, 5, SubPlots{iSubPlot});
                PlotRectangle(NbLayers, 6, 0);
                set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
                    'ytick', [], 'yticklabel', []);

                subplot(2, 5, SubPlots{iSubPlot});
                MeanProfiles = mean(imgaussfilt(Profiles, [NbBin / 250 .0001]), 3);
                imagesc(flipud(MeanProfiles), CLIM);

                axis([0.5 6.5 0 size(Profiles, 1)]);
                set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
                    'ytick', [], 'yticklabel', [], ...
                    'ticklength', [0.01 0], 'fontsize', 10);

                t = title(CondNames{iCdt2});
                set(t, 'fontsize', 10);

                ax = gca;
                [rho, slope] = CorRegRaster(Profiles, DesMat, iToPlot, X_sort);
                PlotCorrCoeff(ax, slope, ToPlot{iToPlot}, .025, .02, .06, .06, ...
                              [0.9 1.3 -.05 0.5], ToPermute);

                PlotCorrCoeff(ax, slope_all_vertices', ToPlot{iToPlot}, .2, .02, .06, .06, ...
                              [0.9 1.3 -.05 0.5], ToPermute);

                PlotColorBar(ax, ColorMap, CLIM);

                iSubPlot = iSubPlot + 1;

            end

            mtit([strrep(ROI(iROI).name, '_', ' ') ' - Percentile ' CondNames{iCdt1} ' - ' ToPlot{iToPlot}], 'fontsize', 14, 'xoff', 0, 'yoff', .025);

            %             imwrite(imind,cm,FileName,'tiff');

            print(fig, FileName, '-dtiff');

        end
    end
end
