function PlotSortedValues(ax, X_sort, NbBin, Profiles, YLabel, PlotScale, Sorting_Raster, CLIM)

if nargin<7
    Sorting_Raster = [];
end

if nargin<8
    warning('No scaling for the sorting raster provided')
    CLIM = [-5 5];
end

MAX = ceil(max(abs(mean(X_sort,1))));

axPos = ax.Position;
axPos(1) = axPos(1)-.04;
axPos(3) = .03;
axes('Position',axPos);
hold on

if ~isempty(Sorting_Raster)
    imagesc(mean(imgaussfilt(Sorting_Raster,[20 .001]),3), CLIM)
    axis([0.5 6.5 1 size(Profiles,1)])
    axis off
end

axes('Position',axPos);
hold on

hh = herrorbar(mean(X_sort,1),1:NbBin, nanstd(X_sort,1));
set(hh,  'color', 'b', 'linewidth',.5)
plot([0 0],[0 size(Profiles,1)],'k')


for i=1:size(X_sort,1)
    tmp = abs(X_sort(i,:));
    [~, idx] = min(tmp); %index of closest value
    plot([MAX*-1 MAX],[idx idx],':k')
end

axis([MAX*-1 MAX 1 size(Profiles,1)])

if PlotScale
    set(gca,'color', 'none', 'tickdir', 'out', 'xtick', [MAX*-1 MAX],'xticklabel', [MAX*-1 MAX], ...
        'ytick', linspace(1,size(Profiles,1),5),'yticklabel', 0:25:100, ...
        'ticklength', [0.01 0.01], 'fontsize', 6)
else
    set(gca,'color', 'none', 'tickdir', 'out', 'xtick', [MAX*-1 MAX],'xticklabel', [MAX*-1 MAX], ...
    'ytick', linspace(1,size(Profiles,1),5),'yticklabel', [], ...
    'ticklength', [0.01 0.01], 'fontsize', 6)
end

t=ylabel(YLabel);
set(t,'fontsize',10)

end
