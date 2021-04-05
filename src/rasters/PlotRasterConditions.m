% (C) Copyright 2021 Remi Gau
%
% Plot rasters for each condition or preferred conditions (no contrasts)
%
% see ``src/settings``
% and ``lib/laminar_tools/src/settings``
% to change plotting options
%

clc;
clear;
close all;

SortingCondition = 5;
SortBy = 'Cst';
Hemi = {'lh', 'rh'};

AllRoisAllCondtions(SortBy, SortingCondition, Hemi);
AllRoisNonPreferred(SortBy, SortingCondition, Hemi);

function AllRoisNonPreferred(SortBy, SortingCondition, Hemi)

    Opt = SetDefaults();

    Title = 'Non preferred';

    ROIs = {'A1', 'PT'};

    SortedCondition = [ ...
                       3, 4; ...
                       5, 6];

    if Opt.PoolIpsiContra
        SortedCondition(:, 2) = [];
        PlotHemispheresIpsiContraPooled(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    else
        PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    end

    ROIs = {'V1', 'V2'};

    SortedCondition = [ ...
                       1, 2; ...
                       5, 6];

    if Opt.PoolIpsiContra
        SortedCondition(:, 2) = [];
        PlotHemispheresIpsiContraPooled(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    else
        PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    end

end

function AllRoisAllCondtions(SortBy, SortingCondition, Hemi)

    Opt = SetDefaults();

    ROIs = {'A1', 'PT' 'V1', 'V2'};

    SortedCondition = [ ...
                       1, 2; ...
                       3, 4; ...
                       5, 6];

    Title = 'All conditions';

    if Opt.PoolIpsiContra
        SortedCondition(:, 2) = [];
        PlotHemispheresIpsiContraPooled(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    else
        PlotHemisphere(Hemi, ROIs, SortedCondition, SortBy, SortingCondition, Title);
    end

end

function PlotHemisphere(Hemi, ROIs, Sorted, SortBy, Sorting, Title)

    [Opt, NbSub, Dirs, CondNamesIpsiContra] = SetUpRasterPlotting();

    for iROI = 1:numel(ROIs)

        fprintf('\n\n%s\n', ROIs{iROI});

        RoiData = LoadDataForRaster(Opt, Dirs, ROIs{iROI});

        Titles = GetTitlesRasters(Sorted);

        for hs = 1:numel(Hemi)

            fprintf('\n hemisphere: %s\n', Hemi{hs});

            for iSub = 1:NbSub

                for iRow = 1:size(Sorted, 1)
                    for iCol = 1:size(Sorted, 2)

                        Data{iRow, iCol}{iSub, 1} = ReturnInputDataForRaster( ...
                                                                             RoiData(iSub, hs).Data, ...
                                                                             RoiData(iSub, hs).ConditionVec, ...
                                                                             RoiData(iSub, hs).RunVec, ...
                                                                             Sorted(iRow, iCol)); %#ok<*SAGROW>

                    end
                end

                SortingData{iSub, 1} = ReturnInputDataForRaster( ...
                                                                RoiData(iSub, hs).Data, ...
                                                                RoiData(iSub, hs).ConditionVec, ...
                                                                RoiData(iSub, hs).RunVec, ...
                                                                Sorting);

            end

            Opt.Title = sprintf('ROI: %s %s ; %s = f(%s_{%s})', ...
                                Hemi{hs}, ...
                                ROIs{iROI}, ...
                                Title, ...
                                SortBy, ...
                                strrep(CondNamesIpsiContra{Sorting}, 'Stim', ' Stim '));

            [Data, SortingData, R] = PrepareRasterData(Data, SortingData, Opt, SortBy);

            fprintf('  Plotting\n');
            PlotSeveralRasters(Opt, Data, SortingData, Titles, R);
            
            OutputDir = fullfile(Dirs.Figures, 'Rasters');
            PrintFigure(fullfile(OutputDir, 'baseline'));

            clear Data SortingData;

        end

    end

end

function PlotHemispheresIpsiContraPooled(Hemi, ROIs, Sorted, SortBy, Sorting, Title)

    [Opt, NbSub, Dirs, CondNamesIpsiContra] = SetUpRasterPlotting();

    for iROI = 1:numel(ROIs)

        fprintf('\n\n%s\n', ROIs{iROI});

        RoiData = LoadDataForRaster(Opt, Dirs, ROIs{iROI});

        Titles = GetTitlesRasters(Sorted);

        for iRow = 1:size(Titles, 1)

            for hs = 1:numel(Hemi)

                for iSub = 1:NbSub

                    for IspiContra = 0:1

                        tmpSorted(:, :, :, IspiContra + 1) = ReturnInputDataForRaster( ...
                                                                                      RoiData(iSub, hs).Data, ...
                                                                                      RoiData(iSub, hs).ConditionVec, ...
                                                                                      RoiData(iSub, hs).RunVec, ...
                                                                                      Sorted(iRow) + IspiContra); %#ok<*SAGROW>

                        tmpSorting(:, :, :, IspiContra + 1) = ReturnInputDataForRaster( ...
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

        Opt.Title = sprintf('ROI: %s ; %s = f(%s_{%s})', ...
                            ROIs{iROI}, ...
                            Title, ...
                            SortBy, ...
                            CondNamesIpsiContra{Sorting}(1));

        fprintf('\n');

        [Data, SortingData, R] = PrepareRasterData(Data, SortingData, Opt, SortBy);

        fprintf(' Plotting\n');
        PlotSeveralRasters(Opt, Data, SortingData, Titles, R);

        OutputDir = fullfile(Dirs.Figures, 'Rasters');
        PrintFigure(fullfile(OutputDir, 'baseline'));
        
        clear Data SortingData;

    end

end

function Titles = GetTitlesRasters(Sorted)

    Opt = SetDefaults();

    [~, CondNamesIpsiContra] = GetConditionList();

    Hemi = {'lh', 'rh'};

    NbCol = size(Sorted, 2);
    if Opt.PoolIpsiContra
        NbCol = size(Hemi, 2);
    end

    for iRow = 1:size(Sorted, 1)
        for iCol = 1:NbCol

            if Opt.PoolIpsiContra
                CdtName = CondNamesIpsiContra{Sorted(iRow, 1)}(1:5);
            else
                CdtName = CondNamesIpsiContra{Sorted(iRow, iCol)};
            end
            CdtName = strrep(CdtName, 'Stim', ' Stim ');

            Titles{iRow, iCol} = sprintf('%s', CdtName);

            if Opt.PoolIpsiContra
                Titles{iRow, iCol} = [Titles{iRow, iCol}, ' - hemisphere ', Hemi{iCol}];
            end

        end
    end

end

function [Opt, NbSub, Dirs, CondNamesIpsiContra] = SetUpRasterPlotting()
    MVNN = false;
    Dirs = SetDir('surf', MVNN);

    [~, NbSub] = GetSubjectList(Dirs.ExtractedBetas);

    Opt = SetRasterPlotParameters();

    [~, CondNamesIpsiContra] = GetConditionList();
end
