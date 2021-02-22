% (C) Copyright 2020 Remi Gau

function [DispersionIndexLower, DispersionIndexUpper] = ComputeDispersionIndex(Data, Opt)
    %
    % Returns a "dispersion index" for some given data. This can be the standard
    % deviation, SEM or a confidence interval. As this is mostly used for
    % plotting it will return 2 values the "positive" and "negative" values
    % around the mean of the data.
    %
    % USAGE::
    %
    %   [DispersionIndexLower, DispersionIndexUpper] = ComputeDispersionIndex(Data, Opt)
    %
    % :param Data:
    % :type Data: array
    % :param Opt: ``Opt.ErrorBarType`` defines what output to return. The default is ``STD``.
    %             Values can be: ``SEM``, ``CI`` for an accelerated bootstrap confidence
    %             interval around the mean value, ``CI-BC`` for an accelerated bootstrap confidence
    %             interval around a bias corrected value of the effect size.
    % :type Opt: structure
    %
    % :returns:
    %           :DispersionIndexLower: If you want to recover the lower bound
    %                                  then do ``mean(Data) - DispersionIndexLower``
    %           :DispersionIndexUpper: If you want to recover the upper bound
    %                                  then do ``mean(Data) - DispersionIndexUpper``

    switch Opt.ErrorBarType

        case 'SEM'
            DispersionIndex = nansem(Data);

        case 'CI'
            % the more traditional 95% CI based on student distribution
            %  CI(1) = nanmean(Data(:,i))-1.96*nansem(Data(:,i))
            %  CI(2) = nanmean(Data(:,i))+1.96*nansem(Data(:,i))

            % Accelerated bootstrap confidence interval
            % using mean as estimate of effect size
            CI = bootci(10000, {@(x) mean(x), Data}, ...
                        'alpha', Opt.Alpha, ...
                        'type', 'bca');

            DispersionIndex = CI;

        case 'CI-BC'

            % Accelerated bootstrap confidence interval
            % using bias correction of effect size estimate (Hedges and Olkin)
            CI = bootci(10000, {@(x) ComputeUnbiasedEffectSize(x), Data}, ...
                        'alpha', Opt.Alpha, ...
                        'type', 'bca');

            DispersionIndex = CI;

        otherwise
            DispersionIndex = std(Data);

    end

    if size(DispersionIndex, 1) == 1
        DispersionIndexUpper = DispersionIndex;
        DispersionIndexLower = DispersionIndex;

    elseif size(DispersionIndex, 1) == 2
        DispersionIndexUpper = abs(DispersionIndex(2, :)) - abs(mean(Data));
        DispersionIndexLower = abs(DispersionIndex(1, :)) - abs(mean(Data));

    end

end
