% (C) Copyright 2020 Remi Gau

function varargout = PreparePcmInput(Data, RunVec, ConditionVec, Analysis)

    for iSub = 1:size(Data, 1)
        
        % Only keep the conditions for that analysis
        ConditionVec{iSub}(~ismember(ConditionVec{iSub}, Analysis.CdtToSelect)) = 0;
        
        if strcmpi(Analysis.name, 'contraipsi')
            
            for hs = 1:size(Data, 2)
                
                
                [Data{iSub, hs}, tmp1, tmp2] = CombineIpsiAndContra(Data{iSub}, ...
                    ConditionVec{iSub}, ...
                    RunVec{iSub}, ...
                    'pool');
                
                
            end
            
            ConditionVec{iSub} = tmp1;
            RunVec{iSub} = tmp2;
        
        end

    end

    varargout = {Data, RunVec, ConditionVec};

end
