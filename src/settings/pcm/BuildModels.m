% (C) Copyright 2021 Remi Gau

function [Analysis, Models] = BuildModels(ModelType, IsAuditoryRoi)
    
    fprintf('Building models\n');
    
    switch lower(ModelType)
        
        case '3x3'
            Analysis(1).name = 'Ipsi';
            Analysis(1).CdtToSelect = 1:2:5;
            
            Analysis(2).name = 'Contra';
            Analysis(2).CdtToSelect = 2:2:6;
            
            Analysis(3).name = 'ContraIpsi';
            Analysis(3).CdtToSelect = 1:6;
            
        case {'6x6', 'subset6x6'}
            Analysis(1).name = 'AllConditions';
            Analysis(1).CdtToSelect = 1:6;
            
    end
    
    Models = [];
    if nargin>1
    
    switch lower(ModelType)
        case '3x3'
            Models = Set3X3models();
            
        case '6x6'
            sets = {1:3, 1:6, 0:1};
            [x, y, z] = ndgrid(sets{:});
            FeaturesToAdd = [x(:) y(:) z(:)];
            
            Models = Set6X6models(IsAuditoryRoi, FeaturesToAdd);
        case 'subset6x6'
            Models = SetSubset6X6Models(IsAuditoryRoi);
    end
    
    end
    
end