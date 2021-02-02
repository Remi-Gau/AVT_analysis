% PlotBoldProfile

clear;
close all;

ROIs = { ...
    'A1'
    'PT'
    'V1'
    'V2'
    };

space = 'surf';

%%
MVNN =  false;
[Dirs] = SetDir(space, MVNN);
InputDir = fullfile(Dirs.ExtractedBetas, 'group');
OutputDir = fullfile(Dirs.Figures, 'BoldProfiles');
mkdir(OutputDir);

%     ConditionType = 'stim';
%     if IsTarget
%         ConditionType = 'target'; %#ok<*UNRCH>
%     end

Data = LoadProfileData(ROIs, InputDir);

[~, CondNamesIpsiContra] = GetConditionList();

for Cdt = 1:6
    AllocateProfileDataAndPlot(Data, ROIs, CondNamesIpsiContra{Cdt}, {Cdt});
    PrintFigure(OutputDir);
end

AllocateProfileDataAndPlot(Data, ROIs, '[Contra-Ipsi]_A', {2, -1});
PrintFigure(OutputDir);
AllocateProfileDataAndPlot(Data, ROIs, '[Contra-Ipsi]_V', {4, -3});
PrintFigure(OutputDir);
AllocateProfileDataAndPlot(Data, ROIs, '[Contra-Ipsi]_T', {6, -5});
PrintFigure(OutputDir);

% Does not work because of subject 6
%     AllocateDataAndPlot(Data, ROIs, '[A-T]_ipsi', {1, -5});
%     AllocateDataAndPlot(Data, ROIs, '[A-T]_contra', {2, -6});

AllocateProfileDataAndPlot(Data, ROIs, '[V-T]_{ipsi}', {3, -5});
PrintFigure(OutputDir);
AllocateProfileDataAndPlot(Data, ROIs, '[V-T]_{contra}', {4, -6});
PrintFigure(OutputDir);

ROIs = {'PT'};
AllocateProfileDataAndPlot(Data, ROIs, 'PT - [Contra-Ipsi]_T', {6, -5});
PrintFigure(OutputDir);
ROIs = {'V2'};
AllocateProfileDataAndPlot(Data, ROIs, 'V2 - [Contra-Ipsi]_T', {6, -5});
PrintFigure(OutputDir);

%%
ROIs = { ...
    'PT'
    'V2'
    };

for iROI = 1:size(ROIs, 1)
    
    Title = [ROIs{iROI} ' - [Contra & Ipsi]_T'];
    XLabel = {'T contra', 'T ipsi'};
    
    Cdt1 = 6;
    Cdt2 = 5;
    
    idx = ReturnRoiIndex(Data, ROIs{iROI});
    
    ToPlot = struct('Data', [], 'SubjectVec', [], 'ConditionVec', [], 'RoiVec', []);
    
    RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt1});
    RowsToSelect2 = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt2});
    
    ToPlot.Data = [ToPlot.Data; ...
        Data(idx, 1).Data(RowsToSelect, :); ...
        Data(idx, 1).Data(RowsToSelect2, :)];
    ToPlot.SubjectVec = [ToPlot.SubjectVec; ...
        Data(idx, 1).SubjVec(RowsToSelect, :); ...
        Data(idx, 1).SubjVec(RowsToSelect2, :)];
    ToPlot.ConditionVec = [ToPlot.ConditionVec; ...
        Data(idx, 1).ConditionVec(RowsToSelect, :); ...
        Data(idx, 1).ConditionVec(RowsToSelect2, :)];
    
    ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum([RowsToSelect; RowsToSelect2]), 1) * iROI];
    
    Opt.Specific{1} = ToPlot;
    Opt.Specific{1}.Titles = Title;
    Opt.Specific{1}.RoiNames = XLabel;
    
    Opt = SetProfilePlottingOptions(Opt);
    
    PlotProfileAndBetas(Opt);
    
    PrintFigure(OutputDir);
    
end