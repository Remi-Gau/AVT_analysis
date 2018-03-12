clc; clear; close all

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

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

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);


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


ColorMap = brain_colour_maps('hot_increasing');
FigDim = [50, 50, 1400, 750];
visible = 'on';


PCM_dir = fullfile(StartDir, 'figures', 'PCM');
Save_dir = fullfile(StartDir, 'results', 'PCM', Output_dir);

% to know how many ROIs we have
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

if hs_idpdt==1
    hs_suffix = {'LHS' 'RHS'};
    NbHS = 2;
else
    hs_suffix = {'LRHS'};
    NbHS = 1;
end

Comp_suffix{1} = 'A_stim';
Comp_suffix{end+1} = 'V_stim';
Comp_suffix{end+1} = 'T_stim';
Comp_suffix{end+1} = 'A_V_ipsi';
Comp_suffix{end+1} = 'A_T_ipsi';
Comp_suffix{end+1} = 'V_T_ipsi';
Comp_suffix{end+1} = 'A_V_contra';
Comp_suffix{end+1} = 'A_T_contra';
Comp_suffix{end+1} = 'V_T_contra';

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
        
        for iROI = 1:5%numel(ROI)
            
            for ihs=1:NbHS
                
                for iComp = 1:9
                    
                    ls_files_2_load = dir(fullfile(Save_dir, ...
                        sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s_201*.mat', ...
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
                
                %% plot group results
                m = 9;
                n = 5;
                close all
                FigDim = [50, 50, 500, 700];
                
                for SameScale=1:2
                    
                    if SameScale==2
                        ScaleSuffix='-SameScale';
                    else
                        ScaleSuffix='';
                    end
                    
                    
                    opt.FigName = sprintf('GMat-3Models-%s-%s-%s-PCM_{grp}-%s-%s-%s', ...
                        ScaleSuffix,strrep(ROI(iROI).name, '_thresh',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    
                    figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                    
                    Subplot=1;
                    
                    for iComp = 1:numel(M_all)
                        
                        switch iComp
                            case 1
                                CdtToSelect = 1:2;
                            case 2
                                CdtToSelect = 3:4;
                            case 3
                                CdtToSelect = 5:6;
                            case 4
                                CdtToSelect = [1 3];
                            case 5
                                CdtToSelect = [1 5];
                            case 6
                                CdtToSelect = [3 5];
                            case 7
                                CdtToSelect = [2 4];
                            case 8
                                CdtToSelect = [2 6];
                            case 9
                                CdtToSelect = [4 6];
                        end
                        
                        G_hat = G_hat_all{iComp,1};
                        G_pred_cr = G_pred_cr_all{iComp,1};
                        M = M_all{iComp,1};
                        
                        
                        % Get min and max for same scale plotting
                        tmp = H*mean(G_hat,3)*H';
                        %                         tmp = H*mean(G_pred_cr{end},3)*H';
                        %                         for iM=2:4
                        %                             tmp(:,:,end+1) = H*mean(G_pred_cr{iM},3)*H';
                        %                         end
                        CLIM = [min(tmp(:)) max(tmp(:))];
                        clear tmp
                        
                        
                        % CVed G_{emp}
                        subplot(m,n,Subplot);
                        colormap(ColorMap)
                        imagesc(H*mean(G_hat,3)*H');
                        %                         if SameScale==2
                        %                             imagesc(H*mean(G_hat,3)*H', CLIM);
                        %                         end
                        set(gca,'tickdir', 'out', 'xtick', 1:2,'xticklabel', [], ...
                            'ytick', 1:2,'yticklabel', {CondNames{CdtToSelect}}, ...
                            'ticklength', [0.01 0], 'fontsize', 8)
                        
                        box off
                        axis square
                        
                        if iComp==1
                            t=title('G_{emp} CV');
                            set(t, 'fontsize', 8);
                        end
                        
                        Subplot = Subplot+1;
                        
                        % CVed G_{pred} free model
                        subplot(m,n,Subplot);
                        colormap(ColorMap);
                        imagesc(H*mean(G_pred_cr{end},3)*H');
                        if SameScale==2
                            imagesc(H*mean(G_pred_cr{end},3)*H', CLIM);
                        end
                        set(gca,'tickdir', 'out', 'xtick', [],'xticklabel', [], ...
                            'ytick', [],'yticklabel', [], ...
                            'ticklength', [0.01 0], 'fontsize', 8)
                        
                        box off
                        axis square
                        
                        if iComp==1
                            t=title('G_{pred} free CV');
                            set(t, 'fontsize', 6);
                        end
                        
                        Subplot = Subplot+1;
                        
                        
                        % plot pred G mat from each model
                        for iModel=2:4
                            subplot(m,n,Subplot);
                            colormap(ColorMap)
                            try
                                imagesc(H*mean(G_pred_cr{iModel},3)*H');
                                if SameScale==2
                                    imagesc(H*mean(G_pred_cr{iModel},3)*H', CLIM);
                                end
                            catch
                                warning('model %i has an imaginary G_pred_CV', iModel)
                                imagesc(H*mean(real(G_pred_cr{iModel}),3)*H');
                            end
                            
                            set(gca,'tickdir', 'out', 'xtick', [],'xticklabel', [], ...
                                'ytick', [],'yticklabel', [], ...
                                'ticklength', [0.01 0], 'fontsize', 8)
                            
                            box off
                            axis square
                            
                            if iComp==1
                                t=title(M{iModel}.name);
                                set(t, 'fontsize', 6);
                            end
                            
                            Subplot = Subplot+1;
                        end
                        
                        
                    end
                    
                    mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                    set(gcf,'visible', visible')
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                    
                end
                
                
                %% Provide a plot of the crossvalidated likelihoods
                close all
                clear Likelihood
                
                YAxis = {...
                    'A stim';
                    'V stim';
                    'T stim';
                    'A & V ipsi';
                    'A & T ipsi';
                    'V & T ipsi';
                    'A & V contra';
                    'A & T contra';
                    'V & T contra'};
                
                colors={'b';'b';'b';'b';'b'};
                
                FigDim = [50, 50, 1000, 800];
                
                figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                
                for iComp = 1:numel(M_all)
                    
                    for j=1:2
                        
                        if j==2
                            Normalize=1;
                        else
                            Normalize = 0;
                        end
                        
                        for i=1:2
                            
                            Upperceil = T_group_all{iComp,1}.likelihood(:,end);
                            
                            if i==1
                                Data2Plot=T_group_all{iComp,1};
                            else
                                Data2Plot = T_cross_all{iComp,1};
                            end
                            M = M_all{iComp,1};
                            
                            T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                                'normalize',Normalize);
                            
                            Likelihood(iComp,:,i,j) = mean(T.likelihood_norm);
                        end
                    end
                    
                end
                
                
                opt.FigName = sprintf('Likelihoods-3Models-%s-%s-PCM_{grp}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                
                Subplot = 1;
                
                for j=1:2
                    
                    for i=1:2
                        
                        if i==1
                            Title = 'NoCV';
                        elseif i==2
                            Title = 'CV';
                        end
                        
                        subplot(2,2,Subplot);
                        colormap(ColorMap)
                        
                        if j==2
                            imagesc(Likelihood(:,2:end,i,j), [0 1])
                        else
                            imagesc(Likelihood(:,2:end,i,j))
                        end
                        
                        set(gca,'tickdir', 'out', 'xtick', 1:4,'xticklabel', ...
                            {'S';'S+I';'I';'Free'}, ...
                            'ytick', 1:9,'yticklabel', YAxis, ...
                            'ticklength', [0.01 0], 'fontsize', 8)
                        
                        %                         set(gca,'tickdir', 'out', 'xtick', 1:3,'xticklabel', ...
                        %                             {'S';'S+I';'Free'}, ...
                        %                             'ytick', 1:9,'yticklabel', YAxis, ...
                        %                             'ticklength', [0.01 0], 'fontsize', 8)
                        
                        colorbar
                        
                        if i==1
                            if j==2
                                t = ylabel('Normalized log-likelihood');
                            else
                                t = ylabel('Log-likelihood');
                            end
                            set(t,'fontsize', 12)
                        end
                        
                        
                        %                         title(sprintf([Title '\nLower noise ceiling: %0.4f'], tmp(end)))
                        
                        
                        Subplot = Subplot+1;
                    end
                end
                
                mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                set(gcf,'visible', visible')
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
            end
            
            
        end
    end
end
