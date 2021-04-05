% (C) Copyright 2021 Remi Gau

function ToPlot = AllocateProfileData(Data, ROIs, Cdt)

    ToPlot = struct(...
        'Data', [], ...
        'SubjectVec', [], ...
        'ConditionVec', [], ...
        'RoiVec', [], ...
        'Titles', '');

    for iROI = 1:size(ROIs, 1)

        idx = ReturnRoiIndex(Data, ROIs{iROI});

        RowsToSelect = ReturnRowsToSelect({Data(idx, 1).ConditionVec, Cdt{1}});

        SubjectVec = Data(idx, 1).SubjVec(RowsToSelect, :);

        ConditionVec = Data(idx, 1).ConditionVec(RowsToSelect, :);

        RoiVec = ones(sum(RowsToSelect), 1) * iROI;

        switch numel(Cdt)

            % plot one condition
            case 1

                tmp = Data(idx, 1).Data(RowsToSelect, :);

            case 2

                RowsToSelect2 = ReturnRowsToSelect({Data(idx, 1).ConditionVec, abs(Cdt{2})});

                % difference between conditions
                if size(Cdt, 2) == 2

                    tmp = Data(idx, 1).Data(RowsToSelect, :) + ...
                        sign(Cdt{2}) * Data(idx, 1).Data(RowsToSelect2, :);

                    % plot both conditions
                else

                    tmp = cat(1, ...
                              Data(idx, 1).Data(RowsToSelect, :), ...
                              Data(idx, 1).Data(RowsToSelect2, :));

                    ConditionVec = cat(1, ...
                                       Data(idx, 1).ConditionVec(RowsToSelect, :), ...
                                       Data(idx, 1).ConditionVec(RowsToSelect2, :));

                    SubjectVec = repmat(SubjectVec, 2, 1);
                    RoiVec = repmat(RoiVec, 2, 1);

                end

        end

        ToPlot.Data = [ToPlot.Data; tmp];

        ToPlot.SubjectVec = [ToPlot.SubjectVec; SubjectVec];

        ToPlot.ConditionVec = [ToPlot.ConditionVec; ConditionVec];

        ToPlot.RoiVec = [ToPlot.RoiVec; RoiVec];

    end

    ToPlot.XLabel = ROIs;
end
