% (C) Copyright 2020 Remi Gau

function test_suite = test_Set6X6models %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_Set6X6modelsBasic

    sets = {1:3, 1:6, 0:1};
    [x, y, z] = ndgrid(sets{:});
    FeaturesToAdd = [x(:) y(:) z(:)];

    M = Set6X6models(true, FeaturesToAdd);
    M = Set6X6models(false, FeaturesToAdd);

end
