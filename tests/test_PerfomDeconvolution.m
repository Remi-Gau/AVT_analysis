% (C) Copyright 2020 Remi Gau

function test_suite = test_PerfomDeconvolution %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_PerfomDeconvolutionBasic()

    nb_layers = 6;

    data(1, :) = [-0.6 -0.3  0    0.4  0.5  0.7]; % Target
    data(2, :) = [-0.3 -0.4 -0.5 -0.6 -0.8 -1]; % Stim

    deconvolved_data = PerfomDeconvolution(data, nb_layers);

    expected = [ ...
                -0.6000   -0.1537    0.1838    0.5390    0.5075    0.5837
                -0.3000   -0.3268   -0.3471   -0.3625   -0.4740   -0.5584];

    assertElementsAlmostEqual(deconvolved_data, expected, 'absolute', 0.0001);

end
