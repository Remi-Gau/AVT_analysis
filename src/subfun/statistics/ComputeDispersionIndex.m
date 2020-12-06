% (C) Copyright 2020 Remi Gau

function [DispersionIndexLower, DispersionIndexUpper] = ComputeDispersionIndex(Data, Opt)

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
