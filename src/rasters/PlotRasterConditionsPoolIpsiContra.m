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
AllRoisNonPreferred(SortBy, SortingCondition, Hemi);

function AllRoisNonPreferred(SortBy, SortingCondition, Hemi)
    
    Title = 'Non preferred';
    
    ROIs = {'A1', 'PT'};
    
    SortedCondition = [3; ...
        5];
    
    PlotHemispheres(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    
    ROIs = {'V1', 'V2'};
    
    SortedCondition = [1; ...
        5];
    
    %     PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    
end

function AllRoisAllCondtions(SortBy, SortingCondition, Hemi)
    
    ROIs = {'PT'}; % {'A1', 'PT' 'V1', 'V2'};
    
    SortedCondition = [ ...
        1; ...
        3; ...
        5];
    
    Title = 'All conditions';
    
    PlotHemispheres(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    
end

function PlotHemispheres(Hemi, ROIs, Sorted, SortBy, Sorting, Title)
    
    MVNN = false;
    Dirs = SetDir('surf', MVNN);
    
    [~, NbSub] = GetSubjectList(Dirs.ExtractedBetas);
    
    Opt = SetRasterPlotParameters();
    
    [~, CondNamesIpsiContra] = GetConditionList();
    
    for iROI = 1:numel(ROIs)
        
        fprintf('\n\n%s\n', ROIs{iROI});
        
        RoiData = LoadDataForRaster(Opt, Dirs, ROIs{iROI});
        
        Opt.Title = sprintf('ROI: %s ; %s = f(%s_{%s})', ...
            ROIs{iROI}, ...
            Title, ...
            SortBy, ...
            CondNamesIpsiContra{Sorting}(1));
        
        for iRow = 1:size(Sorted, 1)
            for hs = 1:numel(Hemi)
                Titles{iRow, hs} = sprintf('%s - hemisphere %s', ...
                    CondNamesIpsiContra{Sorted(iRow)}(1), ...
                    Hemi{hs});
            end
        end
        
        for iRow = 1:size(Titles, 1)
            
            for hs = 1:numel(Hemi)
                
                for iSub = 1:NbSub
                    
                    for IspiContra = 0:1
                        
                        tmpSorted(:, :, :, IspiContra+1) = ReturnInputDataForRaster( ...
                            RoiData(iSub, hs).Data, ...
                            RoiData(iSub, hs).ConditionVec, ...
                            RoiData(iSub, hs).RunVec, ...
                            Sorted(iRow)+ IspiContra); %#ok<*SAGROW>
                        
                        tmpSorting(:, :, :, IspiContra +1) = ReturnInputDataForRaster( ...
                            RoiData(iSub, hs).Data, ...
                            RoiData(iSub, hs).ConditionVec, ...
                            RoiData(iSub, hs).RunVec, ...
                            Sorting + IspiContra);
                        
                    end
                    
                    Data{iRow, hs}{iSub, 1} = mean(tmpSorted, 4);
                    SortingData{iRow, hs}{iSub, 1} = mean(tmpSorting, 4);
                    
                    clear tmpSorted tmpSorting;
                    
                end
                
            end
            
        end
        
        [Data, SortingData, R] = PrepareRasterData(Data, SortingData, Opt, SortBy);
        
        fprintf('  Plotting\n');
        PlotSeveralRasters(Opt, Data, SortingData, Titles, R);
        
        clear Data SortingData;
        
    end
    
end
