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

[Data, CondNamesIpsiContra] = LoadProfileData(Opt, ROIs, InputDir);

Beta = struct('Subjects', [], 'Rois', [], 'Conditions', [], 'Cst', [], 'Lin', []);

for Cdt = 1:numel(CondNamesIpsiContra)

    Column = 1;
    Opt.Specific = [];
    Opt.Specific{1, Column} = AllocateProfileData(Data, ROIs, {Cdt});
    Opt = ComputeSubjectProfileAndBetaAverage(Opt, Column);

    ThisCondtion = Opt.Specific{1}.Group;
    Beta.Subjects =  [Beta.Subjects; ThisCondtion.SubjectVec];
    Beta.Conditions =  cat(1, Beta.Conditions, ...
                           repmat(CondNamesIpsiContra(Cdt), size(ThisCondtion.ConditionVec)));
    Beta.Cst = [Beta.Cst; ThisCondtion.Beta.Data(:, 1)];
    Beta.Lin = [Beta.Lin; ThisCondtion.Beta.Data(:, 2)];

    RoiVec = {};
    for i = 1:numel(ThisCondtion.RoiVec)
        RoiVec{end + 1, 1} = ROIs{ThisCondtion.RoiVec(i)}; %#ok<*SAGROW>
    end
    Beta.Rois =  cat(1, Beta.Rois, RoiVec);

end

Filename = ['Group-Sparameters', ...
            '_average-', Opt.AverageType, ...
            '_nbLayers-', num2str(Opt.NbLayers), ...
            '_deconvolved-0'];

if Opt.PerformDeconvolution
    Filename(end) = '1';
end

fprintf(1, 'saving:\n %s\n', fullfile(InputDir, [Filename '_data.tsv']));
spm_save(fullfile(InputDir, [Filename '_data.tsv']), Beta);
