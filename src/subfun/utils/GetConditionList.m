% (C) Copyright 2020 Remi Gau

function  [CondNames, CondNamesIpsiContra] = GetConditionList()

    CondNames = { ...
                 'AStimL', 'AStimR', ...
                 'VStimL', 'VStimR', ...
                 'TStimL', 'TStimR', ...
                 'ATargL', 'ATargR', ...
                 'VTargL', 'VTargR', ...
                 'TTargL', 'TTargR' ...
                };

    CondNamesIpsiContra = { ...
                           'AStimIpsi', 'AStimContra', ...
                           'VStimIpsi', 'VStimContra', ...
                           'TStimIpsi', 'TStimContra', ...
                           'ATargIpsi', 'ATargContra', ...
                           'VTargIpsi', 'VTargContra', ...
                           'TTargIpsi', 'TTargContra' ...
                          };

end
