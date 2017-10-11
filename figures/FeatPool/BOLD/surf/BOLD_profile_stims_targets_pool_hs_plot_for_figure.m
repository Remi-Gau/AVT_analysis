clc; clear;

StartDir = fullfile(pwd, '..','..', '..','..', '..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
FigureFolder = fullfile(StartDir, 'figures', 'profiles','surf');
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
                load(fullfile(ResultsDir, strcat('ResultsSurfStimsTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
            else
                load(fullfile(ResultsDir, strcat('ResultsSurfStimsTargetsPoolNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
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
                ToPlot.Name = [Name '-StimVsTargets-Ipsilateral'];
                ToPlot.Data = AllSubjects_Data(iROI).StimTargIpsi;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                ToPlot.ToPermute = ToPermute;
                
                PlotLayersForFig(ToPlot)
                
                ToPlot.Name = [Name '-WholeROI-StimVsTargets-Ipsilateral'];
                
                PlotROIForFig(ToPlot)
                
                clear ToPlot
                
                %% Sensory modalities
                ToPlot.Name = [Name '-StimVsTargets-Contralateral'];
                ToPlot.Data = AllSubjects_Data(iROI).StimTargContra;
                ToPlot.PlotSub = 1;
                ToPlot.WithQuad = WithQuad;
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {{'','Audio'}, {'','Visual'} {'','Tactile'}};
                ToPlot.Visible='on';
                ToPlot.FigureFolder=FigureFolder;
                ToPlot.MVPA = 0;
                ToPlot.ToPermute = ToPermute;
                
                PlotLayersForFig(ToPlot)
                
                ToPlot.Name = [Name '-WholeROI-StimVsTargets-Contralateral'];
                
                PlotROIForFig(ToPlot)
                
                clear ToPlot
                
                
                
            end
            cd(StartDir)
            
        end
    end
end


