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

StartDir = fullfile(pwd, '..','..','..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

surf = 0; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);


if surf
    %     ToPlot={'Cst','Lin','Quad'};
    ToPlot={'Cst'};
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
FigDim = [100, 100, 1000, 1500];

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

load(fullfile(StartDir, 'RunsPerSes.mat'))
for iSub = 1:NbSub
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    
    load(fullfile(Sub_dir, 'ffx_nat', 'SPM.mat'))
    Nb_sess(iSub) = numel(SPM.Sess); %#ok<*SAGROW>
    clear SPM
    
    % Which session belings to which day (for day based CV)
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    tmp = RunPerSes(Idx).RunsPerSes;
    DayCVs{iSub} = {...
        1:tmp(1), ...
        tmp(1)+1:tmp(1)+tmp(2),...
        tmp(1)+tmp(2)+1:sum(tmp)};
    clear Idx
    
end


for iToPlot = 1:numel(ToPlot)
    
    for Target = 1
        
        if Target==2
            Stim_suffix = 'targ';
            CondNames = {...
                'A Targ L','A Targ R',...
                'V Targ L','V Targ R',...
                'T Targ L','T Targ R',...
                };
        else
            Stim_suffix = 'stim';
            CondNames = {...
                'A Stim L','A Stim R',...
                'V Stim L','V Stim R',...
                'T Stim L','T Stim R',...
                };
            %             CondNames = {...
            %                 'A ipsi','A contra',...
            %                 'V ipsi','V contra',...
            %                 'T ipsi','T contra'...
            %                 };
        end
        
        for iROI = 1:numel(ROI)
            
            clear M partVec condVec G G_hat COORD RDMs_CV RDMs T_ind theta_ind G_pred_ind...
                D T_ind_cross theta_ind_cross T_group theta_gr G_pred_gr T_cross theta_cr G_pred_cr
            
            ls_files_2_load = dir( fullfile(Save_dir, sprintf('PCM_features_%s_%s_%s_%s_*.mat', Stim_suffix, Beta_suffix, ROI(iROI).name, ...
                ToPlot{iToPlot})) );
            
            disp(fullfile(Save_dir,ls_files_2_load(end).name))
            
            load(fullfile(Save_dir,ls_files_2_load(end).name))
            
            NbHS = numel(T_ind);
            
            if NbHS==2
                hs_suffix = {'LHS' 'RHS'};
            else
                hs_suffix = {''};
            end
            
            Models_to_keep = 1:numel(M);
            ToRemove = [14:18 20:24]+1;
            Models_to_keep(ToRemove) = [];
             
            M(ToRemove)= [];
            
            for ihs=1:NbHS
                G_pred_cr{ihs}(ToRemove) = [];
                G_pred_gr{ihs}(ToRemove) = [];
                G_pred_ind{ihs}(ToRemove) = [];
                
                
                theta_ind{ihs}(ToRemove) = [];
                theta_ind_cross{ihs}(ToRemove) = [];
                theta_gr{ihs}(ToRemove) = [];
                theta_cr{ihs}(ToRemove) = [];
                
                D{ihs}.noise(:,ToRemove)=[];
                D{ihs}.likelihood(:,ToRemove)=[];
                
                
                T_ind{ihs}.iterations(:,ToRemove)=[];
                T_ind{ihs}.likelihood(:,ToRemove)=[];
                T_ind{ihs}.noise(:,ToRemove)=[];
                T_ind{ihs}.time(:,ToRemove)=[];
                T_ind{ihs}.reg(:,ToRemove)=[];
                
                T_ind_cross{ihs}.noise(:,ToRemove)=[];
                T_ind_cross{ihs}.iterations(:,ToRemove)=[];
                T_ind_cross{ihs}.likelihood(:,ToRemove)=[];
                T_ind_cross{ihs}.time(:,ToRemove)=[];
                
                T_group{ihs}.iterations(:,ToRemove)=[];
                T_group{ihs}.time(:,ToRemove)=[];
                T_group{ihs}.method(ToRemove)=[];
                T_group{ihs}.noise(:,ToRemove)=[];
                T_group{ihs}.scale(:,ToRemove)=[];
                T_group{ihs}.likelihood(:,ToRemove)=[];
                T_group{ihs}.reg(:,ToRemove)=[];
                
                T_cross{ihs}.iterations(:,ToRemove)=[];
                T_cross{ihs}.time(:,ToRemove)=[];
                T_cross{ihs}.fitLike(:,ToRemove)=[];
                T_cross{ihs}.likelihood(:,ToRemove)=[];
                T_cross{ihs}.noise(:,ToRemove)=[];
                T_cross{ihs}.scale(:,ToRemove)=[];
                T_cross{ihs}.reg(:,ToRemove)=[];
                
            end
            
            
            
            % generate the predicted matrices for ind CV
            for ihs=1:NbHS
                for iM = 1:numel(M)
                    for iSub = 1:NbSub
                        tmp = mean(theta_ind_cross{ihs}{iM}(T_ind_cross{ihs}.SN==iSub,:),1);
                        G_pred_ind_CV{ihs}{1,iM}(:,:,iSub) = pcm_calculateG(M{iM},tmp(1:M{iM}.numGparams)');
                        clear tmp
                    end
                end
            end
            
            c = pcm_indicatorMatrix('allpairs' ,1:size(M{1}.Ac,1));
            %             H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
            H = 1;
            
            
            %% Plot models
%             M{1}.name = 'null';
            colors={'b'};
            for iM=2:numel(M)-1
                colors{end+1}='b'; %#ok<*SAGROW>
                M{iM}.name=['Model-' num2str(iM-1) '-' strrep(strrep(M{iM}.name,'w/',''), ' ','')];
            end
            
            if iROI==1
                fig_h = Plot_PCM_models_feature(M);
                
                for iFig = 1:numel(fig_h)
                    print(fig_h(iFig), fullfile(PCM_dir, [fig_h(iFig).Name '.tif']), '-dtiff')
                end
            end
            
            for iM=2:numel(M)-1
                colors{end+1}='b'; %#ok<*SAGROW>
                M{iM}.name=num2str(iM-1);
            end
            
            
            %% compare RSA results
            for ihs=1:NbHS
                for iSub=1:NbSub
                    fprintf('\n  Difference for %s in %s %s\n', SubLs(iSub).name, ROI(iROI).name, hs_suffix{ihs})
                    
                    RDM_PCM = squareform(diag(c*G_hat(:,:,iSub,ihs)*c'))
                    RDM_RSA = RDMs_CV(:,:,iSub,ihs)
                    
                    RDM_RSA-RDM_PCM
                    
                    RDM_PCM_rk = rsa.util.rankTransform_equalsStayEqual(RDM_PCM,1);
                    RDM_RSA_rk = rsa.util.rankTransform_equalsStayEqual(RDM_RSA,1);
                    
                    RDM_RSA_rk-RDM_PCM_rk
                    
                end
                
                Grp_RDM_RSA{ihs}(:,:,iROI)=mean(RDMs_CV(:,:,:,ihs),3);
            end
            
            %% Plot results from individual fits
            close all
            
            opt.SubLs = SubLs;
            opt.scatter = linspace(0,0.2,numel(T_ind{ihs}.SN));
            opt.colors = colors;
            opt.FigDim = FigDim;
            
            for ihs=1:NbHS
                
                opt.FigName = sprintf('%s-%s-PCM_{ind}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                close all
                
%                                 fig_h = plot_PCM_ind(M, squeeze(G(:,:,:,ihs)), squeeze(G_hat(:,:,:,ihs)), ...
%                                     T_ind{ihs}, D{ihs}, T_ind_cross{ihs}, theta_ind{ihs}, theta_ind_cross{ihs},...
%                                     G_pred_ind{ihs}, G_pred_ind_CV{ihs}, squeeze(RDMs(:,:,:,ihs)), squeeze(RDMs_CV(:,:,:,ihs)), ...
%                                     opt);
%                 
%                                 for iFig = 1:numel(fig_h)
%                                     print(fig_h(iFig), fullfile(PCM_dir, 'Cdt', [fig_h(iFig).Name '.tif']), '-dtiff')
%                                 end
                
            end
            
            
            %% plot group results
            close all
            
            for ihs=1:NbHS
                
                clear RDM
                
                fprintf('\n  CV effect in %s %s\n', ROI(iROI).name, hs_suffix{ihs})
                disp(T_group{ihs}.likelihood-T_cross{ihs}.likelihood)
                
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
                    
                    tmp = H*mean(G_hat(:,:,:,ihs),3)*H';
                    tmp(:,:,end+1) = H*mean(G(:,:,:,ihs),3)*H';
                    for iM=1:numel(M)
                        tmp(:,:,end+1) =H*mean(G_pred_cr{ihs}{iM},3)*H';
                        tmp(:,:,end+1) =H*G_pred_gr{ihs}{iM}*H';
                    end
                    CLIM = floor([min(tmp(:)) max(tmp(:))]);
                    
                    
                    
                    Subplot = HorPan*2+1;
                    % G_{emp}
                    subplot(6,HorPan,Subplot:Subplot+1);
                    colormap(ColorMap)
                    if IndGrpColor==1
                        imagesc(log10(H*mean(G_hat(:,:,:,ihs),3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                    else
                        imagesc(H*mean(G_hat(:,:,:,ihs),3)*H');
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
                        imagesc(log10(H*mean(G_pred_cr{ihs}{end},3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                    else
                        imagesc(H*mean(G_pred_cr{ihs}{end},3)*H');
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
                            imagesc(log10(H*mean(G_pred_cr{ihs}{iM},3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                        else
                            imagesc(H*mean(G_pred_cr{ihs}{iM},3)*H');
                        end
                        if IndGrpColor==2
                            colorbar
                        end
                        box off
                        axis square
                        set(gca,'xtick', [],'ytick', [])
                        t=xlabel(['G_{pred} ' num2str(M{iM}.name)]);
                        set(t, 'fontsize', 9);
                        
                        Subplot = Subplot+2;
                    end
                    
                    
                    
                    
                    Subplot = HorPan*4+1;
                    % RDM or MDS or non CV G
                    subplot(6,HorPan,Subplot:Subplot+1);
                    
                    colormap(ColorMap);
                    if IndGrpColor==1
                        imagesc(log10(H*mean(G(:,:,:,ihs),3)*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                    else
                        imagesc(H*mean(G(:,:,:,ihs),3)*H');
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
                        imagesc(log10(H*G_pred_gr{ihs}{end}*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                    else
                        imagesc(H*G_pred_gr{ihs}{end}*H');
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
                            imagesc(log10(H*G_pred_gr{ihs}{iM}*H'-CLIM(1)),log10(CLIM-CLIM(1)));
                        else
                            imagesc(H*G_pred_gr{ihs}{iM}*H');
                        end
                        
                        set(gca,'xtick', [],'ytick', [])
                        if IndGrpColor==2
                            colorbar
                        end
                        box off
                        axis square
                        
                        
                        t=xlabel(['G_{pred} ' num2str(M{iM}.name)]);
                        set(t, 'fontsize', 9);
                        
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
                            Data2Plot = T_group{ihs};
                            SubPlotRange = [1:floor(HorPan/3) (HorPan+1):(HorPan+(floor(HorPan/3)))];
                            Title = 'NoCV';
                            Upperceil = Data2Plot.likelihood(:,end);
                        elseif i==2
                            Data2Plot = T_cross{ihs};
                            SubPlotRange = [floor(HorPan/3+1):2*floor(HorPan/3) HorPan+(floor(HorPan/3+1):2*floor(HorPan/3))];
                            Title = 'CV';
                            Upperceil = T_group{ihs}.likelihood(:,end);
                        elseif i==3 %
                            Data2Plot = T_group{ihs};
                            SubPlotRange = [2*floor(HorPan/3+1):3*floor(HorPan/3) HorPan+(2*floor(HorPan/3+1):3*floor(HorPan/3))];
                            Title = 'AIC: ln(L_{NoCV})-k';
                            for iM=1:size(Data2Plot.likelihood,2)
                                Data2Plot.likelihood(:,iM)=...
                                    -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                            end
                            Upperceil = T_group{ihs}.likelihood(:,end);
                        end
                        
                        subplot(6,HorPan,SubPlotRange);
                        hold on
                        
                        T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                            'normalize',0);
                        
                        
                        % print subjects
                        binWidth = max(max(T.likelihood_norm(:,2:end-1))-min(T.likelihood_norm(:,2:end-1)));
                        
                        for iM=2:numel(M)-1
                            h = plotSpread(T.likelihood_norm(:,iM), 'distributionIdx', ones(size(T.likelihood_norm(:,iM))), ...
                                'distributionMarkers',{'o'},'distributionColors',{'w'}, ...
                                'xValues', iM-0.8, 'binWidth', binWidth/100, 'spreadWidth', .2);
                            set(h{1}, 'MarkerSize', 5, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)
                            labels{iM-1} = M{iM}.name;
                        end
                        
                        MIN = min(min(T.likelihood_norm(:,2:end-1)));
                        MAX = max(max(T.likelihood_norm(:,2:end-1)));
                        
                        ax=axis;
                        %                         MIN = ceil(abs(MIN));
                        if MIN>0
                            MIN=0;
                        end
                        
                        axis([ax(1) ax(2) MIN MAX])
                        
                        set(gca,'XTick',1:numel(M)-2, 'XTickLabel',labels);
                        
                        
                        if i==1
                            ylabel('Log-likelihood');
                            set(gca,'fontsize', 8)
                        else
                            set(gca,'yaxislocation', 'right')
                        end
                        
                        title(Title)
                    end
                    
                    mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName SameClim '.tif'] ), '-dtiff')
                    
                end
                
                
                
                %% Plot only the best models
                close all
                
                fig = figure('name', ['Best-models-' opt.FigName], 'Position', FigDim, 'Color', [1 1 1]);
                
                Data2Plot = T_group{ihs};
                for iM=1:size(Data2Plot.likelihood,2)
                    Data2Plot.likelihood(:,iM)=...
                        -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                end
                T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',T_group{ihs}.likelihood(:,end), 'colors', colors, ...
                        'normalize',0);
                
                [~,I] = sort(mean(T.likelihood_norm(:,1:end-1)),'ascend');
                NULL = I(5);
                I(1:5)=[];

                % Provide a plot of the crossvalidated likelihoods
                for i=1:3
                    
                    if i==1
                        Data2Plot = T_group{ihs};

                        Title = 'NoCV';
                        
                    elseif i==2
                        Data2Plot = T_cross{ihs};
                        
                        Title = 'CV';
                        
                    elseif i==3 %
                        
                        Data2Plot = T_group{ihs};
                        
                        Title = 'AIC: ln(L_{NoCV})-k';
                        for iM=1:size(Data2Plot.likelihood,2)
                            Data2Plot.likelihood(:,iM)=...
                                -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                        end

                        
                    end

                    subplot(1,3,i);
                    Upperceil = T_group{ihs}.likelihood(:,end);
                    T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                        'normalize', 0, 'style', 'dot', 'mindx', I, 'Nnull', NULL, 'Nceil', numel(M));

                    title(Title)
                    
%                     MIN = min(mean(T.likelihood_norm(:,I))-nansem(T.likelihood_norm(:,I)));
                    MIN = min(mean(T.likelihood_norm(:,I)));
                    
%                     MAX = mean(Upperceil-T_group{ihs}.likelihood(:,1));
                    
                    ax=axis;
                    
%                     if MIN>0
%                         MIN=0;
%                     end
                    
                    axis([ax(1) ax(2) MIN ax(4)])
                    
                    set(gca,'fontsize', 8)
                end
                
                mtit(fig.Name, 'fontsize', 12, 'xoff',0,'yoff',.035)
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif']  ), '-dtiff')
                
                %% Plot each model results at the group level
                %                 NbSubj = numel(T.SN);
                %                 close all
                %
                %                 for iM=2:numel(M)-1
                %
                %                     fig = figure('name', ['Model-' M{iM}.name  '--'  opt.FigName] ,'Position', opt.FigDim , 'Color', [1 1 1]);
                %
                %                     % G matrix
                %                     subplot(3,2,1);
                %                     colormap(ColorMap);
                %                     imagesc(H*mean(G_hat(:,:,:,ihs),3)*H');
                %
                %                     axis on
                %                     set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                %                         'ytick', 1:6,'yticklabel', CondNames, ...
                %                         'ticklength', [0.01 0], 'fontsize', 4)
                %                     box off
                %                     axis square
                %                     colorbar
                %
                %                     t=title('group G_{emp-CV}');
                %                     set(t, 'fontsize', 10);
                %
                %
                %                     % G matrix
                %                     subplot(3,2,2);
                %                     colormap(ColorMap);
                %                     imagesc(H*mean(G_pred_cr{ihs}{iM},3)*H');
                %
                %                     axis on
                %                     set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                %                         'ytick', 1:6,'yticklabel', CondNames, ...
                %                         'ticklength', [0.01 0], 'fontsize', 4)
                %                     box off
                %                     axis square
                %                     colorbar
                %
                %                     t=title('group G_{pred-CV}');
                %                     set(t, 'fontsize', 10);
                %
                %
                %
                %                     subplot(3,2,4:6);
                %                     hold on
                %
                %                     Val2Plot = 1:M{iM}.numGparams;
                %                     MEAN = mean(theta_cr{ihs}{iM}(Val2Plot,:),2);
                %                     SEM = nansem(theta_cr{ihs}{iM}(Val2Plot,:),2);
                %
                %                     t = errorbar(Val2Plot-.1, MEAN, SEM, ' .k');
                %                     set(t,'MarkerSize', 10)
                %
                %                     for iVal=Val2Plot
                %                         for iSub=1:NbSub
                %                             plot(iVal+.1+opt.scatter(iSub), theta_cr{ihs}{iM}(iVal,iSub), 'linestyle', 'none', ...
                %                                 'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(iSub,:), ...
                %                                 'MarkerFaceColor', COLOR_Subject(iSub,:), 'MarkerSize', 28)
                %                         end
                %                     end
                %
                %                     plot([0.5 M{iM}.numGparams+.5],[0 0],'-- k')
                %
                %                     axis tight
                %                     grid on
                %                     set(gca, 'Xtick', 1:M{iM}.numGparams, 'Xticklabel', 1:M{iM}.numGparams)
                %
                %                     xlabel('Features')
                %
                %                     mtit(strrep(fig.Name, '_',' '), 'fontsize', 12, 'xoff',0,'yoff',.035)
                %
                %                     print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif'] ), '-dtiff')
                %                 end
                %
            end
            
        end
        
        %% Plot RSA
        
        A = {'A1' 'PT' 'V1' 'V2' 'V3' 'V4' 'V5'};
        
        for i=0:1
            
            if i==1
                Rank_trans = 'ranktrans-';
            else
                Rank_trans = 'raw-';
            end
            
            for ihs=1:NbHS
                
                opt.FigName = sprintf('%s-PCM_{grp}-%s-%s-%s', ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                fig = figure('name', ['Grp_avg_RDM_-' Rank_trans  opt.FigName] ,'Position', opt.FigDim , 'Color', [1 1 1]);
                
                rsa.fig.showRDMs(Grp_RDM_RSA{ihs}, gcf, i, [], 1, [], [], ColorMap);
                
                rename_subplot([3 3],CondNames,A)
                
                mtit(strrep(fig.Name, '_',' '), 'fontsize', 12, 'xoff',0,'yoff',.035)
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif'] ), '-dtiff')
                
            end
            
        end
        
    end
end