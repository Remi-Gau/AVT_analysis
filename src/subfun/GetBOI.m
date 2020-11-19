function [BetaOfInterest, BetaNames] = GetBOI(SPM, CondNames)
  % GETBOI Gets the numbers of the betas of interest
  %   Detailed explanation goes here

  BetaNames = char(SPM.xX.name'); % list regressor names

  for iCond = 1:numel(CondNames)
    tmp = strfind(cellstr(BetaNames), [CondNames{iCond} '*bf(1)']);
    BetaOfInterest(:, iCond) = ~cellfun('isempty', tmp);
    clear tmp;
  end

  BetaOfInterest = find(any(BetaOfInterest, 2));

end
