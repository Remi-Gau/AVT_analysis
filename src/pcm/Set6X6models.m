% (C) Copyright 2020 Remi Gau

function M = Set6X6models(AuditoryOrVisual, FeaturesToAdd)

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

    for iModel = 1:size(FeaturesToAdd, 1)
        M{end + 1}.type       = 'feature'; %#ok<*AGROW>
        % first dummy feature to be able to simply use end+1 everywhere
        M{end}.Ac = [0 0 0 0 0 0]';

        IpsiContraScaled = FeaturesToAdd(iModel, 1);

        switch FeaturesToAdd(iModel, 2)

            case 1
                M = AllScaled(M, NbConditions, IpsiContraScaled);
%                 M = AllIdpdt(M, NbConditions, IpsiContraScaled);

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

        M = SetFeatureGeneralIpsiContra(M, FeaturesToAdd(iModel, 3));
        
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















