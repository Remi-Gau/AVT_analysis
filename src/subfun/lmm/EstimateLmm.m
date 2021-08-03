function model = EstimateLmm(model)

    temp = model.RegNames;
    idx = cellfun(@(x) regexp(x, '[\[\]{} -]'), temp, 'UniformOutput', false);
    for i = 1:numel(temp)
        temp{i}(idx{i}) = '';
    end

    model.lme = fitlmematrix(model.X, model.Y, model.Z, model.G, ...
                             'FitMethod', 'REML', ...
                             'FixedEffectPredictors', temp, ...
                             'RandomEffectPredictors', {{'Intercept'}}, ...
                             'RandomEffectGroups', {'Subject'});
end
