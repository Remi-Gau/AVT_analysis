% (C) Copyright 2021 Remi Gau

% use the same pipeline as PlotBoldProfile to compute the laminar GLM
% for each condition / run / subject / ROI and ouputs this in one single matrix

% the output will be used to run the linear mixed effects

clc;
clear;
close all;

space = 'surf';
MVNN =  false;

[Dirs] = SetDir(space, MVNN);
InputDir = fullfile(Dirs.ExtractedBetas, 'group');

ROIs = { ...
        'A1'
        'PT'
        'V1'
        'V2'
       };

Opt = SetDefaults();
Opt = SetProfilePlotParameters(Opt);

% we need all conditions for the LMM
Opt.PoolIpsiContra = false;

[~, IpsiContra] = GetConditionList();

[Data] = LoadProfileData(Opt, ROIs, InputDir);

Column = 1;

%% Base conditions

Beta = struct('Subjects', [], 'Rois', [], 'Conditions', [], 'Cst', [], 'Lin', []);

for Cdt = 1:numel(IpsiContra)

    Opt.Specific = [];
    Opt.Specific{1, Column} = AllocateProfileData(Data, ROIs, {Cdt});
    Opt = ComputeSubjectProfileAndBetaAverage(Opt, Column);

    ThisCondtion = Opt.Specific{1}.Group;

    Beta.Conditions =  cat(1, Beta.Conditions, ...
                           repmat(IpsiContra(Cdt), size(ThisCondtion.ConditionVec)));

    Beta = AppendData(ThisCondtion, Beta);
    Beta = GenerateRoiVector(ThisCondtion, Beta, ROIs);

end

Filename = ReturnSparametersFileName('BaseCondition');

fprintf(1, 'saving:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
spm_save(fullfile(InputDir, [Filename '_data.tsv']), Beta);

%% Cross side difference

[~, ~, CrossSide] = GetConditionList();

BetaCrossSide = struct('Subjects', [], 'Rois', [], 'Conditions', [], 'Cst', [], 'Lin', []);

for Cdt = 2:2:numel(IpsiContra)

    Opt.Specific = [];

    Opt.Specific{1, Column} = AllocateProfileData(Data, ROIs, {Cdt, -1 * (Cdt - 1)});

    Opt = ComputeSubjectProfileAndBetaAverage(Opt, Column);

    ThisCondtion = Opt.Specific{1}.Group;

    BetaCrossSide.Conditions =  cat(1, BetaCrossSide.Conditions, ...
                                    repmat(CrossSide(Cdt / 2), size(ThisCondtion.ConditionVec)));

    BetaCrossSide = AppendData(ThisCondtion, BetaCrossSide);
    BetaCrossSide = GenerateRoiVector(ThisCondtion, BetaCrossSide, ROIs);

end

Filename = ReturnSparametersFileName('CrossSide');

fprintf(1, 'saving:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
spm_save(fullfile(InputDir, [Filename '_data.tsv']), BetaCrossSide);

%% Cross Sensorry difference

[~, ~, ~, CrossSens] = GetConditionList();

Comparisons = {
               [1, -5], [2, -6]
               [3, -5], [4, -6]
               [7, -11], [8, -12]
               [9, -5], [10, -12]
              };

BetaCrossSens = struct('Subjects', [], 'Rois', [], 'Conditions', [], 'Cst', [], 'Lin', []);

for iComp = 1:size(CrossSens, 1)

    Opt = SetUpComparisonPlot(Data, ROIs, Comparisons, iComp);
    Opt = SetProfilePlotParameters(Opt);

    for iColumn = 1:2

        Opt = ComputeSubjectProfileAndBetaAverage(Opt, iColumn);

        ThisCondtion = Opt.Specific{1, iColumn}.Group;

        BetaCrossSens.Conditions =  cat(1, BetaCrossSens.Conditions, ...
                                        repmat(CrossSens(iComp, iColumn), size(ThisCondtion.ConditionVec)));

        BetaCrossSens = AppendData(ThisCondtion, BetaCrossSens);
        BetaCrossSens = GenerateRoiVector(ThisCondtion, BetaCrossSens, ROIs);

    end

end

Filename = ReturnSparametersFileName('CrossSens');

fprintf(1, 'saving:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
spm_save(fullfile(InputDir, [Filename '_data.tsv']), BetaCrossSens);

%% Helper Functions
function Beta = AppendData(ThisCondtion, Beta)

    Beta.Subjects =  [Beta.Subjects; ThisCondtion.SubjectVec];
    Beta.Cst = [Beta.Cst; ThisCondtion.Beta.Data(:, 1)];
    Beta.Lin = [Beta.Lin; ThisCondtion.Beta.Data(:, 2)];

end

function Beta = GenerateRoiVector(ThisCondtion, Beta, ROIs)
    RoiVec = {};
    for i = 1:numel(ThisCondtion.RoiVec)
        RoiVec{end + 1, 1} = ROIs{ThisCondtion.RoiVec(i)}; %#ok<*SAGROW>
    end
    Beta.Rois =  cat(1, Beta.Rois, RoiVec);
end
