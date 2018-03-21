function Plot_PCM_simple_models_likelihoods

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

Comp_label{1} = 'Ai/Ac';
Comp_label{end+1} = 'Vi/Vc';
Comp_label{end+1} = 'Ti/Tc';
Comp_label{end+1} = 'Ai Vi';
Comp_label{end+1} = 'Ai Ti';
Comp_label{end+1} = 'Vi Ti';
Comp_label{end+1} = 'Ac Vc';
Comp_label{end+1} = 'Ac Tc';
Comp_label{end+1} = 'Vc Tc';

UpperTri=1;
Switch=0;
surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;
Split_half = 0; % only implemented for surface
on_merged_ROI = 0;
% RFX = 1;
%
% if RFX==1
%     RFX_suffix = 'RFX1';
% else
%     RFX_suffix = 'RFX2';
% end

if on_merged_ROI
    NbROI = 1;
else
    NbROI = 5;
end

if UpperTri
    UpTriSuffix = 'uptri';
else
    UpTriSuffix = '';
end

if Switch
    SwitchSuffix = 'switched';
    %   Ac Vc Tc Ai Vi Ti
    PositionToFill = [3 8 12 13 14 15 1 2 6];
    ConditionOrder = [2:2:6 1:2:6];
else
    SwitchSuffix = '';
    %     Ai Ac Vi Vc Ti Tc
    %         PositionToFill = [1 10 15 2 4 11 7 9 14];
    %         ConditionOrder = 1:6;
    
    %     Ac Ai Vc Vi Tc Ti
    PositionToFill = [1 10 15 7 9 14 2 4 11];
    ConditionOrder = [2 1 4 3 6 5];
end

if Split_half==1
    NbSplits=2;
else
    NbSplits=1;
end

if Split_half
else
    Split_suffix = '';
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
    ROI(1).name ='V2V3';
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

ColorMap = [
    0 0 0;...
    1 0 0;...
    0 1 0;...
    0 0 1];
ColorMap(5+1,1:3) = [1 1 0];
ColorMap(10+1,1:3) = [1 0 1];
ColorMap(13+1,1:3) = [0 1 1];

ColorMap(all(ColorMap==0,2),:)=repmat([1 1 1],sum(all(ColorMap==0,2)),1);

ColorMap(14+1,1:3) = [0 0 0];


for iToPlot = 2 %[1 3:numel(ToPlot)]
    
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
                if Switch
                    CondNames = {...
                        'A','A',...
                        'V','V',...
                        'T','T'...
                        };
                end
            end
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
                    
                    M_all{iComp,1} = M;
                    T_group_all{iComp,1} = T_group;
                    G_all{iComp,1} = G;
                    G_hat_all{iComp,1} = G_hat;
                    G_pred_gr_all{iComp,1} = G_pred_gr;
                    T_cross_all{iComp,1} = T_cross;
                    G_pred_cr_all{iComp,1} =  G_pred_cr;
                    
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
                    
                    Likelihood_norm{iROI,ihs}(:,:,iComp) = T.likelihood_norm;
                    Likelihood{iROI,ihs}(:,:,iComp) = T.likelihood;
                    
                end
            end
        end
        
        close all
        
        for iROI = 1:NbROI
            
            
            %% FFX
            opt.FigName = sprintf('BestModel-FFX-3Models-%s-%s-PCM_{grp}-%s-%s-%s-%s-%s', ...
                ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot},...
                UpTriSuffix, SwitchSuffix);
            
            figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
            
            Data2Plot = zeros(15,1);
            for iComp = 1:numel(M_all)
                
                loglike_norm = mean(Likelihood_norm{iROI,ihs}(:,2:end-1,iComp));
                
                % check which is best model
                [~,idx] = sort(loglike_norm);
                
                % if best model superior to second best by more than 3
                if loglike_norm(idx(end-1))+3<loglike_norm(idx(end))
                    Data2Plot(PositionToFill(iComp)) = idx(end);
                    % otherwise we check if second best is better than the last
                elseif loglike_norm(idx(end-2))+3<loglike_norm(idx(end-1))
                    Data2Plot(PositionToFill(iComp)) = idx(end)^2+idx(end-1)^2;
                else
                    Data2Plot(PositionToFill(iComp)) = idx(end)^2+idx(end-1)^2+idx(end-2)^2;
                end
                
            end
            
            Img2Plot = squareform(Data2Plot);
            if UpperTri
                Img2Plot = triu(Img2Plot);
            end
            
            for i=1
                
                tmp = Img2Plot;
                
                if Switch==1
                    suffix = '';
                else
                    switch i
                        case 1
                            suffix = '';
                        case 2
                            suffix = '-CvsI';
                            tmp(1:2,3:6) = 0;
                            tmp(3:4,5:6) = 0;
                        case 3
                            suffix = '-C';
                            tmp(1,2) = 0;
                            tmp(3,4) = 0;
                            tmp(5,6) = 0;
                            tmp(2,3:6) = 0;
                            tmp(4,5:6) = 0;
                        case 4
                            suffix = '-I';
                            tmp(5,6) = 0;
                            tmp(1,2:6) = 0;
                            tmp(3,4:6) = 0;
                    end
                end
                
                clf
                
                TmpColorMap = ColorMap;
                TmpColorMap((max(tmp(:))+2):end,:)=[];
                colormap(TmpColorMap)
                
                imagesc(tmp)
                
                % Add white lines
                Add_lines_frame(UpperTri,Switch)
                
                axis square
                box off
                
                Label_axis(UpperTri,CondNames(ConditionOrder))

                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName suffix '.tif'] ), '-dtiff')
                %             print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName, '.svg']  ), '-dsvg')
                
            end
            
            
            
            %% RFX: perform bayesian model selection
            % Compute exceedance probabilities
            Data2Plot = zeros(15,3);
            for iComp = 1:numel(M_all)
                
                loglike = Likelihood{iROI,ihs}(:,2:end-1,iComp);
                
                % compare the 3 models together
                [~,~,~,pxp3,~] = spm_BMS(loglike);
                All_pxp(iComp,:) = pxp3;
                clear pxp3
                
                % compares model 1 and 3 (S Vs I) and then compares the winner to S+I
                [~,~,~,pxp(iComp,:,1),~] = spm_BMS(loglike(:,[1 3]));
                [~,~,~,pxp(iComp,:,2),~] = spm_BMS(loglike(:,[1 2]));
                [~,~,~,pxp(iComp,:,3),~] = spm_BMS(loglike(:,[2 3]));
                if pxp(iComp,1,1)>pxp(iComp,2,1)
                    Data2Plot(PositionToFill(iComp),[1 2]) = pxp(iComp,:,2);
                    Data2Plot(PositionToFill(iComp),3) = eps;
                else
                    Data2Plot(PositionToFill(iComp),[2 3]) = pxp(iComp,:,3);
                    Data2Plot(PositionToFill(iComp),1) = eps;
                end
                Data2Plot2(PositionToFill(iComp),:) = [pxp(iComp,1,1) pxp(iComp,2,2) pxp(iComp,2,3)];
                
            end
            
            
            %% plot the 3 models compared all together
            opt.FigName = sprintf('BestModel-RFX1-3Models-%s-%s-PCM_{grp}-%s-%s-%s-%s-%s', ...
                ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot},...
                UpTriSuffix, SwitchSuffix);
            
            figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
            
            [h,hg,htick]=terplot;
            hter=ternaryc(All_pxp(:,1),All_pxp(:,2),All_pxp(:,3));
            hlabels=terlabel('S','S+I','I');
            
            set(hter(1:3), 'color', 'k', 'MarkerFaceColor', 'k')
            set(hter(4:6), 'color', 'r', 'MarkerFaceColor', 'r')
            
            set(hter(1:3:9), 'marker', 'o')
            set(hter(2:3:9), 'marker', 'square')
            
            set(hter(:), 'MarkerSize', 12)
            
            p=mtit([ROI(iROI).name ' - ' ToPlot{iToPlot}],...
                'fontsize',14,...
                'xoff',0,'yoff',.025);
            
            print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName suffix '_ternary_plot.tif'] ), '-dtiff')
            
            
            %% plot the 3 models compared by pair
            opt.FigName = sprintf('BestModel-RFX2-3Models-%s-%s-PCM_{grp}-%s-%s-%s-%s-%s', ...
                ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot},...
                UpTriSuffix, SwitchSuffix);
            
            figure('name', opt.FigName, 'Position', [50, 50, 1200, 600], 'Color', [1 1 1]);
            
            
            subplot(1,2,1)
            hold on
            % plot probability of Scaled when doing Scaled VS Scaled+Independent
            plot(1:9,pxp(:,1,2),'r', 'linewidth', 2)
            % plot probability of Scaled+Independent when doing Scaled+Independent VS Independent
            plot(1:9,pxp(:,1,3),'g', 'linewidth', 2)
            % plot probability of Scaled when doing Scaled VS Independent
            plot(1:9,pxp(:,1,1),'k', 'linewidth', 2)            
            
            plot([1 9], [.5 .5], '--k')
            
            set(gca,'tickdir', 'out', 'xtick', 1:9,'xticklabel', Comp_label, ...
                'ytick', 0:.1:1,'yticklabel', 0:.1:1, ...
                'ticklength', [0.01 0.001], 'fontsize', 8)
           
            axis([.5 9.5 0 1])
            
            legend({'p(S_{S vs S+I})','p(S+I_{S+I vs I})','p(S_{S vs I})'},...
                'Location','NorthOutside')
            
            % plot color scaled of the probability of the second step of the RFX
            subplot(1,2,2)
            
            L1 = squareform(Data2Plot(:,1));
            L2 = squareform(Data2Plot(:,2));
            L3 = squareform(Data2Plot(:,3));
            
            if UpperTri
                L1 = triu(L1);
                L2 = triu(L2);
                L3 = triu(L3);
            end
            
            Img2Plot = cat(3,L1,L2,L3);
            
            if UpperTri
                Img2Plot(Img2Plot==0)=1;
            end
            
            
            for i=1
                
                tmp = Img2Plot;
                
                if Switch==1
                    suffix = '';
                else
                    switch i
                        case 1
                            suffix = '';
                        case 2
                            suffix = '-CvsI';
                            tmp(1:2,3:6,:) = 1;
                            tmp(3:4,5:6,:) = 1;
                        case 3
                            suffix = '-C';
                            tmp(1,2,:) = 1;
                            tmp(3,4,:) = 1;
                            tmp(5,6,:) = 1;
                            tmp(2,3:6,:) = 1;
                            tmp(4,5:6,:) = 1;
                        case 4
                            suffix = '-I';
                            tmp(1,2:6,:) = 1;
                            tmp(3,4:6,:) = 1;
                            tmp(5,6,:) = 1;
                    end
                end
                
                image(tmp)
                
                % Add white lines
                Add_lines_frame(UpperTri,Switch)
                
                axis square
                box off
                
                Label_axis(UpperTri,CondNames(ConditionOrder))
                
                p=mtit([ROI(iROI).name ' - ' ToPlot{iToPlot}],...
                    'fontsize',14,...
                    'xoff',0,'yoff',.025);
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                %             print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName, '.svg']  ), '-dsvg')
                
            end
            
        end
        
    end
end

return

% close all


%% Color wheel
figure('name', 'color wheel','Color', [1 1 1])
img = Colour_Wheel('Polar', 90, 1, 1);

% make back ground white
tmp = all(img==0,3);
for i=1:3
    L = img(:,:,i);
    L(tmp)=1;
    img(:,:,i)=L;
end

% add transparency
%         radius = (size(img,2)-1)/2;
%         [x y] = meshgrid(-radius:radius, -radius:radius);
%         [t r] = cart2pol(x,y);
%         for i=1:radius-20
%             for RGB=1:3
%                 L = img(:,:,RGB);
%                 Annulus = all(cat(3,i<r,r<i+1),3);
%                 L(Annulus)=L(Annulus)+1*(1-i/(radius-20));
%                 img(:,:,RGB)=L;
%             end
%         end

image(img);
axis square
axis off

print(gcf, fullfile(PCM_dir, 'Cdt', 'Color_wheel.tif' ), '-dtiff')
%         print(gcf, fullfile(PCM_dir, 'Cdt', 'Color_wheel.svg'  ), '-dsvg')


%% Color scales
X = 1:-.001:0;
tmp = zeros(1,1001,3);

figure('name', 'color scales','Color', [1 1 1],'Position', FigDim)

subplot(2,1,1)
img = tmp;
img(:,:,1) = X;
img(:,:,2) = fliplr(X);
image(img);
title('S VS S+I')
set(gca,'tickdir', 'out', 'xtick', linspace(1,1001,11),'xticklabel', linspace(0,1,11), ...
    'ytick', [],'yticklabel', [], ...
    'ticklength', [0.01 0.001], 'fontsize', 14)
box off

subplot(2,1,2)
img = tmp;
img(:,:,2) = X;
img(:,:,3) = fliplr(X);
image(img);
title('S+I VS I')
set(gca,'tickdir', 'out', 'xtick', linspace(1,1001,11),'xticklabel', linspace(0,1,11), ...
    'ytick', [],'yticklabel', [], ...
    'ticklength', [0.01 0.001], 'fontsize', 14)
box off

print(gcf, fullfile(PCM_dir, 'Cdt', 'Color_scales.tif' ), '-dtiff')



end


function Add_lines_frame(UpperTri,Switch)
hold on

if UpperTri
    if Switch
        plot([3.5 3.5],[0.5 3.5],'color',[.5 .5 .5],'linewidth', 3)
        plot([3.5 6.5],[3.5 3.5],'color',[.5 .5 .5],'linewidth', 3)
    else
        plot([2.5 2.5],[0.5 2.5],'color',[.5 .5 .5],'linewidth', 3)
        plot([4.5 4.5],[0.5 4.5],'color',[.5 .5 .5],'linewidth', 3)
        plot([2.5 6.5],[2.5 2.5],'color',[.5 .5 .5],'linewidth', 3)
        plot([4.5 6.5],[4.5 4.5],'color',[.5 .5 .5],'linewidth', 3)
    end
    plot([0.51 6.51],[0.5 6.5],'k','linewidth', 1)
else
    if Switch
        error('Not implemented')
    else
        Pos = 2.5;
        for  i=1:2
            plot([Pos Pos],[0.52 6.52],'color',[.5 .5 .5],'linewidth', 3)
            plot([0.52 6.52],[Pos Pos],'color',[.5 .5 .5],'linewidth', 3)
            Pos = Pos + 2 ;
        end
        plot([0.51 6.51],[6.5 6.5],'k','linewidth', 1)
        plot([0.5 0.5],[0.51 6.51],'k','linewidth', 1)
    end
end
plot([0.51 6.51],[0.5 0.5],'k','linewidth', 1)
plot([6.5 6.5],[0.51 6.51],'k','linewidth', 1)
end

function Label_axis(UpperTri,CondNames)
if UpperTri
    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', CondNames, ...
        'ytick', 1:6,'yticklabel', CondNames, 'YAxisLocation','right',...
        'XAxisLocation','top',...
        'ticklength', [0.02 0.02], 'fontsize', 22)
else
    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', CondNames, ...
        'ytick', 1:6,'yticklabel', CondNames, ...
        'ticklength', [0.02 0.02], 'fontsize', 22)
end
end