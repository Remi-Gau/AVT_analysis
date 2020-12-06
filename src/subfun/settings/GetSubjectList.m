% (C) Copyright 2020 Remi Gau

function [SubLs, NbSub] = GetSubjectList(folder)
    %
    % USAGE::
    %
    %    [SubLs, NbSub] = GetSubjectList(folder)
    %

    if nargin < 1 || isempty(folder)

        SubLs(1).name = 'sub-02';
        SubLs(2).name = 'sub-03';
        SubLs(3).name = 'sub-04';
        SubLs(4).name = 'sub-05';
        SubLs(5).name = 'sub-06';
        SubLs(6).name = 'sub-08';
        SubLs(7).name = 'sub-10';
        SubLs(8).name = 'sub-12';
        SubLs(9).name = 'sub-16';
        SubLs(10).name = 'sub-19';

        NbSub = numel(SubLs);

        return

    end

    SubLs = dir(fullfile(folder, 'sub*'));
    NbSub = numel(SubLs);

    if NbSub < 1
        error('No subject was found');
    end

end
