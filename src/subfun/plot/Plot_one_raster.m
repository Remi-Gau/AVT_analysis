function Plot_one_raster(Profiles, Title, FontSize, CLIM)
  % UNTITLED Plots one raster

  NbLayers = 6;

  DephLevels = round(linspace(100, 0, 8));
  DephLevels([1; end]) = [];

  imagesc(imgaussfilt(flipud(Profiles), [size(Profiles, 1) / 500 .001]), CLIM);

  axis([0.5 NbLayers + .5 0 size(Profiles, 1)]);

  t = title(Title);
  set(t, 'fontsize', FontSize);

  set(gca, 'color', 'none', 'tickdir', 'out', 'xtick', 1:NbLayers, 'xticklabel',  DephLevels, ...
      'ytick', [], 'yticklabel', [], ...
      'ticklength', [0.01 0], 'fontsize', FontSize);

end
