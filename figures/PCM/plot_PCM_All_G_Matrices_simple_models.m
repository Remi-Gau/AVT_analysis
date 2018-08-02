clc; clear; close all

StartDir = fullfile(pwd, '..', '..', '..');
addpath(genpath(fullfile(StartDir, 'AVT-7T-code','subfun')))

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

for iToPlot = 1:2%:numel(ToPlot)
    
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
                    'A_i','A_c',...
                    'V_i','V_c',...
                    'T_i','T_c'...
                    };
            end
        end
        
        MinMax = [];
        
        for iROI = 1:5 %:numel(ROI)
            
            for ihs=1:NbHS
                
                ls_files_2_load = dir( fullfile(Save_dir, ...
                    sprintf('PCM_group_features_%s_%s_%s_%s_%s_2018_02*.mat', ...
                    Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                    ToPlot{iToPlot})) );
                
                disp(fullfile(Save_dir,ls_files_2_load(end).name))
                load(fullfile(Save_dir,ls_files_2_load(end).name), 'G_pred_cr')
                
                G_pred_cr_free = G_pred_cr{end};
                
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
                
                %% Combine G Matrices
                close all
                FigDim = [50, 50, 700, 700];
                opt.FigDim = FigDim;
                
                G_hat = zeros(6);
                G_free = zeros(6);
                for iComp = 1:3 %numel(M_all)
                    switch iComp
                        case 1
                            CdtToSelect = 1:2;
                        case 2
                            CdtToSelect = 3:4;
                        case 3
                            CdtToSelect = 5:6;
                    end
                    % rotate the matrix so that we have the contra
                    % condition in the top left
                    G_hat(CdtToSelect,CdtToSelect) = rot90(rot90(H*mean(G_hat_all{iComp,1},3)*H'));
                    G_free(CdtToSelect,CdtToSelect)  = rot90(rot90(H*mean(G_pred_cr_all{iComp,1}{end},3)*H'));
                end
                
                % plot pred G mat from each model
                for iModel=1:2
                    
                    Title = strrep(ROI(iROI).name, '_thresh','');
                    switch iModel
                        case 1
                            Title = [Title ' - G_{emp}'];
                            Mat2Plot = G_hat;
                        case 2
                            Title = [Title ' - G_{pred}-free'];
                            Mat2Plot = G_free;
                    end
                    Title = [Title ' - Ipsi VS Contra'];
                    
                    opt.FigName = sprintf('%s-%s-PCM_{grp}-%s-%s-%s', ...
                        strrep(Title, ' ',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    
                    figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                    
                    hold on
                    
                    [ NewColorMap ] = Create_non_centered_diverging_colormap(Mat2Plot, ColorMap);
                    colormap(NewColorMap)
                    
                    MIN = min(Mat2Plot(:));
                    MAX = max(Mat2Plot(:));
                    if MIN>0
                        MIN=0;
                    end
                    if MAX<0
                        MAX=0;
                    end
                    CLIM = [MIN MAX];
                    
                    imagesc(flipud(Mat2Plot), CLIM);
                    
                    colorbar
                    
                    % Add white lines
                    Pos = 2.5;
                    for  i=1:2
                        plot([Pos Pos],[0.52 6.52],'color',[.8 .8 .8],'linewidth', 3)
                        plot([0.52 6.52],[Pos Pos],'color',[.8 .8 .8],'linewidth', 3)
                        Pos = Pos + 2 ;
                    end
                    
                    % add black line contours
                    plot([0.5 0.5],[0.51 6.51],'k','linewidth', 3)
                    plot([6.5 6.5],[0.51 6.51],'k','linewidth', 3)
                    plot([0.51 6.51],[0.5 0.5],'k','linewidth', 3)
                    plot([0.51 6.51],[6.5 6.5],'k','linewidth', 3)
                    
                    axis square
                    axis ([.5 6.5 .5 6.5])
                    
                    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', CondNames([2 1 4 3 6 5]), ...
                        'ytick', 1:6,'yticklabel', CondNames([5 6 3 4 1 2]), ...
                        'ticklength', [0.01 0], 'fontsize', 16, 'xaxislocation', 'top')
                    
                    %                     t = title(Title);
                    %                     set(t, 'fontsize', 16);
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', '2X2', ToPlot{iToPlot}, [opt.FigName '.tif'] ), '-dtiff')
                    
                end
                
                
                
                %% Plot G matrices
                %                 for iComp = 1:numel(M_all)
                %
                %                     switch iComp
                %                         case 1
                %                             CdtToSelect = 1:2;
                %                         case 2
                %                             CdtToSelect = 3:4;
                %                         case 3
                %                             CdtToSelect = 5:6;
                %                         case 4
                %                             CdtToSelect = [1 3];
                %                         case 5
                %                             CdtToSelect = [1 5];
                %                         case 6
                %                             CdtToSelect = [3 5];
                %                         case 7
                %                             CdtToSelect = [2 4];
                %                         case 8
                %                             CdtToSelect = [2 6];
                %                         case 9
                %                             CdtToSelect = [4 6];
                %                     end
                %
                %                     G_hat = G_hat_all{iComp,1};
                %                     G_pred_cr = G_pred_cr_all{iComp,1};
                %                     M = M_all{iComp,1};
                %
                %                     % plot pred G mat from each model
                %                     for iModel=[1 5 2:4]
                %
                %                         Title = strrep(ROI(iROI).name, '_thresh','');
                %
                %                         switch iModel
                %                             case 1
                %                                 Title = [Title ' - G_{emp}'];
                %                             case 5
                %                                 Title = [Title ' - G_{pred}-free'];
                %                             otherwise
                %                                 Title = [Title ' - ' M{iModel}.name];
                %                         end
                %
                %                         Title = [Title ' - ' CondNames{CdtToSelect(1)} ' VS ' CondNames{CdtToSelect(2)}];
                %
                %
                %                         opt.FigName = sprintf('%s-%s-PCM_{grp}-%s-%s-%s', ...
                %                             strrep(Title, ' ',''), ...
                %                             hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                %
                %                         figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                %
                %
                %                         if iModel==1
                %                             Mat2Plot = H*mean(G_hat,3)*H';
                %                         else
                %                             Mat2Plot = H*mean(G_pred_cr{iModel},3)*H';
                %                         end
                %
                %                         [ NewColorMap ] = Create_non_centered_diverging_colormap(Mat2Plot, ColorMap);
                %
                %                         colormap(NewColorMap)
                %
                %                         MIN = min(Mat2Plot(:));
                %                         MAX = max(Mat2Plot(:));
                %                         if MIN>0
                %                             MIN=0;
                %                         end
                %                         if MAX<0
                %                             MAX=0;
                %                         end
                %                         CLIM = [MIN MAX];
                %
                %                         imagesc(Mat2Plot, CLIM);
                %
                %                         %                         try
                %                         %                             imagesc(Mat2Plot);
                %                         %                         catch
                %                         %                             warning('model %i has an imaginary G_pred_CV', iModel)
                %                         %                             imagesc(H*mean(real(G_pred_cr{iModel}),3)*H');
                %                         %                         end
                %                         colorbar
                %
                %                         set(gca,'tickdir', 'out', 'xtick', 1:2,'xticklabel', [], ...
                %                             'ytick', 1:2,'yticklabel', {CondNames{CdtToSelect}}, ...
                %                             'ticklength', [0.01 0], 'fontsize', 16)
                %
                %
                %                         t = title(Title);
                %                         set(t, 'fontsize', 16);
                %
                %                         print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                %
                %                     end
                %
                %                 end
                
                
                %% Recombine variances of the same condition coming from the free models of different comparison
                %                 close all
                %
                %                 FigDim = [50, 50, 1400, 750];
                %                 [ color_map ] = brain_colour_maps('hot_increasing');
                %
                %                 switch iROI
                %                     case 1
                %                         CLIM = [0 .02];
                %                     case 2
                %                         CLIM = [0 .035];
                %                     case 3
                %                         CLIM = [0 .006];
                %                     case 4
                %                         CLIM = [0 .009];
                %                     case 5
                %                         CLIM = [0 .01];
                %                 end
                %
                %                 Comp_name{1} = 'Ai vs Ac';
                %                 Comp_name{end+1} = 'Vi vs Vc';
                %                 Comp_name{end+1} = 'Ti vs Tc';
                %                 Comp_name{end+1} = 'Ai vs Vi';
                %                 Comp_name{end+1} = 'Ai vs Ti';
                %                 Comp_name{end+1} = 'Vi vs Ti';
                %                 Comp_name{end+1} = 'Ac vs Vc';
                %                 Comp_name{end+1} = 'Ac vs Tc';
                %                 Comp_name{end+1} = 'Vc vs Tc';
                %
                %
                %                 opt.FigName = sprintf('%s-PCM_{grp}-Variances-of-Free-Models', ...
                %                     strrep(strrep(ROI(iROI).name, '_thresh',''), ' ',''));
                %
                %                 figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                %
                %
                %                 colormap(color_map);
                %
                %                 iSubplot = 1;
                %
                %                 for iCdt = 1:numel(CondNames)
                %
                %                     % For exah condition we identify in which comparison it
                %                     % is involve and if it is the first or the second
                %                     % condition
                %                     switch iCdt
                %                         case 1
                %                             Comp2Sel = [1 4 5];
                %                             Val2Sel = [1 1 1];
                %                         case 2
                %                             Comp2Sel = [1 7 8];
                %                             Val2Sel = [2 1 1];
                %                         case 3
                %                             Comp2Sel = [2 4 6];
                %                             Val2Sel = [1 2 1];
                %                         case 4
                %                             Comp2Sel = [2 7 9];
                %                             Val2Sel = [2 2 1];
                %                         case 5
                %                             Comp2Sel = [3 5 6];
                %                             Val2Sel = [1 2 2];
                %                         case 6
                %                             Comp2Sel = [3 8 9];
                %                             Val2Sel = [2 2 2];
                %                     end
                %
                %                     Mat2Plot = [];
                %                     for iComp=1:numel(Comp2Sel)
                %                         G_pred_cr = G_pred_cr_all{Comp2Sel(iComp),1};
                %                         G_pred_free = G_pred_cr{5};% only take the cross validated G matrix of the Free model
                %                         Mat2Plot(iComp,:) = G_pred_free(Val2Sel(iComp),Val2Sel(iComp),:);
                %                     end
                %
                %                     Mat2Plot(end+1,:) = G_pred_cr_free(iCdt,iCdt,:);
                %
                %                     %                     Mat2Plot = [mean(Mat2Plot,2) Mat2Plot];
                %                     MinMax(end+1,:) = [min(Mat2Plot(:)) max(Mat2Plot(:))];
                %
                %                     subplot(3,2,iSubplot)
                %                     imagesc(Mat2Plot, CLIM)
                %
                %                     for i=1:size(Mat2Plot,1)
                %                         for j=1:size(Mat2Plot,2)
                %                             t=text(j-.4,i,sprintf('%.4f', Mat2Plot(i,j)));
                %                             set(t, 'fontsize', 8, 'color', [0.5 0.5 0.5]);
                %                         end
                %                     end
                %
                %                     XTickLabel = cell2mat({SubLs(:).name}');
                %                     XTickLabel = XTickLabel(:,end-1:end);
                %                     XTickLabel = mat2cell(XTickLabel,ones(10,1),2);
                %
                %                     title(CondNames(iCdt))
                %
                %                     YTickLabel = Comp_name(Comp2Sel);
                %                     YTickLabel{end+1} = '6X6';
                %
                %                     set(gca,'tickdir', 'out', 'xtick', 1:11,'xticklabel', XTickLabel, ...
                %                         'ytick', 1:4,'yticklabel', YTickLabel, ...
                %                         'ticklength', [0.01 0], 'fontsize', 12)
                %
                %                     iSubplot = iSubplot + 1;
                %
                %                 end
                %
                %                 mtit(opt.FigName, 'fontsize', 12, 'xoff',0,'yoff',.035)
                %
                %                 print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                %
                
            end
        end
    end
end
