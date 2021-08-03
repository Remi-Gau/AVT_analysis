% (C) Copyright 2020 Remi Gau
%
% Runs RSA

% TODO
% - Make it run on the b parameters
% - Make it run on volume
%

clc;
clear;
close all;

%% Main parameters

% Choose on what type of data the analysis will be run
%
% b-parameters
%
% 'ROI'
%
% s-parameters
%
% 'Cst', 'Lin', 'Quad'
%

InputType = 'Cst';

% Region of interest:
%  possible choices: A1, PT, V1-5

ROIs = { ...
        'V1'
        'V2'
        'A1'
        'PT'
       };

%% Other parameters
% Unlikely to change

Opt = SetDefaults();

Space = 'surf';
MVNN = true;

%%

ConditionType = 'stim';
if Opt.Targets
    ConditionType = 'target'; %#ok<*UNRCH>
end

Dirs = SetDir(Space, MVNN);

% TODO
% This input dir might have to change if we are dealing with volume data
InputDir = Dirs.ExtractedBetas;
if any(ismember(InputType, {'Cst', 'Lin', 'Quad'}))
    InputDir = Dirs.LaminarGlm;
end

OutputDir = fullfile(Dirs.Figures, 'RSA');
spm_mkdir(OutputDir);

%% Start
fprintf('Get started\n');

for iROI =  1:numel(ROIs)

    [GrpData, GrpConditionVec, GrpRunVec] = LoadAndPreparePcmData(ROIs{iROI}, InputDir, Opt, InputType);

end
