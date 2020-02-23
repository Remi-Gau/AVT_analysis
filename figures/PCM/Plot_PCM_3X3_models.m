% Plot the results of the 3X3 PCM
% First plots the G matrices: empirical, free model and then all the fitted of all the models
% Then gives the bar plot of the likelihoods of the different models

clc; clear; close all

%% set up directories and get dependencies
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


surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;
Split_half = 0; % only implemented for surface
if Split_half==1
    NbSplits=2;
else
    NbSplits=1;
end
if Split_half
else
    Split_suffix = '';
end


SubLs = dir(fullfile(Dirs.DerDir,'sub*'));
NbSub = numel(SubLs);

ColorSubject = ColorSubject();

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

if raw
    Beta_suffix = 'raw-betas';
else
    Beta_suffix = 'wht-betas';
end


ColorMap = seismic(1000);
FigDim = [50, 50, 1400, 750];
visible = 'on';


PCM_dir = fullfile(Dirs.DerDir, 'figures', 'PCM');
Save_dir = fullfile(Dirs.DerDir, 'results', 'PCM', Output_dir);

% to know how many ROIs we have
if surf
    load(fullfile(Dirs.DerDir, 'sub-02', 'roi', 'surf','sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex')
else
    ROI(1).name ='A1';
    ROI(2).name ='PT';
    ROI(3).name ='V1_thres';
    ROI(4).name ='V2_thres';
    ROI(5).name ='V3_thres';
    ROI(6).name ='V4_thres';
    ROI(7).name ='V5_thres';
end

if hs_idpdt==1
    hs_suffix = {'LHS' 'RHS'};
    NbHS = 2;
else
    hs_suffix = {'LRHS'};
    NbHS = 1;
end

Comp_suffix{1} = '3X3_Ipsi';
Comp_suffix{end+1} = '3X3_Contra';
Comp_suffix{end+1} = '3X3_ContraIpsi';

for iToPlot = 1%:numel(ToPlot)
    
    for Target = 1
        
        if Target==2
            Stim_suffix = 'targ';
            if hs_idpdt==1
                CondNames = {...
                    'A Targ L','A Targ R',...
                    'V Targ L','V Targ R',...
                    'T Targ L','T Targ R',...
                    };
            else
                CondNames = {...
                    'A Targ ipsi','A Targ contra',...
                    'V Targ ipsi','V Targ contra',...
                    'T Targ ipsi','T Targ contra',...
                    };
            end
            
        else
            Stim_suffix = 'stim';
            if hs_idpdt==1
                CondNames = {...
                    'A Stim L','A Stim R',...
                    'V Stim L','V Stim R',...
                    'T Stim L','T Stim R',...
                    };
            else
                CondNames = {...
                    'A ipsi','A contra',...
                    'V ipsi','V contra',...
                    'T ipsi','T contra'...
                    };
            end
        end
        
        for iROI = 1:4 %numel(ROI)
            
            for ihs=1:NbHS
                
                for iComp = 1:3
                    
                    ls_files_2_load = dir(fullfile(Save_dir, ...
                        sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s_20*.mat', ...
                        Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                        ToPlot{iToPlot}, Split_suffix, Comp_suffix{iComp})));
                    
                    disp(fullfile(Save_dir,ls_files_2_load(end).name))
                    load(fullfile(Save_dir,ls_files_2_load(end).name),...
                        'M','T_group','G_hat','G','G_pred_gr','T_cross','G_pred_cr')
                    
                    M_all{iComp,1} = M;
                    T_group_all{iComp,1} = T_group;
                    G_all{iComp,1} = G;
                    G_hat_all{iComp,1} = G_hat;
                    G_pred_gr_all{iComp,1} = G_pred_gr;
                    T_cross_all{iComp,1} = T_cross;
                    G_pred_cr_all{iComp,1} =  G_pred_cr;
                    
                    clear M G G_hat T_group G_pred_gr T_cross G_pred_cr
                end
                
                c = pcm_indicatorMatrix('allpairs' ,1:size(M_all{1}{1}.Ac,1));
                %                 H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
                H = 1;
                
                opt.SubLs = SubLs;
                opt.FigDim = FigDim;
                
                
                %% Plot G matrices
                m = 3; n= 5;
                
                close all
                
                for iComp = 1:numel(M_all)
                    
                    switch iComp
                        case 1
                            CdtToSelect = 1:2:5;
                        case 2
                            CdtToSelect = 2:2:6;
                    end
                    
                    Subplot=1;
                    
                    opt.FigName = sprintf('GMat-3x3Models-%s-%s-%s-PCM_{grp}-%s-%s-%s', ...
                        Comp_suffix{iComp},strrep(ROI(iROI).name, '_thresh',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    
                    figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                    
                    colormap(ColorMap)

                    % Get info
                    G_hat = G_hat_all{iComp,1};
                    G_pred_cr = G_pred_cr_all{iComp,1};
                    M = M_all{iComp,1};

                    
                    % CVed G_{emp}
                    subplot(m,n,Subplot);
                    
                    tmp = H*mean(G_hat,3)*H';
                    MIN_MAX = max(abs( [min(tmp(:)) max(tmp(:))] ));
                    CLIM = [MIN_MAX*-1 MIN_MAX];
                    imagesc(tmp, CLIM);
                    colorbar
                    
                    set(gca,'tickdir', 'out', 'xtick', 1:3,'xticklabel', [], ...
                        'ytick', 1:3,'yticklabel', {CondNames{CdtToSelect}}, ...
                        'ticklength', [0.01 0], 'fontsize', 8)
                    box off
                    axis square
                    t=title('G_{emp} CV');
                    set(t, 'fontsize', 8);
                    
                    Subplot = Subplot+1;
                    
                    
                    % CVed G_{pred} free model
                    subplot(m,n,Subplot);
                    
                    tmp = H*mean(G_pred_cr{end},3)*H';
                    MIN_MAX = max(abs( [min(tmp(:)) max(tmp(:))] ));
                    CLIM = [MIN_MAX*-1 MIN_MAX];
                    imagesc(tmp, CLIM);
                    colorbar
                    
                    set(gca,'tickdir', 'out', 'xtick', 1:3,'xticklabel', [], ...
                        'ytick', 1:3,'yticklabel', {CondNames{CdtToSelect}}, ...
                        'ticklength', [0.01 0], 'fontsize', 8)
                    box off
                    axis square
                    t=title('G_{pred} free CV');
                    set(t, 'fontsize', 6);  
                    
                    Subplot = Subplot+1;
                    
                    
                    % plot pred G mat from each model
                    for iModel=2:13
                        subplot(m,n,Subplot);

                        tmp = H*mean(G_pred_cr{iModel},3)*H';
                        MIN_MAX = max(abs( [min(tmp(:)) max(tmp(:))] ));
                        CLIM = [MIN_MAX*-1 MIN_MAX];
                        imagesc(tmp, CLIM);
                        colorbar
                        
                    set(gca,'tickdir', 'out', 'xtick', 1:3,'xticklabel', [], ...
                        'ytick', 1:3,'yticklabel', {CondNames{CdtToSelect}}, ...
                        'ticklength', [0.01 0], 'fontsize', 8)     
                        box off
                        axis square
                        t=title([num2str(iModel-1) ' - ' strrep(M{iModel}.name, '_', ' ')] );
                        set(t, 'fontsize', 8);
                        
                        Subplot = Subplot+1;
                    end
                    
                    mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)

                    print(gcf, fullfile(PCM_dir, 'Cdt', '3X3_models', [opt.FigName '.tif'] ), '-dtiff')
          
                end

                
                %% Provide a plot of the likelihoods as bar plots
                clear Likelihood

                for WithSubj = 1:2
                    
                    opt.FigName = sprintf('LikelihoodsBarPlot-3x3Models-%s-%s-PCM_{grp}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    if WithSubj==2
                        opt.FigName = sprintf('LikelihoodsBarPlot-SUBJ-3x3Models-%s-%s-PCM_{grp}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                            hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    end
                    
                    figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                    
                    Subplot = 1;
                    
                    for iComp = 1:numel(M_all)
                        
                        for j=1:2
                            
                            colors={'b';'b';'b';'b';'b';'b';'b';'b';'b';'b';'b';'b'};
                            
                            subplot(numel(M_all),2,Subplot)
                            
                            if j==2
                                Normalize=1;
                            else
                                Normalize = 0;
                            end
                            
                            Upperceil = T_group_all{iComp,1}.likelihood(:,end);
                            Data2Plot = T_cross_all{iComp,1};
                            M = M_all{iComp,1};
                            
                            T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                                'normalize',Normalize);
                            
                            if j==1
                                loglike = mean(T.likelihood_norm(:,2:end-1));
                                [loglike_sorted,idx] = sort(mean(T.likelihood_norm(:,2:end-1)));
                                if loglike(idx(end-1))+3<loglike(idx(end))
                                    colors{idx(end)} = 'r';
                                    T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                                        'normalize',Normalize);
                                end
                            end
                            
                            
                            if WithSubj==2
                                hold on
                                Scatter = linspace(-.3, .3, NbSub);
                                for iM=2:numel(M)-1
                                    for isubj=1:NbSub
                                        plot(iM-1+Scatter(isubj),T.likelihood_norm(isubj,iM),...
                                            'marker', 'o', 'MarkerSize', 3,...
                                            'MarkerEdgeColor', ColorSubject(isubj,:), ...
                                            'MarkerFaceColor', ColorSubject(isubj,:))
                                    end
                                end
                            end
                            
                            ylabel('')
                            
                            set(gca,'fontsize', 8, ...
                                'xtick', 1:12,...
                                'xticklabel', 1:12)
                            
                            if WithSubj==2
                                MIN = min(min(T.likelihood_norm(:,2:end-1)));
                                MAX = max(max(T.likelihood_norm(:,2:end-1)));
                                MAX = MAX*1.1;
                            else
                                MIN = min(mean(T.likelihood_norm(:,2:end-1)))-...
                                    max(nansem(T.likelihood_norm(:,2:end-1)))/4;
                                
                                MAX = max(mean(T.likelihood_norm(:,2:end-1)))+...
                                    max(nansem(T.likelihood_norm(:,2:end-1)));
                                MAX = MAX*1.005;
                                if MAX < 1.005
                                    MAX = 1.005;
                                end
                            end
                            
                            if iComp==1
                                if j==2
                                    t = title('Normalized log-likelihood - Cross validation');
                                else
                                    t = title('Log-likelihood - Cross validation');
                                end
                                set(t,'fontsize', 12)
                            end
                            
                            if j==1
                                t = ylabel(Comp_suffix{iComp});
                                set(t, 'fontsize', 14)
                            end
                            
                            axis([0.5 12.5 0 MAX])
                            
                            Subplot = Subplot + 1;
                        end
                        
                    end
                    
                    mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                    set(gcf,'visible', visible')
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', '3X3_models', [opt.FigName '.tif'] ), '-dtiff')
                    
                end
            end
        end
    end
end
