% (C) Copyright 2020 Remi Gau
function SetFigureDefaults(Opt)
    
    if nargin < 1 || isempty(Opt)
        Opt.Visible = 'on';
    end

    set(gca, 'units', 'centimeters');
    pos = get(gca, 'Position');
    ti = get(gca, 'TightInset');

    set(gcf, ...
        'PaperUnits', 'centimeters', ....
        'PaperSize', [pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)], ....
        'PaperPositionMode', 'manual', ....
        'PaperPosition', [0 0 pos(3) + ti(1) + ti(3) pos(4) + ti(2) + ti(4)], ....
        'defaultAxesFontName', 'Arial', ....
        'defaultTextFontName', 'Arial', ...
        'Color', [1 1 1], ...
        'Visible', Opt.Visible);

end
