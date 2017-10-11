clc; clear;

StartDir = fullfile(pwd, '..','..','..','..', '..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf');
[~,~,~] = mkdir(FigureFolder);

SubLs = dir('sub*');
NbSub = numel(SubLs);
for iSub=1:size(SubLs,1)
    sets{iSub} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
% ToPermute = [];

for NbLayers=6
    for WithQuad= 1
        for WithPerm = 0
            
            if WithQuad
                load(fullfile(ResultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
            else
                load(fullfile(ResultsDir, strcat('ResultsSurfTargetsPoolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
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
                ToPlot.Name = [Name '-Targets-Ipsilateral'];
                ToPlot.Data = AllSubjects_Data(iROI).Ispi;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                ToPlot.ToPermute = ToPermute;
                
                PlotLayersForFig(ToPlot)

                ToPlot.Name = [Name '-WholeROI-Targets-Ipsilateral'];
                
                PlotROIForFig(ToPlot)
                
                clear ToPlot
                
                %% Sensory modalities
                ToPlot.Name = [Name '-Targets-Contralateral'];
                ToPlot.Data = AllSubjects_Data(iROI).Contra;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                 ToPlot.ToPermute = ToPermute;
                
                PlotLayersForFig(ToPlot)
                
                ToPlot.Name = [Name '-WholeROI-Targets-Contralateral'];
                
                PlotROIForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Left VS Right
                ToPlot.Name = [Name '-Targets-Contra-Ipsi'];
                ToPlot.Data = AllSubjects_Data(iROI).Contra_VS_Ipsi;
                
                % multiply by -1 to get contra-ipsi instead of ipsi-contra
                ToPlot.Data.grp = -1 * ToPlot.Data.grp;
                ToPlot.Data.whole_roi_grp = -1 * ToPlot.Data.whole_roi_grp;
                ToPlot.Data.MEAN = -1 * ToPlot.Data.MEAN;
                ToPlot.Data.whole_roi_MEAN = -1 * ToPlot.Data.whole_roi_MEAN;
                ToPlot.Data.Beta.DATA = -1 * ToPlot.Data.Beta.DATA;
                
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                 ToPlot.ToPermute = ToPermute;
                
                PlotLayersForFig(ToPlot)
                
                ToPlot.Name = [Name '-WholeROI-Targets-Contra-Ipsi'];
                
                PlotROIForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Contrast between sensory modalities Ispi
                ToPlot.Name = [Name '-Targets-SensModContrasts-Ipsi'];
                ToPlot.Data = AllSubjects_Data(iROI).ContSensModIpsi;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio-Visual'}, {'','Audio-Tactile'} {'','Visual-Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                 ToPlot.ToPermute = ToPermute;
                
                PlotLayersForFig(ToPlot)
                
                ToPlot.Name = [Name '-WholeROI-Targets-SensModContrasts-Ipsi'];
                
                PlotROIForFig(ToPlot)
                
                clear ToPlot
                
                
                %% Contrast between sensory modalities Contra
                ToPlot.Name = [Name '-Targets-SensModContrasts-Contra'];
                ToPlot.Data = AllSubjects_Data(iROI).ContSensModContra;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio-Visual'}, {'','Audio-Tactile'} {'','Visual-Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                 ToPlot.ToPermute = ToPermute;
                
                PlotLayersForFig(ToPlot)
                
                ToPlot.Name = [Name '-WholeROI-Targets-SensModContrasts-Contra'];
                
                PlotROIForFig(ToPlot)
                
                clear ToPlot
                
                
            end
            cd(StartDir)
            
        end
    end
end


