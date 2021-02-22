% (C) Copyright 2020 Remi Gau

function [GroupData, SubjectVec] = ComputeSubjectAverage(Data, SubjectVec)
    %
    % Given almost tidy data and a vector specifying which rows belongs to which
    % subject, it returns an array with one row per subject.
    %
    % USAGE::
    %
    %   [GroupData, SubjectVec] = ComputeSubjectAverage(Data, SubjectVec)
    %
    % :param Data:
    % :type Data: array
    % :param SubjectVec:
    % :type SubjectVec:
    %
    % :returns:
    %           :GroupData:
    %           :SubjectVec:

    if any(isnan(Data))
        error('Input data contains some NaN values');
    end

    % make sure SubjectVec is a vertical vector
    SubjectVec = ReturnVerticalVector(SubjectVec);

    ListSubjects = unique(SubjectVec);

    GroupData = nan(numel(ListSubjects), size(Data, 2));

    for idx = 1:numel(ListSubjects)

        iSubject = ListSubjects(idx);
        RowsToSelect = ReturnRowsToSelect({SubjectVec, iSubject});
        GroupData(iSubject, :) = mean(Data(RowsToSelect, :));

    end

    SubjectVec = ListSubjects;

end
