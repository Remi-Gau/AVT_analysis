function RasterData = ReturnInputDataForRaster(Data, ConditionVec, RunVec, ConditionToReturn)
    
    RowsToSelect = ReturnRowsToSelect({ConditionVec, ConditionToReturn});
    
    Data = Data(RowsToSelect, :);
    RunVec = RunVec(RowsToSelect, :);
    
    Runs = unique(RunVec);
    
    NbRuns = numel(Runs);
    
    for iRun = 1:NbRuns

        RowsToSelect = ReturnRowsToSelect({RunVec, Runs(iRun)});
        
        tmp = Data(RowsToSelect, :);
        
        RasterData(:,:,iRun) = tmp'; %#ok<*AGROW>
        
    end
     
end