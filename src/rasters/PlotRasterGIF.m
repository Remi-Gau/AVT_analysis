%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..', '..', '..');
cd (StartDir);
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'rasters');
mkdir(FigureFolder);
mkdir(fullfile(FigureFolder, 'cdt'));

CondNames = { ...
             'A Stim Ipsi', 'A Stim Contra', ...
             'V Stim Ipsi', 'V Stim Contra', ...
             'T Stim Ipsi', 'T Stim Contra'
             %     'ATargL','ATargR';...
             %     'VTargL','VTargR';...
             %     'TTargL','TTargR';...
            };

% Color map
X = 0:0.001:1;
R = 0.237 - 2.13 * X + 26.92 * X.^2 - 65.5 * X.^3 + 63.5 * X.^4 - 22.36 * X.^5;
G = ((0.572 + 1.524 * X - 1.811 * X.^2) ./ (1 - 0.291 * X + 0.1574 * X.^2)).^2;
B = 1 ./ (1.579 - 4.03 * X + 12.92 * X.^2 - 31.4 * X.^3 + 48.6 * X.^4 - 23.36 * X.^5);
ColorMap = [R' G' B'];
clear R G B;

FigDim = [100, 100, 1000, 1500];
Visibility = 'on';

nMax = 20;

CLIM = [-5 5];

load(fullfile(StartDir, 'results', 'roi', 'MinNbVert.mat'), 'MinVert');

load(fullfile(StartDir, 'results', 'profiles', 'surf', 'rasters', 'RasterAllCdt.mat'), ...
     'ROI', 'All_X_sort', 'All_Profiles');

%% Grp level  ; raster stim = f(other stim)
A = repmat(1:6, 6, 1);
Cdt = [A(:), repmat([1:6]', 6, 1)];
clear A;

ToPlot = {'Constant', 'Linear', 'Quadratic'};

for iToPlot = 1 % :numel(ToPlot)

    for iROI = 1:numel(ROI)

        close all;

        NbBin = MinVert(strcmp(ROI(iROI).name, {MinVert.name}')).MinVert;

        Splits = floor(linspace(1, NbBin, nMax + 1));

        fprintf('    %s\n', ROI(iROI).name);

        for iCdt = 1:6

            clear Sorting_Raster;

            FileName = fullfile(FigureFolder, 'cdt', ...
                                ['GrpLvl_raster_AllCdt_' CondNames{iCdt} '_' ToPlot{iToPlot} '_' ROI(iROI).name '.gif']);

            for iSubj = 1:size(All_Profiles, 1)
                Sorting_Raster(:, :, iSubj) = All_Profiles{iSubj, iToPlot, all(Cdt == iCdt, 2), iROI};
            end

            for n = 1:nMax

                h = figure('name', [strrep(ROI(iROI).name, ' ', '_') '-' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility); %#ok<*UNRCH>

                for iCdt2 = 1:6

                    clear X_sort Profiles;

                    for iSubj = 1:size(All_Profiles, 1)
                        Get = all(Cdt == repmat([iCdt iCdt2], size(Cdt, 1), 1), 2);
                        X_sort(iSubj, :) = All_X_sort{iSubj, iToPlot, Get, iROI};
                        Profiles(:, :, iSubj) = All_Profiles{iSubj, iToPlot, Get, iROI};
                    end

                    MeanProfiles = mean(Profiles, 3);

                    subplot(3, 2, iCdt2);

                    colormap(ColorMap);
                    imagesc(flipud(MeanProfiles), CLIM);

                    axis([0.5 6.5 0 size(Profiles, 1)]);

                    set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
                        'ytick', [], 'yticklabel', [], ...
                        'ticklength', [0.01 0], 'fontsize', 10);

                    t = title(CondNames{iCdt2});
                    set(t, 'fontsize', 10);

                    DephLevels = round(linspace(100, 0, 8));
                    DephLevels([1; end]) = [];
                    set(gca, 'color', 'none', 'tickdir', 'out', 'xtick', 1:6, 'xticklabel',  DephLevels, ...
                        'ytick', [], 'yticklabel', [], ...
                        'ticklength', [0.01 0], 'fontsize', 10);

                    t = xlabel('cortical depth');
                    set(t, 'fontsize', 10);

                    ax = gca;
                    axes('Position', ax.Position);

                    hold on;

                    errorbar(1:6, mean(MeanProfiles(Splits(n):Splits(n + 1), :)), ...
                             nansem(squeeze(mean(Profiles(Splits(n):Splits(n + 1), :, :))), 2), 'k', 'linewidth', 2);
                    for iSubj = 1:size(Profiles, 3)
                        plot(1:6, mean(Profiles(Splits(n):Splits(n + 1), :, iSubj)), ':k', 'linewidth', .5);
                    end
                    plot([1 6], [0 0], '--k');

                    axis([0.5 6.5 -8 8]);

                    DephLevels = round(linspace(100, 0, 8));
                    DephLevels([1; end]) = [];
                    set(gca, 'color', 'none', 'tickdir', 'out', 'xtick', 1:6, 'xticklabel',  DephLevels, ...
                        'YAxisLocation', 'right', 'ytick', -10:10, 'yticklabel', -10:10, ...
                        'ticklength', [0.01 0], 'fontsize', 10);

                    t = xlabel('cortical depth');
                    set(t, 'fontsize', 10);

                    if iCdt2 == 1 ||  iCdt2 == 3  ||  iCdt2 == 5
                        ax = gca;

                        YLabel = sprintf('Perc %s %s', ...
                                         ToPlot{iToPlot}, CondNames{iCdt});
                        PlotSortedValues(ax, X_sort, NbBin, Profiles, YLabel, 1, Sorting_Raster, CLIM);

                        tmp = axis;
                        r = rectangle('Position', [tmp(1) Splits(n) tmp(2) - tmp(1) (Splits(n + 1) - Splits(n))]);
                        set(r, 'linewidth', 2, 'EdgeColor', 'r');

                        clear tmp;

                    end

                    if iCdt2 == 2 ||  iCdt2 == 4 ||  iCdt2 == 6
                        PlotColorBar(ax, ColorMap, CLIM);
                    end

                end

                mtit([strrep(ROI(iROI).name, '_', ' ') ' - Percentile ' CondNames{iCdt} ' - ' ToPlot{iToPlot}], 'fontsize', 14, 'xoff', 0, 'yoff', .025);

                pause(0.2);

                frame = getframe(h);
                im = frame2im(frame);
                [imind, cm] = rgb2ind(im, 256);

                if n == 1
                    imwrite(imind, cm, FileName, 'gif', 'Loopcount', inf);
                else
                    imwrite(imind, cm, FileName, 'gif', 'WriteMode', 'append');
                end

                close all;

            end

        end

    end

end
