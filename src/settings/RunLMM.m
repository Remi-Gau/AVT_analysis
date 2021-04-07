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

Opt = SetDefaults();

Filename = ['Group-Sparameters', ...
            '_average-', Opt.AverageType, ...
            '_nbLayers-', num2str(Opt.NbLayers), ...
            '_deconvolved-0'];
if Opt.PerformDeconvolution
    Filename(end) = '1';
end

fprintf(1, 'loading:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
Beta = spm_load(fullfile(InputDir, [Filename '_data.tsv']));

% SavedTxt = fullfile(FigureFolder, 'LMM_BOLD_results.tsv');
% fid = fopen (SavedTxt, 'w');
fid = 1;

%% V and T / Ipsi and Contra in A1 and PT
Conditions = 3:6;
RoisToSelect = {'A1', 'PT'};

%
Parameters = {'Cst'};
model = ReturnLmmSpecAndData(Beta, Conditions, RoisToSelect, Parameters, false());
model = FitLmm(model);

PrintModelDesciption(fid, RoisToSelect, Conditions, Parameters)

[c, message] = returnContrast('F_CdtXSide', model, Conditions);
[PVAL, F, DF1, DF2] = test_and_print(model, c, message, fid);

if PVAL < 0.05 / 4

    % Ipsi
model = ReturnLmmSpecAndData(Beta, Conditions([1 3]), RoisToSelect, Parameters, false());
model = FitLmm(model);

PrintModelDesciption(fid, RoisToSelect, Conditions, Parameters)

[c, message] = returnContrast('F_CdtXSide', model, Conditions);
[PVAL, F, DF1, DF2] = test_and_print(model, c, message, fid);

end

%
Parameters = {'Lin'};
model = ReturnLmmSpecAndData(Beta, Conditions, RoisToSelect, Parameters, false());
model = FitLmm(model);

PrintModelDesciption(fid, RoisToSelect, Conditions, Parameters)

[c, message] = returnContrast('F_CdtXSide', model, Conditions);
[PVAL, F, DF1, DF2] = test_and_print(model, c, message, fid);

%% A and T / Ipsi and Contra in V1 and V2
Conditions = [1:2 5:6];
RoisToSelect = {'V1', 'V2'};

%
Parameters = {'Cst'};

model = ReturnLmmSpecAndData(Beta, Conditions, RoisToSelect, Parameters, false());
model = FitLmm(model);

PrintModelDesciption(fid, RoisToSelect, Conditions, Parameters)

[c, message] = returnContrast('F_CdtXSide', model, Conditions);
[PVAL, F, DF1, DF2] = test_and_print(model, c, message, fid);

%
Parameters = {'Lin'};

model = ReturnLmmSpecAndData(Beta, Conditions, RoisToSelect, Parameters, false());
model = FitLmm(model);

PrintModelDesciption(fid, RoisToSelect, Conditions, Parameters)

[c, message] = returnContrast('F_CdtXSide', model, Conditions);
[PVAL, F, DF1, DF2] = test_and_print(model, c, message, fid);


return

% fprintf('\n');
% fprintf(fid, '\n');
% fclose (fid);

%% HELPER FUNCTIONS

function PrintModelDesciption(fid, RoisToSelect, Conditions, Parameters)
    
    [~, ConditionList] = GetConditionList;

    fprintf(fid, '\nROI: %s', strjoin(RoisToSelect));
    fprintf(fid, ' - Conditions: %s ', strjoin(ConditionList(Conditions)));
    fprintf(fid, ' - Parameters: %s \n', strjoin(Parameters));
end

function [c, message] = returnContrast(ContrastType, model, Conditions)

    PARAM = {'Cst', 'Lin'};
    SIDE = {'Ipsi', 'Contra'};

    if nargin > 2 && ~isempty(Conditions) && isnumeric(Conditions)
        if all(Conditions == 3:6)
            Conditions = {'VStim', 'TStim'};
        elseif all(Conditions == [1:2 5:6])
            Conditions = {'AStim', 'TStim'};
        end
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

            idx1 = ReturnRegLogicIdx(model, {Conditions{1}; SIDE{1}});
            idx2 = ReturnRegLogicIdx(model, {Conditions{2}; SIDE{2}});

            tmp(1, :) = any([idx1; idx2]);

            idx1 = ReturnRegLogicIdx(model, {Conditions{2}; SIDE{1}});
            idx2 = ReturnRegLogicIdx(model, {Conditions{1}; SIDE{2}});

            tmp(2, :) = any([idx1; idx2]);

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
        idx(i, :) = cellfun(@(x) ~isempty(x), strfind(model.RegNames, string{i}));
    end
    idx = all(idx, 1);
end

function model = FitLmm(model)

    model.lme = fitlmematrix(model.X, model.Y, model.Z, model.G, ...
                             'FitMethod', 'REML', ...
                             'FixedEffectPredictors', model.RegNames, ...
                             'RandomEffectPredictors', {{'Intercept'}}, ...
                             'RandomEffectGroups', {'Subject'});
end

function [PVAL, F, DF1, DF2] = test_and_print(model, c, message, fid)

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

    NbSubj = 11;

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
