%%
clc; clear; close all;

ToPlot={'Cst','Lin'};

StartDir = fullfile(pwd, '..','..','..','..','..');
cd (StartDir)
addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

SubLs = dir('sub*');
NbSub = numel(SubLs);

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

FigDim = [50, 50, 1000, 700];
Xpos =  [1 2];
Visibility = 'on';

% load(fullfile(StartDir,'results','profiles','surf','correlation','SurfCorrelation.mat'))

for iSub = 1:NbSub
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    load(fullfile(Sub_dir,'results','profiles','surf','correlations',[SubLs(iSub).name '-SurfCorrelation.mat']), ...
        'Rho_Stim', 'Slope_Stim', 'Rho_CrossSide_fStim', ...
        'Slope_CrossSide_fStim', 'Rho_CrossSens_fStim', ....
        'Slope_CrossSens_fStim', 'Rho_CrossSide_fCrossSide', ...
        'Slope_CrossSide_fCrossSide', 'Rho_CrossSens_fCrossSens', 'Slope_CrossSens_fCrossSens')
    
    load(fullfile(Sub_dir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI')
    
    for iToPlot = 1:numel(ToPlot)
        
        Cdt = combnk(1:6,2);
        for iCdt = 1:size(Cdt,1)
            for iROI = 1:5
                CompilGrpBetaCdt(iSub,iToPlot,iCdt,iROI) = mean(Slope_Stim{iToPlot, iCdt, iROI});
            end
        end
        
        sets = {1:6,1:3};
        [x, y] = ndgrid(sets{:});
        Cdt = [x(:) y(:)]; clear x y sets
        for iCdt = 1:size(Cdt,1)
            for iROI = 1:5
                CompilGrpBetaCrossSide(iSub,iToPlot,iCdt,iROI) = mean(Slope_CrossSide_fStim{iToPlot, iCdt, iROI});
            end
        end
        
        sets = {1:6,1:6};
        [x, y] = ndgrid(sets{:});
        Cdt = [x(:) y(:)]; clear x y sets
        for iCdt = 1:size(Cdt,1)
            for iROI = 1:5
                CompilGrpBetaCrossSens(iSub,iToPlot,iCdt,iROI) = mean(Slope_CrossSens_fStim{iToPlot, iCdt, iROI});
                CompilGrpBetaSenseVSSense(iSub,iToPlot,iCdt,iROI) = mean(Slope_CrossSens_fCrossSens{iToPlot, iCdt, iROI});
            end
        end
        
        sets = {1:3,1:3};
        [x, y] = ndgrid(sets{:});
        Cdt = [x(:) y(:)]; clear x y sets
        for iCdt = 1:size(Cdt,1)
            for iROI = 1:5
                CompilGrpBetaSideVSSide(iSub,iToPlot,iCdt,iROI) = mean(Slope_CrossSide_fCrossSide{iToPlot, iCdt, iROI});
            end
        end
    end
end

%% plot stim VS stim correlation results
close all

Cdt = combnk(1:6,2);

SubPlot = [1:5 7:10 13:15 19:20 25];

for iROI=1:5
    
    figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
    
    for iCdt=1:size(Cdt,1)
        
        subplot(5,5,SubPlot(iCdt))
        hold on
        
        plot([0 10],[0 0],':k', 'linewidth', 2)
        
        %  OLD       CompilGrpBetaCdt(:,iCdt,iROI,iToPlot,iCV,iSub)
        tmp = CompilGrpBetaCdt(:,:,iCdt,iROI);
        
        MAX = max(abs(tmp(:)));
        MAX = MAX+MAX*.1;
        
        [H,P] = ttest(tmp);
        for i=1:numel(P)
            if P(i)<0.001
                Sig = sprintf('\np<0.001 ');
            else
                Sig = sprintf('\np=%.3f ',P(i));
            end
            t = text(Xpos(i),MAX,sprintf(Sig));
            set(t,'fontsize',4);
            
            if P(i)<0.01
                set(t,'color','r');
            end
        end
        h = errorbar(Xpos, mean(tmp), nanstd(tmp), 'o','LineStyle','none','Color',[0 0 0]);
        set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
        
        h = plotSpread(tmp, ...
            'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
            'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
        set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
        
        set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
            'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin'}, 'ytick', -3:.05:3 ,'yticklabel', -3:.05:3,...
            'ygrid', 'on')
        axis([0.9 2.5 -1*MAX MAX])
        
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
close all

sets = {1:6,1:3};
[x, y] = ndgrid(sets{:});
Cdt = [x(:) y(:)]; clear x y sets

Cond_con_name = {'A Contra-Ipsi','V Contra-Ipsi','T Contra-Ipsi'};

SubPlot = [1:3:18, 2:3:18, 3:3:18];

for iROI=1:5
    
    figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
    
    for iCdt=1:size(Cdt,1)
        
        subplot(6,3,SubPlot(iCdt))
        hold on
        
        plot([0 10],[0 0],':k', 'linewidth', 2)
        
        %         tmp = squeeze(mean(CompilGrpBetaCrossSide(2,iCdt,iROI,:,:,:),5));
        tmp = CompilGrpBetaCrossSide(:,:,iCdt,iROI);
        
        MAX = max(abs(tmp(:)));
        MAX = MAX+MAX*.1;
        
        [H,P] = ttest(tmp);
        for i=1:numel(P)
            if P(i)<0.001
                Sig = sprintf('\np<0.001 ');
            else
                Sig = sprintf('\np=%.3f ',P(i));
            end
            t = text(Xpos(i),MAX,sprintf(Sig));
            set(t,'fontsize',4);
            
            if P(i)<0.01
                set(t,'color','r');
            end
        end
        h = errorbar(Xpos, mean(tmp), nanstd(tmp), 'o','LineStyle','none','Color',[0 0 0]);
        set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
        
        h = plotSpread(tmp, ...
            'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
            'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
        set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
        
        set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
            'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin'}, ...
            'ytick', -3:.05:3 ,'yticklabel', -3:.05:3,...
            'ygrid', 'on')
        axis([0.9 2.5 -1*MAX MAX])
        
        if any(SubPlot(iCdt)==1:3:18)
            t=ylabel(CondNames(Cdt(iCdt,1)));
            set(t,'fontsize',8);
        end
        
        if any(SubPlot(iCdt)==1:3)
            t=title(Cond_con_name{Cdt(iCdt,2)});
            set(t,'fontsize',8);
        end
        
    end
    
    mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)
    
    print(gcf, fullfile(FigureFolder, 'cross_sens', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
end



%% Correlation Stim VS Cross sens
close all

A = repmat(1:6,6,1);
Cdt = [A(:), repmat((1:6)',6,1)];

Cond_con_name = {...
    'Contra A-V','Contra A-T','Contra V-T',...
    'Ipsi A-V','Ipsi A-T','Ipsi V-T'};

SubPlot = [1:6 7:12 13:18 19:24 25:30 31:36];

for iROI=1:5

    figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)

    for iCdt=1:size(Cdt,1)

        subplot(6,6,SubPlot(iCdt))
        hold on

        plot([0 10],[0 0],':k', 'linewidth', 2)

%         tmp = squeeze(mean(CompilGrpBetaCrossSens(2,iCdt,iROI,:,:,:),5));
        tmp = CompilGrpBetaCrossSens(:,:,iCdt,iROI);
        
        MAX = max(abs(tmp(:)));
        MAX = MAX+MAX*.1;

        [H,P] = ttest(tmp);
        for i=1:numel(P)
            if P(i)<0.001
                Sig = sprintf('\np<0.001 ');
            else
                Sig = sprintf('\np=%.3f ',P(i));
            end
            t = text(Xpos(i),MAX,sprintf(Sig));
            set(t,'fontsize',4);

            if P(i)<0.01
                set(t,'color','r');
            end
        end
        h = errorbar(Xpos, mean(tmp), nanstd(tmp), 'o','LineStyle','none','Color',[0 0 0]);
        set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)

        h = plotSpread(tmp, ...
            'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
            'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
        set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)

        set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
            'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin'},...
            'ytick', -3:.05:3 ,'yticklabel', -3:.05:3,...
            'ygrid', 'on')
        axis([0.9 2.5 -1*MAX MAX])

        if any(SubPlot(iCdt)==1:6:36)
            t=ylabel(CondNames(Cdt(iCdt,1)));
            set(t,'fontsize',8);
        end

         if any(SubPlot(iCdt)==1:6)
            t=title(Cond_con_name{Cdt(iCdt,2)});
            set(t,'fontsize',8);
         end

    end

    mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)

    print(gcf, fullfile(FigureFolder, 'cross_side', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
end



%% Correlation cross-side sense A VS cross-side sense B
close all

A = repmat(1:3,3,1);
Cdt = [A(:), repmat((1:3)',3,1)];

Cond_con_name = {'A Contra-Ipsi','V Contra-Ipsi','T Contra-Ipsi'};

SubPlot = 1:9;


for iROI=1:5

    figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)

    for iCdt=1:size(Cdt,1)

        subplot(3,3,SubPlot(iCdt))
        hold on

        plot([0 10],[0 0],':k', 'linewidth', 2)

%         tmp = squeeze(mean(CompilGrpBetaSideVSSide(2,iCdt,iROI,:,:,:),5));
        tmp = CompilGrpBetaSideVSSide(:,:,iCdt,iROI);

        MAX = max(abs(tmp(:)));
        MAX = MAX+MAX*.1;

        [H,P] = ttest(tmp);
        for i=1:numel(P)
            if P(i)<0.001
                Sig = sprintf('\np<0.001 ');
            else
                Sig = sprintf('\np=%.3f ',P(i));
            end
            t = text(Xpos(i),MAX,sprintf(Sig));
            set(t,'fontsize',4);

            if P(i)<0.01
                set(t,'color','r');
            end
        end
        h = errorbar(Xpos, mean(tmp), nanstd(tmp), 'o','LineStyle','none','Color',[0 0 0]);
        set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)

        h = plotSpread(tmp, ...
            'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
            'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
        set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)

        set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
            'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin'},...
            'ytick', -3:.05:3 ,'yticklabel', -3:.05:3,...
            'ygrid', 'on')
        axis([0.9 2.5 -1*MAX MAX])

        if any(SubPlot(iCdt)==1:3:9)
            t=ylabel(Cond_con_name(Cdt(iCdt,1)));
            set(t,'fontsize',8);
        end

         if any(SubPlot(iCdt)==1:3)
            t=title(Cond_con_name{Cdt(iCdt,2)});
            set(t,'fontsize',8);
         end

    end

    mtit(['Slope of vertex wise regression- ' ROI(iROI).name], 'fontsize', 14, 'xoff',0,'yoff',.025)

    print(gcf, fullfile(FigureFolder, 'cross_side_cross_side', ['Vertex_wise_reg_' ROI(iROI).name '.tif']), '-dtiff')
end



%% Correlation cross-sense VS cross-sens
close all

A = repmat(1:6,6,1);
Cdt = [A(:), repmat((1:6)',6,1)];

Cond_con_name = {...
    'Contra A-V','Contra A-T','Contra V-T',...
    'Ipsi A-V','Ipsi A-T','Ipsi V-T'};

SubPlot = [1:6 7:12 13:18 19:24 25:30 31:36];


for iROI=1:5
    
    figure('name', ['Slope - ' ROI(iROI).name], 'Position', FigDim, 'Color', [1 1 1], 'Visible', Visibility)
    
    for iCdt=1:size(Cdt,1)
        
        subplot(6,6,SubPlot(iCdt))
        hold on
        
        plot([0 10],[0 0],':k', 'linewidth', 2)
        
%         tmp = squeeze(mean(CompilGrpBetaSenseVSSense(2,iCdt,iROI,:,:,:),5));
        tmp = CompilGrpBetaSenseVSSense(:,:,iCdt,iROI);
        
        MAX = max(abs(tmp(:)));
        MAX = MAX+MAX*.1;
        
        [H,P] = ttest(tmp);
        for i=1:numel(P)
            if P(i)<0.001
                Sig = sprintf('\np<0.001 ');
            else
                Sig = sprintf('\np=%.3f ',P(i));
            end
            t = text(Xpos(i),MAX,sprintf(Sig));
            set(t,'fontsize',4);
            
            if P(i)<0.01
                set(t,'color','r');
            end
        end
        h = errorbar(Xpos, mean(tmp), nanstd(tmp), 'o','LineStyle','none','Color',[0 0 0]);
        set(h, 'MarkerSize', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
        
        h = plotSpread(tmp, ...
            'distributionMarkers',{'.'},'distributionColors',{'k'}, ...
            'xValues', Xpos+.4, 'binWidth', 0.5, 'spreadWidth', 0.6);
        set(h{1}, 'MarkerSize', 9, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 1)
        
        set(gca,'tickdir', 'out', 'ticklength', [0.01 0.01], 'fontsize', 6, ...
            'xtick', Xpos+.1 ,'xticklabel', {'Cst','Lin'},...
            'ytick', -3:.05:3 ,'yticklabel', -3:.05:3,...
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
