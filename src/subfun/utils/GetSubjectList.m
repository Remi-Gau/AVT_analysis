% (C) Copyright 2020 Remi Gau

function [SubLs, NbSub] = GetSubjectList(folder)
    %
    % USAGE::
    %
    %    [SubLs, NbSub] = GetSubjectList(folder)
    %

    SubLs = dir(fullfile(folder, 'sub*'));
    NbSub = numel(SubLs);

    if NbSub < 1
        error('No subject was found');
    end

end
