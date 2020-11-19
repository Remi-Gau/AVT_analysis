clc;
clear;

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'AVT-7T-code', 'subfun')));
Get_dependencies('D:\Dropbox/');
cd (StartDir);

ResultsDir = fullfile(StartDir, 'results', 'profiles');
FigureFolder = fullfile(StartDir, 'figures', 'profiles');
[~, ~, ~] = mkdir(FigureFolder);

for NbLayers = 6
  for WithQuad = 1
    for WithPerm = 1

      if WithQuad
        load(fullfile(ResultsDir, strcat('ResultsVolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
      else
        load(fullfile(ResultsDir, strcat('ResultsVolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
      end

      if  WithPerm
        sets = {};
        for iSub = 1:10
          sets{iSub} = [-1 1]; %#ok<*AGROW>
        end
        [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
        clear sets;
        ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
      else
        ToPermute = [];
      end

      ToPlot.ToPermute = ToPermute;

      %% Plots
      for iROI = 1:length(AllSubjects_Data)

        close all;

        fprintf([AllSubjects_Data(iROI).name '\n']);

        Name = strrep(AllSubjects_Data(iROI).name, '_', ' ');
        if WithQuad
        else
          Name = [Name '-NoQuad-ALL'];
        end

        %% Basic condition
        ToPlot.Name = [Name '-Conditions'];
        ToPlot.Data = AllSubjects_Data(iROI).Cdt;
        ToPlot.PlotSub = 1;
        ToPlot.WithQuad = WithQuad;
        ToPlot.SubPlotOrder = [1 4 2 5 3 6];
        ToPlot.Legend = { ...
                         {'Audio', 'Left'}, {'', 'Right'}; ...
                         {'Visual', ''}, {'', ''}; ...
                         {'Tactile', ''}, {'', ''} ...
                        };
        ToPlot.Visible = 'on';
        ToPlot.FigureFolder = FigureFolder;
        ToPlot.MVPA = 0;

        PlotLayersForFig(ToPlot);

        clear ToPlot;

        %% Sensory modalities
        ToPlot.Name = [Name '-SensoryModalities'];
        ToPlot.Data = AllSubjects_Data(iROI).SensMod;
        ToPlot.PlotSub = 1;
        ToPlot.WithQuad = WithQuad;
        ToPlot.SubPlotOrder = [1 2 3];
        ToPlot.Legend = {{'', 'Audio'}, {'', 'Visual'} {'', 'Tactile'}};
        ToPlot.Visible = 'off';
        ToPlot.FigureFolder = FigureFolder;
        ToPlot.MVPA = 0;

        PlotLayersForFig(ToPlot);

        clear ToPlot;

        %% Left VS Right
        ToPlot.Name = [Name '-SideContrast'];
        ToPlot.Data = AllSubjects_Data(iROI).ContSide;
        ToPlot.PlotSub = 1;
        ToPlot.WithQuad = WithQuad;
        ToPlot.SubPlotOrder = [1 2 3];
        ToPlot.Legend = {{'', 'Audio: Left-Right'}, {'', 'Visual: Left-Right'} {'', 'Tactile: Left-Right'}};
        ToPlot.Visible = 'off';
        ToPlot.FigureFolder = FigureFolder;
        ToPlot.MVPA = 0;

        PlotLayersForFig(ToPlot);

        clear ToPlot;

        %% Contrast between sensory modalities
        ToPlot.Name = [Name '-SensModContrasts'];
        ToPlot.Data = AllSubjects_Data(iROI).ContSensMod;
        ToPlot.PlotSub = 1;
        ToPlot.WithQuad = WithQuad;
        ToPlot.SubPlotOrder = [1 2 3];
        ToPlot.Legend = {{'', 'Audio-Visual'}, {'', 'Audio-Tactile'} {'', 'Visual-Tactile'}};
        ToPlot.Visible = 'off';
        ToPlot.FigureFolder = FigureFolder;
        ToPlot.MVPA = 0;

        PlotLayersForFig(ToPlot);

        clear ToPlot;

      end
      cd(StartDir);

    end
  end
end
