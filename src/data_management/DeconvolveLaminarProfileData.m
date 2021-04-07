% Deconvolve laminar profile data
%
% Loads the laminar profile group data (1 profile per cdt / run / subject)
% Reassign left and right to ipsi and contra if necessary
% Performs deconvolution a la Makuerkiaga
% Runs laminar GLM
% Saves the data (X s-parameters per cdt / run / subject)
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
OutputDir = fullfile(Dirs.LaminarGlm, 'group');
spm_mkdir(OutputDir);

Opt = SetDefaults;

[Data, CondNamesIpsiContra] = LoadProfileData(Opt, ROIs, InputDir);

DesignMatrix = SetDesignMatLamGlm(Opt.NbLayers, Opt.PlotQuadratic);

for iROI = 1:numel(Data)

    GrpData = PerfomDeconvolution(Data(iROI).Data, Opt.NbLayers);

    BetaHat = RunLaminarGlm(GrpData, DesignMatrix);

    SubjVec = Data(iROI, 1).SubjVec;
    GrpRunVec = Data(iROI, 1).RunVec;
    GrpConditionVec = Data(iROI, 1).ConditionVec;

    Filename = ['Group-roi-', Data(iROI).RoiName, ...
                '_average-', Opt.AverageType, ...
                '_NbLayers-', num2str(Opt.NbLayers), '_deconvolved-1.mat' ...
               ];

    fprintf('Saving: %s\n', fullfile(OutputDir, Filename));

    save(fullfile(OutputDir, Filename), ...
         'GrpData', ...
         'BetaHat', ...
         'SubjVec', ...
         'GrpRunVec', ...
         'GrpConditionVec', ...
         'CondNamesIpsiContra');

end
