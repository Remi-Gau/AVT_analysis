function plot_all_ROIs(ToPlot)

fontsize = 6;

SubPlots = {...
    [1 4] [2 5] [3 6];...
    7, 8, 9;...
    10, 11, 12;...
    13, 14, 15;...
    };

line_colors = [...
    0 .2 1;...
    0 .8 1;...
    0.2 1 0;...
    .35 1 0;...
    .5 1 0;...
    .65 1 0;...
    .8 1 0;...
    ];

NbROI = numel(ToPlot.ROIs_name);

if isempty(ToPlot.ToPermute)
    suffix = '_ttest';
else
    suffix = '_perm';
end

Name = strrep(ToPlot.Name, ' ', '_');
Name = strrep(Name, '_', '-');


fig = figure('Name', Name, 'Position', [100, 100, 1500, 1000], 'Color', [1 1 1], 'Visible', ToPlot.Visible);

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(fig, 'PaperUnits','centimeters');
set(fig, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(fig, 'PaperPositionMode', 'manual');
set(fig, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

set(fig, 'Visible', ToPlot.Visible)

for iCdt = 1:numel(ToPlot.Legend)
    
    ToPlot.Cst = 0;
    
    Cdt2Plot = ToPlot.SubPlotOrder(iCdt);
    
    % plot profiles
    subplot (5,3,SubPlots{1,iCdt})
    PlotRectangle(6,fontsize)
    subplot(5,3,SubPlots{1,iCdt})
    hold on
    
    l=errorbar(...
        repmat((1:6)',1,NbROI)+repmat(linspace(-.15,.15,7),6,1),...
        ToPlot.profile.MEAN(:,:,Cdt2Plot),...
        ToPlot.profile.SEM(:,:,Cdt2Plot));
    for iLine=1:numel(l)
        set(l(iLine),'color', line_colors(iLine,:))
    end
    
    if iCdt==1
        legend(ToPlot.ROIs_name, 'location', 'NorthWest')
        
        t=ylabel(ToPlot.YLabel);
        set(t,'fontsize',fontsize);
    end
    
    if ToPlot.MVPA
        plot([0.5 6.5], [0.5 0.5], '--k')
    else
        plot([0.5 6.5], [0 0], '--k')
    end
    
    ax = axis;
    axis([0.75 6.25 ax(3) ax(4)])
    
    title(ToPlot.Legend{Cdt2Plot})
    
    set(gca,'tickdir', 'out', 'xtick', [] , ...
        'xticklabel', ' ', 'ticklength', [0.01 0.01], ...
        'fontsize', fontsize)
    
    
    % plot betas constant
    subplot (5,3,SubPlots{2,iCdt})
    hold on
    tmp = ToPlot.profile.beta(:,:,1,Cdt2Plot);
    plot_betas(tmp,ToPlot,fontsize)
    if iCdt==1
        ylabel(sprintf('constant\nParam. est. [a u]'));
        set(t,'fontsize',fontsize);
    end
    
    
    % plot betas linear
    subplot (5,3,SubPlots{3,iCdt})
    hold on
    if ToPlot.MVPA
        tmp = ToPlot.profile.beta(:,:,2,Cdt2Plot);
    else
        tmp = ToPlot.profile.beta(:,:,2,Cdt2Plot)*-1;
    end
    plot_betas(tmp,ToPlot,fontsize)
    if iCdt==1
        ylabel(sprintf('linear\nParam. est. [a u]'));
        set(t,'fontsize',fontsize);
    end
    
    
    % plot whole ROI
    subplot (5,3,SubPlots{4,iCdt})
    hold on
    tmp = ToPlot.ROI.grp(:,:,Cdt2Plot);
    ToPlot.Cst = 1;
    plot_betas(tmp,ToPlot,fontsize)
    if iCdt==1
        ylabel(sprintf('whole ROI\nParam. est. [a u]'));
        set(t,'fontsize',fontsize);
    end
    
end

mtit(sprintf(Name),'xoff', 0, 'yoff', +0.03, 'fontsize', fontsize+4)

print(fig, fullfile(ToPlot.FigureFolder, ['All_ROIs_' strrep(Name,'\n','-'), suffix, '.tif']), '-dtiff')
end


function plot_betas(tmp,ToPlot,fontsize)

Alpha = 0.05;

Xpos = [1 2 4:8];

% plot spead
tmp_cell = mat2cell(tmp,size(tmp,1),ones(1,size(tmp,2)));
h = plotSpread(tmp_cell, 'distributionMarkers',{'.'},...
    'xValues', (Xpos)+.2, 'binWidth', 1, 'spreadWidth', 1);
set(h{1}, 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)

% plot mean+SEM
errorbar(Xpos-.2, nanmean(tmp), nansem(tmp), 'b. ')

% plot zero line
if ToPlot.Cst
    plot([0 9], [0.5 0.5], '--k')
else
    plot([0 9], [0 0], '--k')
end

set(gca, 'tickdir', 'out', 'xtick', Xpos,'xticklabel',ToPlot.ROIs_name, ...
    'ticklength', [0.01 0.01], 'fontsize', fontsize)

axis tight
ax = axis;

if ToPlot.MVPA && ToPlot.Cst
    tmp=tmp-.5;
end

% now compute p values and print them
if ~isempty(ToPlot.ToPermute)
    for iPerm = 1:size(ToPlot.ToPermute,1)
        tmp2 = ToPlot.ToPermute(iPerm,:);
        tmp2 = repmat(tmp2',1,size(tmp,2));
        Perms(iPerm,:) = mean(tmp.*tmp2); %#ok<*SAGROW>
    end
end

if isfield(ToPlot, 'OneSideTTest')
    
    if ~isempty(ToPlot.ToPermute)
        if strcmp(ToPlot.OneSideTTest,'left')
            %             P = sum(Perms<mean(tmp))/numel(Perms);
        elseif strcmp(ToPlot.OneSideTTest,'right')
            %             P = sum(Perms>mean(tmp))/numel(Perms);
        elseif strcmp(ToPlot.OneSideTTest,'both')
            
            P = sum( ...
                abs( Perms ) > ...
                repmat( abs(mean(tmp)), size(Perms,1),1)  ) ...
                / size(Perms,1) ;
        end
    else
        [~,P] = ttest(tmp, 0, 'alpha', 0.05, 'tail', ToPlot.OneSideTTest);
    end
else
    
    if ~isempty(ToPlot.ToPermute)
            P = sum( ...
                abs( Perms ) > ...
                repmat( abs(mean(tmp)), size(Perms,1),1)  ) ...
                / size(Perms,1) ;
    else
        [~,P] = ttest(tmp, 0, 'alpha', 0.05);
    end
    
end

for iP = 1:numel(P)
    Sig = [];
    if P(iP)<0.001
        Sig = sprintf('p<0.001 ');
    else
        Sig = sprintf('p=%.3f ',P(iP));
    end
    
    t = text(Xpos(iP)-.2,ax(4)+ax(4)*.2,sprintf(Sig));
    set(t,'fontsize',fontsize-1);
    
    if P(iP)<Alpha
        set(t,'color','r');
    end
end

axis([0.5 8.5 ax(3) ax(4)+ax(4)*.25])

end
