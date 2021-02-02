% (C) Copyright 2021 Remi Gau

function ToPlot = AllocateProfileData(Data, ROIs, Cdt)

    ToPlot = struct('Data', [], 'SubjectVec', [], 'ConditionVec', [], 'RoiVec', []);

    for iROI = 1:size(ROIs, 1)

        idx = ReturnRoiIndex(Data, ROIs{iROI});

        RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt{1}});
        
        switch numel(Cdt)

            case 1

                ToPlot.Data = [ToPlot.Data; Data(idx, 1).Data(RowsToSelect, :)];


            case 2

                RowsToSelect2 = ReturnRowsToSelect({Data(idx, 1).ConditionVec, abs(Cdt{2})});

                tmp = Data(idx, 1).Data(RowsToSelect, :) + ...
                    sign(Cdt{2}) * Data(idx, 1).Data(RowsToSelect2, :);

                ToPlot.Data = [ToPlot.Data; tmp];

        end
        
        ToPlot.SubjectVec = [ToPlot.SubjectVec; Data(idx, 1).SubjVec(RowsToSelect, :)];
        ToPlot.ConditionVec = [ToPlot.ConditionVec; Data(idx, 1).ConditionVec(RowsToSelect, :)];
        
        ToPlot.RoiVec = [ToPlot.RoiVec; ones(sum(RowsToSelect), 1) * iROI];

    end

end
