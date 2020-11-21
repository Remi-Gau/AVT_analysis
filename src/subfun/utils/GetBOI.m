% (C) Copyright 2020 Remi Gau
function [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames)
    %
    %  Gets the indices of some betas of interest.
    %
    % USAGE::
    %
    %    [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames)
    %

    BetaNames = char(SPM.xX.name'); % list regressor names

    for iCond = 1:numel(CondNames)
        tmp = strfind(cellstr(BetaNames), [CondNames{iCond} '*bf(1)']);
        BetaOfInterest(:, iCond) = ~cellfun('isempty', tmp); %#ok<*AGROW>
        clear tmp;
    end

    BetaOfInterest = find(any(BetaOfInterest, 2));

end
