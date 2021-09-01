function RDM = ComputeCvedSquaredEuclidianDist(Data, RunVector, ConditionVector)
    %
    % because when doing cross validation distance A --> B can be different
    % from B-->A we recompute the RSA in the other direction and take the
    % mean of both directions
    %
    % (C) Copyright 2021 Remi Gau

    A =  rsa.distanceLDC(Data, RunVector, ConditionVector);
    B =  rsa.distanceLDC(flipud(Data), flipud(RunVector), ConditionVector);
    B = FlipBack(B);
    RDM = squareform(mean([A; B]));

end

function B = FlipBack(B)
    %
    % reorganize data

    % computed distance  ==> computed distance after flipud(Data)
    % 1-->2              ==> 6-->5
    % 1-->3              ==> 6-->4
    % 1-->4              ==> 6-->3
    %           ...
    % 5-->6              ==> 2-->1

    % for 6 conditions
    if numel(B) == 15
        NewOrder = [1:2 4 7 11 3 5 8 12 6 9 13 10 14:15];
    end

    B = fliplr(B);
    B = B(NewOrder);

end
