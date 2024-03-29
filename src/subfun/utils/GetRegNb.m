function RegNumbers = GetRegNb(SPM)
    %
    % Gets the number each regressor of the SPM design matrix.
    %
    % USAGE::
    %
    %   RegNumbers = GetRegNb(SPM)
    %
    % :returns:
    %           :RegNumbers: [n X m] matrix with n being the number of session and m the
    %                        maximum number of regressors per session.
    %                        This matrix is NaN padded.
    %
    %
    % (C) Copyright 2020 Remi Gau

    MAX = 0;
    for i = 1:size(SPM.Sess, 2)
        MAX = max([MAX, length(SPM.Sess(i).col)]);
    end
    RegNumbers = nan(size(SPM.Sess, 2), MAX);
    for i = 1:size(SPM.Sess, 2)
        RegNumbers(i, 1:length(SPM.Sess(i).col)) = SPM.Sess(i).col;
    end
    clear i MAX;

end
