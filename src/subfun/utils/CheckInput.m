% (C) Copyright 2020 Remi Gau

function [Data, Runs, Conditions, Layers] = CheckInput(Data, Runs, Conditions, IsTarget, Layers)
    %
    % - Removes target data if necessary.
    % - Make sure all runs have the same number of condtions.
    % - Makes sures all output have the same number of rows.
    %
    % USAGE::
    %
    %   [Data, Runs, Conditions, Layers] = CheckInput(Data, Runs, Conditions, IsTarget, Layers)
    %

    % HACK to give layers some plausible dimension
    if nargin < 5 || isempty(Layers)
        Layers = nan(size(Conditions));
    end

    % Remove target data
    % In many cases this might no be necessary but it could make the data matrix
    % lighter and thus easier to pass around.
    if ~IsTarget
        Conditions(Conditions > 6) = 0;
    end
    Data(Conditions == 0, :) = [];
    Runs(Conditions == 0) = [];
    Layers(Conditions == 0) = [];
    Conditions(Conditions == 0) = [];

    % make sure all runs have the same number of condtions
    RunsToRemove = IdentifyRunsToRemove(Runs, Conditions);
    if ~isempty(RunsToRemove)
        Data(Runs == RunsToRemove, :) = [];
        Conditions(Runs == RunsToRemove) = [];
        Layers(Runs == RunsToRemove) = [];
        Runs(Runs == RunsToRemove) = [];
    end

    CheckSizeOutput(Data, Conditions, Runs, Layers);

end
