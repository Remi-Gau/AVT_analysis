function DeconvolvedData = PerfomDeconvolution(Data, NbLayers, PeakToTailModel, NbLayerModel, Normalize)
    %
    % Data: array n X m array with m = number of layers and n = number of
    %       measurements
    %
    % adapted from simulation code from Uta Noppeney

    if nargin < 3 || isempty(PeakToTailModel)
        % default from Makuerkiaga
        PeakToTailModel = 6.5;
    end
    if nargin < 4 || isempty(NbLayerModel)
        % default from Makuerkiaga
        NbLayerModel = 10;
    end
    if nargin < 5 || isempty(nb_layernormalize_model)
        Normalize = false();
    end

    Peak = 1;
    if Normalize
        Peak = Data;
    end

    PeakToTail = ComputePeakToTailRatio(NbLayers, PeakToTailModel, NbLayerModel);

    Tail = 1 / PeakToTail;

    X = ReturnDeconvolutionMatrix(NbLayers, Peak, Tail);

    Beta = pinv(X) * Data';

    DeconvolvedData = Beta';

end

function PeakToTail = ComputePeakToTailRatio(NbLayers, PeakToTailModel, NbLayerModel)

    % peak to tail adjusted for the number of layers
    PeakToTail = PeakToTailModel * NbLayers / NbLayerModel + ...
                   (NbLayerModel - NbLayers) / (2 * NbLayerModel);

end
