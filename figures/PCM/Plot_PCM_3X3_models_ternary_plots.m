clc; clear; close all

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

PCM_dir = fullfile(StartDir, 'figures', 'PCM');

Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

Comp_suffix{1} = '3X3_Ipsi';
Comp_suffix{end+1} = '3X3_Contra';

%% Sorting models for each family comparison

family_names={...
    'Idpdt',...
    'Scaled',...
    'Scaled_Idpdt'};

CdtComb = ['AV';'AT';'VT'];

% These are the 12 models from the PCM
% M{1}.name = 'all_scaled';
% M{2}.name = 'all_idpdt';
% M{3}.name = 'all_scaled_&_idpdt';
%
% M{4}.name = 'A idpdt - V,T scaled';
% M{5}.name = 'V idpdt - A,T scaled';
% M{6}.name = 'T idpdt - V,A scaled';
%
% M{7}.name = 'A idpdt+scaled - V,T scaled';
% M{8}.name = 'V idpdt+scaled - A,T scaled';
% M{9}.name = 'T idpdt+scaled - V,A scaled';
%
% M{10}.name = 'A idpdt+scaled V - T idpdt';
% M{11}.name = 'A idpdt+scaled T - V idpdt';
% M{12}.name = 'V idpdt+scaled T - A idpdt';

% Models to include for each modality for the family comparison
A_Idpdt_V = [2 4 5 11 12];
A_Scaled_V = [1 6 8];
A_Scaled_Idpdt_V = [3 7 8 10];

Cdt{1} = [A_Idpdt_V A_Scaled_V A_Scaled_Idpdt_V];

A_Idpdt_T = [2 4 6 10 12];
A_Scaled_T = [1 5 8];
A_Scaled_Idpdt_T = [3 7 9 11];

Cdt{2} = [A_Idpdt_T A_Scaled_T A_Scaled_Idpdt_T];

V_Idpdt_T = [2 5 6 10 11];
V_Scaled_T = [1 4 7];
V_Scaled_Idpdt_T = [3 8 9 12];

Cdt{3} = [V_Idpdt_T V_Scaled_T V_Scaled_Idpdt_T];

% create the families
for iCdt1 = 1:3
    Families{iCdt1} = ...
        struct('names', [], 'partition', [1 1 1 1 1 2 2 2 3 3 3 3], ...
        'modelorder', [], 'infer', 'RFX', 'Nsamp', 1e4, 'prior', 'F-unity');
    for iFam = 1:3
        Families{iCdt1}.names{iFam} = [CdtComb(iCdt1,1) '_' family_names{iFam} '_' CdtComb(iCdt1,2)];
    end
    % The field model order will be used to only extract the likelihood
    % of the models of interest
    Families{iCdt1}.modelorder = Cdt{iCdt1};
end


%%
surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;
on_merged_ROI = 0;

Split_suffix = '';

NbROI = 5;


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
if surf
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


%% Figure parameters
set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')

FigDim = [50, 50, 600, 600];


for iToPlot = 2 %:numel(ToPlot)
    
    for Target = 1
        
        if Target==2
            Stim_suffix = 'targ';
        else
            Stim_suffix = 'stim';
        end
        
        for iROI = 1:NbROI
            
            for ihs=1:NbHS
                
                for iComp = 1:2
                    
                    ls_files_2_load = dir(fullfile(Save_dir, ...
                        sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s_201*.mat', ...
                        Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                        ToPlot{iToPlot}, Split_suffix, Comp_suffix{iComp})));
                    
                    disp(fullfile(Save_dir,ls_files_2_load(end).name))
                    load(fullfile(Save_dir,ls_files_2_load(end).name),...
                        'M','T_group','G_hat','G','G_pred_gr','T_cross','G_pred_cr')
                    
                    M_all{iComp,1} = M; %#ok<*AGROW>
                    T_group_all{iComp,1} = T_group;
                    T_cross_all{iComp,1} = T_cross;
                    
                    clear M G G_hat T_group G_pred_gr T_cross G_pred_cr
                    
                end
                
                Normalize = 0;
                colors={'b';'b';'b';'b';'b';'b';'b';'b';'b';'b';'b';'b'};
                
                
                for iComp = 1:numel(M_all)
                    
                    Upperceil = T_group_all{iComp,1}.likelihood(:,end);
                    Data2Plot = T_cross_all{iComp,1};
                    M = M_all{iComp,1};
                    
                    T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                        'normalize',Normalize);
                    Likelihood{iROI,ihs}(:,:,iComp) = T.likelihood;
                    Likelihood_norm{iROI,ihs}(:,:,iComp) = T.likelihood_norm;
                    
                end
            end
        end
        
        %% Do family comparison and plot
        for iROI = 1:NbROI
            
            close all
            
            %% For ipsi and contra
            for iComp = 1:numel(M_all)
                
                %% RFX: perform bayesian model family comparison
                % Compute exceedance probabilities
                XP = [];
                Comp = [];
                for iCdt1 = 1:3
                    family = Families{iCdt1};
                    loglike = Likelihood{iROI,ihs}(:,family.modelorder+1,iComp);%-Likelihood{iROI,ihs}(:,1,iComp);
                    family = spm_compare_families(loglike,family);
                    Families{iCdt1} = family;
                    XP(iCdt1,:) = family.xp;
                    Comp(iCdt1,:) = [CdtComb(iCdt1,1) ' VS ' CdtComb(iCdt1,2) ];
                end
                
                
                %% ternary plots: the 3 models compared all together
                opt.FigName = sprintf('TernaryPlot-3X3Models-%s-%s-%s-PCM_{grp}-%s-%s-%s', ...
                    ROI(iROI).name, Comp_suffix{iComp}, hs_suffix{ihs}, ...
                    Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
                
                [h,hg,htick]=terplot;
                set(htick(:),'fontsize',15)
                set(hg(:), 'linewidth', 1, 'linestyle', '-')
                
                hter=ternaryc(XP(:,2),XP(:,3),XP(:,1));
                hlabels=terlabel('p(Scaled)','p(Scaled and independent)','p(Independent)');
                set(hlabels(:),'fontsize',20)
                
                if iComp==1
                    set(hter, 'color', 'r')
                elseif iComp==2
                    set(hter, 'color', 'b')
                end
                
                set(hter, 'MarkerFaceColor', 'none')
                
                set(hter(1), 'marker', '+')
                set(hter(2), 'marker', 'diamond')
                set(hter(3), 'marker', 'o')
                
                set(hter(:), 'MarkerSize', 20, 'linewidth', 3)
                
                p=mtit([ROI(iROI).name ' - Ex probability - ' ToPlot{iToPlot} ' - ' Comp_suffix{iComp}],...
                    'fontsize',14,...
                    'xoff',0,'yoff',.025);
                
                print(gcf, fullfile(PCM_dir, 'Cdt', '3X3_models', [opt.FigName  '.tif'] ), '-dtiff')
  
            end
        end
    end
end


