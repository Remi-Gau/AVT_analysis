function [Min, Max] = ComputeMinMax(Data, SubjectVec, Opt)
    
    Min = 0;
    Max = 0;
    
    for iLine = 1:size(Data, 3)
        
        GroupData = ComputeSubjectAverage(Data{:, :, iLine}, SubjectVec{:, :, iLine});
        
        if Opt.PlotSubjects
            ThisMax = max(GroupData(:));
            ThisMin = min(GroupData(:));
            
        else
            GroupMean =  mean(GroupData);
            [LowerError, UpperError] = ComputeDispersionIndex(GroupData, Opt);
            
            ThisMax = max(GroupMean(:) + UpperError(:));
            ThisMin = min(GroupMean(:) - LowerError(:));
            
        end
        
        Max = max([Min, ThisMax]);
        Min = min([Min, ThisMin]);
        
    end
    

end
