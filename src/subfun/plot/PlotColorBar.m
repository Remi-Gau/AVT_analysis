function PlotColorBar(ax, ColorMap, CLIM)

  axPos = ax.Position;
  axPos(1) = axPos(1) + axPos(3) + .04;
  axPos(3) = .01;
  axes('Position', axPos);

  colormap(ColorMap);
  imagesc(repmat([CLIM(2):-.01:CLIM(1)]', [1, 200]), CLIM);
  set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel',  [], ...
      'ytick', linspace(1, numel(CLIM(2):-.01:CLIM(1)), 5), ...
      'yticklabel', round(10 * linspace(CLIM(2), CLIM(1), 5)) / 10, ...
      'ticklength', [0.01 0.01], 'fontsize', 8, 'YAxisLocation', 'right');
  box off;

end
