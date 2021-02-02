% PlotBoldProfile

clear;
close all;

space = 'surf';
MVNN =  false;

[Dirs] = SetDir(space, MVNN);
InputDir = fullfile(Dirs.ExtractedBetas, 'group');
OutputDir = fullfile(Dirs.Figures, 'BoldProfiles');
[~, ~, ~] = mkdir(OutputDir);

%     ConditionType = 'stim';
%     if IsTarget
%         ConditionType = 'target'; %#ok<*UNRCH>
%     end

ROIs = { ...
    'A1'
    'PT'
    'V1'
    'V2'
    };

Data = LoadProfileData(ROIs, InputDir);

%%
ROIs = { ...
    'A1'
    'PT'
    'V1'
    'V2'
    };

[~, CondNamesIpsiContra] = GetConditionList();

iColumn = 1;

for Cdt = 2:2:6
    
    iColumn = 1;
    
    ToPlot = AllocateProfileData(Data, ROIs, {Cdt});

    Opt.Specific{iColumn} = ToPlot;
    Opt.Specific{iColumn}.Titles = CondNamesIpsiContra{Cdt}(6:end);
    Opt.Specific{iColumn}.XLabel = ROIs;

    iColumn = 2;
    
    Opt.Specific{iColumn} = ToPlot;
    Opt.Specific{iColumn}.Titles = CondNamesIpsiContra{Cdt-1}(6:end);
    Opt.Specific{iColumn}.XLabel = ROIs;
    
    Opt.Title = strrep(CondNamesIpsiContra{Cdt}(1:5), 'S', ' S');
    
    Opt = SetProfilePlottingOptions(Opt);
    
    PlotProfileAndBetas(Opt);
    
    PrintFigure(fullfile(OutputDir, 'baseline'));
    
end

% AllocateProfileDataPlotPrint(Data, ROIs, '[Contra-Ipsi]_A', {2, -1}, iColumn, fullfile(OutputDir, 'cross-side'));
% AllocateProfileDataPlotPrint(Data, ROIs, '[Contra-Ipsi]_V', {4, -3}, fullfile(OutputDir, 'cross-side'));
% AllocateProfileDataPlotPrint(Data, ROIs, '[Contra-Ipsi]_T', {6, -5}, fullfile(OutputDir, 'cross-side'));
%
% AllocateProfileDataPlotPrint(Data, ROIs, '[A-T]_{ipsi}', {1, -5}, fullfile(OutputDir, 'cross-sensory'));
% AllocateProfileDataPlotPrint(Data, ROIs, '[A-T]_{contra}', {2, -6}, fullfile(OutputDir, 'cross-sensory'));
% AllocateProfileDataPlotPrint(Data, ROIs, '[V-T]_{ipsi}', {3, -5}, fullfile(OutputDir, 'cross-sensory'));
% AllocateProfileDataPlotPrint(Data, ROIs, '[V-T]_{contra}', {4, -6}, fullfile(OutputDir, 'cross-sensory'));

return

%%
ROIs = {'PT'};
AllocateProfileDataAndPlot(Data, ROIs, 'PT - [Contra-Ipsi]_T', {6, -5});
ROIs = {'V2'};
AllocateProfileDataAndPlot(Data, ROIs, 'V2 - [Contra-Ipsi]_T', {6, -5});

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
    Opt.Specific{1}.XLabel = XLabel;
    
    Opt = SetProfilePlottingOptions(Opt);
    
    PlotProfileAndBetas(Opt);
    
    PrintFigure(OutputDir);
    
end
