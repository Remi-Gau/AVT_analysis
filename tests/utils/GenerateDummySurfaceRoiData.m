function [Data, CdtVec, RunVec, LayerVec] = GenerateDummySurfaceRoiData(Cdt, Run, Layer, Vertice)

    LayerVec = repmat([1:Layer]', Cdt * Run, 1);

    Data = repmat([1:Layer]', Cdt * Run, Vertice);

    RunVec = [];
    for i = 1:Run
        RunVec = [RunVec; i * ones(Layer * Cdt, 1)];
    end

    CdtVec = repmat([ones(Layer, 1); 2 * ones(Layer, 1)], Run, 1);

end
