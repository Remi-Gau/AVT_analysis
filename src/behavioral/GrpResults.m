%%
clc;
clear;
close all;

StartDir = fullfile(pwd, '..', '..');
cd (StartDir);

FigureFolder = fullfile(StartDir, 'figures', 'behavioral');
mkdir(FigureFolder);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

FigDim = [100 100 1500 1000];

colors = 'rgbk';

SubLs = dir('sub*');
NbSub = numel(SubLs);

GrpRes.D_prime.data = nan(20, 4, NbSub);
GrpRes.Accuracy.data = nan(20, 4, NbSub);
GrpRes.CorrectRejection.data = nan(20, 4, NbSub);
GrpRes.Miss.data = nan(20, 4, NbSub);
GrpRes.Hits.data = nan(20, 4, NbSub);
GrpRes.FalseAlarms.data = nan(20, 4, NbSub);

for iSub = 1:NbSub % for each subject

    fprintf('\n\nProcessing %s\n', SubLs(iSub).name);

    % Subject directory
    SubDir = fullfile(StartDir, SubLs(iSub).name);

    %     copyfile(fullfile('E:\derivatives',SubLs(iSub).name,['Behavior_' SubLs(iSub).name '.mat']),...
    %         fullfile(SubDir,['Behavior_' SubLs(iSub).name '.mat']))
    %
    load(fullfile(SubDir, ['Behavior_' SubLs(iSub).name '.mat']), 'D_prime', 'CorrectRejection', 'Miss', 'Hits', ...
         'FalseAlarms');

    Accuracy = round([(Hits + CorrectRejection) ./ (Hits + Miss + CorrectRejection + FalseAlarms)] * 100);

    FalseAlarmRate = FalseAlarms ./ (FalseAlarms + CorrectRejection) * 100;
    CorrectRejectionRate = CorrectRejection ./ (FalseAlarms + CorrectRejection) * 100;
    HitRate = Hits ./ (Hits + Miss) * 100;
    MissRate = Miss ./ (Hits + Miss) * 100;

    GrpRes.D_prime.data(1:size(D_prime, 1), :, iSub) = D_prime;
    GrpRes.Accuracy.data(1:size(D_prime, 1), :, iSub) = Accuracy;
    GrpRes.CorrectRejection.data(1:size(CorrectRejection, 1), :, iSub) = CorrectRejectionRate;
    GrpRes.Miss.data(1:size(Miss, 1), :, iSub) = MissRate;
    GrpRes.Hits.data(1:size(Hits, 1), :, iSub) = HitRate;
    GrpRes.FalseAlarms.data(1:size(FalseAlarms, 1), :, iSub) = FalseAlarmRate;

end

GrpRes.D_prime.mean = squeeze(nanmean(GrpRes.D_prime.data))';
GrpRes.Accuracy.mean = squeeze(nanmean(GrpRes.Accuracy.data))';
GrpRes.CorrectRejection.mean = squeeze(nanmean(GrpRes.CorrectRejection.data))';
GrpRes.Miss.mean = squeeze(nanmean(GrpRes.Miss.data))';
GrpRes.Hits.mean = squeeze(nanmean(GrpRes.Hits.data))';
GrpRes.FalseAlarms.mean = squeeze(nanmean(GrpRes.FalseAlarms.data))';

GrpRes.D_prime.MEAN = nanmean(GrpRes.D_prime.mean);
GrpRes.D_prime.STD = nanstd(GrpRes.D_prime.mean);
GrpRes.D_prime.SEM = nansem(GrpRes.D_prime.mean);

GrpRes.Accuracy.MEAN = nanmean(GrpRes.Accuracy.mean);
GrpRes.Accuracy.STD = nanstd(GrpRes.Accuracy.mean);
GrpRes.Accuracy.SEM = nansem(GrpRes.Accuracy.mean);

GrpRes.CorrectRejection.MEAN = nanmean(GrpRes.CorrectRejection.mean);
GrpRes.CorrectRejection.STD = nanstd(GrpRes.CorrectRejection.mean);
GrpRes.CorrectRejection.SEM = nansem(GrpRes.CorrectRejection.mean);

GrpRes.Miss.MEAN = nanmean(GrpRes.Miss.mean);
GrpRes.Miss.STD = nanstd(GrpRes.Miss.mean);
GrpRes.Miss.SEM = nansem(GrpRes.Miss.mean);

GrpRes.Hits.MEAN = nanmean(GrpRes.Hits.mean);
GrpRes.Hits.STD = nanstd(GrpRes.Hits.mean);
GrpRes.Hits.SEM = nansem(GrpRes.Hits.mean);

GrpRes.FalseAlarms.MEAN = nanmean(GrpRes.FalseAlarms.mean);
GrpRes.FalseAlarms.STD = nanstd(GrpRes.FalseAlarms.mean);
GrpRes.FalseAlarms.SEM = nansem(GrpRes.FalseAlarms.mean);

%%
COLOR_Subject = [
                 31, 120, 180
                 178, 223, 138
                 51, 160, 44
                 251, 154, 153
                 227, 26, 28
                 253, 191, 111
                 255, 127, 0
                 202, 178, 214
                 106, 61, 154
                 0, 0, 130];
COLOR_Subject = COLOR_Subject / 255;

Scatter = linspace(0, .4, size(COLOR_Subject, 1));

Titles = {'Audio', 'Visual', 'Tactile', 'Total'};

%%
fig = figure('name', 'AVT', 'position', FigDim);

set(gca, 'units', 'centimeters');
pos = get(gca, 'Position');
ti = get(gca, 'TightInset');

set(fig, 'PaperUnits', 'centimeters');
set(fig, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
set(fig, 'PaperPositionMode', 'manual');
set(fig, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

set(fig, 'Visible', 'on');

for iCdt = 1:4

    ToPlotMean = [ ...
                  GrpRes.Hits.MEAN(iCdt), ...
                  GrpRes.Miss.MEAN(iCdt), ...
                  GrpRes.FalseAlarms.MEAN(iCdt), ...
                  GrpRes.CorrectRejection.MEAN(iCdt), ...
                  GrpRes.Accuracy.MEAN(iCdt)];

    ToPlotDispersion = [ ...
                        GrpRes.Hits.STD(iCdt), ...
                        GrpRes.Miss.STD(iCdt), ...
                        GrpRes.FalseAlarms.STD(iCdt), ...
                        GrpRes.CorrectRejection.STD(iCdt), ...
                        GrpRes.Accuracy.STD(iCdt)];

    SubjData = [ ...
                GrpRes.Hits.mean(:, iCdt), ...
                GrpRes.Miss.mean(:, iCdt), ...
                GrpRes.FalseAlarms.mean(:, iCdt), ...
                GrpRes.CorrectRejection.mean(:, iCdt), ...
                GrpRes.Accuracy.mean(:, iCdt)];

    subplot(4, 1, iCdt);
    hold on;

    h = errorbar(1:5, ToPlotMean, ToPlotDispersion, '.k');

    for iSubj = 1:size(COLOR_Subject, 1)
        plot((1.2:1:5.2) + Scatter(iSubj), SubjData(iSubj, :), ...
             'linestyle', 'none', ...
             'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(iSubj, :), ...
             'MarkerFaceColor', COLOR_Subject(iSubj, :), 'MarkerSize', 28);
    end

    axis([0.8 5.8 -5 105]);
    set(gca, 'tickdir', 'out', ...
        'xtick', 1:5, 'xticklabel', {'Hits', 'Miss', 'FA', 'CR', 'Accuracy'}, ...
        'ytick', 0:25:100, 'yticklabel', 0:25:100, ...
        'ticklength', [0.01 0.01], 'fontsize', 8);
    box off;
    grid on;

    t = ylabel(Titles{iCdt});
    set(t, 'fontsize', 12);

end

print(gcf, fullfile(FigureFolder, 'GrpResulst_Acc.tif'), '-dtiff');

%%
fig = figure('name', 'AVT', 'position', FigDim);

set(gca, 'units', 'centimeters');
pos = get(gca, 'Position');
ti = get(gca, 'TightInset');

set(fig, 'PaperUnits', 'centimeters');
set(fig, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
set(fig, 'PaperPositionMode', 'manual');
set(fig, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

set(fig, 'Visible', 'on');

hold on;

ToPlotMean = GrpRes.D_prime.MEAN;

ToPlotDispersion = GrpRes.D_prime.STD;

h = errorbar(1:4, ToPlotMean, ToPlotDispersion, '.k');

SubjData = GrpRes.D_prime.mean;

for iSubj = 1:size(COLOR_Subject, 1)
    plot((1.2:1:4.2) + Scatter(iSubj), SubjData(iSubj, :), ...
         'linestyle', 'none', ...
         'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(iSubj, :), ...
         'MarkerFaceColor', COLOR_Subject(iSubj, :), 'MarkerSize', 28);
end

axis([0.8 4.8 2 4]);
set(gca, 'tickdir', 'out', ...
    'xtick', [], 'xticklabel', [], ...
    'ytick', 0:.5:4, 'yticklabel', 0:.5:4, ...
    'ticklength', [0.01 0.01], 'fontsize', 8);
box off;
grid on;

t = ylabel('D prime');
set(t, 'fontsize', 12);

print(gcf, fullfile(FigureFolder, 'GrpResulst_d_prime.tif'), '-dtiff');

%%
SavedTxt = fullfile(FigureFolder, 'Behavioral_results.csv');
fid = fopen (SavedTxt, 'w');

fprintf (fid, 'Condition,,hit,,,,,miss,,,,,faslse alarm,,,,,correct rejection,,,,,accuracy,,,,,d prime,,,,,');

for iCdt = 1:4

    fprintf (fid, '\n');

    fprintf(fid, '%s,,', Titles{iCdt});

    for Output = 1:6
        switch Output
            case 1
                Data = GrpRes.Hits;
            case 2
                Data = GrpRes.Miss;
            case 3
                Data = GrpRes.FalseAlarms;
            case 4
                Data = GrpRes.CorrectRejection;
            case 5
                Data = GrpRes.Accuracy;
            case 6
                Data = GrpRes.D_prime;
        end

        for i = 1:2
            if i == 1
                fprintf (fid, '%f,', Data.MEAN(iCdt));
            else
                fprintf (fid, '(,%f,),,', Data.STD(iCdt));
            end
        end
    end

end

fclose(fid);
