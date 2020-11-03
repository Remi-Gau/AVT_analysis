clc;
clear;

StartDir = fullfile(pwd, '..', '..');
addpath(genpath(fullfile(StartDir, 'code', 'subfun')));

Get_dependencies('/home/rxg243/Dropbox/');
Get_dependencies('D:\Dropbox\');

cd(StartDir);
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

load(fullfile(StartDir, 'results', 'roi', 'MinNbVert.mat'), 'MinVert');

for iSub = 1:NbSub

  fprintf('\n\n\n');

  fprintf('Processing %s\n', SubLs(iSub).name);

  Sub_dir = fullfile(StartDir, SubLs(iSub).name);
  Data_dir = fullfile(Sub_dir, 'ffx_nat', 'betas', '6_surf');

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
                             ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg.vtk$']);
    [vertex, faces, ~] = read_vtk(InfSurfFile, 0, 1);

    NbVertices(hs) = size(vertex, 2);

    % Load data or extract them
    fprintf('  Reading VTKs\n');
    if exist(FeatureSaveFile, 'file')
      load(FeatureSaveFile, 'VertexWithData', 'AllMapping');
      VertexWithDataHS{hs} = VertexWithData;
      MappingBothHS{hs} = AllMapping;
    else
      error('The features have not been extracted from the VTK files.');
    end

  end

  cd(StartDir);

  if any(NbVertex ~= NbVertices)
    NbVertex;
    NbVertices; %#ok<*NOPTS>
    error('The number of vertices does not match.');
  end

  Features_lh = nan(NbVertex(1), NbLayers, size(MappingBothHS{1}, 3));
  Features_lh(VertexWithDataHS{1}, :, :) = MappingBothHS{1};

  Features_rh = nan(NbVertex(2), NbLayers, size(MappingBothHS{2}, 3));
  Features_rh(VertexWithDataHS{2}, :, :) = MappingBothHS{2};

  %%
  fprintf(' Averaging for ROI:\n');

  for iROI = 1:numel(ROI)

    clear Data_ROI;

    Data_ROI.name = ROI(iROI).name;

    fprintf(['  '  Data_ROI.name '\n']);

    FeaturesL = Features_lh(ROI(iROI).VertOfInt{1}, :, :);
    FeaturesR = Features_rh(ROI(iROI).VertOfInt{2}, :, :);

    NbVert.All(iSub, 1:2, iROI) = [size(FeaturesL, 1) size(FeaturesR, 1)];

    NbVert.AnyNan(iSub, 1:2, iROI) = [sum(any(any(isnan(FeaturesL), 3), 2)) sum(any(any(isnan(FeaturesR), 3), 2))];
    NbVert.AnyZero(iSub, 1:2, iROI) = [sum(any(any(FeaturesL == 0, 3), 2)) sum(any(any(FeaturesR == 0, 3), 2))];

    NbVert.AllNan(iSub, 1:2, iROI) = [sum(all(any(isnan(FeaturesL), 3), 2)) sum(all(any(isnan(FeaturesR), 3), 2))];
    NbVert.AllZero(iSub, 1:2, iROI) = [sum(all(any(FeaturesL == 0, 3), 2)) sum(all(any(FeaturesR == 0, 3), 2))];

  end

end

cd(StartDir);

ResultsDir = fullfile(StartDir, 'results', 'profiles');
save(fullfile(ResultsDir, strcat('NbVertices_l-', num2str(NbLayers), '.mat')), ...
     'NbVert', 'SubLs', 'NbSub', 'ROI');

%%
close all;

FigureFolder = fullfile(StartDir, 'figures');

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

ToPLot = { ...
          {'A1', 'PT'}; ...
          {'V1', 'V2', 'V3', 'V4', 'V5'} };

FigDim = [100 50 1000 700];
Visible = 'on';

Scatter = linspace(1.1, 1.5, NbSub);

SubjectList = char({SubLs.name}');
SubjectList(:, 1:4) = [];

%%
figure('position', FigDim, 'name', 'ROI size', 'Color', [1 1 1], 'visible', Visible);

set(gca, 'units', 'centimeters');
pos = get(gca, 'Position');
ti = get(gca, 'TightInset');

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

iSubPlot = 1;

for iToPlot = 1:size(ToPLot, 1)

  for iROI = 1:numel(ToPLot{iToPlot, 1})

    Idx = find(strcmp({ROI.name}', ToPLot{iToPlot, 1}{iROI}));

    subplot(size(ToPLot, 1), 2, iSubPlot);
    hold on;
    errorbar(iROI, mean(NbVert.All(:, 1, Idx)), std(NbVert.All(:, 1, Idx)), '.k');
    for iSubj = 1:NbSub
      plot((iROI - 1) * 1 + Scatter(iSubj), NbVert.All(iSubj, 1, Idx), 'marker', '.', 'markersize', 30, ....
           'color', COLOR_Subject(iSubj, :));
    end
    XtickLabel1{iROI} = ROI(Idx).name;
    set(gca, 'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot, 1}), 'xticklabel', XtickLabel1);
    axis([0.9 numel(ToPLot{iToPlot, 1}) + .6 0 25000]);

    subplot(size(ToPLot, 1), 2, iSubPlot + 1);
    hold on;
    errorbar(iROI, mean(NbVert.All(:, 2, Idx)), std(NbVert.All(:, 2, Idx)), '.k');
    for iSubj = 1:NbSub
      plot((iROI - 1) * 1 + Scatter(iSubj), NbVert.All(iSubj, 2, Idx), 'marker', '.', 'markersize', 30, ....
           'color', COLOR_Subject(iSubj, :));
    end
    set(gca, 'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot, 1}), 'xticklabel', XtickLabel1);
    axis([0.9 numel(ToPLot{iToPlot, 1}) + .6 0 25000]);

  end

  clear XtickLabel1 XtickLabel2;

  iSubPlot = iSubPlot + 2;

end

subplot(size(ToPLot, 1), 2, 1);
title('LEFT');
subplot(size(ToPLot, 1), 2, 2);
title('RIGHT');

mtit('ROI size', 'xoff', 0, 'yoff', .025);

print(gcf, fullfile(FigureFolder, 'NbVerticesLeftRightROI_surf.tif'), '-dtiff');

%%
figure('position', FigDim, 'name', 'ROI coverage', 'Color', [1 1 1], 'visible', Visible);

set(gca, 'units', 'centimeters');
pos = get(gca, 'Position');
ti = get(gca, 'TightInset');

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);

iSubPlot = 1;

Coverage = 1 - NbVert.AnyNan ./ NbVert.All;

for iToPlot = 1:size(ToPLot, 1)

  for iROI = 1:numel(ToPLot{iToPlot, 1})

    Idx = find(strcmp({ROI.name}', ToPLot{iToPlot, 1}{iROI}));

    subplot(size(ToPLot, 1), 2, iSubPlot);
    hold on;
    errorbar(iROI, mean(Coverage(:, 1, Idx)), std(Coverage(:, 1, Idx)), '.k');
    for iSubj = 1:NbSub
      plot((iROI - 1) * 1 + Scatter(iSubj), Coverage(iSubj, 1, Idx), 'marker', '.', 'markersize', 30, ....
           'color', COLOR_Subject(iSubj, :));
    end
    XtickLabel1{iROI} = ROI(Idx).name;
    set(gca, 'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot, 1}), 'xticklabel', XtickLabel1);
    axis([0.9 numel(ToPLot{iToPlot, 1}) + .6 0 1]);

    subplot(size(ToPLot, 1), 2, iSubPlot + 1);
    hold on;
    errorbar(iROI, mean(Coverage(:, 2, Idx)), std(Coverage(:, 2, Idx)), '.k');
    for iSubj = 1:NbSub
      plot((iROI - 1) * 1 + Scatter(iSubj), Coverage(iSubj, 2, Idx), 'marker', '.', 'markersize', 30, ....
           'color', COLOR_Subject(iSubj, :));
    end
    set(gca, 'ygrid', 'on', 'xtick', 1:numel(ToPLot{iToPlot, 1}), 'xticklabel', XtickLabel1);
    axis([0.9 numel(ToPLot{iToPlot, 1}) + .6 0 1]);

  end

  clear XtickLabel1 XtickLabel2;

  iSubPlot = iSubPlot + 2;

end

subplot(size(ToPLot, 1), 2, 1);
title('LEFT');
subplot(size(ToPLot, 1), 2, 2);
title('RIGHT');

mtit('ROI coverage', 'xoff', 0, 'yoff', .025);

print(gcf, fullfile(FigureFolder, 'CoverageLeftRightROI_surf.tif'), '-dtiff');

%% Print table
Legends1 = {'Nb Vertices (*10^3)', '', '', '', '', '', '', '', '', 'Coverage'};
Legends2 = {'mean', 'std', 'range', '', '', '', '', ''};
SavedTxt = fullfile('D:\Dropbox\PhD\Experiments\AVT\derivatives\', 'Number_vertices_coverage.csv');

Coverage = 1 - sum(NbVert.AnyNan, 2) ./ sum(NbVert.All, 2);

fid = fopen (SavedTxt, 'w');

for i = 1:length(Legends1)
  fprintf (fid, '%s,', Legends1{i});
end
fprintf (fid, '\nROI,');

for j = 1:2
  for i = 1:length(Legends2)
    fprintf (fid, '%s,', Legends2{i});
  end
end
fprintf (fid, '\n');

for iROI = 1:numel(ROI)
  Idx = iROI; % find(strcmp({ROI.name}',ToPLot{iToPlot,1}{iROI}));

  fprintf (fid, '%s,', ROI(Idx).name);

  fprintf (fid, '%f,', mean(sum(NbVert.All(:, :, Idx), 2)) / 1000);
  fprintf (fid, '%f,', std(sum(NbVert.All(:, :, Idx), 2)) / 1000);
  fprintf (fid, '(,%f,', min(sum(NbVert.All(:, :, Idx), 2)) / 1000);
  fprintf (fid, '-,%f,),', max(sum(NbVert.All(:, :, Idx), 2)) / 1000);

  fprintf (fid, ',');

  fprintf (fid, '%f,', mean(sum(Coverage(:, :, Idx), 2)));
  fprintf (fid, '%f,', std(sum(Coverage(:, :, Idx), 2)));
  fprintf (fid, '(,%f,', min(sum(Coverage(:, :, Idx), 2)));
  fprintf (fid, '-,%f,),', max(sum(Coverage(:, :, Idx), 2)));

  fprintf (fid, '\n');

end

fclose (fid);
