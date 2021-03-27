% (C) Copyright 2020 Remi Gau

function CreateFigureColorBar(Name, MIN, MAX, ColorMap)

    if nargin < 1
        Name = 'test';
    end

    if nargin < 3
        MAX = 100;
        MIN = -50;
    end

    if nargin < 4
        ColorMap = BrainColourMaps('hot_increasing');
    end

    NbYtick = 10;
    NbLevels = 1000;

    % Create a scale with the original values
    figure( ...
           'name', Name, ...
           'Position', [50, 50, 200, 500], ...
           'Color', [1 1 1]);

    SetFigureDefaults();

    colormap(ColorMap);

    imagesc(repmat(linspace(MAX, MIN, NbLevels)', 1, 100));

    set(gca, ...
        'tickdir', 'out', ...
        'xtick', [], ...
        'xticklabel', [], ...
        'ytick', linspace(1, NbLevels, NbYtick), ...
        'yticklabel', floor(linspace(MAX, MIN, NbYtick) * NbLevels) / NbLevels, ...
        'ticklength', [0.01 0.01], ...
        'fontsize', 10);

    % For a second axis
    %         ax = gca;
    %         axPos = ax.Position;
    %
    %         axes('Position', axPos);
    %
    %         imagesc(repmat(linspace(MAX, MIN, NbLevels)', 1, NbLevels));
    %
    % get the Y scale unnormalized
    %         linspace(MAX,MIN,NbYtick)
    %         abs(linspace(MAX,MIN,NbYtick))
    %         10.^abs(linspace(MAX,MIN,NbYtick))
    %         10.^abs(linspace(MAX,MIN,NbYtick))*Min2Keep
    %         10.^abs(linspace(MAX,MIN,NbYtick))*Min2Keep.*sign(linspace(MAX,MIN,NbYtick))
    %         YTickLabel = linspace(MAX, MIN, NbYtick);
    %         YTickLabel = 10.^(abs(linspace(MAX, MIN, NbYtick))) * Min2Keep .* sign(YTickLabel);
    %         YTickLabel = floor(YTickLabel * 10^4) / 10^4;
    %
    %         set(gca, 'tickdir', 'out', 'xtick', [], 'xticklabel', [], ...
    %             'ytick', linspace(1, 1000, NbYtick), ...
    %             'yticklabel', YTickLabel, ...
    %             'YAxisLocation', 'right', ...
    %             'ticklength', [0.01 0.01], 'fontsize', 14);

end
