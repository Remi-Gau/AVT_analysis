% (C) Copyright 2020 Remi Gau

function M = Set3X3models()

    CondNames = { ...
                 'A ipsi', 'A contra', ...
                 'V ipsi', 'V contra', ...
                 'T ipsi', 'T contra' ...
                };

    Alg = 'NR'; % 'minimize'; 'NR'

    M = {};

    % null model
    M{1}.type       = 'feature';
    M{1}.Ac = [];
    M{1}.Ac = zeros(3, 1);
    M{1}.numGparams = size(M{1}.Ac, 3);
    M{1}.name       = 'null';
    M{1}.fitAlgorithm = 'minimize';

    % A, T, V scaled
    M{end + 1}.type = 'feature';
    M{end}.name = 'all_scaled';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 1, end + 1) = [0 1 0]';
    M{end}.Ac(:, 1, end + 1) = [0 0 1]';

    % A, V, T idpdt
    M{end + 1}.type = 'feature';
    M{end}.name = 'all_idpdt';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 2, end + 1) = [0 1 0]';
    M{end}.Ac(:, 3, end + 1) = [0 0 1]';

    % A, V, T scaled + idpdt
    M{end + 1}.type = 'feature';
    M{end}.name = 'all_scaled_&_idpdt';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 1, end + 1) = [0 1 0]';
    M{end}.Ac(:, 1, end + 1) = [0 0 1]';
    M{end}.Ac(:, 2, end + 1) = [1 0 0]';
    M{end}.Ac(:, 3, end + 1) = [0 1 0]';
    M{end}.Ac(:, 4, end + 1) = [0 0 1]';

    % A idpdt-V,T scaled
    M{end + 1}.type = 'feature';
    M{end}.name = 'A idpdt-V,T scaled';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 2, end + 1) = [0 1 0]';
    M{end}.Ac(:, 2, end + 1) = [0 0 1]';

    % V idpdt-A,T scaled
    M{end + 1}.type = 'feature';
    M{end}.name = 'V idpdt-A,T scaled';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 2, end + 1) = [0 1 0]';
    M{end}.Ac(:, 1, end + 1) = [0 0 1]';

    % T idpdt-V,A scaled
    M{end + 1}.type = 'feature';
    M{end}.name = 'T idpdt-V,A scaled';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 1, end + 1) = [0 1 0]';
    M{end}.Ac(:, 2, end + 1) = [0 0 1]';

    % A idpdt+scaled-V,T scaled
    M{end + 1}.type = 'feature';
    M{end}.name = 'A idpdt+scaled-V,T scaled';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 2, end + 1) = [0 1 0]';
    M{end}.Ac(:, 2, end + 1) = [0 0 1]';
    M{end}.Ac(:, 2, end + 1) = [1 0 0]';

    % V idpdt+scaled-A,T scaled
    M{end + 1}.type = 'feature';
    M{end}.name = 'V idpdt+scaled-A,T scaled';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 1, end + 1) = [0 1 0]';
    M{end}.Ac(:, 1, end + 1) = [0 0 1]';
    M{end}.Ac(:, 2, end + 1) = [0 1 0]';

    % T idpdt+scaled-V,A scaled
    M{end + 1}.type = 'feature';
    M{end}.name = 'T idpdt+scaled-V,A scaled';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 1, end + 1) = [0 1 0]';
    M{end}.Ac(:, 1, end + 1) = [0 0 1]';
    M{end}.Ac(:, 2, end + 1) = [0 0 1]';

    % A idpdt+scaled V-V,T idpdt-A,T idpdt
    M{end + 1}.type = 'feature';
    M{end}.name = 'A idpdt+scaled V-V,T idpdt-A,T idpdt';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 1, end + 1) = [0 1 0]';
    M{end}.Ac(:, 2, end + 1) = [1 0 0]';
    M{end}.Ac(:, 3, end + 1) = [0 0 1]';

    % A idpdt+scaled T-V,T idpdt-A,V idpdt
    M{end + 1}.type = 'feature';
    M{end}.name = 'A idpdt+scaled T-V,T idpdt-A,V idpdt';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 1, end + 1) = [0 0 1]';
    M{end}.Ac(:, 2, end + 1) = [1 0 0]';
    M{end}.Ac(:, 3, end + 1) = [0 1 0]';

    % T idpdt+scaled V-V,A idpdt-T,A idpdt
    M{end + 1}.type = 'feature';
    M{end}.name = 'T idpdt+scaled V-V,A idpdt-T,A idpdt';
    M{end}.Ac = [];
    M{end}.Ac(:, 1, 1) = [1 0 0]';
    M{end}.Ac(:, 2, end + 1) = [0 1 0]';
    M{end}.Ac(:, 2, end + 1) = [0 0 1]';
    M{end}.Ac(:, 3, end + 1) = [0 0 1]';
    
    for iM = 2:( numel(M)- 1 )
        M{iM}.fitAlgorithm = Alg;
        M{iM}.numGparams = size(M{iM}.Ac, 3);
    end

    % Free model as Noise ceiling
    M{end + 1}.type       = 'freechol';
    M{end}.numCond    = numel(CondNames) / 2;
    M{end}.name       = 'noiseceiling';
    M{end}           = pcm_prepFreeModel(M{end});
    M{end}.fitAlgorithm = 'minimize';

end
