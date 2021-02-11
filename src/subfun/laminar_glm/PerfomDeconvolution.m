function beta = PerfomDeconvolution(data, nb_layers, peak_to_tail_model, nb_layer_model, normalize)
    %
    %
    % adapted from simulation code from Uta Noppeney

    if nargin < 3 || isempty(peak_to_tail_model)
        % default from Makuerkiaga
        peak_to_tail_model = 6.5;
    end
    if nargin < 4 || isempty(nb_layer_model)
        % default from Makuerkiaga
        nb_layer_model = 10;
    end
    if nargin < 5 || isempty(nb_layernormalize_model)
        normalize = false();
    end

    peak = 1;
    if normalize
        peak = data;
    end

    peak_to_tail = ComputePeakToTailRatio(nb_layers, peak_to_tail_model, nb_layer_model);

    tail = 1 / peak_to_tail;

    X = ReturnDeconvolutionMatrix(nb_layers, peak, tail);

    beta = pinv(X) * data';

end

function peak_to_tail = ComputePeakToTailRatio(nb_layers, peak_to_tail_model, nb_layer_model)

    % peak to tail adjusted for the number of layers
    peak_to_tail = peak_to_tail_model * nb_layers / nb_layer_model + ...
                   (nb_layer_model - nb_layers) / (2 * nb_layer_model);

end
