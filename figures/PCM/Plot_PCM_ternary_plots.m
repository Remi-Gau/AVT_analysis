clc; clear; close all

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

PCM_dir = fullfile(StartDir, 'figures', 'PCM');


Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

Comp_suffix{1} = 'A_stim';
Comp_suffix{end+1} = 'V_stim';
Comp_suffix{end+1} = 'T_stim';
Comp_suffix{end+1} = 'A_V_ipsi';
Comp_suffix{end+1} = 'A_T_ipsi';
Comp_suffix{end+1} = 'V_T_ipsi';
Comp_suffix{end+1} = 'A_V_contra';
Comp_suffix{end+1} = 'A_T_contra';
Comp_suffix{end+1} = 'V_T_contra';

surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;
on_merged_ROI = 0;

Split_suffix = '';


if on_merged_ROI
    NbROI = 1;
else
    NbROI = 5;
end

if surf
    ToPlot={'Cst','Lin','Avg','ROI'};
    Output_dir = 'surf';
else
    ToPlot={'ROI'}; %#ok<*UNRCH>
    Output_dir = 'vol';
    if raw
        Save_suffix = 'beta-raw';
    else
        Save_suffix = 'beta-wht'; %#ok<*UNRCH>
    end
end
Save_dir = fullfile(StartDir, 'results', 'PCM', Output_dir);

if raw
    Beta_suffix = 'raw-betas';
else
    Beta_suffix = 'wht-betas';
end

if hs_idpdt==1
    hs_suffix = {'LHS' 'RHS'};
    NbHS = 2;
else
    hs_suffix = {'LRHS'};
    NbHS = 1;
end


% To know how many ROIs we have
if on_merged_ROI
    ROI(1).name ='V2V3'; %#ok<*USENS>
elseif surf
    load(fullfile(StartDir, 'sub-02', 'roi', 'surf','sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex')
else
    ROI(1).name ='A1';
    ROI(2).name ='PT';
    ROI(3).name ='V1_thres';
    ROI(4).name ='V2_thres';
    ROI(5).name ='V3_thres';
    ROI(6).name ='V4_thres';
    ROI(7).name ='V5_thres';
end


% Figure parameters
set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')

FigDim = [50, 50, 600, 600];


for iToPlot = 1 %:numel(ToPlot)
    
    for Target = 1
        
        if Target==2
            Stim_suffix = 'targ';
        else
            Stim_suffix = 'stim';
        end
        
        for iROI = 1:NbROI
            
            for ihs=1:NbHS
                
                for iComp = 1:9
                    
                    if on_merged_ROI
                        ls_files_2_load = dir(fullfile(Save_dir, ...
                            sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_201*.mat', ...
                            Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                            ToPlot{iToPlot}, Comp_suffix{iComp})));
                    else
                        ls_files_2_load = dir(fullfile(Save_dir, ...
                            sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s_201*.mat', ...
                            Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                            ToPlot{iToPlot}, Split_suffix, Comp_suffix{iComp})));
                    end
                    
                    disp(fullfile(Save_dir,ls_files_2_load(end).name))
                    load(fullfile(Save_dir,ls_files_2_load(end).name),...
                        'M','T_group','G_hat','G','G_pred_gr','T_cross','G_pred_cr')
                    
                    M_all{iComp,1} = M; %#ok<*AGROW>
                    T_group_all{iComp,1} = T_group;
                    T_cross_all{iComp,1} = T_cross;
                    
                    clear M G G_hat T_group G_pred_gr T_cross G_pred_cr
                end
                
                Normalize = 0;
                colors={'b';'b';'b'};
                
                for iComp = 1:numel(M_all)
                    
                    Upperceil = T_group_all{iComp,1}.likelihood(:,end);
                    Data2Plot = T_cross_all{iComp,1};
                    M = M_all{iComp,1};
                    
                    T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                        'normalize',Normalize);
                    Likelihood{iROI,ihs}(:,:,iComp) = T.likelihood;
                    
                end
            end
        end
        
        close all
        
        for iROI = 1%:NbROI

            %% RFX: perform bayesian model selection
            % Compute exceedance probabilities
            for iComp = 1:numel(M_all)
                
                loglike = Likelihood{iROI,ihs}(:,2:end-1,iComp);
                
                % compare the 3 models together
                [~,~,~,pxp3,~] = spm_BMS(loglike);
                All_pxp(iComp,:) = pxp3;
                clear pxp3

            end
            
            %% ternary plots: the 3 models compared all together
            opt.FigName = sprintf('BestModel-RFX1-3Models-%s-%s-PCM_{grp}-%s-%s-%s', ...
                ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
            
            figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
            
            for iSubplot = 1:3
            subplot(1,3,iSubplot)
            
            switch iSubplot
                case 1
                    ToPlot = 1:3;
                case 2
                    ToPlot = 4:6;
                case 3
                    ToPlot = 7:9;
            end
            
            [h,hg,htick]=terplot;
            hter=ternaryc(All_pxp(ToPlot,1),All_pxp(ToPlot,2),All_pxp(ToPlot,3));
            hlabels=terlabel('S','S+I','I');
            
            set(hter(1:3), 'color', 'k', 'MarkerFaceColor', 'none')
            set(hter(4:6), 'color', 'r', 'MarkerFaceColor', 'none')

            set(hter(1:3:9), 'marker', 'o')
            set(hter(2:3:9), 'marker', 'square')
            
            set(hter(:), 'MarkerSize', 12, 'linewidth', 2)
            end
            
            p=mtit([ROI(iROI).name ' - ' ToPlot{iToPlot}],...
                'fontsize',14,...
                'xoff',0,'yoff',.025);
            
            print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '_ternary_plot.tif'] ), '-dtiff')
            
        end
        
    end
end

