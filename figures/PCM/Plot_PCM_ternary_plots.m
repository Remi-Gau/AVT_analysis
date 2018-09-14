clc; clear; close all

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'AVT-7T-code','subfun')))

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
    NbROI = 4;
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


for iToPlot = 1:2 %:numel(ToPlot)
    
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
                    Likelihood_norm{iROI,ihs}(:,:,iComp) = T.likelihood_norm;
                    
                end
            end
        end
        
        close all
        
        
        %%
        for iROI = 1:NbROI
            close all
            clc
            
            %% RFX: perform bayesian model selection
            % Compute exceedance probabilities
            for iComp = 1:numel(M_all)
                
                loglike = Likelihood{iROI,ihs}(:,2:end-1,iComp);%-Likelihood{iROI,ihs}(:,1,iComp);
                
                % compare the 3 models together
                [~,~,~,All_pxp(iComp,:),~] = spm_BMS(loglike);
                
            end
            
            XP(:,:,iROI) = All_pxp;
            
            
            %% Perform family comparison
            Families = ...
                struct('names', [], 'partition', [1 2 2], ...
                'infer', 'RFX', 'Nsamp', 1e4, 'prior', 'F-unity', 'alpha0', []); %#ok<*SAGROW>
            Families.names{1}='Scaled';
            Families.names{2}='Scaled+Idpdt and Idpdt';
            for iComp = 1:3 %numel(M_all)
                family = Families;
                loglike = Likelihood{iROI,ihs}(:,2:end-1,iComp);
                family = spm_compare_families(loglike,family);
                XP2(iComp,:,iROI) = family.xp;
            end
            
            
            %% Plot
            for iSubplot = 1%:3
                
                switch iSubplot
                    case 1
                        CdtToPlot = 1:3;
                        suffix = ' - CvsI';
                    case 2
                        CdtToPlot = 4:6;
                        suffix = ' - I';
                    case 3
                        CdtToPlot = 7:9;
                        suffix = ' - C';
                end
                
                %% Ternary plots likelihoods
                %                 opt.FigName = sprintf('Likelihoods-3Models-%s-%s-PCM_{grp}-%s-%s-%s', ...
                %                     ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                %
                %                 figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
                %
                %                 hold on
                %
                %                 [h,hg,htick]=terplot;
                %                 set(htick(:),'fontsize',11)
                %                 set(hg(:), 'linewidth', 1, 'linestyle', '-')
                %
                %                 for i=1:3
                %                     tmp = Likelihood{iROI,ihs}(:,2:end-1,CdtToPlot(i))...
                %                         -Likelihood{iROI,ihs}(:,1,CdtToPlot(i)); % remove null model log like value
                %                     tmp = mean(tmp./repmat(sum(tmp,2),1,3)); % take mean across subjects
                %                     hter=ternaryc(tmp(:,1),tmp(:,2),tmp(:,3));
                %
                %                     switch i
                %                         case 1
                %                             set(hter, 'marker', '+')
                %                         case 2
                %                             set(hter, 'marker', 'diamond')
                %                         case 3
                %                             set(hter, 'marker', 'o')
                %                     end
                %
                %                     if iSubplot==1
                %                         set(hter, 'color', 'k')
                %                     elseif iSubplot==2
                %                         set(hter, 'color', 'r')
                %                     end
                %
                %                     set(hter, 'MarkerSize', 15, 'linewidth', 3, 'MarkerFaceColor', 'none')
                %                 end
                %
                %                 hlabels=terlabel('p(Scaled)','p(Scaled and independent)','p(Independent)');
                %                 set(hlabels(:),'fontsize',11)
                %
                %                 p=mtit([ROI(iROI).name ' - Relative loglikelihood - ' ToPlot{iToPlot} suffix],...
                %                     'fontsize',14,...
                %                     'xoff',0,'yoff',.025);
                %
                %                 set(gca, 'ticklength', [10 0.1])
                %
                %                 print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName suffix '_ternary_plot.tif'] ), '-dtiff')
                %                 print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName suffix '_ternary_plot.svg'] ), '-dsvg')
                
                %% ternary plots: the 3 models compared all together
                %                 opt.FigName = sprintf('BestModel-RFX1-3Models-%s-%s-PCM_{grp}-%s-%s-%s', ...
                %                     ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                %
                %                 figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
                %
                %                 [h,hg,htick]=terplot;
                %                 set(htick(:),'fontsize',15)
                %                 set(hg(:), 'linewidth', 1, 'linestyle', '-')
                %                 hter=ternaryc(All_pxp(CdtToPlot,1),All_pxp(CdtToPlot,2),All_pxp(CdtToPlot,3));
                %                 hlabels=terlabel('p(Scaled)','p(Scaled and independent)','p(Independent)');
                %                 set(hlabels(:),'fontsize',20)
                %
                %                 if iSubplot==1
                %                     set(hter, 'color', 'k', 'MarkerFaceColor', 'none')
                %                 elseif iSubplot==2
                %                     set(hter, 'color', 'r', 'MarkerFaceColor', 'none')
                %                 end
                %
                %                 set(hter, 'MarkerFaceColor', 'none')
                %
                %                 set(hter(1), 'marker', '+')
                %                 set(hter(2), 'marker', 'diamond')
                %                 set(hter(3), 'marker', 'o')
                %
                %                 set(hter(:), 'MarkerSize', 20, 'linewidth', 3)
                %
                %                 %                                 p=mtit([ROI(iROI).name ' - Ex probability - ' ToPlot{iToPlot} suffix],...
                %                 %                                     'fontsize',14,...
                %                 %                                     'xoff',0,'yoff',.025);
                %
                %                 print(gcf, fullfile(PCM_dir, 'Cdt', '2x2', ToPlot{iToPlot}, 'Ternary', [opt.FigName suffix '_ternary_plot.tif'] ), '-dtiff')
                %                 print(gcf, fullfile(PCM_dir, 'Cdt', '2x2', ToPlot{iToPlot}, 'Ternary', [opt.FigName suffix '_ternary_plot.svg'] ), '-dsvg')
                
                
                
            end
            
            
        end
        
        %% Matrices plot for exceedance probability of I + (S & I)
        close all
        
        for iFam = 1:2
            
            if iFam==1
                NbFam = '3';
                Mat2Plot = squeeze(XP(1:3,2,:)+XP(1:3,3,:));
            else
                NbFam = '2';
                Mat2Plot = squeeze(XP2(:,2,:));
            end
            
            opt.FigName = sprintf('ExcProba-%sFam--I_VS_C-%s-PCM_{grp}-%s-%s-%s', ...
                NbFam, hs_suffix{ihs}, ...
                Stim_suffix, Beta_suffix, ToPlot{iToPlot});
            
            figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
            
            subplot(2,1,1)
            hold on
            
            colormap('gray')
            
            imagesc(flipud(Mat2Plot), [0 1])
            
            plot([.5 NbROI+.5], [1.5 1.5], 'color', [.2 .2 .2], 'linewidth', 1)
            plot([.5 NbROI+.5], [2.5 2.5], 'color', [.2 .2 .2], 'linewidth', 1)
            plot([1.5 1.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
            plot([2.5 2.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
            plot([3.5 3.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
            plot([4.5 4.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
            
            patch([2.44 2.56 2.56 2.44], [.5 .5 3.5 3.5], 'w', 'linewidth', 2)
            
            plot([.5 .5], [.5 3.5], 'k', 'linewidth', 2)
            plot([NbROI+.5 NbROI+.5], [.5 3.5], 'k', 'linewidth', 2)
            plot([.5 NbROI+.5], [.5 .5], 'k', 'linewidth', 2)
            plot([.5 NbROI+.5], [3.5 3.5], 'k', 'linewidth', 2)
            
            title('Contra VS Ipsi')
            set(gca,'fontsize', 22, ...
                'ytick', 1:3,...
                'yticklabel', flipud(['A_i VS A_c';'V_i VS V_c';'T_i VS T_c']),...
                'xtick', 1:NbROI,...
                'xticklabel', {ROI(1:NbROI).name})
            colorbar
            
            axis([.5 NbROI+.5 .5 3.5])
            
            %             p=mtit(['Exc probability Idpt + Scaled & Idpdt - ' ToPlot{iToPlot}],...
            %                 'fontsize',14,...
            %                 'xoff',0,'yoff',.025);
            
            print(gcf, fullfile(PCM_dir, 'Cdt', '2x2', ToPlot{iToPlot}, [opt.FigName  '.tif'] ), '-dtiff')
            pause(2)
            
            ColorMap = brain_colour_maps('hot_increasing');
            colormap(ColorMap)
            print(gcf, fullfile(PCM_dir, 'Cdt', '2x2', ToPlot{iToPlot}, [opt.FigName  '_hot.tif'] ), '-dtiff')
            
        end
        
    end
end

