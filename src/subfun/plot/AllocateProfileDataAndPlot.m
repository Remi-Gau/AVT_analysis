% (C) Copyright 2021 Remi Gau

function AllocateProfileDataAndPlot(Data, ROIs, Titles, Cdt)

    ToPlot = struct('Data', [], 'SubjectVec', [], 'ConditionVec', [], 'RoiVec', []);

    for iROI = 1:size(ROIs, 1)

        idx = ReturnRoiIndex(Data, ROIs{iROI});

        switch numel(Cdt)

            case 1

                RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt{1}});

                ToPlot.Data = [ToPlot.Data; Data(idx, 1).Data(RowsToSelect, :)];
                ToPlot.SubjectVec = [ToPlot.SubjectVec; Data(idx, 1).SubjVec(RowsToSelect, :)];
                ToPlot.ConditionVec = [ToPlot.ConditionVec; Data(idx, 1).ConditionVec(RowsToSelect, :)];

                ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum(RowsToSelect), 1) * iROI];

            case 2

                RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt{1}});
                RowsToSelect2 = ReturnRowsToSelect({Data(idx, 1).ConditionVec, abs(Cdt{2})});

                tmp = Data(idx, 1).Data(RowsToSelect, :) + ...
                    sign(Cdt{2}) * Data(idx, 1).Data(RowsToSelect2, :);

                ToPlot.Data = [ToPlot.Data; tmp];
                ToPlot.SubjectVec = [ToPlot.SubjectVec; Data(idx, 1).SubjVec(RowsToSelect, :)];
                ToPlot.ConditionVec = [ToPlot.ConditionVec; Data(idx, 1).ConditionVec(RowsToSelect, :)];

                ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum(RowsToSelect), 1) * iROI];

        end

    end

    Opt.Specific{1} = ToPlot;
    Opt.Specific{1}.Titles = Titles;
    Opt.Specific{1}.XLabel = ROIs;

    Opt = SetProfilePlottingOptions(Opt);

    PlotProfileAndBetas(Opt);

end
