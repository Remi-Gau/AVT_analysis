function PlotSortedValues(ax, X_sort, NbBin, Profiles, YLabel, PlotScale, Sorting_Raster, CLIM, plot_sub_zero)

if nargin<7
    Sorting_Raster = [];
end

if nargin<8
    warning('No scaling for the sorting raster provided')
    CLIM = [-5 5];
end

if nargin<9
    plot_sub_zero=1;
end

MAX = ceil(max(abs(mean(X_sort,1))));

axPos = ax.Position;
axPos(1) = axPos(1)-.06;
axPos(3) = .05;

% plot the sorting raster
if ~isempty(Sorting_Raster)
    axes('Position',axPos);
    hold on
    %     imagesc(mean(imgaussfilt(Sorting_Raster,[20 .001]),3), CLIM)
    imagesc(mean(imgaussfilt(Sorting_Raster,[size(Profiles,1)/200 .001]),3), CLIM)
    axis([0.5 6.5 1 size(Profiles,1)])
    axis off
end

% plot the sorting variable with horizontal error bars
axes('Position',axPos);
hold on

hh = herrorbar(mean(X_sort,1),1:NbBin, nanstd(X_sort,1));
set(hh,  'color', 'k', 'linewidth',.5)
plot([0 0],[0 NbBin],'-k', 'linewidth',.5)

% plot each subject's zero
if plot_sub_zero
    for i=1:size(X_sort,1)
        tmp = abs(X_sort(i,:));
        [~, idx] = min(tmp); %index of closest value
        plot([MAX*-1 MAX],[idx idx],':k','linewidth',2)
    end
end

axis([MAX*-1 MAX 1 size(Profiles,1)])

XScale = mat2cell([MAX*-1 0 MAX], 1, [1 1 1]);
XScale = cellfun(@num2str,XScale,'UniformOutput',0);
if PlotScale
    set(gca,'color', 'none', 'tickdir', 'out', 'xtick', [MAX*-1 0 MAX],'xticklabel', XScale, ...
        'ytick', linspace(1,size(Profiles,1),5),'yticklabel', 0:25:100, ...
        'ticklength', [0.01 0.01], 'fontsize', 10)
        set(gca,'color', 'none', 'tickdir', 'out', 'xtick', [MAX*-1 0 MAX],'xticklabel', XScale, ...
        'ytick', linspace(1,size(Profiles,1),5),'yticklabel', 0:25:100, ...
        'ticklength', [0.01 0.01], 'fontsize', 10)
else
    set(gca,'color', 'none', 'tickdir', 'out', 'xtick', [MAX*-1 0 MAX],'xticklabel', [MAX*-1 0 MAX], ...
    'ytick', linspace(1,size(Profiles,1),5),'yticklabel', [], ...
    'ticklength', [0.01 0.01], 'fontsize', 10)
end

t=ylabel(YLabel);
set(t,'fontsize',10)

end
