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

SIDE = {'Ipsi', 'Contra'};

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

%%
% VvsT()

AvsT();
