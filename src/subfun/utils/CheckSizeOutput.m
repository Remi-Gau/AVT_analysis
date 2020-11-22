% (C) Copyright 2020 Remi Gau
function CheckSizeOutput(Data, Conditions, Runs, Layers)
    %
    % Makes sure that the 2D data matrix and its "data dictionary" vector are
    % matched in terms of row numbers.
    %

    % HACK
    % if this input is missing we assume we create a dummy that has the same
    % number of rows as the data matrix
    % This makes the error message potentially more confusing if no layer is
    % involved
    if nargin < 4
        Layers = nan(size(Runs, 1), 1);
    end

    if any([size(Conditions, 1) size(Runs, 1) size(Layers, 1)] ~= size(Data, 1))

        msg = sprintf(['Number or rows in a data dictionary unmatched to that of data matrix.', ...
                       '\n- Data matrix: %i', ...
                       '\n- Condition vector: %i', ...
                       '\n- Run vector: %i', ...
                       '\n- Layer vector: %i\n'], ...
                      size(Data, 1), size(Conditions, 1), size(Runs, 1), size(Layers, 1));

        errorStruct.identifier = 'CheckSizeOutput:NonMatchingSize';
        errorStruct.message = msg;
        error(errorStruct);

    end

end
