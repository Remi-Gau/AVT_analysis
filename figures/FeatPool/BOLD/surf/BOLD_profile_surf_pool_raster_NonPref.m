%%
% clc; clear; close all;

StartDir = fullfile(pwd, '..','..', '..','..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'rasters');
mkdir(FigureFolder)
mkdir(fullfile(FigureFolder,'cdt'));

load(fullfile(StartDir,'results','roi','MinNbVert.mat'),'MinVert')

load(fullfile(StartDir,'results','profiles','surf','rasters','RasterAllCdt.mat'), ...
    'ROI', 'All_X_sort', 'All_Profiles')


CondNames = {...
    'A Stim Ipsi','A Stim Contra',...
    'V Stim Ipsi','V Stim Contra',...
    'T Stim Ipsi','T Stim Contra'...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
    };

ToPlot={'Constant','Linear'};

NbLayers = 6;
DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
DesMat = spm_orth(DesMat);


% Color map
ColorMap = seismic(1000);

FigDim = [50, 50, 1200, 650];
Visibility = 'on';

CLIM = [-2 2];


% Permutation
for iSubj=1:10
    sets{iSubj} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
% ToPermute = [];


%% Grp level  ; raster stim = f(other stim)
close all

A=repmat(1:6,6,1);
Cdt = [A(:), repmat([1:6]',6,1)];
clear A

for iToPlot = 1 %:numel(ToPlot)
    
    for iROI = 1%:5
        
        if iROI<3
            Cdt1 = 1; %1:2;
            Cdt2 = 3:6;
        else
            Cdt1 = 3:4;
            Cdt2 = [1:2 5:6];
        end
        
        close all
        
        NbBin = MinVert(strcmp(ROI(iROI).name,{MinVert.name}')).MinVert;
        
        fprintf('    %s\n',ROI(iROI).name)
        
        for iCdt1 = Cdt1
            
            clear Sorting_Raster
            
            FileName = fullfile(FigureFolder,'cdt', ...
                ['GrpLvl_raster_AllCdt_' CondNames{iCdt1} '_' ToPlot{iToPlot} '_' ROI(iROI).name '.tiff']);
            
            for iSubj = 1:size(All_Profiles,1)
                Sorting_Raster(:,:,iSubj) = All_Profiles{iSubj, iToPlot, all(Cdt==iCdt1,2), iROI};
            end
            
            h = figure('name', [strrep(ROI(iROI).name,' ','_') '-' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility); %#ok<*UNRCH>
            colormap(ColorMap)
            
            SubPlot = 1;
            
            for iCdt2 = Cdt2
                
                clear X_sort Profiles
                
                for iSubj = 1:size(All_Profiles,1)
                    Get = all(Cdt==repmat([iCdt1 iCdt2],size(Cdt,1),1),2);
                    X_sort(iSubj,:) = All_X_sort{iSubj,iToPlot,Get,iROI};
                    Profiles(:,:,iSubj) = All_Profiles{iSubj,iToPlot,Get,iROI};
                end

                subplot(2,2,SubPlot)
                PlotRectangle(NbLayers,10)
%                 set(gca,'tickdir', 'out', 'xtick', [],'xticklabel', [], ...
%                     'ytick', [],'yticklabel', [])
                subplot(2,2,SubPlot)
%                 hold on
                
%                 MeanProfiles = mean(Profiles,3);
                MeanProfiles = mean(imgaussfilt(Profiles,[size(Profiles,1)/100 .0001]),3);
                imagesc(flipud(MeanProfiles), CLIM)
                
                axis([0.5 6.5 0 size(Profiles,1)])   
                set(gca,'tickdir', 'out', 'xtick', [],'xticklabel', [], ...
                    'ytick', [],'yticklabel', [], ...
                    'ticklength', [0.01 0], 'fontsize', 10)
                
                t = title(CondNames{iCdt2});
                set(t,'fontsize',10)

%                 t=xlabel('cortical depth');
%                 set(t,'fontsize',10)
                
                YLabel = sprintf('Perc %s %s',...
                    ToPlot{iToPlot}, CondNames{iCdt1});
                
                
                ax = gca;
%                 PlotSortedValues(ax, X_sort, NbBin, Profiles, YLabel, 1, Sorting_Raster, CLIM)
                PlotSortedValues(ax, X_sort, NbBin, Profiles, YLabel, 1, [], [], 0)
                
                [rho,slope]=CorRegRaster(Profiles,DesMat,iToPlot,X_sort);
                PlotCorrCoeff(ax, slope, ToPlot{iToPlot}, .025, .02, .06, .06, [0.9 1.3 -.1 1], ToPermute)
                
                PlotColorBar(ax, ColorMap, CLIM)
                
                SubPlot = SubPlot + 1;
                
            end
            
            mtit([strrep(ROI(iROI).name,'_',' ') ' - Percentile ' CondNames{iCdt1} ' - ' ToPlot{iToPlot}], 'fontsize', 14, 'xoff',0,'yoff',.025)
            
%             imwrite(imind,cm,FileName,'tiff');
            
        end
    end
end


