clc; clear;

StartDir = fullfile(pwd, '..','..', '..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'profiles');
FigureFolder = fullfile(StartDir, 'figures', 'profiles');
[~,~,~] = mkdir(FigureFolder);

for NbLayers=6
    for WithQuad= 1
        for WithPerm = 0
            
            if WithQuad
                load(fullfile(ResultsDir, strcat('ResultsVolPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
            else
                load(fullfile(ResultsDir, strcat('ResultsVolPoolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
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
                ToPlot.Name = [Name '-Ipsilateral'];
                ToPlot.Data = AllSubjects_Data(iROI).Ispi;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                %% Sensory modalities
                ToPlot.Name = [Name '-Contralateral'];
                ToPlot.Data = AllSubjects_Data(iROI).Contra;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Left VS Right
                ToPlot.Name = [Name '-Ipsi-Contra'];
                ToPlot.Data = AllSubjects_Data(iROI).Contra_VS_Ipsi;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Contrast between sensory modalities Ispi
                ToPlot.Name = [Name '-SensModContrastsIpsi'];
                ToPlot.Data = AllSubjects_Data(iROI).ContSensModIpsi;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio-Visual'}, {'','Audio-Tactile'} {'','Visual-Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Contrast between sensory modalities Contra
                ToPlot.Name = [Name '-SensModContrastsContra'];
                ToPlot.Data = AllSubjects_Data(iROI).ContSensModContra;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio-Visual'}, {'','Audio-Tactile'} {'','Visual-Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                
                PlotLayersForFig(ToPlot)
                
                clear ToPlot
                
                
            end
            cd(StartDir)
            
        end
    end
end


