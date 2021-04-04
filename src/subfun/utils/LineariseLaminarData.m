% (C) Copyright 2020 Remi Gau

function [Data, CvMat] = LineariseLaminarData(Data, CvMat)
    %
    % Puts all vertices data of the same condition and run on the same row
    %
    % USAGE::
    %
    %   [Data, CvMat] = LineariseLaminarData(Data, CvMat)
    %
    % :param Data:
    % :type Data: array
    % :param CvMat: [ConditionVec RunVec LayerVec]
    % :type CvMat: array
    %
    % :output:
    %           :Data:
    %           :CvMat: [ConditionVec RunVec]
    %
    % Input::
    %
    %              Vertices     W X Y Z
    %
    %   cdt 1 run 1 layer A     1 1 1 1
    %   cdt 1 run 1 layer B     2 2 2 2
    %   cdt 1 run 2 layer A     3 3 3 3
    %   cdt 1 run 2 layer B     4 4 4 4
    %
    %
    % ouput::
    %
    %     Vertices     W W X X Y Y Z Z
    %
    %   cdt 1 run 1    1 2 1 2 1 2 1 2
    %   cdt 1 run 2    3 4 3 4 3 4 3 4
    %

    Layers = unique(CvMat(:, 3));

    NewData = nan( ...
                  size(CvMat, 1) / numel(Layers), ...
                  size(Data, 2) * numel(Layers));

    NewCvMat = nan(size(CvMat, 1) / numel(Layers), 2);

    Row = 1;

    for iRun = 1:max(unique(CvMat(:, 2)))

        for iCdt = 1:max(unique(CvMat(:, 1)))

            idx = all(CvMat(:, 1:2) == repmat([iCdt iRun], size(CvMat, 1), 1), 2);

            if sum(idx) > 0

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
