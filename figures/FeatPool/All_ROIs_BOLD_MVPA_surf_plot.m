function All_ROIs_BOLD_MVPA_surf_plot
% gets the BOLD laminar and MVPA decoding accuracy profile of the analysis on the
% surface DATA of the AVT experimnet and plots them.


clc; clear;


Analysis_to_plot = 1;


% Title of analysis
TitSuf = {
    'Contra_vs_Ipsi';...
    'Between_Senses';...
    'Contra_&_Ipsi'; ...
    'Contra_&_Ipsi_same_plot'; ...
    'Between_Senses_same_plot'};


% plot only main results
% only deactivations
% only contra - ipsi for tactile stim
% only differences between non-preferred modalities of a ROI
plot_main = 0;


% average results over ipsi and contra
% for MVPA the accuracy are averaged.
avg_hs = 0;



%%
if isunix
    CodeDir = '/home/remi/github/AVT_analysis';
    StartDir = '/home/remi';
elseif ispc
    CodeDir = 'D:\github\AVT-7T-code';
    StartDir = 'D:\';
else
    disp('Platform not supported')
end

addpath(genpath(fullfile(CodeDir, 'subfun')))

[Dirs] = set_dir();

Get_dependencies()

SubLs = dir(fullfile(Dirs.DerDir,'sub*'));
NbSub = numel(SubLs);

NbLayers=6;

ROIs = {
    'A1'
    'PT'
    'V1'
    'V2'};
ROI_order_BOLD = [1 7 2:3];
ROI_order_MVPA = [6 7 1:2];

ROIs_to_get = 1:7;

SubSVM = [1:3;4:6;7:9];

Test_side = []; % default side of the test to use

% list of option to specify which MVPA results to use
opt.svm.log2c = 1;
opt.svm.dargs = '-s 0';
opt.fs.do = 0;
opt.rfe.do = 0;
opt.permutation.test = 0;
opt.session.curve = 0;
opt.scaling.idpdt = 1;
opt.session.loro = 0;
opt.MVNN = 0;
opt.vol = 0;

IsStim = 1;

if ~plot_main
    plot_pvalue = 1;
else
    plot_pvalue = 0;
end

% multivariate noise normalisation
if opt.MVNN
    ParamToPlot={'Cst','Lin','Avg','ROI'};
    opt.toplot = ParamToPlot{4};
    ROI_order_MVPA = 1:4;
    ROIs_to_get = 1:4;
    SubSVM = [1:3;4:6;7:9;10:12;13:15;16:18];
    suffix = 'Wht_Betas';
end

if opt.vol
    Dirs.BOLD_resultsDir = fullfile(StartDir, 'results', 'profiles');
end

opt.scaling.img.eucledian = 0;
opt.scaling.img.zscore = 1;
opt.scaling.feat.mean = 1;
opt.scaling.feat.range = 0;
opt.scaling.feat.sessmean = 0;

SaveSufix = CreateSaveSufixSurf(opt, [], NbLayers);

% load BOLD and MVPA
if IsStim
    Stim_prefix = 'Stimuli';
    if opt.MVNN
        if opt.vol
            load( fullfile(Dirs.BOLD_resultsDir, ...
                strcat('ResultsVolWhtBetasPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data' )
        else
            load( fullfile(Dirs.BOLD_resultsDir, ...
                strcat('ResultsSurfPoolQuadGLM',suffix,'_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data' )
        end
    else
        load( fullfile(Dirs.BOLD_resultsDir, ...
            strcat('ResultsSurfPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data' )
    end
    File2Load = fullfile(Dirs.MVPA_resultsDir, ...
        strcat('GrpPoolQuadGLM', SaveSufix, '.mat')); %#ok<*UNRCH>
else
    Stim_prefix = 'Target';
    load(fullfile(Dirs.BOLD_resultsDir, ...
        strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
    File2Load = fullfile(Dirs.MVPA_resultsDir, ...
        strcat('GrpTargetsPoolQuadGLM', SaveSufix)); %#ok<*UNRCH>
end

AllSubjects_Data_BOLD = AllSubjects_Data;
clear AllSubjects_Data

if exist(File2Load, 'file')
    load(File2Load, 'SVM')
else
    warning('This file %s does not exist', File2Load)
end

close all

for iAnalysis = Analysis_to_plot
    
    % init
    clear ToPlot ToPlot2
    ToPlot.TitSuf = TitSuf{iAnalysis};
    ToPlot.ROIs_name = ROIs;
    ToPlot.Visible= 'on';
    ToPlot.FigureFolder=Dirs.FigureFolder;
    ToPlot.OneSideTTest = Test_side;
    ToPlot.plot_pvalue = plot_pvalue;
    
    ToPlot.CI_s_parameter = 1;
    
    ToPlot.profile.MEAN=[];
    ToPlot.profile.SEM=[];
    ToPlot.profile.beta=[];
    ToPlot.ROI.grp=[];
    
    ToPlot.MVPA.MEAN=[];
    ToPlot.MVPA.SEM=[];
    ToPlot.MVPA.beta=[];
    ToPlot.MVPA.grp=[];
    
    if plot_main
        ToPlot.plot_main = 'main';
    else
        ToPlot.plot_main = '';
    end
    
    if avg_hs
        ToPlot.avg_hs = 'avg-hs';
    else
        ToPlot.avg_hs = '';
    end
    
    
    %% Get BOLD
    switch iAnalysis
        
        
        %% Contra - Ipsi
        case 1
            
            % Get BOLD data for Contra - Ipsi
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
            
            ToPlot.Row = 1;
            
            ToPlot.Titles{1,1} = '[Contra - Ipsi]';
            ToPlot.Titles{2,1} = '[Contra VS Ipsi]';
            
            if plot_main
                
                % which conditions goes into which column and row
                ToPlot.Col = 1;
                
                ToPlot.Cdt = 3;
                ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
                
                % Same for the MVPA data
                ToPlot.Row = 2; % a new row means a new figure
                Data = Get_data_MVPA(ROIs_to_get,SubSVM,iAnalysis,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                % Defines the number of subplots on each figure
                ToPlot.m=4;
                ToPlot.n=1;
                ToPlot.SubPlots = {... %Each column of this cell is a new condition
                    [1 2] ;...
                    3;...
                    4;...
                    5;... %The fourth row is for the plotting of the whole ROI
                    };
                
                % To know which type of data we are plotting every time
                ToPlot.IsMVPA = [...
                    0; ...
                    1];
                
                Legend{1,1} = 'Tactile';
                Legend{2,1} = 'Tactile';
                
                
                ToPlot.profile(1,1).main = 1:4;
                ToPlot.profile(2,1).main = 1:4;
            else
                
                % which conditions goes into which column and row
                ToPlot.Col = [1 2 3];
                
                ToPlot.Cdt = 1:3;
                ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
                
                % Same for the MVPA data
                ToPlot.Row = 2; % a new row means a new figure
                Data = Get_data_MVPA(ROIs_to_get,SubSVM,iAnalysis,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                % Defines the number of subplots on each figure
                ToPlot.m=4;
                ToPlot.n=3;
                ToPlot.SubPlots = {... %Each column of this cell is a new condition
                    [1 4] [2 5] [3 6];...
                    7, 8, 9;...
                    10, 11, 12;...
                    13, 14, 15;... %The fourth row is for the plotting of the whole ROI
                    };
                
                % To know which type of data we are plotting every time
                ToPlot.IsMVPA = [...
                    0 0 0; ...
                    1 1 1];
                
                Legend{1,1} = 'Auditory';
                Legend{1,2} = 'Visual';
                Legend{1,3} = 'Tactile';
                Legend{2,1} = 'Auditory';
                Legend{2,2} = 'Visual';
                Legend{2,3} = 'Tactile';
                
            end
            
            
            %% Cross sensory
        case 2
            
            ToPlot.Col = 1;
            ToPlot.Row = 1:2;
            ToPlot.Cdt = [...
                2 2;... % Skip 1 so to not plot the contrast and SVC or [A vs V]
                3 3;...
                2 2;...
                3 3];
            
            if avg_hs
                % we average the data from each hemisphere
                Data_contra = cat(1,AllSubjects_Data_BOLD(:).ContSensModContra);
                Data_ipsi = cat(1,AllSubjects_Data_BOLD(:).ContSensModIpsi);
                
                Data = average_hs(Data_contra, Data_ipsi);
                
            else
                % Get BOLD data for between senses contrasts (contra)
                Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModContra);
                ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
                
                % Get BOLD data for between senses contrasts (ipsi)
                ToPlot.Col = 2;
                Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModIpsi);
                
            end
            
            ToPlot = Get_data(ToPlot, Data, ROI_order_BOLD);
            
            % Same for the MVPA data
            ToPlot.Row = 3:4;
            ToPlot.Col = 1;
            
            if avg_hs
                Data_contra = Get_data_MVPA(ROIs_to_get,SubSVM,3,SVM);
                Data_ipsi = Get_data_MVPA(ROIs_to_get,SubSVM,2,SVM);
                
                Data = average_hs(Data_contra, Data_ipsi, 1);
                
            else
                % contra
                Data = Get_data_MVPA(ROIs_to_get,SubSVM,3,SVM);
                ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
                
                % ipsi
                ToPlot.Col = 2;
                Data = Get_data_MVPA(ROIs_to_get,SubSVM,2,SVM);
                
            end
            
            ToPlot = Get_data(ToPlot,Data,ROI_order_MVPA);
            
            % To specify which ROIs to plot for each figure
            if plot_main
                ToPlot.profile(1,1).main = 3:4;
                ToPlot.profile(2,1).main = 1:2;
                ToPlot.profile(3,1).main = 3:4;
                ToPlot.profile(4,1).main = 1:2;
                if ~avg_hs
                    ToPlot.profile(1,2).main = 3:4;
                    ToPlot.profile(2,2).main = 1:2;
                    ToPlot.profile(3,2).main = 3:4;
                    ToPlot.profile(4,2).main = 1:2;
                end
            end
            
            % Defines the number of subplots on each figure
            % m lines
            % n columns
            ToPlot.m=4;
            
            if ~avg_hs
                % To know which type of data we are plotting every time
                ToPlot.IsMVPA = [...
                    0 0; ...
                    0 0; ...
                    1 1; ...
                    1 1];
                
                Legend{1,2} = 'ipsi';
                Legend{1,1} = 'contra';
                Legend{2,2} = 'ipsi';
                Legend{2,1} = 'contra';
                Legend{3,2} = 'ipsi';
                Legend{3,1} = 'contra';
                Legend{4,2} = 'ipsi';
                Legend{4,1} = 'contra';
                
                ToPlot.n=2;
                ToPlot.SubPlots = {...
                    [1 3] [2 4];...
                    5, 6;...
                    7, 8;...
                    9, 10;...
                    };
            else
                ToPlot.IsMVPA = [...
                    0; ...
                    0; ...
                    1; ...
                    1];
                
                Legend{1,1} = 'mean(contra, ipsi)';
                Legend{2,1} = 'mean(contra, ipsi)';
                Legend{3,1} = 'mean(contra, ipsi)';
                Legend{4,1} = 'mean(contra, ipsi)';
                
                ToPlot.n=1;
                ToPlot.SubPlots = {...
                    [1 2];...
                    3;...
                    4;...
                    5};
            end
            
            % set MIN and MAX for plotting
            if plot_main
                tmp={...
                    [-.5 .7;-.5 .7] , [.4 .6;.4 .6];...
                    [-1 1;-1 1] , [-.15 .62;-.15 .62];...
                    [-.35 .35;-.35 .35] , [-.1 .2;-.1 .2];...
                    };
                
                for i=1:2
                    for j = 1:3
                        ToPlot.MinMax{j,i}=tmp{j,1};
                    end
                end
                tmp={...
                    [.4 .9;.4 .9] , [.4 .6;.4 .6];...
                    [-.15 .5;-.15 .5] , [-.15 .62;-.15 .62];...
                    [-0.15 .2;-0.15 .2] , [-.15 .2;-.15 .2];...
                    };
                for i=3:4
                    for j = 1:3
                        ToPlot.MinMax{j,i}=tmp{j,1};
                    end
                end
                
            else
                tmp={...
                    [-0.3 4.5;-0.3 4.5] , [.42 1;.42 1];...
                    [-1 4;-1 4] , [-.15 .62;-.15 .62];...
                    [-0.2 1.3;-0.2 1.3] , [-.1 .2;-.1 .2];...
                    };
                
                for i=1:2
                    for j = 1:3
                        ToPlot.MinMax{j,i}=tmp{j,1};
                    end
                end
                ToPlot.MinMax{1,2}=[-0.5 2.3;-0.5 2.3];
                ToPlot.MinMax{2,2}=[-.8 3.1;-.8 3.1];
                ToPlot.MinMax{3,2}=[-0.3 .8;-0.3 .8];
                for i=3:4
                    for j = 1:3
                        ToPlot.MinMax{j,i}=tmp{j,2};
                    end
                end
            end
            
            ToPlot.Titles{1,1} = '[A - T]';
            ToPlot.Titles{2,1} = '[V - T]';
            ToPlot.Titles{3,1} = '[A VS T]';
            ToPlot.Titles{4,1} = '[V VS T]';
            
            
            %% Against baseline
        case 3
            
            ToPlot.OneSideTTest = ...
                cat(3, ...
                [3 3 1 1;
                1 1 3 3;
                1 1 1 1],...
                2*ones(3,4),...
                2*ones(3,4));
            
            ToPlot.Row = 1:3;
            ToPlot.Col = 1;
            ToPlot.Cdt = [1;2;3];
            
            % Get BOLD data for Cdt-Fix Contra
            if avg_hs
                % we average the data from each hemisphere
                Data_contra = cat(1,AllSubjects_Data_BOLD(:).Contra);
                Data_ipsi = cat(1,AllSubjects_Data_BOLD(:).Ispi);
                
                Data = average_hs(Data_contra, Data_ipsi);
                
                ToPlot = Get_data(ToPlot, Data, ROI_order_BOLD);
                
            else
                Data = cat(1,AllSubjects_Data_BOLD(:).Contra);
                ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
                
                Data = cat(1,AllSubjects_Data_BOLD(:).Ispi);
                ToPlot.Col = 2;
                ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            end
            
            % To specify which ROIs to plot for each figure
            if plot_main
                ToPlot.profile(1,1).main = 3:4;
                ToPlot.profile(2,1).main = 1:2;
                ToPlot.profile(3,1).main = 1:4;
                if ~avg_hs
                    ToPlot.profile(1,2).main = 3:4;
                    ToPlot.profile(2,2).main = 1:2;
                    ToPlot.profile(3,2).main = 1:4;
                end
            end
            
            ToPlot.IsMVPA = [...
                0 0;...
                0 0;...
                0 0];
            
            ToPlot.m=4;
            
            if ~avg_hs
                % To know which type of data we are plotting every time
                Legend{1,1} = 'contra';
                Legend{2,1} = 'contra';
                Legend{3,1} = 'contra';
                Legend{1,2} = 'ipsi';
                Legend{2,2} = 'ipsi';
                Legend{3,2} = 'ipsi';
                
                ToPlot.n=2;
                ToPlot.SubPlots = {...
                    [1 3] [2 4];...
                    5, 6;...
                    7, 8;...
                    9, 10;...
                    };
                
            else
                Legend{1,1} = 'mean(contra, ipsi)';
                Legend{2,1} = 'mean(contra, ipsi)';
                Legend{3,1} = 'mean(contra, ipsi)';
                
                ToPlot.n=1;
                ToPlot.SubPlots = {...
                    [1 2];...
                    3;...
                    4;...
                    5};
                
            end
            
            
            % set maximum and minimum for B parameters profiles (row 1) and
            % for S param (row 2: Cst; row 3: Lin)
            if plot_main
                ToPlot.MinMax={...
                    repmat([-1.4 0.35],2,1) , repmat([-1.4 0.35],2,1) , repmat([-1.4 0.35],2,1);...
                    repmat([-1.5 1],2,1) , repmat([-1.5 1],2,1) , repmat([-1.5 1],2,1);...
                    repmat([-0.5 0.35],2,1) , repmat([-0.5 0.35],2,1) , repmat([-0.5 0.35],2,1);...
                    };
            else
                ToPlot.MinMax={...
                    repmat([-1 4.2],2,1) , repmat([-1.2 2.2],2,1) , repmat([-1.4 0.1],2,1);...
                    repmat([-1.2 4],2,1) , repmat([-1.5 2.5],2,1) , repmat([-1.5 1],2,1);...
                    repmat([-0.4 1.3],2,1) , repmat([-0.4 0.65],2,1) , repmat([-0.5 0.35],2,1);...
                    };
            end
            
            ToPlot.Titles{1,1} = '[A - Fix]';
            ToPlot.Titles{2,1} = '[V - Fix]';
            ToPlot.Titles{3,1} = '[T - Fix]';
            
            
            
            %% contra & ipsi on same figure
        case 4
            
            
            
            ToPlot.on_same_figure = 1;
            ToPlot.bivariate_subplot = 1;
            
            
            % To specify which ROIs to plot for each figure
            if plot_main
                
                ToPlot.Row = 1:2;
                ToPlot.Cdt = [3;3];
                
                ToPlot.profile(1,1).main = 1:2;
                ToPlot.profile(2,1).main = 3:4;
                ToPlot.profile(1,2).main = 1:2;
                ToPlot.profile(2,2).main = 3:4;
                
                ToPlot.Titles{1,1} = '[T - Fix] - A';
                ToPlot.Titles{2,1} = '[T - Fix] - V';
                
                Legend{1,1} = 'contra & ipsi';
                Legend{2,1} = 'contra & ipsi';
                
            else
                
                ToPlot.Row = 1:4;
                ToPlot.Cdt = [1;2;3;3];
                
                ToPlot.Titles{1,1} = '[A - Fix] ';
                ToPlot.Titles{2,1} = '[V - Fix]';
                ToPlot.Titles{3,1} = '[T - Fix]';
                ToPlot.Titles{4,1} = '[T - Fix]';
                
                Legend{1,1} = 'contra & ipsi';
                Legend{2,1} = 'contra & ipsi';
                Legend{3,1} = 'contra & ipsi';
                Legend{4,1} = 'contra & ipsi';
                
            end
            
            ToPlot.bivariate_subplot_legend{1,1} = {'contra', 'ipsi'};
            ToPlot.bivariate_subplot_legend{2,1} = {'contra', 'ipsi'};
            ToPlot.bivariate_subplot_legend{3,1} = {'contra', 'ipsi'};
            ToPlot.bivariate_subplot_legend{4,1} = {'contra', 'ipsi'};
            
            % Get BOLD data for Cdt-Fix Contra
            
            ToPlot.Col = 1;
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra);
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            ToPlot.Col = 2;
            Data = cat(1,AllSubjects_Data_BOLD(:).Ispi);
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            
            ToPlot.IsMVPA = [...
                0 0;...
                0 0;...
                0 0;...
                0 0];
            
            ToPlot.m=2;
            ToPlot.n=2;
            ToPlot.SubPlots = {... %Each column of this cell is a new condition
                [1 2] ;...
                3;...
                4;...
                };
            
            
            
            % set maximum and minimum for B parameters profiles (row 1) and
            % for S param (row 2: Cst; row 3: Lin)
            if plot_main
                ToPlot.MinMax={...
                    repmat([-1.4 0.35],2,1) , repmat([-0.9 0.35],2,1);...
                    };
            else
                ToPlot.MinMax={...
                    repmat([-1 4.2],2,1)   , repmat([-1.2 2.2],2,1)  , repmat([-1.4 0.1],2,1)  , repmat([-1.4 0.1],2,1);...
                    };
            end
            
            
            
            
            %% Cross sensory on same figure
        case 5
            
            if ~avg_hs
                warning('those results are only plotted with averaging over contra and ipsi')
            end
            
            
            ToPlot.on_same_figure = 1;
            ToPlot.bivariate_subplot = 1;
            
            
            % To specify which ROIs to plot for each figure
            if plot_main
                
                ToPlot.profile(1,1).main = 3:4;
                ToPlot.profile(2,1).main = 1:2;
                
            else
                
            end
            
            ToPlot.Titles{1,1} = 'A & T';
            ToPlot.Titles{2,1} = 'V & T';
            
            Legend{1,1} = 'mean(contra, ipsi)';
            Legend{2,1} = 'mean(contra, ipsi)';
            
            ToPlot.bivariate_subplot_legend{1,1} = {'Audio', 'Tactile'};
            ToPlot.bivariate_subplot_legend{2,1} = {'Visual', 'Tactile'};
            
            % Get BOLD data for Cdt-Fix Contra
            
            
            % we average the data from each hemisphere
            Data_contra = cat(1,AllSubjects_Data_BOLD(:).Contra);
            Data_ipsi = cat(1,AllSubjects_Data_BOLD(:).Ispi);
            
            Data = average_hs(Data_contra, Data_ipsi);
            
            
            ToPlot.Row = 1;
            ToPlot.Col = 1;
            ToPlot.Cdt = 1;
            ToPlot = Get_data(ToPlot, Data, ROI_order_BOLD);
            
            ToPlot.Row = 1;
            ToPlot.Col = 2;
            ToPlot.Cdt = 3;
            ToPlot = Get_data(ToPlot, Data, ROI_order_BOLD);
            
            
            ToPlot.Row = 2;
            ToPlot.Col = 1;
            ToPlot.Cdt = 2;
            ToPlot = Get_data(ToPlot, Data, ROI_order_BOLD);
            
            ToPlot.Row = 2;
            ToPlot.Col = 2;
            ToPlot.Cdt = 3;
            ToPlot = Get_data(ToPlot, Data, ROI_order_BOLD);
            
            
            ToPlot.IsMVPA = [...
                0 0;...
                0 0];
            
            ToPlot.m=2;
            ToPlot.n=2;
            ToPlot.SubPlots = {... %Each column of this cell is a new condition
                [1 2] ;...
                3;...
                4;...
                };
            
            
            
            % set maximum and minimum for B parameters profiles (row 1) and
            % for S param (row 2: Cst; row 3: Lin)
            if plot_main
                ToPlot.MinMax={...
                    repmat([-0.8 0.35],2,1) , repmat([-1.4 0.1],2,1);...
                    };
            else
                ToPlot.MinMax={...
                    repmat([-1 4.2],2,1)   , repmat([-1.2 2.2],2,1)  , repmat([-1.4 0.1],2,1)  , repmat([-1.4 0.1],2,1);...
                    };
            end
            
            
    end
    
    
    if opt.MVNN
        ToPlot = rmfield(ToPlot,'MinMax');
    end
    
    
    %% Plot
    for WithPerm = 1
        
        [ToPermute] = list_permutation(WithPerm, NbSub);
        
        
        ToPlot.Legend = Legend; clear Legend
        ToPlot.ToPermute = ToPermute;
        if opt.vol
            ToPlot.Name = ['BOLD_vol-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
        else
            ToPlot.Name = ['BOLD-MVPA-' Stim_prefix '\n' SaveSufix(15:end-12)];
        end
        
        
        Plot_BOLD_MVPA_all_ROIs(ToPlot)
        
    end
    
end

cd(StartDir)

end



function ToPlot = Get_data(ToPlot,Data,ROI_order)
% extracts data and rearranges is for plotting.
ROI_idx = 1;
for iROI = ROI_order
    for iRow = 1:numel(ToPlot.Row)
        for iCol = 1:numel(ToPlot.Col)
            
            ToPlot.profile(ToPlot.Row(iRow),ToPlot.Col(iCol)).MEAN(:,ROI_idx) = ...
                Data(iROI).MEAN(:,ToPlot.Cdt(iRow,iCol));
            ToPlot.profile(ToPlot.Row(iRow),ToPlot.Col(iCol)).SEM(:,ROI_idx) = ...
                Data(iROI).SEM(:,ToPlot.Cdt(iRow,iCol));
            
            if isfield(Data, 'whole_roi_grp')
                ToPlot.ROI(ToPlot.Row(iRow),ToPlot.Col(iCol)).grp(:,ROI_idx,:) = ...
                    Data(iROI).whole_roi_grp(:,ToPlot.Cdt(iRow,iCol));
            end
            
            % Do not plot quadratic
            % 1rst dimension: subject
            % 2nd dimension: ROI
            % 3rd dimension: Cst, Lin
            % 4th dimension : different conditions (e.g A, V, T)
            ToPlot.profile(ToPlot.Row(iRow),ToPlot.Col(iCol)).beta(:,ROI_idx,:,:) = ...
                shiftdim(Data(iROI).Beta.DATA(1:2,ToPlot.Cdt(iRow,iCol),:),2);
        end
    end
    ROI_idx = ROI_idx + 1;
end
end


function Data = Get_data_MVPA(ROIs,SubSVM,iSubSVM,SVM)
% extract data and rearanges it so it is in the same format as the BOLD
% profile data so it can be passed to Get_data
for iROI = 1:numel(ROIs)
    
    tmp_grp = [];
    
    for iSVM = SubSVM(iSubSVM,:)
        
        tmp_grp{end+1} = SVM(iSVM).ROI(iROI).layers.DATA;
        
        Data(iROI).whole_roi_grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp;
        
        Data(iROI).MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = ...
            flipud(SVM(iSVM).ROI(iROI).layers.MEAN(1:end)');
        Data(iROI).SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = ...
            flipud(SVM(iSVM).ROI(iROI).layers.SEM(1:end)');
        Data(iROI).Beta.DATA(:,iSVM+1-SubSVM(iSubSVM,1),:) = ...
            reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA, [3,1,size(SVM(iSVM).ROI(iROI).layers.Beta.DATA,2)]);
        
    end
    
    for i_subj = 1:numel(tmp_grp{1})
        tmp_subj = [];
        for iSVM = 1:numel(tmp_grp)
            tmp_subj = cat(3, tmp_subj, ...
                flipud(tmp_grp{iSVM}{i_subj}));
        end
        Data(iROI).DATA{i_subj} = tmp_subj;
    end
end
end


function data = average_hs(data_contra, data_ipsi, isMVPA)
% we average the data from each hemisphere

if nargin<3 || isempty(isMVPA)
    isMVPA = false;
end

for iROI = 1:numel(data_contra)
    for isubj = 1:numel(data_contra(iROI).DATA)
        data(iROI).DATA{isubj} = ...
            mean(...
            cat(4, ...
            data_contra(iROI).DATA{isubj}, ...
            data_ipsi(iROI).DATA{isubj}), ...
            4);
    end
end

% we recompute all the descriptive stats
data = grp_stats(data, isMVPA);

end