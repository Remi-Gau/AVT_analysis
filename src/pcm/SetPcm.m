function varargout = SetPcm()
    %
    % [ModelType, InputType, ROIs, ConditionType, Dirs] = SetPcm()
    %
    % (C) Copyright 2021 Remi Gau

    % '3X3', '6X6', 'subset6X6'
    ModelType = 'subset6X6';

    % Choose on what type of data the analysis will be run
    %
    % b-parameters
    %
    % 'ROI'
    %
    % s-parameters
    %
    % 'Cst', 'Lin', 'Quad'
    %
    InputType = 'Cst';

    % Region of interest:
    %  possible choices: A1, PT, V1-5
    ROIs = { ...
            'A1'
            'PT'
            'V1'
            'V2'
           };

    ConditionType = 'stim';
    if Opt.Targets
        ConditionType = 'target'; %#ok<*UNRCH>
    end

    MVNN = true;
    Space = 'surf';
    Dirs = SetDir(Space, MVNN);

    varargout = {ModelType, InputType, ROIs, ConditionType, Dirs};
end
