% (C) Copyright 2021 Remi Gau
%
% Plot raster conditions (no contrasts)
%
% Plot each hemisphere independently
%

clc;
clear;
close all;

SortingCondition = 5;
SortBy = 'Cst';
Hemi = {'lh', 'rh'};

% AllRoisAllCondtions(SortBy, SortingCondition, Hemi)
AllRoisNonPreferred(SortBy, SortingCondition, Hemi)

function AllRoisNonPreferred(SortBy, SortingCondition, Hemi)
    
    Title = 'Non preferred';
    
    ROIs = {'A1', 'PT'};
    
    SortedCondition = [ ...
        3, 4; ...
        5, 6];
    
    PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    
    ROIs = {'V1', 'V2'};
    
    SortedCondition = [ ...
        1, 2; ...
        5, 6];
    
    %     PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    
end

function AllRoisAllCondtions(SortBy, SortingCondition, Hemi)
    
    ROIs = {'PT'}; % {'A1', 'PT' 'V1', 'V2'};
    
    SortedCondition = [ ...
        1, 2; ...
        3, 4; ...
        5, 6];
    
    Title = 'All conditions';
    
    PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    
end

function PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title)
    
    MVNN = false;
    Dirs = SetDir('surf', MVNN);
    
    [~, NbSub] = GetSubjectList(Dirs.ExtractedBetas);
    
    Opt = SetRasterPlotParameters();
    
    [~, CondNamesIpsiContra] = GetConditionList();
    
    for iROI = 1:numel(ROIs)
        
        fprintf('\n\n%s\n', ROIs{iROI});
        
        RoiData = LoadDataForRaster(Opt, Dirs, ROIs{iROI});
        
        for hs = 1:numel(Hemi)
            
            fprintf('\n hemisphere: %s\n', Hemi{hs});
            
            for iRow = 1:size(SortedCondition, 1)
                for iCol = 1:size(SortedCondition, 2)
                    Titles{iRow, iCol} = CondNamesIpsiContra{SortedCondition(iRow, iCol)};
                    Titles{iRow, iCol} = strrep(Titles{iRow, iCol}, 'Stim', ' Stim ');
                end
            end
            
            Opt.Title = sprintf('ROI: %s %s ; %s = f(%s_{%s})', ...
                Hemi{hs}, ...
                ROIs{iROI}, ...
                Title, ...
                SortBy, ...
                strrep(CondNamesIpsiContra{SortingCondition}, 'Stim', ' Stim '));
            
            
            for iSub = 1:NbSub
                
                for iRow = 1:size(SortedCondition, 1)
                    for iCol = 1:size(SortedCondition, 2)
                        
                        Data{iRow, iCol}{iSub, 1} = ReturnInputDataForRaster( ...
                            RoiData(iSub, hs).Data, ...
                            RoiData(iSub, hs).ConditionVec, ...
                            RoiData(iSub, hs).RunVec, ...
                            SortedCondition(iRow, iCol)); %#ok<*SAGROW>
                        
                    end
                end
                
                SortingData{iSub, 1} = ReturnInputDataForRaster( ...
                    RoiData(iSub, hs).Data, ...
                    RoiData(iSub, hs).ConditionVec, ...
                    RoiData(iSub, hs).RunVec, ...
                    SortingCondition);
                
            end
            
            [Data, SortingData, R] = PrepareRasterData(Data, SortingData, Opt, SortBy);
            
            fprintf('  Plotting\n');
            PlotSeveralRasters(Opt, Data, SortingData, Titles, R);
            
            clear Data SortingData
            
        end
        
    end
    
end