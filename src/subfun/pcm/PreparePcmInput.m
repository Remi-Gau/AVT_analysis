% (C) Copyright 2020 Remi Gau

function varargout = PreparePcmInput(Data, RunVec, ConditionVec, Analysis)

    for iSub = 1:size(Data, 1)

        % Only keep the conditions for that analysis

        ConditionVec{iSub}(~ismember(ConditionVec{iSub}, Analysis.CdtToSelect)) = 0;

        if strcmpi(Analysis.name, 'contraipsi')
            [Data{iSub}, ConditionVec{iSub}, RunVec{iSub}] = CombineIpsiAndContra( ...
                                                                                  Data{iSub}, ...
                                                                                  ConditionVec{iSub}, ...
                                                                                  RunVec{iSub}, ...
                                                                                  'pool');
        end

    end

    varargout = {Data, RunVec, ConditionVec};

end