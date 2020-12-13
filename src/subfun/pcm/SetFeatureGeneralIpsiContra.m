% (C) Copyright 2020 Remi Gau

function Models = SetFeatureGeneralIpsiContra(Models, Do)
    %
    % Adds:
    %   - one feature for ipsi of all condition
    %   - one feature for contra of all condition
    %
    
    if Do == 1

    Models{end}.Ac(:, end + 1, end + 1) = [1 0 1 0 1 0];
    Models{end}.Ac(:, end + 1, end + 1) = [0 1 0 1 0 1];
    
    end

end