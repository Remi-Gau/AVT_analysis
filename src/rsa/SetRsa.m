function varargout = SetRsa()
    %
    % [InputType, ROIs, Opt, ConditionType, Analysis, CondNames, Dirs] = SetRsa;
    %
    % (C) Copyright 2021 Remi Gau
    
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
        'V1'
        'V2'
        'A1'
        'PT'
        };
    
    %% Options
    Opt = SetDefaults();
    Opt.CombineHemisphere = true;
    
    %%
    ConditionType = 'stim';
    Analysis.name = 'all_stim';
    Analysis.CdtToSelect = 1:6;
    
    if Opt.Targets
        ConditionType = 'target'; %#ok<*UNRCH>
        Analysis.CdtToSelect = 7:12;
        Analysis.name = 'all_target';
    end
    
    CondNames = GetConditionList();
    CondNames = CondNames(Analysis.CdtToSelect);
    
    %% Directorires
    % TODO
    % This input dir might have to change if we are dealing with volume data
    Space = 'surf';
    MVNN = true;
    Dirs = SetDir(Space, MVNN);
    
    varargout = {InputType, ROIs, Opt, ConditionType, Analysis, CondNames, Dirs};
    
end