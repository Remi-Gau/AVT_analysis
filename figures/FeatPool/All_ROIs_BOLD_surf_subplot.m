function All_ROIs_BOLD_surf_subplot
% creates "subplots" to the main figures of the AVT:
% e.g if the main figure shows the results of contra - ipsi for tactile
% then the subplot will show contra and ipsi on the same figure


clc; clear;

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

% plot only main results
% only deactivations
% only contra - ipsi for tactile stim
% only differences between non-preferred modalities of a ROI
plot_main = 1;


SubLs = dir(fullfile(Dirs.DerDir,'sub*'));
NbSub = numel(SubLs);

NbLayers=6;

ROIs = {
    'A1'
    'PT'
    'V1'
    'V2'};
ROI_order_BOLD = [1 7 2:3];

TitSuf = {'Contra_&_Ipsi'};


Test_side = []; % default side of the test to use

IsStim = 1;

if ~plot_main
    plot_pvalue = 1;
else
    plot_pvalue = 0;
end

opt.MVNN = 0;
opt.vol = 0;


SaveSufix = '_results_surf';

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
else
    Stim_prefix = 'Target';
    load(fullfile(Dirs.BOLD_resultsDir, ...
        strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
end

AllSubjects_Data_BOLD = AllSubjects_Data;
clear AllSubjects_Data

close all

for iAnalysis = 1:numel(TitSuf)
    
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
    
    ToPlot.avg_hs = '';
    ToPlot.plot_main = '';
    
    
    %% Get BOLD
    switch iAnalysis
        
        %% Against baseline
        case 1
            
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
            
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra);
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            Data = cat(1,AllSubjects_Data_BOLD(:).Ispi);
            ToPlot.Col = 2;
            ToPlot = Get_data(ToPlot,Data,ROI_order_BOLD);
            
            
            % To specify which ROIs to plot for each figure
            if plot_main
                ToPlot.profile(1,1).main = 3:4;
                ToPlot.profile(2,1).main = 1:2;
                ToPlot.profile(3,1).main = 1:4;
                
                ToPlot.profile(1,2).main = 3:4;
                ToPlot.profile(2,2).main = 1:2;
                ToPlot.profile(3,2).main = 1:4;
                
            end
            
            ToPlot.IsMVPA = [...
                0 0;...
                0 0;...
                0 0];
            
            ToPlot.m=4;
            
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
            
            
            if opt.MVNN
                ToPlot = rmfield(ToPlot,'MinMax');
            end
            
            
            ToPlot.Titles{1,1} = '[A - Fix]';
            ToPlot.Titles{2,1} = '[V - Fix]';
            ToPlot.Titles{3,1} = '[T - Fix]';
            
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