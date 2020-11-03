function set_tight_figure()

  set(gca, 'units', 'centimeters');
  pos = get(gca, 'Position');
  ti = get(gca, 'TightInset');

  set(gcf, 'PaperUnits', 'centimeters');
  set(gcf, 'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
  set(gcf, 'PaperPositionMode', 'manual');
  set(gcf, 'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)]);
  %                 set(gcf, 'PaperOrientation','landscape');

end
