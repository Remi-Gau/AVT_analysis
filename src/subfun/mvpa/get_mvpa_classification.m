function SVM = get_mvpa_classification(ROI)

    % --------------------------------------------------------- %
    %                     Analysis to perform                   %
    % --------------------------------------------------------- %

    %%_Ipsi_VS_contra
    SVM(1)     = struct('name', 'A_Ipsi_VS_Contra', ...
                        'class', [1 2], ...
                        'ROI_2_analyse', 1:numel(ROI), ...
                        'Featpool', 1);

    SVM(end + 1) = struct('name', 'V_Ipsi_VS_Contra', ...
                          'class', [3 4], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    SVM(end + 1) = struct('name', 'T_Ipsi_VS_Contra', ...
                          'class', [5 6], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    %% Cross senses_Ipsi
    SVM(end + 1) = struct('name', 'A_VS_V_Ipsi', ...
                          'class', [1 3], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    SVM(end + 1) = struct('name', 'A_VS_T_Ipsi', ...
                          'class', [1 5], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    SVM(end + 1) = struct('name', 'V_VS_T_Ipsi', ...
                          'class', [3 5], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    %% Cross senses_Ipsi
    SVM(end + 1) = struct('name', 'A_VS_V_Contra', ...
                          'class', [2 4], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    SVM(end + 1) = struct('name', 'A_VS_T_Contra', ...
                          'class', [2 6], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    SVM(end + 1) = struct('name', 'V_VS_T_Contra', ...
                          'class', [4 6], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 1);

    %% Left_VS_Right
    SVM(end + 1) = struct('name', 'A_L_VS_A_R', ...
                          'class', [1 2], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    SVM(end + 1) = struct('name', 'V_L_VS_V_R', ...
                          'class', [3 4], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    SVM(end + 1) = struct('name', 'T_L_VS_T_R', ...
                          'class', [5 6], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    %% Cross senses left
    SVM(end + 1) = struct('name', 'A_L_VS_V_L', ...
                          'class', [1 3], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    SVM(end + 1) = struct('name', 'A_L_VS_T_L', ...
                          'class', [1 5], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    SVM(end + 1) = struct('name', 'V_L_VS_T_L', ...
                          'class', [3 5], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    %% Cross senses right
    SVM(end + 1) = struct('name', 'A_R_VS_V_R', ...
                          'class', [2 4], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    SVM(end + 1) = struct('name', 'A_R_VS_T_R', ...
                          'class', [2 6], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    SVM(end + 1) = struct('name', 'V_R_VS_T_R', ...
                          'class', [4 6], ...
                          'ROI_2_analyse', 1:numel(ROI), ...
                          'Featpool', 0);

    fprintf('\n\n');
    for iSVM = 1:numel(SVM)
        fprintf('Classification %02.0f : %s\n', iSVM, SVM(iSVM).name);
    end
    fprintf('\n\n');

end
