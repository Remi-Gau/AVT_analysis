function [Data, SubjectVec] = GenerateDataROI(OptGenData, ROI, Cdt)

    %  Cst       Lin      Quad
    %  0.1767    0.2359   -0.0594 % Target
    % -0.3948   -0.0500   -0.0117 % Stim

    % target
    if ROI == 1 && Cdt == 1
        Cst = 0.1767;
        Lin = 0.2359;
        Quad = -0.0594;
    end

    if ROI == 2 && Cdt == 1
        Cst = -5;
        Lin = 0.8;
        Quad = 0.1;
    end

    % Stim
    if ROI == 1 && Cdt == 2
        Cst = -0.3948;
        Lin = -0.0500;
        Quad = -0.0117;
    end

    if ROI == 2 && Cdt == 2
        Cst = 2;
        Lin = -0.4;
        Quad = 0.1;
    end

    OptGenData.StdDevBetweenSubject = 0.1;
    OptGenData.StdDevWithinSubject = 0.1;

    OptGenData.Betas = [Cst; Lin; Quad];

    [Data, SubjectVec] = GenerateGroupDataLaminarProfiles(OptGenData);

end
