% (C) Copyright 2020 Remi Gau
function PlotRectangle(Opt, PrintDepthLabel)

    if nargin < 1 || isempty(Opt)
        Opt.Fontsize = 8;
    end

    if nargin < 2 || isempty(PrintDepthLabel)
        PrintDepthLabel = true;
    end

    COLOR_LAYERS = LayerColours();
    Opt.NbLayers = size(COLOR_LAYERS, 1);

    Ax = gca;
    AxPos = Ax.Position;
    AxPos(2) = AxPos(2) - .015;
    AxPos(4) = .015;
    axes('Position', AxPos);

    Text = round(linspace(0, 100, Opt.NbLayers + 2));
    Text([1 end]) = [];
    Text = fliplr(Text);

    RecPos = linspace(0, 0.9, Opt.NbLayers + 1);

    for i = 1:size(COLOR_LAYERS, 1)

        rectangle( ...
                  'Position', [RecPos(i) 0 diff(RecPos(1:2)) 1], ...
                  'facecolor', COLOR_LAYERS(i, :), 'edgecolor', 'w');

        if PrintDepthLabel
            t = text( ...
                     RecPos(i) + diff(RecPos(1:2)) / 2, ...
                     0.5, ...
                     num2str(Text(i)));
            set(t, 'fontsize', Opt.Fontsize);
        end

    end

    axis([0, 0.9, 0, 1]);

    set(gca, ...
        'color', 'none', ...
        'tickdir', 'out', ...
        'xtick', [0 0.45 .9], ...
        'xticklabel',  {'WM|     ' 'GM' '     |CSF'}, ...
        'ytick', [], ...
        'yticklabel', [], ...
        'ticklength', [0.0001 0], ...
        'fontsize', Opt.Fontsize);
end
