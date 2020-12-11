% (C) Copyright 2020 Remi Gau
%
% Runs the PCM on the 3 sensory modalities (A, V and T) but separately for
% ipsi and contra
%
% It has 12 models that represent all the different ways that those 3
% conditions can be either:
%
% - scaled
% - scaled and independent
% - independent
%
% See also `Set3X3models()`
%

clc;
clear;
close all;

Space = 'surf';

MVNN = true;

Dirs = SetDir(Space, MVNN);

FigureDir = fullfile(Dirs.PCM, '3X3', 'figures');
Models = Set3X3models();

mkdir(FigureDir);

[~, ~, ~] = mkdir(fullfile(FigureDir, 'models')); %#ok<*UNRCH>

fig_h = PlotPcmModels(Models);

for iFig = 1:numel(fig_h)

    FigureName = ['Model-', num2str(iFig), '-', strrep( ...
                                                       strrep( ...
                                                              fig_h(iFig).Name, ...
                                                              ',', ...
                                                              ''), ...
                                                       ' ', ...
                                                       ''), ...
                  '.tif'];

    %     print(fig_h(iFig), ...
    %         fullfile(FigureDir, 'models', FigureName), ...
    %         '-dtiff');

end
