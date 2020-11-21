% (C) Copyright 2020 Remi Gau
function SaveMatLabBatch(File, Var)
    % SAVEMATLABBATCH
    %   To save in a parfor loop
    save(File, 'Var');
end
