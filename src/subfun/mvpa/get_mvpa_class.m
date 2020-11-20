function Class = get_mvpa_class()

    % --------------------------------------------------------- %
    %              Classes and associated conditions            %
    % --------------------------------------------------------- %

    %% Stimuli
    Class(1) = struct('name', 'A Stim - Left', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'AStimL'};

    Class(2) = struct('name', 'A Stim - Right', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'AStimR'};

    Class(3) = struct('name', 'V Stim - Left', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'VStimL'};

    Class(4) = struct('name', 'V Stim - Right', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'VStimR'};

    Class(5) = struct('name', 'T Stim - Left', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'TStimL'};

    Class(6) = struct('name', 'T Stim - Right', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'TStimR'};

    %% Targets
    Class(7) = struct('name', 'A Targ - Left', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'ATargL'};

    Class(8) = struct('name', 'A Targ - Right', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'ATargR'};

    Class(9) = struct('name', 'V Targ - Left', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'VTargL'};

    Class(10) = struct('name', 'V Targ - Right', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'VTargR'};

    Class(11) = struct('name', 'T Targ - Left', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'TTargL'};

    Class(12) = struct('name', 'T Targ - Right', 'cond', cell(1), 'nbetas', 1);
    Class(end).cond = {'TTargR'};

    %% Combined classes
    Class(13) = struct('name', 'A Stim', 'cond', cell(1), 'nbetas', 2);
    Class(end).cond = {'AStimL' 'AStimR'};

    Class(14) = struct('name', 'V Stim', 'cond', cell(1), 'nbetas', 2);
    Class(end).cond = {'VStimL' 'VStimR'};

    Class(15) = struct('name', 'T Stim', 'cond', cell(1), 'nbetas', 2);
    Class(end).cond = {'TStimL' 'TStimR'};

    fprintf('\n\n');
    for iClass = 1:numel(Class)
        fprintf('Class %02.0f : %s\n', iClass, Class(iClass).name);
    end
    fprintf('\n\n');

end
