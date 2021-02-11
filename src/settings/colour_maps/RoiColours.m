% (C) Copyright 2020 Remi Gau

function COLOR_ROIS = RoiColours()
    %
    % Returns the color for each ROI
    %

    COLOR_ROIS = [ ...
                  37, 52, 148; ...
                  65, 182, 196; ...
                  0, 94, 45; ...
                  89, 153, 74; ...
                  110, 188, 111; ...
                  184, 220, 143; ...
                  235, 215, 184];
    COLOR_ROIS = COLOR_ROIS / 255;

end