% (C) Copyright 2020 Remi Gau
function PlotRectangle(NbLayers, Fontsize, LabelDepth)

    if nargin < 3 || isempty(LabelDepth)
        LabelDepth = 1;
    end

    COLOR_LAYERS = LayerColours();

    ax = gca;
    axPos = ax.Position;
    axPos(2) = axPos(2) - .02;
    axPos(4) = .02;
    axes('Position', axPos);

    TEXT = round(linspace(0, 100, NbLayers + 2));
    TEXT([1 end]) = [];
    TEXT = fliplr(TEXT);

    RecPos = linspace(0, 0.9, NbLayers + 1);

    for i = 1:size(COLOR_LAYERS, 1)
        rectangle('Position', [RecPos(i) 0 diff(RecPos(1:2)) 1], 'facecolor', COLOR_LAYERS(i, :), 'edgecolor', 'w');
        if LabelDepth
            t = text(RecPos(i) + diff(RecPos(1:2)) / 2 - .026, 0.5, num2str(TEXT(i)));
            set(t, 'fontsize', Fontsize);
        end
    end

    axis([0 0.9 0 1]);

    set(gca, 'color', 'none', 'tickdir', 'out', 'xtick', [0 0.45 .9], 'xticklabel',  {'WM|     ' 'GM' '     |CSF'}, ...
        'ytick', [], 'yticklabel', [], ...
        'ticklength', [0.00001 0], 'fontsize', Fontsize);
end
