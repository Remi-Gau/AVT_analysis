%%
clc; clear; close all;


StartDir = fullfile(pwd, '..','..','..','..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

Get_dependencies('D:\Dropbox\')

FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'correlations');
mkdir(FigureFolder)

mkdir(fullfile(FigureFolder,'cdt'));
mkdir(fullfile(FigureFolder,'cross_sens'));
mkdir(fullfile(FigureFolder,'cross_side'));
mkdir(fullfile(FigureFolder,'cross_side_cross_side'));
mkdir(fullfile(FigureFolder,'cross_sens_cross_sens'));

CondNames = {...
    'A Stim Ipsi','A Stim Contra',...
    'V Stim Ipsi','V Stim Contra',...
    'T Stim Ipsi','T Stim Contra'...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
    };

FigDim = [100, 100, 1000, 1500];
Visibility = 'on';

load(fullfile(StartDir,'results','profiles','surf','correlation','SurfCorrelation.mat'))


Xpos =  [1 2 3];


%% plot stim VS stim correlation results
close all

Cdt = combnk(1:6,2);

SubPlot = [1:5 7:10 13:15 19:20 25];

for iROI=1:numel(ROI)
    
    figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
    
    for iCdt=1:size(Cdt,1)

        subplot(5,5,SubPlot(iCdt))
        hold on
        
        plot([0 10],[0 0],':k', 'linewidth', 2)
        
%         CompilGrpBetaCdt(:,iCdt,iROI,iToPlot,iCV,iSub)
        tmp = squeeze(mean(CompilGrpBetaCdt(2,iCdt,iROI,:,:,:),5));
        
        MAX = max(abs(tmp(:)));
        MAX = MAX+MAX*.1;
        
        [H,P] = ttest(tmp');
        for i=1:numel(P)
            if P(i)<0.001
                Sig = sprintf('\np<0.001 ');
            else
                Sig = sprintf('\np=%.3f ',P(i));
            end
            t = text(Xpos(i),MAX,sprintf(Sig));
            set(t,'fontsize',4);
            
            if H(i)==1
                set(t,'color','r');
            end
        end
        h = errorbar(Xpos, mean(tmp,2), nanstd(tmp,2), 'o','LineStyle','none','Color',[0 0 0]);
        set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
        
        h = plotSpread(tmp', ...
            'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
            'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
        set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
        
        set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
            'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin','Quad'}, 'ytick', -3:.02:3 ,'yticklabel', -3:.02:3,...
            'ygrid', 'on')
        axis([0.9 3.5 -1*MAX MAX])
        
        if iCdt<6
            t=title(CondNames(Cdt(iCdt,2)));
            set(t,'fontsize',6);
        end
        
         if any(SubPlot(iCdt)==[1 7 13 19 25])
            t=ylabel(CondNames(Cdt(iCdt,1)));
            set(t,'fontsize',8);
         end

    end

    mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)

    print(gcf, fullfile(FigureFolder, 'cdt', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
end





%% Correlation Stim VS Contra-Ipsi
% close all
% 
% sets = {1:6,1:3};
% [x, y] = ndgrid(sets{:});
% Cdt = [x(:) y(:)]; clear x y sets
% 
% Cond_con_name = {'A Contra-Ipsi','V Contra-Ipsi','T Contra-Ipsi'};
% 
% SubPlot = [1:3:18, 2:3:18, 3:3:18];
% 
% 
% for iROI=1:numel(ROI)
%     
%     figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
%     
%     for iCdt=1:size(Cdt,1)
%         
%         subplot(6,3,SubPlot(iCdt))
%         hold on
%         
%         plot([0 10],[0 0],':k', 'linewidth', 2)
% 
%         tmp = squeeze(mean(CompilGrpBetaCrossSide(2,iCdt,iROI,:,:,:),5));
%         
%         MAX = max(abs(tmp(:)));
%         MAX = MAX+MAX*.1;
%         
%         [H,P] = ttest(tmp');
%         for i=1:numel(P)
%             if P(i)<0.001
%                 Sig = sprintf('\np<0.001 ');
%             else
%                 Sig = sprintf('\np=%.3f ',P(i));
%             end
%             t = text(Xpos(i),MAX,sprintf(Sig));
%             set(t,'fontsize',4);
%             
%             if H(i)==1
%                 set(t,'color','r');
%             end
%         end
%         h = errorbar(Xpos, mean(tmp,2), nanstd(tmp,2), 'o','LineStyle','none','Color',[0 0 0]);
%         set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
%         
%         h = plotSpread(tmp', ...
%             'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
%             'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
%         set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
%         
%         set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
%             'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin','Quad'}, 'ytick', -3:.02:3 ,'yticklabel', -3:.02:3,...
%             'ygrid', 'on')
%         axis([0.9 3.5 -1*MAX MAX])
%         
%         if any(SubPlot(iCdt)==1:3:18)
%             t=ylabel(CondNames(Cdt(iCdt,1)));
%             set(t,'fontsize',8);
%         end
%         
%          if any(SubPlot(iCdt)==1:3)
%             t=title(Cond_con_name{Cdt(iCdt,2)});
%             set(t,'fontsize',8);
%          end
% 
%     end
% 
%     mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)
% 
%     print(gcf, fullfile(FigureFolder, 'cross_sens', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
% end




%% Correlation Stim VS Contra-Ipsi
% close all
% 
% sets = {1:6,1:6};
% [x, y] = ndgrid(sets{:});
% Cdt = [x(:) y(:)]; clear x y sets
% 
% Cond_con_name = {...
%     'Contra A-V','Contra A-T','Contra V-T',...
%     'Ipsi A-V','Ipsi A-T','Ipsi V-T'};
% 
% SubPlot = [1:6:36, 2:6:36, 3:6:36 4:6:36, 5:6:36, 6:6:36];
% 
% 
% for iROI=1:numel(ROI)
%     
%     figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
%     
%     for iCdt=1:size(Cdt,1)
%         
%         subplot(6,6,SubPlot(iCdt))
%         hold on
%         
%         plot([0 10],[0 0],':k', 'linewidth', 2)
% 
%         tmp = squeeze(mean(CompilGrpBetaCrossSens(2,iCdt,iROI,:,:,:),5));
%         
%         MAX = max(abs(tmp(:)));
%         MAX = MAX+MAX*.1;
%         
%         [H,P] = ttest(tmp');
%         for i=1:numel(P)
%             if P(i)<0.001
%                 Sig = sprintf('\np<0.001 ');
%             else
%                 Sig = sprintf('\np=%.3f ',P(i));
%             end
%             t = text(Xpos(i),MAX,sprintf(Sig));
%             set(t,'fontsize',4);
%             
%             if H(i)==1
%                 set(t,'color','r');
%             end
%         end
%         h = errorbar(Xpos, mean(tmp,2), nanstd(tmp,2), 'o','LineStyle','none','Color',[0 0 0]);
%         set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
%         
%         h = plotSpread(tmp', ...
%             'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
%             'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
%         set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
%         
%         set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
%             'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin','Quad'}, 'ytick', -3:.02:3 ,'yticklabel', -3:.02:3,...
%             'ygrid', 'on')
%         axis([0.9 3.5 -1*MAX MAX])
%         
%         if any(SubPlot(iCdt)==1:6:36)
%             t=ylabel(CondNames(Cdt(iCdt,1)));
%             set(t,'fontsize',8);
%         end
%         
%          if any(SubPlot(iCdt)==1:6)
%             t=title(Cond_con_name{Cdt(iCdt,2)});
%             set(t,'fontsize',8);
%          end
% 
%     end
% 
%     mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)
% 
%     print(gcf, fullfile(FigureFolder, 'cross_side', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
% end



 %% Correlation cross-sensory ipsi VS cross-sensory contra
% close all
% 
% sets = {1:3,1:3};
% [x, y] = ndgrid(sets{:});
% Cdt = [x(:) y(:)]; clear x y sets
% 
% Cond_con_name = {'A Contra-Ipsi','V Contra-Ipsi','T Contra-Ipsi'};
% 
% SubPlot = [1:3:9, 2:3:9, 3:3:9];
% 
% 
% for iROI=1:numel(ROI)
%     
%     figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
%     
%     for iCdt=1:size(Cdt,1)
%         
%         subplot(3,3,SubPlot(iCdt))
%         hold on
%         
%         plot([0 10],[0 0],':k', 'linewidth', 2)
% 
%         tmp = squeeze(mean(CompilGrpBetaSideVSSide(2,iCdt,iROI,:,:,:),5));
%         
%         MAX = max(abs(tmp(:)));
%         MAX = MAX+MAX*.1;
%         
%         [H,P] = ttest(tmp');
%         for i=1:numel(P)
%             if P(i)<0.001
%                 Sig = sprintf('\np<0.001 ');
%             else
%                 Sig = sprintf('\np=%.3f ',P(i));
%             end
%             t = text(Xpos(i),MAX,sprintf(Sig));
%             set(t,'fontsize',4);
%             
%             if H(i)==1
%                 set(t,'color','r');
%             end
%         end
%         h = errorbar(Xpos, mean(tmp,2), nanstd(tmp,2), 'o','LineStyle','none','Color',[0 0 0]);
%         set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
%         
%         h = plotSpread(tmp', ...
%             'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
%             'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
%         set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
%         
%         set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
%             'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin','Quad'}, 'ytick', -3:.02:3 ,'yticklabel', -3:.02:3,...
%             'ygrid', 'on')
%         axis([0.9 3.5 -1*MAX MAX])
%         
%         if any(SubPlot(iCdt)==1:3:9)
%             t=ylabel(Cond_con_name(Cdt(iCdt,1)));
%             set(t,'fontsize',8);
%         end
%         
%          if any(SubPlot(iCdt)==1:3)
%             t=title(Cond_con_name{Cdt(iCdt,2)});
%             set(t,'fontsize',8);
%          end
% 
%     end
% 
%     mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)
% 
%     print(gcf, fullfile(FigureFolder, 'cross_side_cross_side', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
% end



 %% Correlation ipsi-contra sense A VS ipsi-contra sense B
close all

sets = {1:6,1:6};
[x, y] = ndgrid(sets{:});
Cdt = [x(:) y(:)]; clear x y sets

Cond_con_name = {...
    'Contra A-V','Contra A-T','Contra V-T',...
    'Ipsi A-V','Ipsi A-T','Ipsi V-T'};

SubPlot = [1:6:36, 2:6:36, 3:6:36 4:6:36, 5:6:36, 6:6:36];


for iROI=1:numel(ROI)
    
    figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
    
    for iCdt=1:size(Cdt,1)
        
        subplot(6,6,SubPlot(iCdt))
        hold on
        
        plot([0 10],[0 0],':k', 'linewidth', 2)

        tmp = squeeze(mean(CompilGrpBetaSenseVSSense(2,iCdt,iROI,:,:,:),5));
        
        MAX = max(abs(tmp(:)));
        MAX = MAX+MAX*.1;
        
        [H,P] = ttest(tmp');
        for i=1:numel(P)
            if P(i)<0.001
                Sig = sprintf('\np<0.001 ');
            else
                Sig = sprintf('\np=%.3f ',P(i));
            end
            t = text(Xpos(i),MAX,sprintf(Sig));
            set(t,'fontsize',4);
            
            if H(i)==1
                set(t,'color','r');
            end
        end
        h = errorbar(Xpos, mean(tmp,2), nanstd(tmp,2), 'o','LineStyle','none','Color',[0 0 0]);
        set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
        
        h = plotSpread(tmp', ...
            'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
            'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
        set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
        
        set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
            'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin','Quad'}, 'ytick', -3:.02:3 ,'yticklabel', -3:.02:3,...
            'ygrid', 'on')
        axis([0.9 3.5 -1*MAX MAX])
        
        if any(SubPlot(iCdt)==1:6:36)
            t=ylabel(Cond_con_name(Cdt(iCdt,1)));
            set(t,'fontsize',8);
        end
        
         if any(SubPlot(iCdt)==1:6)
            t=title(Cond_con_name{Cdt(iCdt,2)});
            set(t,'fontsize',8);
         end

    end

    mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)

    print(gcf, fullfile(FigureFolder, 'cross_sens_cross_sens', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
end

return