function [acc_layer, results_layer, weight] = RunSVM(SVM, Features, LogFeat, FeaturesLayers, CV_Mat, TrainSess, TestSess, opt, iSVM)

if isempty(Features) || all(Features(:)==Inf)
    
    warning('Empty ROI')
    
    acc_layer = NaN;
    results_layer = struct();
    weight = [];
    
else
    
    if ~opt.permutation.test
        [acc_layer, weight, results_layer] = machine_SVC_layers(SVM(iSVM), ...
            Features(:,LogFeat), FeaturesLayers(:,LogFeat), CV_Mat, TrainSess, TestSess, opt);
    else
        acc_layer = NaN;
        results_layer = struct();
        weight = [];
    end
    
    if opt.verbose
        fprintf('\n       Running on all layers.')
    end
    
end

end
