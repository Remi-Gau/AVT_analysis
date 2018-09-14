clc; clear;

StartDir = fullfile(pwd, '..','..', '..');
addpath(genpath(fullfile(StartDir, 'AVT-7T-code','subfun')))
Get_dependencies('D:\Dropbox/')
cd (StartDir)

ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf');
[~,~,~] = mkdir(FigureFolder);

for NbLayers = 6
    for WithQuad = 1
        for WithPerm = 1
            
            if WithQuad
                load(fullfile(ResultsDir, strcat('ResultsSurfQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
            else
                load(fullfile(ResultsDir, strcat('ResultsSurfNoQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
            end
            
            if  WithPerm
                sets = {};
                for iSub=1:10
                    sets{iSub} = [-1 1]; %#ok<*AGROW>
                end
                [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:}); clear sets
                ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
            else
                ToPermute = [];
            end
            
            ToPlot.ToPermute = ToPermute;
            
            
            %% Plots
            for ihs = 1:2
                if ihs==1
                    HS_suffix = '_L';
                else
                    HS_suffix = '_R';
                end
                
                for iROI = 1:length(AllSubjects_Data)
                    
                    close all
                    
                    Name = strrep(AllSubjects_Data(iROI).name, '_', ' ');
                    Name = [Name HS_suffix];
                    fprintf([Name '\n'])
                    
                    if WithQuad
                    else
                        Name = [Name '-NoQuad-ALL'];
                    end
                    
                    %% Basic condition
                    ToPlot.Name = [Name '-Conditions'];
                    
                    ToPlot.Data.MEAN(:,1:3,:)=AllSubjects_Data(iROI).Ispi.MEAN(:,:,:,ihs);
                    ToPlot.Data.SEM(:,1:3,:)=AllSubjects_Data(iROI).Ispi.SEM(:,:,:,ihs);
                    ToPlot.Data.grp(:,1:3,:)=AllSubjects_Data(iROI).Ispi.grp(:,:,:,ihs);
                    ToPlot.Data.Beta.DATA(:,1:3,:)=AllSubjects_Data(iROI).Ispi.Beta.DATA(:,:,:,ihs);
                    
                    ToPlot.Data.MEAN(:,4:6,:)=AllSubjects_Data(iROI).Contra.MEAN(:,:,:,ihs);
                    ToPlot.Data.SEM(:,4:6,:)=AllSubjects_Data(iROI).Contra.SEM(:,:,:,ihs);
                    ToPlot.Data.grp(:,4:6,:)=AllSubjects_Data(iROI).Contra.grp(:,:,:,ihs);
                    ToPlot.Data.Beta.DATA(:,4:6,:)=AllSubjects_Data(iROI).Contra.Beta.DATA(:,:,:,ihs);
                    
                    ToPlot.PlotBeta = 1;
                    ToPlot.ToPermute = ToPermute;
                    ToPlot.PlotSub = 1;
                    ToPlot.WithQuad = WithQuad;
                    ToPlot.SubPlotOrder = [1 4 2 5 3 6];
                    ToPlot.Legend = {...
                        {'Audio','Ipsi'}, {'','Contra'};...
                        {'Visual',''}, {'',''};...
                        {'Tactile',''}, {'',''};...
                        };
                    ToPlot.Visible='on';
                    ToPlot.FigureFolder=FigureFolder;
                    ToPlot.MVPA = 0;
                    
                    PlotLayersForFig(ToPlot)
                    
                    clear ToPlot
                    
                    %% Contrast between sensory modalities
                    ToPlot.Name = [Name '-SensModContrasts'];
                    
                    ToPlot.Data.MEAN(:,1:3,:)=AllSubjects_Data(iROI).ContSensModIpsi.MEAN(:,:,:,ihs);
                    ToPlot.Data.SEM(:,1:3,:)=AllSubjects_Data(iROI).ContSensModIpsi.SEM(:,:,:,ihs);
                    ToPlot.Data.grp(:,1:3,:)=AllSubjects_Data(iROI).ContSensModIpsi.grp(:,:,:,ihs);
                    ToPlot.Data.Beta.DATA(:,1:3,:)=AllSubjects_Data(iROI).ContSensModIpsi.Beta.DATA(:,:,:,ihs);
                    
                    ToPlot.Data.MEAN(:,4:6,:)=AllSubjects_Data(iROI).ContSensModContra.MEAN(:,:,:,ihs);
                    ToPlot.Data.SEM(:,4:6,:)=AllSubjects_Data(iROI).ContSensModContra.SEM(:,:,:,ihs);
                    ToPlot.Data.grp(:,4:6,:)=AllSubjects_Data(iROI).ContSensModContra.grp(:,:,:,ihs);
                    ToPlot.Data.Beta.DATA(:,4:6,:)=AllSubjects_Data(iROI).ContSensModContra.Beta.DATA(:,:,:,ihs);
                    
                    ToPlot.PlotBeta = 1;
                    ToPlot.ToPermute = ToPermute;
                    ToPlot.PlotSub = 1;
                    ToPlot.WithQuad = WithQuad;
                    ToPlot.SubPlotOrder = [1 4 2 5 3 6];
                    ToPlot.Legend = {...
                        {'A-V','Ipsi'}, {'','Contra'};...
                        {'A-T',''}, {'',''};...
                        {'V-T',''}, {'',''};...
                        };
                    ToPlot.Visible='on';
                    ToPlot.FigureFolder=FigureFolder;
                    ToPlot.MVPA = 0;
                    
                    PlotLayersForFig(ToPlot)
                    
                    clear ToPlot
                    
                    
                    %% Left VS Right
                    ToPlot.Name = [Name '-Contra-Ipsi'];
                    
                    ToPlot.Data.MEAN(:,1:3,:)=AllSubjects_Data(iROI).Contra_VS_Ipsi.MEAN(:,:,:,ihs);
                    ToPlot.Data.SEM(:,1:3,:)=AllSubjects_Data(iROI).Contra_VS_Ipsi.SEM(:,:,:,ihs);
                    ToPlot.Data.grp(:,1:3,:)=AllSubjects_Data(iROI).Contra_VS_Ipsi.grp(:,:,:,ihs);
                    ToPlot.Data.Beta.DATA(:,1:3,:)=AllSubjects_Data(iROI).Contra_VS_Ipsi.Beta.DATA(:,:,:,ihs);
                    
                    ToPlot.PlotBeta = 1;
                    ToPlot.ToPermute = ToPermute;
                    ToPlot.PlotSub = 1;
                    ToPlot.WithQuad = WithQuad;
                    ToPlot.SubPlotOrder = [1 2 3];
                    ToPlot.Legend = {{'','Audio: Contra-Ipsi'}, {'','Visual: Contra-Ipsi'} {'','Tactile: Contra-Ipsi'}};
                    ToPlot.Visible='on';
                    ToPlot.FigureFolder=FigureFolder;
                    ToPlot.MVPA = 0;
                    
                    PlotLayersForFig(ToPlot)
                    
                    clear ToPlot
                    
                    
                end
            end
            cd(StartDir)
            
        end
    end
end


