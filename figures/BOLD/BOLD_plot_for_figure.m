clc; clear;

StartDir = fullfile(pwd, '..','..', '..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'profiles');
FigureFolder = fullfile(StartDir, 'figures', 'profiles');
[~,~,~] = mkdir(FigureFolder);

for NbLayers=6
    for WithQuad= 1
        for WithPerm = 0
            
            if WithQuad
                load(fullfile(ResultsDir, strcat('ResultsVolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
            else
                load(fullfile(ResultsDir, strcat('ResultsVolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
            end
            
            
            %% Plots
            for iROI = 1:length(AllSubjects_Data)
                
                close all
                
                fprintf([AllSubjects_Data(iROI).name '\n'])
                
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
                ToPlot.Legend = {...
                    {'Audio','Left'}, {'','Right'};...
                    {'Visual',''}, {'',''};...
                    {'Tactile',''}, {'',''};...
                    };
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                %% Sensory modalities
                ToPlot.Name = [Name '-SensoryModalities'];
                ToPlot.Data = AllSubjects_Data(iROI).SensMod;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='off';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Left VS Right
                ToPlot.Name = [Name '-SideContrast'];
                ToPlot.Data = AllSubjects_Data(iROI).ContSide;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio: Left-Right'}, {'','Visual: Left-Right'} {'','Tactile: Left-Right'}};
                ToPlot.Visible='off';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Contrast between sensory modalities
                ToPlot.Name = [Name '-SensModContrasts'];
                ToPlot.Data = AllSubjects_Data(iROI).ContSensMod;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio-Visual'}, {'','Audio-Tactile'} {'','Visual-Tactile'}};
                ToPlot.Visible='off';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
            end
            cd(StartDir)
            
        end
    end
end


