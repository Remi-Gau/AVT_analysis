% (C) Copyright 2020 Remi Gau

% Raster business
%

clc;
clear;

ROIs = { ...
    'A1'
    };

SortBy = 'Cst';

MVNN = false;

%%
Opt = SetDefaults();

CondNames = GetConditionList();

Dirs = SetDir('surf', MVNN);

[SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

SortingCondition = 1;
SortedCondition = [ ...
    1, 2; ...
    3, 4; ...
    5, 6];

hemi = {'lh', 'rh'};

for iROI = 1:numel(ROIs)
    
    fprintf('%s\n', ROIs{iROI});
    
    RoiData = LoadDataForRaster(Opt, Dirs, ROIs{iROI});
    
    Opt = SetRasterPlotParameters(Opt);
    
    for hs = 1
        
        fprintf('%s\n', hemi{hs});

        for iSub = 1:NbSub
            
            for iRow = 1:size(SortedCondition, 1)
                for iCol = 1:size(SortedCondition, 2)
                    Data{iRow, iCol}{iSub, 1} = ReturnInputDataForRaster( ...
                        RoiData(iSub, hs).Data, ...
                        RoiData(iSub, hs).ConditionVec, ...
                        RoiData(iSub, hs).RunVec, ...
                        SortedCondition(iRow, iCol)); %#ok<*SAGROW>
                    
                    Titles{iRow, iCol} = CondNames{SortedCondition(iRow, iCol)};
                    
                end
            end
            
            SortingData{iSub, 1} = ReturnInputDataForRaster( ...
                RoiData(iSub, hs).Data, ...
                RoiData(iSub, hs).ConditionVec, ...
                RoiData(iSub, hs).RunVec, ...
                SortingCondition);
            
        end
        
        % Sort and bin
        
        for i = 1:numel(Data)
            
            [Data{i}, ~, R{i}] = SortRaster(Data{i}, SortingData, Opt, SortBy);
            Data{i} = BinRaster(Data{i});
            
        end
        
        [SortingData] = SortRaster(SortingData, SortingData, Opt, SortBy);
        SortingData = BinRaster(SortingData);
        
        % plot
        
        Opt.Title = sprintf('ROI: %s %s ; %s=f(%s_{%s})', ...
            hemi{hs}, ...
            ROIs{iROI}, ...
            'Conditions', ...
            SortBy, ...
            CondNames{SortingCondition});
        
        PlotSeveralRasters(Opt, Data, SortingData, Titles);
        
    end

end

function Data = LoadDataForRaster(Opt, Dirs, RoiName)
    
    fprintf('\n');
    
    [SubLs, NbSub] = GetSubjectList(Dirs.ExtractedBetas);
    
    for iSub = 1:NbSub
        
        fprintf(' Loading %s\n', SubLs(iSub).name);
        
        SubDir = fullfile(Dirs.ExtractedBetas, SubLs(iSub).name);
        
        for hs = 1:2
            
            if hs == 1
                HsSufix = 'l';
            else
                HsSufix = 'r';
            end
            
            Filename = ReturnFilename('hs_roi_run_cdt_layer', ...
                SubLs(iSub).name, ...
                HsSufix, ...
                Opt.NbLayers, ...
                RoiName);
            
            RoiSaveFile = fullfile(SubDir, Filename);
            load(RoiSaveFile);
            
            % remove all data from run 17 to avoid imbalalance
            if strcmp(SubLs(iSub).name, 'sub-06')
                
                RowsToSelect = ReturnRowsToSelect({RunVec, 17});
                
                RoiData(RowsToSelect, :) = [];
                ConditionVec(RowsToSelect, :) = [];
                LayerVec(RowsToSelect, :) = [];
                RunVec(RowsToSelect, :) = [];
                
            end
            
            Data(iSub, hs).RoiName = RoiName; %#ok<*AGROW>
            Data(iSub, hs).Data = RoiData;
            Data(iSub, hs).ConditionVec = ConditionVec;
            Data(iSub, hs).RunVec = RunVec;
            Data(iSub, hs).LayerVec = LayerVec;
            
        end
        
    end
    
end
