% Deconvolve laminar porofile data
%
% Loads the laminar profile data
% Performs deconvolution a la Makuerkiaga
% Saves a new copy of the data

clc;
clear;
close all;

space = 'surf';
MVNN =  false;

[Dirs] = SetDir(space, MVNN);
InputDir = fullfile(Dirs.ExtractedBetas, 'group');
OutputDir = fullfile(Dirs.Figures, 'BoldProfiles');
[~, ~, ~] = mkdir(OutputDir);

ROIs = { ...
    'A1'
    'PT'
    'V1'
    'V2'
    };

[NbLayers, AverageType] = GetPlottingDefaults();

[Data, CondNamesIpsiContra] = LoadProfileData(ROIs, InputDir);

for iROI = 1:numel(Data)

    GrpData = PerfomDeconvolution(Data(iROI).Data, NbLayers);    
    ConditionVec = Data(iROI, 1).ConditionVec;
    SubjVec = Data(iROI, 1).SubjVec;
    GrpRunVec = Data(iROI, 1).RunVec;
    GrpConditionVec = Data(iROI, 1).ConditionVec;
    
    Filename = ['Group-roi-', Data(iROI).RoiName, ...
        '_average-', AverageType, ...
        '_nbLayers-', num2str(NbLayers), '_deconvolved.mat' ...
        ];

    save(fullfile(InputDir, Filename), ...
        'GrpData', ...
        'ConditionVec', ...
        'SubjVec', ...
        'GrpRunVec', ...
        'GrpConditionVec');
    
end


