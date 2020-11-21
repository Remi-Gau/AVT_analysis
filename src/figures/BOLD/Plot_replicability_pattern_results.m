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

Col = reshape(1:18, 3, 6)';

set(0, 'defaultAxesFontName', 'Arial');
set(0, 'defaultTextFontName', 'Arial');
FigDim = [50, 50, 1300, 600];
ColorMap = seismic(1000);

HS = 'LR';

ROI(1).name = 'A1';
ROI(2).name = 'PT';
ROI(3).name = 'V1';
ROI(4).name = 'V2';
ROI(5).name = 'V3';

NbROI = numel(ROI);

%%
FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'replicability', 'day2day');
mkdir(FigureFolder);

All_Subjs_All_Cdt = cell(2, numel(CondNames), 5);

MinMax = [];

for  iSub =  1:NbSub

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'correlations');
    load(fullfile(Results_dir, [SubLs(iSub).name '-Day2DayCorrelation.mat']), ...
         'RHO_day', 'RHO_session');

    close all;

    % set limits for imagesc
    CLIM = [-.1 0.5];

    % adapts color scale so that 0 is white
    [NewColorMap] = Create_non_centered_diverging_colormap(CLIM, ColorMap);

    for iROI = 1:NbROI

        opt.FigName = sprintf('%s - Day2DayCorrelation - %s', ...
                              SubLs(iSub).name, ROI(iROI).name);

        fig = figure('name', opt.FigName, ...
                     'Position', FigDim, 'Color', [1 1 1]);

        colormap(NewColorMap);

        iSubplot = 1;

        for hs = 1:2
            for iCdt = 1:numel(CondNames)

                subplot(2, numel(CondNames), iSubplot);

                Mat2Plot = RHO_day(Col(iCdt, :), Col(iCdt, :), hs, iROI);

                % collected maximum and minimum values to adjust CLIM post
                % hoc
                tmp = sort(unique(Mat2Plot(:)));
                MinMax(end + 1, :) = [min(tmp(:)) tmp(end - 1)];

                imagesc(Mat2Plot, CLIM);

                All_Subjs_All_Cdt{hs, iCdt, iROI}(:, :, iSub) = Mat2Plot;

                axis square;

                set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 8, ...
                    'xtick', 1:3, 'xticklabel', {'Day 1', 'Day 2', 'Day 3'}, ...
                    'ytick', 1:3, 'yticklabel', {'Day 1', 'Day 2', 'Day 3'});

                iSubplot = iSubplot + 1;

                if hs == 1
                    t = title(CondNames{iCdt});
                    set(t, 'fontsize', 12);
                end

                if iCdt == 1
                    t = ylabel(['Hemisphere ' HS(hs)]);
                    set(t, 'fontsize', 12);
                end
            end
        end

        mtit(opt.FigName, 'fontsize', 12);

        print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');

    end

end

min(MinMax);
max(MinMax);

%% plot color scale

opt.FigName = 'Color bar - day 2 day';

fig = figure('name', opt.FigName, ...
             'Position', [50, 50, 200, 600], 'Color', [1 1 1]);

colormap(NewColorMap);

CLIM = [-.1 0.5];

imagesc(repmat((1000:-1:1)', 1, 100));

set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 12, ...
    'xtick', [], 'xticklabel', [], ...
    'ytick', linspace(1, 1000, 7), 'yticklabel', linspace(.5, -.1, 7));

mtit(opt.FigName, 'fontsize', 12);

print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');

%% Plot group average
close all;

% set limits for imagesc
CLIM = [-.01 0.32];

% adapts color scale so that 0 is white
[NewColorMap] = Create_non_centered_diverging_colormap(CLIM, ColorMap);

MinMax = [];

for iROI = 1:NbROI

    opt.FigName = sprintf('GroupAVG - Day2DayCorrelation - FisherTransPearsonCorCoeff - %s', ...
                          ROI(iROI).name);

    fig = figure('name', opt.FigName, ...
                 'Position', FigDim, 'Color', [1 1 1]);

    colormap(NewColorMap);

    iSubplot = 1;

    for hs = 1:2
        for iCdt = 1:numel(CondNames)

            subplot(2, numel(CondNames), iSubplot);

            Mat2Plot = mean(atanh(All_Subjs_All_Cdt{hs, iCdt, iROI}), 3);

            tmp = sort(unique(Mat2Plot(:)));
            MinMax(end + 1, :) = [min(tmp(:)) tmp(end - 1)];

            imagesc(Mat2Plot, CLIM);

            axis square;

            set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 8, ...
                'xtick', 1:3, 'xticklabel', {'Day 1', 'Day 2', 'Day 3'}, ...
                'ytick', 1:3, 'yticklabel', {'Day 1', 'Day 2', 'Day 3'});

            iSubplot = iSubplot + 1;

            if hs == 1
                t = title(CondNames{iCdt});
                set(t, 'fontsize', 12);
            end

            if iCdt == 1
                t = ylabel(['Hemisphere ' HS(hs)]);
                set(t, 'fontsize', 12);
            end
        end
    end

    mtit(opt.FigName, 'fontsize', 12);

    print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');

end

min(MinMax);
max(MinMax);

%% plot color scale

opt.FigName = 'Color bar - day 2 day - GrpAvg';

fig = figure('name', opt.FigName, ...
             'Position', [50, 50, 200, 600], 'Color', [1 1 1]);

colormap(NewColorMap);

CLIM = [-.01 0.32];

imagesc(repmat((1000:-1:1)', 1, 100));

set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 12, ...
    'xtick', [], 'xticklabel', [], ...
    'ytick', linspace(1, 1000, 5), 'yticklabel', linspace(.32, -.02, 5));

mtit(opt.FigName, 'fontsize', 12);

print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');

%% Compare to a reference matrix
% See http://mvpa.blogspot.com/2018/07/rsa-how-to-describe-with-single-number.html
All_Subjs_All_Cdt_linear = cell(2, numel(CondNames), 5);

ReferenceMat = [1 0 1];

% "Linearize" the correlation matrices
for hs = 1:2
    for iCdt = 1:numel(CondNames)
        for iROI = 1:NbROI
            for iSubj = 1:NbSub

                % Only take half of the matrix
                A = All_Subjs_All_Cdt{hs, iCdt, iROI}(:, :, iSubj);
                A(A == 1) = 0; % necessary for squareform to work
                A = squareform(A);

                All_Subjs_All_Cdt_linear{hs, iCdt, iROI}(iSubj, :) = A;

                % get Kendall's tau
                Kendals{hs}(iROI, iCdt, iSubj) = ...
                    corr(A', ReferenceMat', 'type', 'Kendall');

                clear A;
            end

            % Z trasnform of correlation coeeficients
            A = atanh(All_Subjs_All_Cdt_linear{hs, iCdt, iROI});
            % Similarity structure score
            % See Pereira 2013 DOI: 10.1109/PRNI.2013.10
            SSS{hs}(iROI, iCdt, :) = mean(A(:, [1 3]), 2) - A(:, 2);

            clear A;

        end
    end
end

% plot them SSS and kendal's tau
close all;

opt.FigName = sprintf('Day2DayCorrelation - Summary Kendals Tau');
figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);

% [ NewColorMap ] = Create_non_centered_diverging_colormap([0 .8], ColorMap);
% colormap(NewColorMap)
% subplot(121)
% imagesc(mean(abs(),3), [0 .8])
%
% subplot(122)
% imagesc(mean(abs(Kendals{2}),3), [0 .8])
iSubplot = 1;
for iROI = 1:NbROI
    for hs = 1:2

        subplot(NbROI, 2, iSubplot);
        hold on;

        plot(repmat((1:6)', 1, 10), squeeze(Kendals{hs}(iROI, :, :)), ...
             'color', [0.5 0.5 0.5]);

        plot([1 6], [0 0], '--k');

        errorbar(1:6, mean(Kendals{hs}(iROI, :, :), 3), nansem(Kendals{hs}(iROI, :, :), 3), ...
                 'o-k', 'linewidth', 1.5);

        set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 8, ...
            'xtick', 1:6, 'xticklabel', CondNames, ...
            'ytick', -1:.25:1, 'yticklabel', -1:.25:1);

        if hs == 1
            t = ylabel(ROI(iROI).name);
            set(t, 'fontsize', 12);
        end

        if iROI == 1
            switch hs
                case 1
                    t = title('Left HS');
                    set(t, 'fontsize', 12);
                case 2
                    t = title('Right HS');
                    set(t, 'fontsize', 12);
            end
        end

        axis([0.5 6.5 -1 1]);

        iSubplot = iSubplot + 1;
    end
end
mtit(opt.FigName, 'fontsize', 12);
print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');

opt.FigName = sprintf('Day2DayCorrelation - Summary Similarity structure score');
figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
% colormap(ColorMap)
% subplot(121)
% imagesc(mean(SSS{hs},3), [-0.04 0.04])
%
% subplot(122)
% imagesc(mean(SSS{hs},3), [-0.04 0.04])
iSubplot = 1;
for iROI = 1:NbROI
    for hs = 1:2

        subplot(NbROI, 2, iSubplot);
        hold on;

        plot(repmat((1:6)', 1, 10), squeeze(SSS{hs}(iROI, :, :)), ...
             'color', [0.5 0.5 0.5]);

        plot([1 6], [0 0], '--k');

        errorbar(1:6, mean(SSS{hs}(iROI, :, :), 3), nansem(SSS{hs}(iROI, :, :), 3), ...
                 'o-k', 'linewidth', 1.5);

        set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 8, ...
            'xtick', 1:6, 'xticklabel', CondNames, ...
            'ytick', -0.1:.025:0.1, 'yticklabel', -0.1:.025:0.1);

        if hs == 1
            t = ylabel(ROI(iROI).name);
            set(t, 'fontsize', 12);
        end

        if iROI == 1
            switch hs
                case 1
                    t = title('Left HS');
                    set(t, 'fontsize', 12);
                case 2
                    t = title('Right HS');
                    set(t, 'fontsize', 12);
            end
        end

        axis([0.5 6.5 -0.1 0.1]);

        iSubplot = iSubplot + 1;
    end
end
mtit(opt.FigName, 'fontsize', 12);
print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');

return

%% Plot results session by session
clc;
close all;

FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'replicability', 'run2run');
mkdir(FigureFolder);

set(0, 'defaultAxesFontName', 'Arial');
set(0, 'defaultTextFontName', 'Arial');

FigDim = [50, 50, 1300, 600];

ColorMap = seismic(1000);

HS = 'LR';

MinMax = [];

for  iSub = [1:4 6:NbSub] % [1:4 6:NbSub]

    Col = reshape(1:(6 * sum(RunPerSes(iSub).RunsPerSes)), ...
                  sum(RunPerSes(iSub).RunsPerSes), 6)';

    Subcol = [0 cumsum(RunPerSes(iSub).RunsPerSes)];

    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'correlations');
    load(fullfile(Results_dir, [SubLs(iSub).name '-Day2DayCorrelation.mat']), ...
         'RHO_day', 'RHO_session');

    close all;

    % set limits for imagesc
    CLIM = [-.25 0.35];

    % adapts color scale so that 0 is white
    [NewColorMap] = Create_non_centered_diverging_colormap(CLIM, ColorMap);

    for iROI = 1:NbROI

        for hs = 1:2

            opt.FigName = sprintf('%s - Run2RunCorrelation - %s - Hemisphere %s', ...
                                  SubLs(iSub).name, ROI(iROI).name, HS(hs));

            fig = figure('name', opt.FigName, ...
                         'Position', FigDim, 'Color', [1 1 1]);

            colormap(NewColorMap);

            %             if hs==1
            iSubplot = 1;
            %             else
            %                 iSubplot = 19;
            %             end

            for iCdt = 1:numel(CondNames)

                for iDay = 1:3

                    subplot(3, numel(CondNames), iSubplot + numel(CondNames) * (iDay - 1));

                    Mat2PlotAllDays = RHO_session(Col(iCdt, :), Col(iCdt, :), hs, iROI);
                    Mat2Plot = Mat2PlotAllDays((Subcol(iDay) + 1):Subcol(iDay + 1), (Subcol(iDay) + 1):Subcol(iDay + 1));

                    % collected maximum and minimum values to adjust CLIM post
                    % hoc
                    tmp = sort(unique(Mat2Plot(:)));
                    MinMax(end + 1, :) = [min(tmp(:)) tmp(end - 1)];

                    imagesc(Mat2Plot, CLIM);
                    axis square;

                    if iDay == 1
                        title(CondNames{iCdt});
                    end

                    if iCdt == 1
                        if iDay == 1
                            ylabel(['Day ' num2str(iDay)]);
                        elseif iDay == 2
                            ylabel(sprintf('Hemisphere %s\nDay %i', HS(hs), iDay));
                        else
                            ylabel(['Day ' num2str(iDay)]);
                        end
                    end

                    set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 8, ...
                        'xtick', 1:7, 'xticklabel', 1:7, ...
                        'ytick', 1:7, 'yticklabel', 1:7);

                end

                iSubplot = iSubplot + 1;

            end

            mtit(opt.FigName, 'fontsize', 12, 'xoff', 0, 'yoff', .035);

            print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');

        end

    end

end

min(MinMax);
max(MinMax);

%% plot color scale

opt.FigName = 'Color bar - day 2 day';

fig = figure('name', opt.FigName, ...
             'Position', [50, 50, 200, 600], 'Color', [1 1 1]);

colormap(NewColorMap);

CLIM = [-.25 0.35];

imagesc(repmat((1000:-1:1)', 1, 100));

set(gca, 'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 12, ...
    'xtick', [], 'xticklabel', [], ...
    'ytick', linspace(1, 1000, 13), 'yticklabel', linspace(.35, -.25, 13));

mtit(opt.FigName, 'fontsize', 12);

print(gcf, fullfile(FigureFolder, [strrep(opt.FigName, ' ', '') '.tif']), '-dtiff');
