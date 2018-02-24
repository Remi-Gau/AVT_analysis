clc; clear; close all

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;
combine_models = 1; %Pool and recombine results from different model estimation

Add_models_suffix = '-More_models';
Split_suffix = '';
ModelSwitch = [...
    2:7;
    8:10 26:28];

% Plot pred G mat of each model
ModelOrderForPlot = reshape(2:19,3,6);
ModelOrderForPlot = ModelOrderForPlot(:,[1 6 3 4 5 2]);
% ModelOrderForPlot = cat(1,ModelOrderForPlot,reshape(20:37,3,6));

Do_group = 1;

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
        
        for iROI = 1:numel(ROI)
            
            for ihs=1:NbHS
                
                clear M partVec condVec G G_hat COORD RDMs_CV RDMs ...
                    D T_group theta_gr G_pred_gr T_cross theta_cr G_pred_cr
                
                if combine_models
                    ls_extra_files_2_load = dir( fullfile(Save_dir, ...
                        sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s201*.mat', ...
                        Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                        ToPlot{iToPlot}, Split_suffix, Add_models_suffix)));
                    disp(fullfile(Save_dir,ls_extra_files_2_load(end).name))
                    load(fullfile(Save_dir,ls_extra_files_2_load(end).name), ...
                        'M',...
                        'T_group','G_pred_gr',...
                        'T_cross','G_pred_cr' )
                    M1=M;
                    T_group1=T_group;
                    T_cross1=T_cross;
                    G_pred_cr1=G_pred_cr;
                end
                ls_files_2_load = dir( fullfile(Save_dir, ...
                    sprintf('PCM_group_features_%s_%s_%s_%s_%s_201*.mat', Stim_suffix,...
                    Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                    ToPlot{iToPlot})) );
                
                disp(fullfile(Save_dir,ls_files_2_load(end).name))
                load(fullfile(Save_dir,ls_files_2_load(end).name),'M','T_group','G_hat','G_pred_gr','T_cross','G_pred_cr')
                
                for iModel2Switch=1:size(ModelSwitch,2)
                    M{ModelSwitch(2,iModel2Switch)}= M1{ModelSwitch(1,iModel2Switch)};
                    G_pred_cr{ModelSwitch(2,iModel2Switch)}=G_pred_cr1{ModelSwitch(1,iModel2Switch)};
                    T_group.noise(:,ModelSwitch(2,iModel2Switch))=T_group1.noise(:,ModelSwitch(1,iModel2Switch));
                    T_group.scale(:,ModelSwitch(2,iModel2Switch))=T_group1.scale(:,ModelSwitch(1,iModel2Switch));
                    T_group.likelihood(:,ModelSwitch(2,iModel2Switch))=T_group1.likelihood(:,ModelSwitch(1,iModel2Switch));
                end
                
                if 0 %iToPlot==1 && (iROI==1 || iROI==3)
                    fig_h = Plot_PCM_models_feature(M);
                    for iFig = 1:numel(fig_h)
                        print(fig_h(iFig), fullfile(PCM_dir, ...
                            ['Model-' num2str(iFig) '-' strrep(strrep(fig_h(iFig).Name,'w/',''),' ','') '_' ROI(iROI).name '.tif']),...
                            '-dtiff')
                    end
                    clear fig_h
                    close all
                end
                
                c = pcm_indicatorMatrix('allpairs' ,1:size(M{1}.Ac,1));
                %             H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
                H = 1;
                
                colors={'b'};
                for iM=2:numel(M)-1
                    colors{end+1}='b'; %#ok<*SAGROW>
                    M{iM}.name=num2str(iM-1);
                end
                
                opt.SubLs = SubLs;
                opt.FigDim = FigDim;
                
                %% plot group results
                if 1
                m = 3;
                n = 8;
                close all
                
                tmp=mean(G_hat,3);
                tmp2=mean(G_pred_cr{end},3)<0;
                if any(tmp(tmp2)>0)
                    disp(ROI(iROI).name)
                    disp(mean(G_hat,3))
                    disp(mean(G_pred_cr{end},3))
                end
                
                for SameScale=1:2
                    
                    if SameScale==2
                        ScaleSuffix='-SameScale';
                    else
                        ScaleSuffix='';
                    end
                    
                    
                    opt.FigName = sprintf('GMat-Factorial%s-%s-%s-PCM_{grp}-%s-%s-%s', ScaleSuffix,strrep(ROI(iROI).name, '_thresh',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    
                    figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                    
                    tmp = H*mean(G_hat,3)*H';
                    tmp(:,:,end+1) = H*mean(G_pred_cr{end},3)*H';
                    for iM=ModelOrderForPlot(:)'
                        tmp(:,:,end+1) = H*mean(G_pred_cr{iM},3)*H';
                    end
                    CLIM = floor([min(tmp(:)) max(tmp(:))]);
                    
                    % CVed G_{emp}
                    subplot(m,n,1);
                    colormap(ColorMap)
                    imagesc(H*mean(G_hat,3)*H');
                    if SameScale==2
                        imagesc(H*mean(G_hat,3)*H', CLIM);
                    end
                    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                        'ytick', 1:6,'yticklabel', CondNames, ...
                        'ticklength', [0.01 0], 'fontsize', 6)
                    
                    box off
                    axis square
                    t=xlabel('G_{emp}');
                    set(t, 'fontsize', 8);
                    t=ylabel('CV');
                    set(t, 'fontsize', 12);
                    
                    % CVed G_{pred} free model
                    
                    
                    subplot(m,n,17);
                    colormap(ColorMap);
                    imagesc(H*mean(G_pred_cr{end},3)*H');
                    if SameScale==2
                        imagesc(H*mean(G_pred_cr{end},3)*H', CLIM);
                    end
                    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
                        'ytick', 1:6,'yticklabel', CondNames, ...
                        'ticklength', [0.01 0], 'fontsize', 6)
                    
                    box off
                    axis square
                    t=xlabel(sprintf('G_{pred} free\nN.Param.=%i', M{end}.numGparams));
                    set(t, 'fontsize', 8);
                    t=ylabel('CV');
                    set(t, 'fontsize', 12);
                    
                    
                    Subplot = 3;
                    for j = 1:size(ModelOrderForPlot,1)
                        for i = 1:size(ModelOrderForPlot,2)
                            
                            subplot(m,n,Subplot);
                            
                            colormap(ColorMap)
                            try
                                imagesc(H*mean(G_pred_cr{ModelOrderForPlot(j,i)},3)*H');
                                if SameScale==2
                                    imagesc(H*mean(G_pred_cr{ModelOrderForPlot(j,i)},3)*H', CLIM);
                                end
                            catch
                                warning('model %i has an imaginary G_pred_CV', ModelOrderForPlot(j,i))
                                imagesc(H*mean(real(G_pred_cr{ModelOrderForPlot(j,i)}),3)*H');
                            end
                            
                            
                            set(gca,'tickdir', 'out', 'xtick', [],'xticklabel', [], ...
                                'ytick', [],'yticklabel', [], ...
                                'ticklength', [0.01 0], 'fontsize', 6)
                            xlabel([])
                            t=xlabel(sprintf('Model %i\nN.Param.=%i', ...
                                ModelOrderForPlot(j,i), M{ModelOrderForPlot(j,i)}.numGparams));
                            set(t, 'fontsize', 8);
                            
                            box off
                            axis square
                            
                            if j==1
                                title(['Factor 2: level ' num2str(i)])
                            end
                            
                            if i==1
                                ylabel(sprintf('Factor 3: level %i\nFactor 1: level %i', ...
                                    floor(j/4)+1, mod(j,3)))
                            end
                            
                            Subplot = Subplot+1;
                        end
                        Subplot = Subplot+2;
                    end
                    
                    mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                    set(gcf,'visible', visible')
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                    
                end
                
                end
                
                %% Provide a plot of the crossvalidated likelihoods
                if 1
                    close all
                
                opt.FigName = sprintf('Likelihoods-Factorial-%s-%s-PCM_{grp}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                
                Subplot = 1;
                
                for j=1:2
                    
                    if j==2
                        Normalize=1;
                    else
                        Normalize = 0;
                    end
                    
                    for i=1:2
                        
                        if i==1
                            Data2Plot = T_group;
                            Title = 'NoCV';
                        elseif i==2
                            Data2Plot = T_cross;
                            Title = 'CV';
                        elseif i==3
                            Data2Plot = T_group;
                            Title = 'AIC: ln(L_{NoCV})-k';
                            for iM=1:size(Data2Plot.likelihood,2)
                                Data2Plot.likelihood(:,iM)=...
                                    -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                            end
                        end
                        Upperceil = T_group.likelihood(:,end);
                        
                        
                        subplot(2,2,Subplot);
                        colormap(ColorMap)
                        
                        T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                            'normalize',Normalize);
                        tmp = mean(T.likelihood_norm);
                        
                        Likelikehood_norm = tmp(ModelOrderForPlot);
                        
                        if j==1
                            imagesc(Likelikehood_norm)
                        else
                            tmp2 = Likelikehood_norm;
                            tmp2(3,:) = [];
                            %                             tmp2=sort(tmp2(:));
                            imagesc(Likelikehood_norm, [floor(min(tmp2(:))*1000)/1000 1])
                        end
                        
                        set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', ...
                            {'X,1,X';'X,2,X';'X,3,X';'X,4,X';'X,5,X';'X,6,X'}, ...
                            'ytick', 1:6,'yticklabel', ...
                            {'1,X,1';'2,X,1';'3,X,1';'1,X,2';'2,X,2';'3,X,2'}, ...
                            'ticklength', [0.01 0], 'fontsize', 8)
                        
                        colorbar
                        
                        if i==1
                            if j==2
                                t = ylabel('Normalized log-likelihood');
                            else
                                t = ylabel('Log-likelihood');
                            end
                            set(t,'fontsize', 12)
                        end
                        
                        
                        title(sprintf([Title '\nLower noise ceiling: %0.4f'], tmp(end)))
                        
                        
                        Subplot = Subplot+1;
                    end
                end
                
                mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                set(gcf,'visible', visible')
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                end
                
                %% Model Family comparison
                close all;
                lme = T_cross.likelihood(:,2:19);
                family.infer='RFX';
                tmp = repmat(1:6,3,1);
                family.partition=tmp(:)';
                family.names={'fam1','fam2','fam3','fam4','fam5','fam6'};
                [family_col,model_col] = spm_compare_families(lme,family);
                
                family.partition=repmat(1:3,1,6);
                family.names={'fam1','fam2','fam3'};
                [family_row,model_row] = spm_compare_families(lme,family);
                
                tmp = model_row.xp;
                xp_row = tmp(ModelOrderForPlot-1);
                
                tmp = model_col.xp;
                xp_col = tmp(ModelOrderForPlot-1);
                
                xp_col-xp_row
                
                %
                close all
                tmp = [xp_col(:);xp_row(:)];
                
                opt.FigName = sprintf('Model family comparison-%s-%s-PCM_{grp}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', 'on');
                
                colormap(gray)
                
                subplot(2,3,1)
                bar(family_col.xp([1 6 3:5 2]))
                ylabel('Exceedance probability')
                xlabel('Model family')
                set(gca,'ygrid','off','ytick',0:.1:1,'yticklabel',0:.1:1, ...
                    'xtick', 1:6,  'xticklabel',1:6)
                ax=axis;
                axis([0.5 6.5 0 ax(4)])
                grid on
                
                subplot(2,3,4)
                imagesc(xp_col, [min(tmp) max(tmp)])
                axis off
                
                subplot(2,3,5)
                imagesc(xp_row, [min(tmp) max(tmp)])
                axis off
                colorbar

                subplot(2,3,6)
                barh(fliplr(family_row.xp));
                xlabel('Exceedance probability')
                ylabel('Model family')
                
                set(gca,'ygrid','off','xtick',0:.1:1,'xticklabel',0:.1:1, ...
                'ytick', 1:3,  'yticklabel',1:3)
                ax=axis;
                axis([0 ax(2) 0.5 3.5])
                grid on
                
                mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                
                %% Plot of the likelihoods of each subject
                close all
                
                % Color for Subjects
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
                
                opt.FigName = sprintf('Likelihoods-Subjects-%s-%s-PCM_{grp}-%s-%s-%s', strrep(ROI(iROI).name, '_thresh',''), ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', 'on');
                
                Subplot = 1;
                
                for j=1:3
                    
                    if j>1
                        Normalize=1;
                    else
                        Normalize = 0;
                    end
                    
                    for i = 1:2
                        if i==1
                            Data2Plot = T_group;
                            Title = 'NoCV';
                        elseif i==2
                            Data2Plot = T_cross;
                            Title = 'CV';
                        elseif i==3
                            Data2Plot = T_group;
                            Title = 'AIC: ln(L_{NoCV})-k';
                            for iM=1:size(Data2Plot.likelihood,2)
                                Data2Plot.likelihood(:,iM)=...
                                    -1*((M{iM}.numGparams+2) - Data2Plot.likelihood(:,iM)); %-AIC/2
                            end
                        end
                        Upperceil = T_group.likelihood(:,end);
                        
                        
                        subplot(3,2,Subplot);
                        
                        T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                            'normalize',Normalize);
                        Likelikehood_norm = T.likelihood_norm(:,ModelOrderForPlot(:));
                        
                        t=plot(repmat(1:18,10,1)',Likelikehood_norm', 'k');
                        for iLine=1:numel(t)
                            set(t(iLine), 'color', COLOR_Subject(iLine,:))
                        end
                        
                        if i==1
                            if j>1
                                t = ylabel('Normalized log-likelihood');
                            else
                                t = ylabel('Log-likelihood');
                                legend({SubLs.name}')
                            end
                            set(t,'fontsize', 12)
                        end
                        
                        set(gca,'tickdir', 'out', 'xtick', 1:18,'xticklabel', ModelOrderForPlot(:),...
                            'ticklength', [0.01 0], 'fontsize', 8)
                        
                        xlabel('Model number')
                        
                        title(Title)
                        
%                         axis tight
                        ax=axis;
                        axis([0 19 ax(3) ax(4)])
                        if j==3
                            axis([0 19 0.90 1.05])
                        end
                          
                        
                        Subplot=Subplot+1;
                    end
                end
                
                mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                set(gcf,'visible', visible')
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                
            end
        end
    end
end