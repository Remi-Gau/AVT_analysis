function M = Set6X6models(AuditoryOrVisual)

    % AuditoryOrVisual: determines if this is for an auditory or visual ROI

    % To get the conditions this based on::
    %
    %   [~, CondNamesIpsiContra] = GetConditionList()
    %
    % This will run only on the Stimulus or the Target conditions
    % That's why ``NbConditions = 6``

    % Relies on ``FeaturesToAdd`` to decide on the features that will make up
    % the mode
    %
    % 1rst column: Ipsi-contra
    %   1 --> scaled
    %   2 --> independent and scaled.
    %   3 --> independent
    %
    % 2nd column: Condition
    %   1 --> all scaled
    %   2 --> all scaled + non-prefered as scaled versions of each other
    %   3 -->
    %   4 --> preferred and non prefered are independent,
    %         non prefered are scaled versions of each other
    %   5 --> preferred and non prefered are independent,
    %         non prefered are scaled & independent versions of each other
    %   6 --> all independent

    % ------------------
    % older version
    %   1 --> all scaled
    %   2 --> preferred and non-preferred are scaled and independe;non-prefered as scaled versions of each other
    %   3 --> preferred and non prefered are independent, non prefered are
    %   scaled versions of each other
    %   4 --> preferred and non prefered are independent, non prefered are
    %   scaled versions of each other but also indepedent
    %   5 --> all independent
    % ------------------

    % 3rd column: one feature for ipsi of all condition + one feature for contra of all condition
    %   0 --> no
    %   1 --> yes

    % TODO
    % compare to in the docs/pcm/6X6/Set_PCM_models_feature.m

    if nargin < 1 || isempty(AuditoryOrVisual)
        AuditoryOrVisual = 'auditory';
    end

    NbConditions = 6;

    Alg = 'NR'; % 'minimize'; 'NR'

    M = {};

    % null model
    M{1}.type       = 'feature';
    M{1}.Ac = [];
    M{1}.Ac = zeros(NbConditions, 1);
    M{1}.numGparams = size(M{1}.Ac, 3);
    M{1}.name       = 'null';
    M{1}.fitAlgorithm = 'minimize';

    sets = {1:3, 1:6, 0:1};
    [x, y, z] = ndgrid(sets{:});
    FeaturesToAdd = [x(:) y(:) z(:)];

    for iModel = 1:size(FeaturesToAdd, 1)
        M{end + 1}.type       = 'feature'; %#ok<*AGROW>
        % first dummy feature to be able to simply use end+1 everywhere
        M{end}.Ac = [0 0 0 0 0 0]';

        IpsiContraScaled = FeaturesToAdd(iModel, 1);

        switch FeaturesToAdd(iModel, 2)

            case 1
                M = AllScaled(M, NbConditions, IpsiContraScaled);

            case 2
                M = AllScaled(M, NbConditions, IpsiContraScaled);
                M = NonPrefScaled(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);

            case 3
                M = AllScaledWithPrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);
                M = NonPrefScaled(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);
                M = NonPrefIdpdt(M, NbConditions, IpsiContraScaled);

            case 4
                M = PrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);
                M = NonPrefScaled(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);

            case 5
                M = PrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);
                M = NonPrefScaled(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);
                M = NonPrefIdpdt(M, NbConditions, IpsiContraScaled);

            case 6
                M = AllIdpdt(M, NbConditions, IpsiContraScaled);

        end

        switch FeaturesToAdd(iModel, 3)
            case 0
            case 1
                M = GeneralIpsiContra(M);
        end

        % remove dummy feature
        M{end}.Ac(:, :, 1) = [];
        % remove columns of 0s
        M{end}.Ac(:, all(all(M{end}.Ac == 0), 3), :) = [];

        M{end}.numGparams = size(M{end}.Ac, 3);
        M{end}.fitAlgorithm = Alg;

        % Model name
        % These numbers refer to the table of models in the doc.
        % Each number indicates the level of this model factor.
        M{end}.name = [ ...
                       num2str(FeaturesToAdd(iModel, 1)) ',' ...
                       num2str(FeaturesToAdd(iModel, 2)) ',' ...
                       num2str(FeaturesToAdd(iModel, 3))];

    end

    % Free model as Noise ceiling
    M{end + 1}.type       = 'freechol';
    M{end}.numCond    = NbConditions;
    M{end}.name       = 'noiseceiling';
    M{end}           = pcm_prepFreeModel(M{end});
    M{end}.fitAlgorithm = 'minimize';

end

function M = AllScaled(M, NbConditions, IpsiContraScaled)

    if IpsiContraScaled == 1
        col_num = [1 1 1 1 1 1];
    else
        col_num = [1 2 1 2 1 2];
    end

    for i = 1:numel(NbConditions)

        A = zeros(1, numel(NbConditions));
        A(i) = 1;
        M{end}.Ac(:, col_num(i), end + 1) = A;

        if IpsiContraScaled == 2 && mod(col_num(i), 2) == 0
            A = zeros(1, numel(NbConditions));
            A(i) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end

    end

end

function M = PrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual)

    if strcmpi(AuditoryOrVisual, 'auditory')
        Cdt = 1:2;
    else
        Cdt = 3:4;
    end

    if IpsiContraScaled == 1
        col_num = [1 1];
    else
        col_num = [1 2];
    end

    for i = 1:numel(Cdt)

        A = zeros(1, NbConditions);
        A(Cdt(i)) = 1;
        M{end}.Ac(:, col_num(i), end + 1) = A;

        if IpsiContraScaled == 2 && mod(col_num(i), 2) == 0
            A = zeros(1, NbConditions);
            A(Cdt(i)) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end

    end

end

function M = AllScaledWithPrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual)

    M = PrefIdpdt(M, NbConditions, IpsiContraScaled, AuditoryOrVisual);

    if IpsiContraScaled == 1
        col_num = [1 1 1 1 1 1] + size(M{end}.Ac, 2);
    else
        col_num = [1 2 1 2 1 2] + size(M{end}.Ac, 2);
    end

    for i = 1:NbConditions

        A = zeros(1, NbConditions);

        A(i) = 1;

        M{end}.Ac(:, col_num(i), end + 1) = A;

        if IpsiContraScaled == 2 && mod(col_num(i), 2) == 0
            A = zeros(1, NbConditions);
            A(i) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end

    end

end

function M = NonPrefScaled(M, NbConditions, IpsiContraScaled, AuditoryOrVisual)

    if strcmpi(AuditoryOrVisual, 'auditory')
        Cdt = 3:6;
    elseif strcmpi(AuditoryOrVisual, 'visual')
        Cdt = [1 2 5 6];
    end

    if mod(size(M{end}.Ac, 2), 2) == 0
        ColToAppend = size(M{end}.Ac, 2) + 1;
    else
        ColToAppend = size(M{end}.Ac, 2) + 2;
    end

    if IpsiContraScaled == 1
        col_num = repmat(ColToAppend, 1, 4);
    else
        col_num = repmat([ColToAppend, ColToAppend + 1], 1, 2);
    end

    for i = 1:numel(Cdt)

        A = zeros(1, NbConditions);
        A(Cdt(i)) = 1;
        M{end}.Ac(:, col_num(i), end + 1) = A;

        if IpsiContraScaled == 2 && mod(col_num(i), 2) == 0
            A = zeros(1, NbConditions);
            A(Cdt(i)) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end

    end

end

function M = NonPrefIdpdt(M, NbConditions, IpsiContraScaled)

    Cdt = 5:6;

    if mod(size(M{end}.Ac, 2), 2) == 0
        ColToAppend = size(M{end}.Ac, 2) + 1;
    else
        ColToAppend = size(M{end}.Ac, 2) + 2;
    end

    if IpsiContraScaled == 1
        col_num = [ColToAppend ColToAppend];
    else
        col_num = [ColToAppend ColToAppend + 1];
    end

    for i = 1:2
        A = zeros(1, NbConditions);
        A(Cdt(i)) = 1;
        M{end}.Ac(:, col_num(i), end + 1) = A;
        if IpsiContraScaled == 2 && mod(col_num(i), 2) == 0
            A = zeros(1, NbConditions);
            A(Cdt(i)) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end
    end

end

function M = AllIdpdt(M, NbConditions, IpsiContraScaled)

    if IpsiContraScaled == 1
        col_num = [1 1 2 2 3 3];
    else
        col_num = 1:6;
    end

    for i = 1:NbConditions

        A = zeros(1, NbConditions);
        A(i) = 1;
        M{end}.Ac(:, col_num(i), end + 1) = A;

        if IpsiContraScaled == 2 && mod(i, 2) == 0
            A = zeros(1, NbConditions);
            A(i) = 1;
            M{end}.Ac(:, col_num(i) - 1, end + 1) = A;
        end
    end

end

function M = GeneralIpsiContra(M)
    %
    % Adds:
    %   - one feature for ipsi of all condition
    %   - one feature for contra of all condition
    %

    M{end}.Ac(:, end + 1, end + 1) = [1 0 1 0 1 0];
    M{end}.Ac(:, end + 1, end + 1) = [0 1 0 1 0 1];

end
