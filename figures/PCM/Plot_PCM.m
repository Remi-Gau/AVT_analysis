clc; clear; close all

COLOR_Subject= [
    31,120,180;
    178,223,138;
    51,160,44;
    251,154,153;
    227,26,28;
    253,191,111;
    255,127,0;
    202,178,214;
    106,61,154;
    0,0,130];
COLOR_Subject=COLOR_Subject/255;

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;

Do_ind = 0;
Do_group = 1;
Plot_model_group = 1;

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

for iToPlot = 1 %numel(ToPlot)
    
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
        
        for iROI = 1:numel(ROI)
            
            for ihs=1:NbHS
                
                clear M partVec condVec G G_hat COORD RDMs_CV RDMs T_ind theta_ind G_pred_ind...
                    D T_ind_cross theta_ind_cross T_group theta_gr G_pred_gr T_cross theta_cr G_pred_cr
                
                if Do_ind
                    ls_files_2_load = dir( fullfile(Save_dir, sprintf('PCM_ind_features_%s_%s_%s_%s_%s*.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs}, ...
                        ToPlot{iToPlot})) );
                else
                    ls_files_2_load = dir( fullfile(Save_dir, sprintf('PCM_group_features_%s_%s_%s_%s_%s_201*.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                        ToPlot{iToPlot})) );
                end
                
                disp(fullfile(Save_dir,ls_files_2_load(end).name))
                load(fullfile(Save_dir,ls_files_2_load(end).name))
                
                c = pcm_indicatorMatrix('allpairs' ,1:size(M{1}.Ac,1));
                %             H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
                H = 1;
                
                colors={'b'};
                for iM=2:numel(M)-1
                    colors{end+1}='b'; %#ok<*SAGROW>
                    M{iM}.name=num2str(iM-1);
                end
                
                opt.SubLs = SubLs;
                opt.scatter = linspace(0,0.2,size(G_hat,3));
                opt.colors = colors;
                opt.FigDim = FigDim;
                
                
                %% compare RSA results
                for iSub=1:NbSub
                    %                     fprintf('\n  Difference for %s in %s %s\n', SubLs(iSub).name, ROI(iROI).name, hs_suffix{ihs})
                    
                    RDM_PCM = squareform(diag(c*G_hat(:,:,iSub)*c'));
                    RDM_RSA = RDMs_CV(:,:,iSub);
                    
                    %                     RDM_RSA-RDM_PCM
                    
                    RDM_PCM_rk = rsa.util.rankTransform_equalsStayEqual(RDM_PCM,1);
                    RDM_RSA_rk = rsa.util.rankTransform_equalsStayEqual(RDM_RSA,1);
                    
                    %                     RDM_RSA_rk-RDM_PCM_rk
                    
                end
                
                Grp_RDM_RSA{ihs}(:,:,iROI)=mean(RDMs_CV(:,:,:),3);
                
                %% Plot results from individual fits
                if Do_ind
                    % generate the predicted matrices for ind CV
                    for iM = 1:numel(M)
                        for iSub = 1:NbSub
                            tmp = mean(theta_ind_cross{iM}(T_ind_cross.SN==iSub,:),1);
                            G_pred_ind_CV{1,iM}(:,:,iSub) = pcm_calculateG(M{iM},tmp(1:M{iM}.numGparams)');
                            clear tmp
                        end
                    end
                    
                    close all
                    
                    opt.FigName = sprintf('%s-%s-PCM_{ind}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    
                    fig_h = plot_PCM_ind(M, G, G_hat, ...
                        T_ind, D, T_ind_cross, theta_ind, theta_ind_cross,...
                        G_pred_ind, G_pred_ind_CV, RDMs_CV, ...
                        opt);
                    
                    for iFig = 1:numel(fig_h)
                        print(fig_h(iFig), fullfile(PCM_dir, 'Cdt', [fig_h(iFig).Name '.tif']), '-dtiff')
                    end
                    
                end
                
                %% plot group results
                if Do_group
                    close all
                    
                    %                     fprintf('\n  CV effect in %s %s\n', ROI(iROI).name, hs_suffix{ihs})
                    %                     disp(T_group.likelihood-T_cross.likelihood)
                    
                    opt.FigName = sprintf('%s-%s-PCM_{grp}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    
                    if mod(numel(M),2)==0
                        HorPan = numel(M);
                    else
                        HorPan = numel(M)+1;
                    end
                    
                    for IndGrpColor=3
                        
                        switch IndGrpColor
                            case 1
                                SameClim = '-GrpColorMap';
                            case 2
                                SameClim = '-IndColorMap';
                            case 3
                                SameClim = '';
                        end
                        
                        figure('name', [opt.FigName SameClim], 'Position', FigDim, 'Color', [1 1 1]);
                        
                        tmp = H*mean(G_hat,3)*H';
                        tmp(:,:,end+1) = H*mean(G,3)*H';
                        for iM=1:numel(M)
                            tmp(:,:,end+1) =H*mean(G_pred_cr{iM},3)*H';
                            tmp(:,:,end+1) =H*G_pred_gr{iM}*H';
                        end
                        CLIM = floor([min(tmp(:)) max(tmp(:))]);
                        
                        
                        
                        Subplot = HorPan*2+1;
                        % G_{emp}
                        subplot(6,HorPan,Subplot:Subplot+1);
                        colormap(ColorMap)
                        if IndGrpColor==1
                            imagesc(log10(H*mean(G_hat,3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                        else
                            imagesc(H*mean(G_hat,3)*H');
                        end
                        set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                            'ytick', 1:6,'yticklabel', CondNames, ...
                            'ticklength', [0.01 0], 'fontsize', 6)
                        if IndGrpColor==2
                            colorbar
                        end
                        box off
                        axis square
                        t=xlabel('G_{emp}');
                        set(t, 'fontsize', 8);
                        t=ylabel('CV');
                        set(t, 'fontsize', 12);
                        Subplot = Subplot+2;
                        
                        
                        % CVed G_{pred} free model
                        subplot(6,HorPan,Subplot:Subplot+1);
                        colormap(ColorMap);
                        if IndGrpColor==1
                            imagesc(log10(H*mean(G_pred_cr{end},3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                        else
                            imagesc(H*mean(G_pred_cr{end},3)*H');
                        end
                        set(gca,'xtick', [],'ytick', [])
                        if IndGrpColor==2
                            colorbar
                        end
                        box off
                        axis square
                        t=xlabel('G_{pred} free');
                        set(t, 'fontsize', 8);
                        Subplot = Subplot+2;
                        
                        
                        % plot the CVed G_{pred} of each model
                        for iM=2:numel(M)-1
                            subplot(6,HorPan,Subplot:Subplot+1);
                            
                            colormap(ColorMap);
                            if IndGrpColor==1
                                imagesc(log10(H*mean(G_pred_cr{iM},3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                            else
                                try
                                    imagesc(H*mean(G_pred_cr{iM},3)*H');
                                catch
                                    warning('model %i has an imaginary G_pred_CV', iM)
                                    imagesc(H*mean(real(G_pred_cr{iM}),3)*H');
                                end
                            end
                            if IndGrpColor==2
                                colorbar
                            end
                            box off
                            axis square
                            set(gca,'xtick', [],'ytick', [])
                            %                             t=xlabel(['G_{pred} ' num2str(M{iM}.name)]);
                            t=xlabel(num2str(M{iM}.name));
                            set(t, 'fontsize', 8);
                            
                            Subplot = Subplot+2;
                        end
                        
                        
                        
                        
                        Subplot = HorPan*4+1;
                        % RDM or MDS or non CV G
                        subplot(6,HorPan,Subplot:Subplot+1);
                        
                        colormap(ColorMap);
                        if IndGrpColor==1
                            imagesc(log10(H*mean(G,3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                        else
                            imagesc(H*mean(G,3)*H');
                        end
                        
                        
                        set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                            'ytick', 1:6,'yticklabel', CondNames, ...
                            'ticklength', [0.01 0], 'fontsize', 6)
                        if IndGrpColor==2
                            colorbar
                        end
                        box off
                        axis square
                        t=xlabel('G_{emp}');
                        set(t, 'fontsize', 8);
                        t=ylabel('No CV');
                        set(t, 'fontsize', 12);
                        Subplot = Subplot+2;
                        
                        
                        % G_{pred} free model
                        subplot(6,HorPan,Subplot:Subplot+1);
                        colormap(ColorMap);
                        if IndGrpColor==1
                            imagesc(log10(H*G_pred_gr{end}*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                        else
                            imagesc(H*G_pred_gr{end}*H');
                        end
                        set(gca,'xtick', [],'ytick', [])
                        if IndGrpColor==2
                            colorbar
                        end
                        box off
                        axis square
                        t=xlabel('G_{pred} free');
                        set(t, 'fontsize', 8);
                        Subplot = Subplot+2;
                        
                        
                        % plot the G_{pred} of each model
                        for iM=2:numel(M)-1
                            subplot(6,HorPan,Subplot:Subplot+1);
                            
                            colormap(ColorMap);
                            if IndGrpColor==1
                                imagesc(log10(H*G_pred_gr{iM}*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                            else
                                imagesc(H*G_pred_gr{iM}*H');
                            end
                            
                            set(gca,'xtick', [],'ytick', [])
                            if IndGrpColor==2
                                colorbar
                            end
                            box off
                            axis square
                            
                            
                            %                             t=xlabel(['G_{pred} ' num2str(M{iM}.name)]);
                            t=xlabel(num2str(M{iM}.name));
                            set(t, 'fontsize', 8);
                            
                            Subplot = Subplot+2;
                        end
                        
                        if IndGrpColor==1
                            ax = gca;
                            axPos = ax.Position;
                            axPos(1) = axPos(1)+axPos(3)+.02;
                            axPos(3) = .02;
                            axes('Position',axPos);
                            colormap(ColorMap);
                            imagesc(log10(repmat([CLIM(2):-100:CLIM(1)]', [1,200])-CLIM(1)), log10(CLIM-CLIM(1)))
                            set(gca,'tickdir', 'out', 'xtick', [],'xticklabel',  [], ...
                                'ytick', linspace(1,numel(CLIM(2):-100:CLIM(1)),5),...
                                'yticklabel', round(10*linspace(CLIM(2),CLIM(1),5))/10, ...
                                'ticklength', [0.01 0.01], 'fontsize', 8, 'YAxisLocation','right')
                            box off
                        end
                        
                        
                        % Provide a plot of the crossvalidated likelihoods
                        for i=1:3
                            
                            if i==1
                                Data2Plot = T_group;
                                SubPlotRange = [1:floor(HorPan/3) (HorPan+1):(HorPan+(floor(HorPan/3)))];
                                Title = 'NoCV';
                                Upperceil = Data2Plot.likelihood(:,end);
                            elseif i==2
                                Data2Plot = T_cross;
                                SubPlotRange = [floor(HorPan/3+1):2*floor(HorPan/3) HorPan+(floor(HorPan/3+1):2*floor(HorPan/3))];
                                Title = 'CV';
                                Upperceil = T_group.likelihood(:,end);
                            elseif i==3 %
                                Data2Plot = T_group;
                                SubPlotRange = [2*floor(HorPan/3+1):3*floor(HorPan/3) HorPan+(2*floor(HorPan/3+1):3*floor(HorPan/3))];
                                Title = 'AIC: ln(L_{NoCV})-k';
                                for iM=1:size(Data2Plot.likelihood,2)
                                    Data2Plot.likelihood(:,iM)=...
                                        -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                                end
                                Upperceil = T_group.likelihood(:,end);
                            end
                            
                            subplot(6,HorPan,SubPlotRange);
                            hold on
                            
                            T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                                'normalize',0);
                            
                            
                            % print subjects
                            binWidth = max(max(T.likelihood_norm(:,2:end-1))-min(T.likelihood_norm(:,2:end-1)));
                            
                            for iM=2:numel(M)-1
                                %                                 h = plotSpread(T.likelihood_norm(:,iM), 'distributionIdx', ones(size(T.likelihood_norm(:,iM))), ...
                                %                                     'distributionMarkers',{'o'},'distributionColors',{'w'}, ...
                                %                                     'xValues', iM-0.8, 'binWidth', binWidth/100, 'spreadWidth', .2);
                                %                                 set(h{1}, 'MarkerSize', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
                                labels{iM-1} = M{iM}.name;
                            end
                            
                            %                             MIN = min(min(T.likelihood_norm(:,2:end-1)));
                            %                             MAX = max(max(T.likelihood_norm(:,2:end-1)));
                            
                            %                             ax=axis;
                            %                         MIN = ceil(abs(MIN));
                            %                             if MIN>0
                            %                                 MIN=0;
                            %                             end
                            
                            %                             axis([ax(1) ax(2) MIN MAX])
                            
                            set(gca,'XTick',1:numel(M)-2, 'XTickLabel',labels);
                            
                            
                            if i==1
                                ylabel('Log-likelihood');
                                set(gca,'fontsize', 4)
                            else
                                set(gca,'yaxislocation', 'right')
                                set(gca,'fontsize', 4)
                            end
                            
                            title(Title)
                        end
                        
                        mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                        
                        print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName SameClim '.tif'] ), '-dtiff')
                        
                    end
                    
                    
                    
                    %% Plot only the best models
                    close all
                    
                    fig = figure('name', ['Best-models-' opt.FigName], 'Position', FigDim, 'Color', [1 1 1]);
                    
                    Data2Plot = T_group;
                    for iM=1:size(Data2Plot.likelihood,2)
                        Data2Plot.likelihood(:,iM)=...
                            -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                    end
                    T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',T_group.likelihood(:,end), 'colors', colors, ...
                        'normalize',0);
                    
                    [~,I] = sort(mean(T.likelihood_norm(:,1:end-1)),'ascend');
                    NULL = I(18);
                    I(1:18)=[];
                    
                    % Provide a plot of the crossvalidated likelihoods
                    for i=1:3
                        
                        if i==1
                            Data2Plot = T_group;
                            
                            Title = 'NoCV';
                            
                        elseif i==2
                            Data2Plot = T_cross;
                            
                            Title = 'CV';
                            
                        elseif i==3 %
                            
                            Data2Plot = T_group;
                            
                            Title = 'AIC: ln(L_{NoCV})-k';
                            for iM=1:size(Data2Plot.likelihood,2)
                                Data2Plot.likelihood(:,iM)=...
                                    -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                            end
                            
                            
                        end
                        
                        subplot(1,3,i);
                        
                        Upperceil = T_group.likelihood(:,end);
                        T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                            'normalize', 0, 'style', 'dot', 'mindx', I, 'Nnull', NULL, 'Nceil', numel(M));
                        subplot(1,3,i);
                        hold on
                        plot([0 numel(I)], [0 0], 'b', 'linewidth', 2)
                        
                        title(Title)
                        
                        set(gca,'fontsize', 6)
                        
                        ax=axis;
                        MIN = min(mean(T.likelihood_norm(:,I))-nansem(T.likelihood_norm(:,I)));
                        %                     MIN = min(mean(T.likelihood_norm(:,I)));
                        if MIN>0
                            MIN=0;
                        end
                        
                        %                     MAX = mean(Upperceil-T_group{ihs}.likelihood(:,1));
                        
                        axis([ax(1) ax(2) MIN ax(4)])
                        
                        
                    end
                    
                    mtit(fig.Name, 'fontsize', 12, 'xoff',0,'yoff',.035)
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif']  ), '-dtiff')
                    
                    
                    %% G matrix recap figures
                    close all
                    
                    AllMat = [];
                    
                    for iScale = 1:2
                        
                        if iScale==1
                            Scaling = '';
                        else
                            Scaling = 'SameScale-';
                        end
                        
                        fig = figure('name', ['Recap-G-matrix-' Scaling opt.FigName], 'Position', FigDim, 'Color', [1 1 1]);
                        
                        T = pcm_plotModelLikelihood(T_cross,M,'upperceil',T_group.likelihood(:,end), 'colors', colors, ...
                            'normalize', 0, 'style', 'dot', 'Nnull', 1, 'Nceil', numel(M));
                        [~,Idx_best_model] = max(mean(T.likelihood_norm(:,2:end-1)));
                        
                        clf
                        
                        iSubplot = 1;
                        for iRow = 1:4
                            
                            switch iRow
                                case 1 % empirical G matrix
                                    SourceMat = G_hat;
                                    YLabel = 'G_{emp} CV';
                                case 2 % free model predicted matrix
                                    SourceMat = G_pred_cr{end};
                                    YLabel = 'G_{pred}Free CV';
                                case 3 % best model at the group level
                                    SourceMat = G_pred_cr{Idx_best_model+1};
                                    YLabel = 'G_{pred}Best-GRP CV';
                                case 4 % best model at the group level
                                    YLabel = 'G_{pred}Best-IND CV';
                            end
                            
                            for iSubj = 1:11
                                
                                
                                if iSubj==1
                                    Mat2Plot = mean(SourceMat,3);
                                else
                                    Mat2Plot = SourceMat(:,:,iSubj-1);
                                    if iRow==2
                                        %                                     disp(Mat2Plot)
                                    end
                                end
                                
                                if iRow==4
                                    if iSubj==1
                                        Mat2Plot = mean(SourceMat,3);
                                    else
                                        [~,Idx_best_model] = max(T.likelihood_norm(iSubj-1,2:end-1));
                                        SourceMat = G_pred_cr{Idx_best_model+1};
                                        Mat2Plot = SourceMat(:,:,iSubj-1);
                                    end
                                    
                                end
                                
                                
                                subplot(4,12,iSubplot)
                                colormap(ColorMap);
                                if iScale==2
                                    imagesc(H*Mat2Plot*H',[MIN(iRow) MAX(iRow)]);
                                else
                                    imagesc(H*Mat2Plot*H');
                                    AllMat(:,:,iSubj,iRow) = H*Mat2Plot*H';
                                end
                                
                                
                                axis square
                                box off
                                if iSubj==1
                                    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                                        'ytick', 1:6,'yticklabel', CondNames, ...
                                        'ticklength', [0.01 0], 'fontsize', 6)
                                    t=ylabel(YLabel);
                                    set(t, 'fontsize', 10);
                                else
                                    set(gca,'tickdir', 'out', 'xtick', [],'xticklabel', [], ...
                                        'ytick', [],'yticklabel', [], ...
                                        'ticklength', [0.01 0], 'fontsize', 6)
                                end
                                
                                
                                if iRow<3
                                    if iSubj==1
                                        t=title('Grp mean');
                                    else
                                        t=title(SubLs(iSubj-1).name);
                                    end
                                elseif iRow==3
                                    if iSubj==1
                                        t=title(['Model ' num2str(Idx_best_model)]);
                                    else
                                        t=title(SubLs(iSubj-1).name);
                                    end
                                elseif iRow==4
                                    t=title(['Model ' num2str(Idx_best_model)]);
                                end
                                set(t, 'fontsize', 10);
                                
                                iSubplot = iSubplot+1;
                                if iSubj==1
                                    iSubplot = iSubplot+1;
                                end
                            end
                        end
                        
                        mtit(fig.Name, 'fontsize', 12, 'xoff',0,'yoff',.035)

                        for iRow=1:4
                            tmp = AllMat(:,:,:,iRow);
                            MAX(iRow) = max(tmp(:));
                            MIN(iRow) = min(tmp(:));
                        end
                        
                        print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif']  ), '-dtiff')
                        
                    end
                    
                    %% Plot each model results at the group level
                    if 0 %Plot_model_group
                        NbSubj = numel(T.SN);
                        close all
                        
                        for iM=2:numel(M)-1
                            
                            fig = figure('name', ['Model-' M{iM}.name  '--'  opt.FigName] ,'Position', opt.FigDim , 'Color', [1 1 1]);
                            
                            % G matrix
                            subplot(3,2,1);
                            colormap(ColorMap);
                            imagesc(H*mean(G_hat,3)*H');
                            
                            axis on
                            set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                                'ytick', 1:6,'yticklabel', CondNames, ...
                                'ticklength', [0.01 0], 'fontsize', 4)
                            box off
                            axis square
                            colorbar
                            
                            t=title('group G_{emp-CV}');
                            set(t, 'fontsize', 10);
                            
                            
                            % G matrix
                            subplot(3,2,2);
                            colormap(ColorMap);
                            try
                                imagesc(H*mean(G_pred_cr{iM},3)*H');
                            catch
                                warning('model %i has an imaginary G_pred_CV', iM)
                                imagesc(H*mean(real(G_pred_cr{iM}),3)*H');
                            end
                            
                            axis on
                            set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                                'ytick', 1:6,'yticklabel', CondNames, ...
                                'ticklength', [0.01 0], 'fontsize', 4)
                            box off
                            axis square
                            colorbar
                            
                            t=title('group G_{pred-CV}');
                            set(t, 'fontsize', 10);
                            
                            
                            
                            subplot(3,2,4:6);
                            hold on
                            
                            Val2Plot = 1:M{iM}.numGparams;
                            MEAN = mean(theta_cr{iM}(Val2Plot,:),2);
                            SEM = nansem(theta_cr{iM}(Val2Plot,:),2);
                            
                            t = errorbar(Val2Plot-.1, MEAN, SEM, ' .k');
                            set(t,'MarkerSize', 10)
                            
                            for iVal=Val2Plot
                                for iSub=1:NbSub
                                    plot(iVal+.1+opt.scatter(iSub), theta_cr{iM}(iVal,iSub), 'linestyle', 'none', ...
                                        'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(iSub,:), ...
                                        'MarkerFaceColor', COLOR_Subject(iSub,:), 'MarkerSize', 28)
                                end
                            end
                            
                            plot([0.5 M{iM}.numGparams+.5],[0 0],'-- k')
                            
                            axis tight
                            grid on
                            set(gca, 'Xtick', 1:M{iM}.numGparams, 'Xticklabel', 1:M{iM}.numGparams)
                            
                            xlabel('Features')
                            
                            mtit(strrep(fig.Name, '_',' '), 'fontsize', 12, 'xoff',0,'yoff',.035)
                            
                            print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif'] ), '-dtiff')
                        end
                        
                    end
                end
            end
        end
        
        %% Plot RSA
        
        A = {'A1' 'PT' 'V1' 'V2' 'V3' 'V4' 'V5'};
        for ihs=1:NbHS
            for i=0:1
                
                if i==1
                    Rank_trans = 'ranktrans-';
                else
                    Rank_trans = 'raw-';
                end
                
                opt.FigName = sprintf('%s-PCM_{grp}-%s-%s-%s', ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                fig = figure('name', ['Grp_avg_RDM_-' Rank_trans  opt.FigName] ,'Position', opt.FigDim , 'Color', [1 1 1]);
                
                rsa.fig.showRDMs(Grp_RDM_RSA{ihs}, gcf, i, [], 1, [], [], ColorMap);
                
                rename_subplot([3 3],CondNames,A)
                
                mtit(strrep(fig.Name, '_',' '), 'fontsize', 12, 'xoff',0,'yoff',.035)
                
                print(gcf, fullfile(StartDir, 'figures','RSA', 'Cdt', [fig.Name, '.tif'] ), '-dtiff')
                
            end
        end
    end
end