function [SubLs, NbSub] = GetSubjectList(derivatives_dir)
    SubLs = dir(fullfile(derivatives_dir, 'sub*'));
    NbSub = numel(SubLs);

    if NbSub < 1
        error('No subject was found');
    end
end
