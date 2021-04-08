% (C) Copyright 2021 Remi Gau

function Opt = SetUpComparisonPlot(Data, ROIs, Comparisons, iComp)

    Opt = SetDefaults();

    ColumnNames = {'ipsi', 'contra'};
    if Opt.PoolIpsiContra
        ColumnNames = {''};
    end

    for iColumn = 1:size(ColumnNames, 2)

        tmp = {Comparisons{iComp, iColumn}(1), Comparisons{iComp, iColumn}(2)};

        ToPlot = AllocateProfileData(Data, ROIs, tmp);
        ToPlot.Titles = ColumnNames{iColumn};

        Opt.Specific{1, iColumn} = ToPlot;

    end

end
