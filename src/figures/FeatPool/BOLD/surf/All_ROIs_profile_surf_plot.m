function All_ROIs_profile_surf_plot
    clc;
    clear;

    StartDir = fullfile(pwd, '..', '..', '..', '..', '..');
    cd (StartDir);

    addpath(genpath(fullfile(StartDir, 'code', 'subfun')));
    Get_dependencies('/home/rxg243/Dropbox/');

    ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
    FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf');

    SubLs = dir('sub*');
    NbSub = numel(SubLs);

    NbLayers = 6;

    for WithPerm = 1

        sets = {};
        for iSub = 1:NbSub
            sets{iSub} = [-1 1];
        end
        [a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
        ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];

        if ~WithPerm
            ToPermute = [];
        end

        %% Plot Stim and targets alone
        for IsStim = 1

            if IsStim
                Stim_prefix = 'Stimuli-';
                load(fullfile(ResultsDir, strcat('ResultsSurfQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
            else
                Stim_prefix = 'Target-';
                load(fullfile(ResultsDir, strcat('ResultsSurfTargetsQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data'); %#ok<*UNRCH>
            end

            disp({AllSubjects_Data.name}'); %#ok<NODEF>

            NbROI = length(AllSubjects_Data);
            ROI_order = [1 NbROI 2:NbROI - 1];

            ROI_idx = 1;
            for iROI = ROI_order
                ToPlot.ROIs_name{ROI_idx} = AllSubjects_Data(iROI).name;
                ROI_idx = ROI_idx + 1;
            end

            close all;

            for ihs = 1:2

                if ihs == 1
                    HS_suffix = '-LHS';
                else
                    HS_suffix = '-RHS';
                end

                % Ipsilateral
                ToPlot.Name = [Stim_prefix 'Ipsilateral' HS_suffix];
                ToPlot.SubPlotOrder = [1 2 3];
                ToPlot.Legend = {'Audio', 'Visual', 'Tactile'};
                ToPlot.YLabel = 'Param. est. [a u]';
                ToPlot.Visible = 'on';
                ToPlot.FigureFolder = FigureFolder;
                ToPlot.MVPA = 0;
                ToPlot.ToPermute = ToPermute;

                Data = cat(1, AllSubjects_Data(:).Ispi);
                ToPlot = GetData(ToPlot, Data, ROI_order, ihs);

                plot_all_ROIs(ToPlot);

                % Contralateral
                Data = cat(1, AllSubjects_Data(:).Contra);
                ToPlot = GetData(ToPlot, Data, ROI_order, ihs);
                ToPlot.Name = [Stim_prefix  'Contralateral' HS_suffix];

                plot_all_ROIs(ToPlot);

                % Contra VS Ipsi
                Data = cat(1, AllSubjects_Data(:).Contra_VS_Ipsi);
                ToPlot = GetData(ToPlot, Data, ROI_order, ihs);
                ToPlot.Name = [Stim_prefix  'Contra-Ipsi' HS_suffix];

                plot_all_ROIs(ToPlot);

                % Contrast between sensory modalities Ispi
                Data = cat(1, AllSubjects_Data(:).ContSensModIpsi);
                ToPlot = GetData(ToPlot, Data, ROI_order, ihs);
                ToPlot.Name = [Stim_prefix  'SensModContrasts-Ipsi' HS_suffix];
                ToPlot.Legend = {'Audio-Visual', 'Audio-Tactile', 'Visual-Tactile'};

                plot_all_ROIs(ToPlot);

                % Contrast between sensory modalities Contra
                Data = cat(1, AllSubjects_Data(:).ContSensModContra);
                ToPlot = GetData(ToPlot, Data, ROI_order, ihs);
                ToPlot.Name = [Stim_prefix  'SensModContrasts-Contra' HS_suffix];

                plot_all_ROIs(ToPlot);

            end

        end

    end
    cd(StartDir);

end

function ToPlot = GetData(ToPlot, Data, ROI_order, ihs)
    ROI_idx = 1;
    for iROI = ROI_order
        ToPlot.profile.MEAN(:, ROI_idx, :) = Data(iROI).MEAN(:, :, ihs); %#ok<*SAGROW>
        ToPlot.profile.SEM(:, ROI_idx, :) = Data(iROI).SEM(:, :, ihs);
        % Do not plot quadratic
        % 1rst dimension: subject
        % 2nd dimension: ROI
        % 3rd dimension: Cst, Lin
        % 4th dimension : different conditions (e.g A, V, T)
        ToPlot.profile.beta(:, ROI_idx, :, :) = shiftdim(Data(iROI).Beta.DATA(1:2, :, :, ihs), 2);
        ToPlot.ROI.grp(:, ROI_idx, :) = Data(iROI).whole_roi_grp(:, :, ihs);
        ROI_idx = ROI_idx + 1;
    end
end
