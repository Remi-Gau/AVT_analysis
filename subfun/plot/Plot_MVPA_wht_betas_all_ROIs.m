function Plot_MVPA_wht_betas_all_ROIs(ToPlot)

fontsize = 9;

m=ToPlot.m;
n=ToPlot.n;
SubPlots=ToPlot.SubPlots;

line_colors = [...
    37,52,148;...
    65,182,196;...
    0,94,45;...
    89,153,74;...
    110,188,111;...
    184,220,143;...
    235,215,184;...
    ]/255;
ToPlot.line_colors=line_colors;

% NbROI = numel(ToPlot.ROIs_name);

if isempty(ToPlot.ToPermute)
    suffix = '_ttest';
else
    suffix = '_perm';
end

Name = strrep([ToPlot.TitSuf '--' ToPlot.Name], ' ', '_');
Name = strrep(Name, '_', '-');

if size(SubPlots,2)==3
    figdim = [50, 50, 1500, 600];
elseif size(SubPlots,2)==2
    figdim = [50, 50, 1000, 600];
end

for iRow = 1:size(ToPlot.Legend,1)
    
    fig = figure('Name', [Name '\n' ToPlot.Titles{iRow,1}], ...
        'Position', figdim, 'Color', [1 1 1], 'Visible', ToPlot.Visible);
    
    set(gca,'units','centimeters')
    pos = get(gca,'Position');
    ti = get(gca,'TightInset');
    
    set(fig, 'PaperUnits','centimeters');
    set(fig, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    set(fig, 'PaperPositionMode', 'manual');
    set(fig, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    
    set(fig, 'Visible', ToPlot.Visible)
    
    for iColumn = 1:size(SubPlots,2)
        
        % plot whole ROI
        tmp = ToPlot.ROI(iRow,iColumn).grp;
        
        subplot(m,n,SubPlots{iColumn})
        
        plot_betas(tmp,ToPlot,fontsize)

        t = title(ToPlot.Legend{iRow,iColumn});
        set(t,'fontsize',fontsize+1); clear t
        
        t=ylabel('Decoding accuracy');
        set(t,'fontsize',fontsize); clear t
        
    end
    
    mtit(ToPlot.Titles{iRow,1},'xoff', 0, 'yoff', +0.04, 'fontsize', fontsize+4)
    
    print(fig, fullfile(ToPlot.FigureFolder, ['All_ROIs_' strrep(fig.Name,'\n','-'), suffix, '.tif']), '-dtiff')
    
    
end



end


function plot_betas(tmp,ToPlot,fontsize)

Alpha = 0.05/5;

Xpos = [1 3 6:2:14];
Xpos = Xpos(1:numel(ToPlot.ROIs_name));

% plot zero line
plot([-25 25], [0.5 0.5], '-k','LineWidth', .8)


% plot spead
tmp_cell = mat2cell(tmp,size(tmp,1),ones(1,size(tmp,2)));
for i=1:numel(Xpos)
    distributionPlot(tmp_cell{i}, 'xValues', Xpos(i), 'color', ToPlot.line_colors(i,:), ...
        'distWidth', 1.2, 'showMM', 0, ...
        'globalNorm', 2)
    h = plotSpread(tmp_cell{i}, 'distributionMarkers',{'.'},...
        'xValues', (Xpos(i)), 'binWidth', 1, 'spreadWidth', 1);
    set(h{1}, 'MarkerSize', 7, 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'k', 'LineWidth', 1)
end

% plot mean+SEM
plot(Xpos-.8, nanmean(tmp), 'k. ', 'MarkerSize', 7)
for i=1:numel(Xpos)
    plot([Xpos(i)-.8;Xpos(i)-.8], ...
        [nanmean(tmp(:,i))+nansem(tmp(:,i));nanmean(tmp(:,i))-nansem(tmp(:,i))], ' k','LineWidth', 1.2 )
end


axis tight
ax = axis;
if isfield(ToPlot,'MinMax')
    MIN = ToPlot.MIN;
    MAX = ToPlot.MAX;
else
    MIN = ax(3);
    MAX = ax(4)*1.1;
end

MIN = 0;
MAX = 1.1;
% if MAX<1
%     MAX = 1;
% end


tmp=tmp-.5;
tmp(any(isnan(tmp),2),:) = [];

% now compute p values and print them
if ~isempty(ToPlot.ToPermute)
    for iPerm = 1:size(ToPlot.ToPermute,1)
        tmp2 = ToPlot.ToPermute(iPerm,:);
        tmp2 = repmat(tmp2',1,size(tmp,2));
        Perms(iPerm,:) = mean(tmp.*tmp2);  %#ok<*AGROW>
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
    Sig = []; %#ok<NASGU>
    if P(iP)<0.001
        Sig = sprintf('p<0.001 ');
    else
        Sig = sprintf('p=%.3f ',P(iP));
    end
    
    t = text(...
        Xpos(iP)-.8,...
        .9,...
        sprintf(Sig));
    set(t,'fontsize',fontsize-2);
    
    if P(iP)<Alpha
        set(t,'fontweight','bold','fontsize',fontsize-1.5);
        %         set(t,'color','r','fontweight','bold');
    end
end


axis([-.4 Xpos(end)+.8 MIN MAX])


set(gca, 'tickdir', 'out', 'xtick', Xpos,'xticklabel',ToPlot.ROIs_name, ...
    'ticklength', [0.01 0.01], 'fontsize', fontsize-1, 'FontName','Arial')

end
