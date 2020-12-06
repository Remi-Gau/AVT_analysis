% (C) Copyright 2020 Remi Gau

function [GroupData, SubjectVec] = ComputeSubjectAverage(Data, SubjectVec)

    if any(isnan(Data))
        error('Input data contains some NaN values');
    end

    ListSubjects = unique(SubjectVec);

    GroupData = nan(numel(ListSubjects), size(Data, 2));

    for idx = 1:numel(ListSubjects)

        iSubject = ListSubjects(idx);
        GroupData(iSubject, :) = mean(Data(SubjectVec == iSubject, :));

    end

    SubjectVec = ListSubjects;

end
