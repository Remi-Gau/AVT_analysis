function [c, message] = ReturnContrast(ContrastType, model, Conditions, CdtNames)
    %
    % (C) Copyright 2021 Remi Gau

    PARAM = {'Cst', 'Lin'};
    SIDE = {'Ipsi', 'Contra'};

    if nargin > 3
        Conditions = CdtNames(Conditions);
    end

    tmp = [];

    switch ContrastType
        case 'F_CstOrLin'

            message = 'effect of either linear OR constant';
            for i = 1:numel(PARAM)
                tmp = [tmp; ReturnRegLogicIdx(model, PARAM{i})];
            end

        case 'F_Cdt'
            message = sprintf('F Contrast; Conditions: %s VS %s', ...
                              strjoin(Conditions{1}, ' '), ...
                              strjoin(Conditions{2}, ' '));

            tmp(1, :) = ReturnRegLogicIdx(model, Conditions{1});
            tmp(2, :) = ReturnRegLogicIdx(model, Conditions{2});

            tmp = logical(tmp);

        case 'F_CdtXSide'
            message = 'F Contrast; Interaction between condition and stimulated side';

            if nargin > 3
                tmp(1, :) = ReturnRegLogicIdx(model, {Conditions{1}; SIDE{1}});
                tmp(2, :) = ReturnRegLogicIdx(model, {Conditions{2}; SIDE{2}});

            else
                tmp1(1, :) = ReturnRegLogicIdx(model, {Conditions{1}; SIDE{1}});
                tmp1(2, :) = ReturnRegLogicIdx(model, {Conditions{2}; SIDE{2}});
                tmp(1, :) = any(tmp1);

                tmp1(1, :) = ReturnRegLogicIdx(model, {Conditions{1}; SIDE{2}});
                tmp1(2, :) = ReturnRegLogicIdx(model, {Conditions{2}; SIDE{1}});
                tmp(2, :) = any(tmp1);

            end

            tmp = logical(tmp);

        case 'F'
            message = ['effect of ' Conditions{1} ' averaged'];
            tmp = ReturnRegLogicIdx(model, Conditions);

    end

    c = zeros(size(tmp));
    c(tmp) = 1;

end

function idx = ReturnRegLogicIdx(model, string)
    if ~iscell(string)
        string = {string};
    end
    for i = 1:size(string, 1)
        idx(i, :) = cellfun(@(x) ~isempty(x), strfind(lower(model.RegNames), lower(string{i})));
    end
    idx = all(idx, 1);
end
