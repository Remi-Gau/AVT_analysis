% (C) Copyright 2021 Remi Gau

% Raster business
%

clc;
clear;
close all;

ROIs = {'A1', 'PT', 'V1', 'V2'};

SortBy = 'Cst';

MVNN = false;

SortingCondition = 1;

SortedCondition = [ ...
    1, 2; ...
    3, 4; ...
    5, 6];

hemi = {'lh', 'rh'};

%%
Opt = SetRasterPlotParameters();

[~, CondNamesIpsiContra] = GetConditionList();

Dirs = SetDir('surf', MVNN);

[SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

for iROI = 1:numel(ROIs)
    
    fprintf('\n\n%s\n', ROIs{iROI});
    
    RoiData = LoadDataForRaster(Opt, Dirs, ROIs{iROI});

    for hs = 1:numel(hemi)

        fprintf('\n hemisphere: %s\n', hemi{hs});

        for iSub = 1:NbSub
            
            for iRow = 1:size(SortedCondition, 1)
                for iCol = 1:size(SortedCondition, 2)
                    Data{iRow, iCol}{iSub, 1} = ReturnInputDataForRaster( ...
                        RoiData(iSub, hs).Data, ...
                        RoiData(iSub, hs).ConditionVec, ...
                        RoiData(iSub, hs).RunVec, ...
                        SortedCondition(iRow, iCol)); %#ok<*SAGROW>
                    
                    Titles{iRow, iCol} = CondNamesIpsiContra{SortedCondition(iRow, iCol)};
                    
                end
            end
            
            SortingData{iSub, 1} = ReturnInputDataForRaster( ...
                RoiData(iSub, hs).Data, ...
                RoiData(iSub, hs).ConditionVec, ...
                RoiData(iSub, hs).RunVec, ...
                SortingCondition);
            
        end
        
        fprintf('  Sorting and binning\n');
        
        for i = 1:numel(Data)
            
            [Data{i}, ~, R{i}] = SortRaster(Data{i}, SortingData, Opt, SortBy);
            Data{i} = BinRaster(Data{i});
            
        end
        
        [SortingData] = SortRaster(SortingData, SortingData, Opt, SortBy);
        SortingData = BinRaster(SortingData);
        
        fprintf('  Plotting\n');
        
        Opt.Title = sprintf('ROI: %s %s ; %s=f(%s_{%s})', ...
            hemi{hs}, ...
            ROIs{iROI}, ...
            'Conditions', ...
            SortBy, ...
            CondNamesIpsiContra{SortingCondition});
        
        PlotSeveralRasters(Opt, Data, SortingData, Titles);
        
        clear Data SortingData Titles
        
    end

end