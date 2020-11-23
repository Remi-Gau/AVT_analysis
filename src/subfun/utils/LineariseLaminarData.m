function [Data, CvMat] = LineariseLaminarData(Data, CvMat)

    % CvMat = [ConditionVec RunVec LayerVec];

    Layers = unique(CvMat(:, 3));

    NewData = nan( ...
                  size(CvMat, 1) / numel(Layers), ...
                  size(Data, 2) * numel(Layers));

    NewCvMat = nan(size(CvMat, 1) / numel(Layers), 2);

    Row = 1;

    for iRun = 1:max(unique(CvMat(:, 2)))

        for iCdt = 1:max(unique(CvMat(:, 1)))

            idx = all(CvMat(:, 1:2) == repmat([iCdt iRun], size(CvMat, 1), 1), 2);

            if sum(idx)>0 
              
              tmp = Data(idx, :);

              NewData(Row, :) = tmp(:)';
              NewCvMat(Row, 1:2) = [iCdt iRun];

              Row = Row + 1;
              
            end

        end

    end

    Data = NewData;

    CvMat = NewCvMat;

end
