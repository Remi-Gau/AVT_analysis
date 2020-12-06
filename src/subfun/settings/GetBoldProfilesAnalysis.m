function Analysis = GetBoldProfilesAnalysis(opt)

    %% Baseline Ipsi
    Analysis(1)      = struct('name', 'Audio:Ipsi', ...
                              'conditions', 1);

    Analysis(end + 1) = struct('name', 'Visual:Ipsi', ...
                               'conditions', 3);

    Analysis(end + 1) = struct('name', 'Tactile:Ipsi', ...
                               'conditions', 5);

    %% Baseline Contra
    Analysis(end + 1) = struct('name', 'Audio:Contra', ...
                               'conditions', 1);

    Analysis(end + 1) = struct('name', 'Visual:Contra', ...
                               'conditions', 3);

    Analysis(end + 1) = struct('name', 'Tactile:Contra', ...
                               'conditions', 5);

    %% Contra - Ipsi
    Analysis(end + 1) = struct('name', 'Audio:Contra-Ipsi', ...
                               'conditions', [2 1]);

    Analysis(end + 1) = struct('name', 'Visual:Contra-Ipsi', ...
                               'conditions', [4 3]);

    Analysis(end + 1) = struct('name', 'Tactile:Contra-Ipsi', ...
                               'conditions', [6 5]);

    %% Cross senses Ipsi
    Analysis(end + 1) = struct('name', 'Ipsi:Audio-Visual', ...
                               'conditions', [1 3]);

    Analysis(end + 1) = struct('name', 'Ipsi:Audio-Tactile', ...
                               'conditions', [1 5]);

    Analysis(end + 1) = struct('name', 'Ipsi:Visual-Tactile', ...
                               'conditions', [3 5]);

    %% Cross senses Contra
    Analysis(end + 1) = struct('name', 'Contra:Audio-Visual', ...
                               'conditions', [2 4]);

    Analysis(end + 1) = struct('name', 'Contra:Audio-Tactile', ...
                               'conditions', [2 6]);

    Analysis(end + 1) = struct('name', 'Contra:Visual-Tactile', ...
                               'conditions', [4 6]);

    if opt.verbose
        fprintf('\n\n');
        for iAnalysis = 1:numel(Analysis)
            fprintf('Analysis %02.0f : %s\n', iAnalysis, Analysis(iAnalysis).name);
        end
        fprintf('\n\n');
    end

end
