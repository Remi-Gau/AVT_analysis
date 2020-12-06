function M = Set_PCM_models_feature_2

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
    M{1}.Ac = zeros(numel(CondNames), 1);
    M{1}.numGparams = size(M{1}.Ac, 3);
    % M{1}.theta0=ones(size(M{1}.Ac,3),1);
    M{1}.name       = 'null';
    M{1}.fitAlgorithm = 'minimize';

    % 1rst column: Ipsi-contra
    %   1 --> scaled
    %   2 --> independent and scaled.
    %   3 --> independent
    % 2nd column: condition
    %   1 --> all scaled + all independent
    % 3rd column: one feature for ipsi of all condition + one feature for contra of all condition
    %   1 --> no
    %   2 --> yes

    sets = {1:3, 1, 1:2};
    [x, y, z] = ndgrid(sets{:});
    Features_to_add = [x(:) y(:) z(:)];

    for iModel_2_create = 1:size(Features_to_add, 1)
        M{end + 1}.type       = 'feature';
        M{end}.Ac = [0 0 0 0 0 0]'; % first dummy feature to be able to simply use end+1 everywhere

        IpsiContraScaled = Features_to_add(iModel_2_create, 1);

        switch Features_to_add(iModel_2_create, 2)
            case 1
                M = All_scaled(M, CondNames, IpsiContraScaled);
                M = All_idpdt(M, CondNames, IpsiContraScaled);
        end

        switch Features_to_add(iModel_2_create, 3)
            case 1
            case 2
                M = General_ipsi_contra(M);
        end

        M{end}.Ac(:, :, 1) = []; % remove dummy feature
        M{end}.Ac(:, all(all(M{end}.Ac == 0), 3), :) = []; % remove columns of 0s

        M{end}.numGparams = size(M{end}.Ac, 3);
        % M{end}.theta0=ones(size(M{end}.Ac,3),1);
        M{end}.fitAlgorithm = Alg;

        M{end}.name = [ ...
                       num2str(Features_to_add(iModel_2_create, 1)) ',' ...
                       num2str(Features_to_add(iModel_2_create, 2)) ',' ...
                       num2str(Features_to_add(iModel_2_create, 3))];

    end

end

function M = All_scaled(M, CondNames, IpsiContraScaled)
    if IpsiContraScaled == 1
        col_num = [1 1 1 1 1 1];
    else
        col_num = [1 2 1 2 1 2];
    end
    for i = 1:numel(CondNames)
        A = zeros(1, numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:, col_num(i), end + 1) = A;
        if IpsiContraScaled == 2 && mod(col_num(i), 2) == 0
            A = zeros(1, numel(CondNames));
            A(i) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end
    end
end

function M = All_idpdt(M, CondNames, IpsiContraScaled)
    if IpsiContraScaled == 1
        col_num = [1 1 2 2 3 3] + size(M{end}.Ac, 2);
    else
        col_num = (1:6) + size(M{end}.Ac, 2);
    end
    for i = 1:numel(CondNames)
        A = zeros(1, numel(CondNames));
        A(i) = 1;
        M{end}.Ac(:, col_num(i), end + 1) = A;
        if IpsiContraScaled == 2 && mod(i, 2) == 0
            A = zeros(1, numel(CondNames));
            A(i) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end
    end
end

function M = General_ipsi_contra(M)
    M{end}.Ac(:, end + 1, end + 1) = [1 0 1 0 1 0];
    M{end}.Ac(:, end + 1, end + 1) = [0 1 0 1 0 1];
end