% RunLMM

% small script to print out the results of the LMM and run the step down
% approach
% also outputs tables (does not serve them with fries though)

% 1. F-test in 2x2 (ROI X shape parameters)
%   if significant
%       2. F-test (or one sided t-test if apriori hypothesis) in 1x2
%       (across ROIs)
%       3. followed by t-test if signficant
%
% - Report in tables
% - Do the whole thing parametrically
%

clc;
clear;
close all;

ROIs = { ...
        'A1'
        'PT'
        'V1'
        'V2'
       };

space = 'surf';
MVNN =  false;

[Dirs] = SetDir(space, MVNN);
InputDir = fullfile(Dirs.ExtractedBetas, 'group');

Filename = ReturnSparametersFileName('BaseCondition');
fprintf(1, 'loading:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
Beta = spm_load(fullfile(InputDir, [Filename '_data.tsv']));

Filename = ReturnSparametersFileName('CrossSide');
fprintf(1, 'loading:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
BetaCrossSide = spm_load(fullfile(InputDir, [Filename '_data.tsv']));

Filename = ReturnSparametersFileName('CrossSens');
fprintf(1, 'loading:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
BetaCrossSens = spm_load(fullfile(InputDir, [Filename '_data.tsv']));

[~, IpsiContra, CrossSide, CrossSens] = GetConditionList();

CrossSens = CrossSens';
CrossSens = CrossSens(:);

% SavedTxt = fullfile(FigureFolder, 'LMM_BOLD_results.tsv');
% fid = fopen (SavedTxt, 'w');

%% (V - T) / Ipsi and Contra in A1 and PT
Conditions = 3:4;
RoisToSelect = {'A1', 'PT'};
Parameters = {'Cst', 'Lin'};

[model, fid] = ReturnLmmSpecAndData(BetaCrossSens, RoisToSelect, Parameters, CrossSens, Conditions, false);
model = EstimateLmm(model);
[c, message] = returnContrast('F_CdtXSide', model, Conditions, CrossSens);
[PVAL, F, DF1, DF2] = TestAndPrint(model, c, message, fid);


%% (V - T) / Ipsi and Contra in A1 and PT
Conditions = 1:2;
RoisToSelect = {'V1', 'V2'};
Parameters = {'Cst', 'Lin'};

[model, fid] = ReturnLmmSpecAndData(BetaCrossSens, RoisToSelect, Parameters, CrossSens, Conditions, false);
model = EstimateLmm(model);
[c, message] = returnContrast('F_CdtXSide', model, Conditions, CrossSens);
[PVAL, F, DF1, DF2] = TestAndPrint(model, c, message, fid);

return

% fprintf('\n');
% fprintf(fid, '\n');
% fclose (fid);

%% HELPER FUNCTIONS

function [c, message] = returnContrast(ContrastType, model, Conditions, CdtNames)

    PARAM = {'Cst', 'Lin'};
    SIDE = {'Ipsi', 'Contra'};

    if nargin > 3
        Conditions = CdtNames(Conditions);
    end

    tmp = [];

    switch ContrastType
        case 'F_CstOrLin'
            message = 'effect of either linear OR constant';
            for i = 1:numel(PARAM)
                tmp = [tmp; ReturnRegLogicIdx(model, PARAM{i})];
            end

        case 'F_CdtXSide'
            message = 'Interaction between condition and stimulated side';

            tmp(1, :) = ReturnRegLogicIdx(model, {Conditions{1}; SIDE{1}});
            tmp(2, :) = ReturnRegLogicIdx(model, {Conditions{2}; SIDE{2}});

            tmp = logical(tmp);

        case 'F'
            message = ['effect of ' Conditions{1} ' averaged'];
            tmp = ReturnRegLogicIdx(model, Conditions);

    end

    c = zeros(size(tmp));
    c(tmp) = 1;

end

function idx = ReturnRegLogicIdx(model, string)
    if ~iscell(string)
        string = {string};
    end
    for i = 1:size(string, 1)
        idx(i, :) = cellfun(@(x) ~isempty(x), strfind(lower(model.RegNames), lower(string{i})));
    end
    idx = all(idx, 1);
end

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

function [PVAL, F, DF1, DF2] = TestAndPrint(model, c, message, fid)

    pattern.screen = '\n%s\t F(%i,%i)= %f\t p = %f\n';
    pattern.file = '\n%s\n\tF(%i,%i)=%.3f\t%s\n';

    [PVAL, F, DF1, DF2] = coefTest(model.lme, c);

    fprintf(fid, pattern.screen, ...
            message, ...
            DF1, DF2, ...
            F, PVAL);

end

function p_str = convert_pvalue(p)
    if p < 0.001
        p_str = 'p<0.001';
    else
        p_str = sprintf('p=%.3f', p);
    end
end

function p_ttest = compare_results(i, model)

    if size(model.X, 2) == 4
        ROIs = { ...
                'A1'; ...
                'PT'; ...
                'V1'; ...
                'V2-3'};
        ROI_nb = [1 1 2 2];
        side_idx = [1 2 1 2];
        s_param = {'Cst', 'Lin', 'Cst', 'Lin'};
    elseif size(model.X, 2) == 2
        ROIs = model.ROIs;
        ROI_nb = [1 2];
        side_idx = [1 1];
        s_param = model.s_param;
    end

    betas = model.Y(logical(model.X(:, i))); % get betas
    side = model.test_side{side_idx(i)}; % get side for the test

    [~, p_ttest, ~, STATS] = ttest(betas, 0, 'tail', side);

    % display the results of perm and t-test
    fprintf('%s %s\t t(%i) = %f \t p = %f \t (p_perm = %f)\n', ...
            ROIs{ROI_nb(i)}, s_param{i}, STATS.df, ...
            STATS.tstat, p_ttest);

    if model.print2file
        % print to file
        fprintf(model.fid, '%s\n\tt(%i)=%.3f\t%s\t(%s)\n', ...
                ROIs{ROI_nb(i)}, STATS.df, ...
                STATS.tstat, ...
                convert_pvalue(p_ttest, 0), ...
                convert_pvalue(p_perm, 1));
    end

end
