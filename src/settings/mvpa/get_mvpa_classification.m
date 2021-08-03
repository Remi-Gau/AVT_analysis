function SVM = get_mvpa_classification(opt)

    %% Ipsi VS contra
    SVM(1)     = struct('name', 'Audio-IpsiVSContra', ...
                        'class', [1 2], ...
                        'Featpool', true);

    SVM(end + 1) = struct('name', 'Visual-IpsiVSContra', ...
                          'class', [3 4], ...
                          'Featpool', true);

    SVM(end + 1) = struct('name', 'Tactile-IpsiVSContra', ...
                          'class', [5 6], ...
                          'Featpool', true);

    %% Cross senses Ipsi
    SVM(end + 1) = struct('name', 'Ipsi-AudioVSVisual', ...
                          'class', [1 3], ...
                          'Featpool', true);

    SVM(end + 1) = struct('name', 'Ipsi-AudioVSTactile', ...
                          'class', [1 5], ...
                          'Featpool', true);

    SVM(end + 1) = struct('name', 'Ipsi-VisualVSTactile', ...
                          'class', [3 5], ...
                          'Featpool', true);

    %% Cross senses Contra
    SVM(end + 1) = struct('name', 'Contra-AudioVSVisual', ...
                          'class', [2 4], ...
                          'Featpool', true);

    SVM(end + 1) = struct('name', 'Contra-AudioVSTactile', ...
                          'class', [2 6], ...
                          'Featpool', true);

    SVM(end + 1) = struct('name', 'Contra-VisualVSTactile', ...
                          'class', [4 6], ...
                          'Featpool', true);

    %% Left VS Right
    SVM(end + 1) = struct('name', 'Audio-LeftVSRight', ...
                          'class', [1 2], ...
                          'Featpool', false);

    SVM(end + 1) = struct('name', 'Visual-LeftVSRight', ...
                          'class', [3 4], ...
                          'Featpool', false);

    SVM(end + 1) = struct('name', 'Tactile-LeftVSRight', ...
                          'class', [5 6], ...
                          'Featpool', false);

    %% Cross senses left
    SVM(end + 1) = struct('name', 'Left-AudioVSVisual', ...
                          'class', [1 3], ...
                          'Featpool', false);

    SVM(end + 1) = struct('name', 'Left-AudioVSTactile', ...
                          'class', [1 5], ...
                          'Featpool', false);

    SVM(end + 1) = struct('name', 'Left-VisualVSTactile', ...
                          'class', [3 5], ...
                          'Featpool', false);

    %% Cross senses right
    SVM(end + 1) = struct('name', 'Right-AudioVSVisual', ...
                          'class', [2 4], ...
                          'Featpool', false);

    SVM(end + 1) = struct('name', 'Right-AudioVSTactile', ...
                          'class', [2 6], ...
                          'Featpool', false);

    SVM(end + 1) = struct('name', 'Right-VisualVSTactile', ...
                          'class', [4 6], ...
                          'Featpool', false);

    if opt.verbose
        fprintf('\n\n');
        for iSVM = 1:numel(SVM)
            fprintf('Classification %02.0f : %s\n', iSVM, SVM(iSVM).name);
        end
        fprintf('\n\n');
    end

end