function All_ROIs_BOLD_surf_plot
    clc;
    clear;

    StartDir = fullfile(pwd, '..', '..', '..');
    cd (StartDir);

    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
    Get_dependencies('/home/rxg243/Dropbox/');
    Get_dependencies('D:\Dropbox/');

    FigureFolder = fullfile(StartDir, 'figures');

    set(0, 'defaultAxesFontName', 'Arial');
    set(0, 'defaultTextFontName', 'Arial');

    SubLs = dir('sub*');
    NbSub = numel(SubLs);

    NbLayers = 6;

    ROIs = {
            'A1'
            'PT'
            'V1'
            'V2'};
    ROI_order_BOLD = [1 3 2 4];

    TitSuf = {
              'LR-Contra-Ipsi_A'; ...
              'LR-Contra-Ipsi_V'; ...
              'LR-Contra-Ipsi_T'; ...
              'LR-(A-T)_c'; ...
              'LR-(V-T)_c'; ...
              'LR-(A-T)_i'; ...
              'LR-(V-T)_i'; ...
              'LR-Contra'; ...
              'LR-Ipsi'};

    opt.MVNN = 0;
    opt.vol = 0;

    if opt.MVNN
        ParamToPlot = {'Cst', 'Lin', 'Avg', 'ROI'};
        opt.toplot = ParamToPlot{4};
        suffix = 'Wht_Betas';
    end

    if opt.vol
        BOLD_resultsDir = fullfile(StartDir, 'results', 'profiles');
    else
        BOLD_resultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
    end

    IsStim = 1;

    % load BOLD and MVPA
    if IsStim
        Stim_prefix = 'Stimuli';
        if opt.MVNN
            % not implemented
        else
            load(fullfile(BOLD_resultsDir, strcat('ResultsSurfQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data');
        end
    else
        % not implemented
    end

    AllSubjects_Data_BOLD = AllSubjects_Data;
    clear AllSubjects_Data;

    close all;

    for iAnalysis = 7:numel(TitSuf)

        clear ToPlot ToPlot2;
        ToPlot.TitSuf = TitSuf{iAnalysis};
        ToPlot.ROIs_name = ROIs;
        ToPlot.Visible = 'on';
        ToPlot.FigureFolder = FigureFolder;
        ToPlot.OneSideTTest = {'both' 'both'};

        ToPlot.profile.MEAN = [];
        ToPlot.profile.SEM = [];
        ToPlot.profile.beta = [];
        ToPlot.ROI.grp = [];

        %% Get BOLD
        if iAnalysis <= 7
            % which conditions goes into which column and row
            ToPlot.Col = 1;
            ToPlot.Row = 1;

            % To know which type of data we are plotting every time
            ToPlot.IsMVPA = [ ...
                             0 0];
            % Defines the number of subplots on each figure
            ToPlot.m = 4;
            ToPlot.n = 2;
            ToPlot.SubPlots = { ...
                               [1 3] [2 4]; ...
                               5, 6; ...
                               7, 8; ...
                               9, 10 ...
                              };

            Legend{1, 1} = 'Left';
            Legend{1, 2} = 'Right';
        end

        if iAnalysis < 8 && iAnalysis > 3
            tmp = { ...
                   [-0.3 4.5; -0.3 4.5], [.42 1; .42 1]; ...
                   [-1 4; -1 4], [-.15 .62; -.15 .62]; ...
                   [-0.2 1.3; -0.2 1.3], [-.1 .2; -.1 .2] ...
                  };

            for i = 1:2
                for j = 1:3
                    ToPlot.MinMax{j, i} = tmp{j, 1};
                end
            end
            ToPlot.MinMax{1, 2} = [-0.5 2.3; -0.5 2.3];
            ToPlot.MinMax{2, 2} = [-.8 3.1; -.8 3.1];
            ToPlot.MinMax{3, 2} = [-0.3 .8; -0.3 .8];
            for i = 3:4
                for j = 1:3
                    ToPlot.MinMax{j, i} = tmp{j, 2};
                end
            end

        end

        if iAnalysis > 7
            ToPlot.Col = 1;
            ToPlot.Row = 1:3;
            ToPlot.Cdt = [1; 2; 3];

            ToPlot.IsMVPA = [ ...
                             0 0; ...
                             0 0; ...
                             0 0];

            ToPlot.m = 4;
            ToPlot.n = 2;
            ToPlot.SubPlots = { ...
                               [1 3] [2 4]; ...
                               5, 6; ...
                               7, 8; ...
                               9, 10 ...
                              };

            Legend{1, 1} = 'Left';
            Legend{2, 1} = 'Left';
            Legend{3, 1} = 'Left';
            Legend{1, 2} = 'Right';
            Legend{2, 2} = 'Right';
            Legend{3, 2} = 'Right';

            % set maximum and minimum for B parameters profiles (row 1) and
            % for S param (row 2: Cst; row 3: Lin)
            ToPlot.MinMax = { ...
                             repmat([-1 4.2], 2, 1), repmat([-1.2 2.2], 2, 1), repmat([-1.4 0.1], 2, 1); ...
                             repmat([-1.2 4], 2, 1), repmat([-1.5 2.5], 2, 1), repmat([-1.5 1], 2, 1); ...
                             repmat([-0.4 1.3], 2, 1), repmat([-0.4 0.65], 2, 1), repmat([-0.5 0.35], 2, 1) ...
                            };

        end

        if opt.MVNN
            ToPlot = rmfield(ToPlot, 'MinMax');
        end

        switch iAnalysis
            case 1
                % Get BOLD data for Contra - Ipsi
                ToPlot.Cdt = 1;
                Data = cat(1, AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
                %             ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
                ToPlot.Titles{1, 1} = '[Contra - Ipsi]_A';

            case 2
                % Get BOLD data for Contra - Ipsi
                ToPlot.Cdt = 2;
                Data = cat(1, AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
                %             ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
                ToPlot.Titles{1, 1} = '[Contra - Ipsi]_V';

            case 3
                % Get BOLD data for Contra - Ipsi
                ToPlot.Cdt = 3;
                Data = cat(1, AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
                %             ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
                ToPlot.Titles{1, 1} = '[Contra - Ipsi]_T';

            case 4
                % Get BOLD data for between senses contrasts (contra)
                ToPlot.Cdt = 2;
                Data = cat(1, AllSubjects_Data_BOLD(:).ContSensModContra);
                %             ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);

                ToPlot.Titles{1, 1} = '[A - T]_c';

            case 5
                % Get BOLD data for between senses contrasts (contra)
                ToPlot.Cdt = 3;
                Data = cat(1, AllSubjects_Data_BOLD(:).ContSensModContra);
                %             ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);

                ToPlot.Titles{1, 1} = '[V - T]_c';

            case 6
                % Get BOLD data for between senses contrasts (ipsi)
                ToPlot.Cdt = 2;
                Data = cat(1, AllSubjects_Data_BOLD(:).ContSensModIpsi);
                %             ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);

                ToPlot.Titles{1, 1} = '[A - T]_i';

            case 7
                % Get BOLD data for between senses contrasts (ipsi)
                ToPlot.Cdt = 3;
                Data = cat(1, AllSubjects_Data_BOLD(:).ContSensModIpsi);
                %             ToPlot = (ToPlotGet_data,Data,ROI_order_BOLD);

                ToPlot.Titles{1, 1} = '[V - T]_i';

            case 8
                % Get BOLD data for Cdt-Fix Contra
                Data = cat(1, AllSubjects_Data_BOLD(:).Contra);
                %             ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);

                ToPlot.Titles{1, 1} = '[A_c - Fix]';
                ToPlot.Titles{2, 1} = '[V_c - Fix]';
                ToPlot.Titles{3, 1} = '[T_c - Fix]';

            case 9
                % Get BOLD data for Cdt-Fix Contra
                Data = cat(1, AllSubjects_Data_BOLD(:).Ispi);

                ToPlot.Titles{1, 1} = '[A_i - Fix]';
                ToPlot.Titles{2, 1} = '[V_i - Fix]';
                ToPlot.Titles{3, 1} = '[T_i - Fix]';

        end

        ToPlot = Get_data(ToPlot, Data, ROI_order_BOLD);

        %% Plot
        for WithPerm = 1

            sets = {};
            for iSub = 1:NbSub
                sets{iSub} = [-1 1]; %#ok<*AGROW>
            end
            [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
            ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];

            if ~WithPerm
                ToPermute = [];
            end

            ToPlot.Legend = Legend;
            clear Legend;
            ToPlot.ToPermute = ToPermute;
            if opt.vol
                ToPlot.Name = ['BOLD_vol' Stim_prefix];
            else
                ToPlot.Name = ['BOLD-' Stim_prefix];
            end

            Plot_BOLD_MVPA_all_ROIs(ToPlot);

        end

    end

    cd(StartDir);

end

function ToPlot = Get_data(ToPlot, Data, ROI_order)
    ROI_idx = 1;
    for iROI = ROI_order
        for iRow = 1:numel(ToPlot.Row)
            for iCol = 1:numel(ToPlot.Col)

                ToPlot.profile(ToPlot.Row(iRow), ToPlot.Col(iCol)).MEAN(:, ROI_idx) = Data(iROI).MEAN(:, ToPlot.Cdt(iRow, iCol), :, 1);
                ToPlot.profile(ToPlot.Row(iRow), ToPlot.Col(iCol)).SEM(:, ROI_idx) = Data(iROI).SEM(:, ToPlot.Cdt(iRow, iCol), :, 1);

                if isfield(Data, 'whole_roi_grp')
                    ToPlot.ROI(ToPlot.Row(iRow), ToPlot.Col(iCol)).grp(:, ROI_idx, :) = Data(iROI).whole_roi_grp(:, ToPlot.Cdt(iRow, iCol), :, 1);
                end

                ToPlot.profile(ToPlot.Row(iRow), ToPlot.Col(iCol) + 1).MEAN(:, ROI_idx) = Data(iROI).MEAN(:, ToPlot.Cdt(iRow, iCol), :, 2);
                ToPlot.profile(ToPlot.Row(iRow), ToPlot.Col(iCol) + 1).SEM(:, ROI_idx) = Data(iROI).SEM(:, ToPlot.Cdt(iRow, iCol), :, 2);

                %             if isfield(Data, 'whole_roi_grp')
                %                 ToPlot.ROI(ToPlot.Row(iRow),ToPlot.Col(iCol)).grp(:,ROI_idx,:) = Data(iROI).whole_roi_grp(:,ToPlot.Cdt(iRow,iCol),:,2);
                %             end

                % Do not plot quadratic
                % 1rst dimension: subject
                % 2nd dimension: ROI
                % 3rd dimension: Cst, Lin
                % 4th dimension : different conditions (e.g A, V, T)
                ToPlot.profile(ToPlot.Row(iRow), ToPlot.Col(iCol)).beta(:, ROI_idx, :, :) = shiftdim(Data(iROI).Beta.DATA(1:2, ToPlot.Cdt(iRow, iCol), :, 1), 2);
                ToPlot.profile(ToPlot.Row(iRow), ToPlot.Col(iCol) + 1).beta(:, ROI_idx, :, :) = shiftdim(Data(iROI).Beta.DATA(1:2, ToPlot.Cdt(iRow, iCol), :, 2), 2);
            end
        end
        ROI_idx = ROI_idx + 1;
    end
end
