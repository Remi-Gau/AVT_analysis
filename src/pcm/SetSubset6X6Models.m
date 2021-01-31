% (C) Copyright 2020 Remi Gau

function M = SetSubset6X6Models(IsAuditoryRoi)

    if nargin < 1 || isempty(IsAuditoryRoi)
        IsAuditoryRoi = true();
    end

    NbConditions = 6;

    Alg = 'NR'; % 'minimize'; 'NR'

    ModelList = { ...
                 {['A', 'V', 'T'], []}, true(1, 3); ... % all cdt scaled: 2 models
                 {['A', 'V', 'T'], []}, false(1, 3); ...
                 {[], ['A', 'V', 'T']}, true(1, 3); ... % all cdt idpdt: 8 models
                 {[], ['A', 'V', 'T']}, [true, true, false]; ...
                 {[], ['A', 'V', 'T']}, [true, false, true]; ...
                 {[], ['A', 'V', 'T']}, [true, false, false]; ...
                 {[], ['A', 'V', 'T']}, [false, true, true]; ...
                 {[], ['A', 'V', 'T']}, [false, true, false]; ...
                 {[], ['A', 'V', 'T']}, [false, false, true]; ...
                 {[], ['A', 'V', 'T']}, false(1, 3) ...
                };

    % Preferred condition is independent: 4 models
    if IsAuditoryRoi
        tmp = { ...
               {['V', 'T'], ['A']}, true(1, 3); ...
               {['V', 'T'], ['A']}, [true false false]; ...
               {['V', 'T'], ['A']}, [false true true]; ...
               {['V', 'T'], ['A']}, false(1, 3) ...
              };
    else
        tmp = { ...
               {['A', 'T'], ['V']}, true(1, 3); ...
               {['A', 'T'], ['V']}, [false true false]; ...
               {['A', 'T'], ['V']}, [true false true]; ...
               {['A', 'T'], ['V']}, false(1, 3) ...
              };
    end

    ModelList = cat(1, ModelList, tmp);
    clear tmp;

    M = {};

    M = SetNullModelPcm(M, NbConditions);

    for iModel = 1:size(ModelList)
        M = SetModelSixConditions(M, ModelList{iModel, 1}, ModelList{iModel, 2});
        M{end}.type       = 'feature'; %#ok<*AGROW>
        M{end}.numGparams = size(M{end}.Ac, 3);
        M{end}.fitAlgorithm = Alg;

        name = [];
        if ~isempty(ModelList{iModel, 1}{1})
            name = [name, 'Scaled_' ModelList{iModel, 1}{1} '-'];
        end
        if ~isempty(ModelList{iModel, 1}{2})
            name = [name 'Independent_' ModelList{iModel, 1}{2} '-'];
        end
        name = [name 'IpsiContraScaled_' num2str(ModelList{iModel, 2})];
        M{end}.name = strrep(name, ' ', '');

    end

    M = SetFreeModelPcm(M, NbConditions);

end
