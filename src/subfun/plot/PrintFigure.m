% (C) Copyright 2021 Remi Gau

function PrintFigure(OutputDir)
    [~, ~, ~] = mkdir(OutputDir);
    Filename = strrep(get(gcf, 'name'), ' ', '_');
    print(gcf, fullfile(OutputDir, [Filename '.tif']), '-dtiff');
end