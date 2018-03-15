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

UpperTri=1;
Switch=0;
surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;
Split_half = 0; % only implemented for surface


if UpperTri
    UpTriSuffix = 'uptri';
else
    UpTriSuffix = '';
end

if Switch
    SwitchSuffix = 'switched';
    %   Ac Vc Tc Ai Vi Ti
    PositionToFill = [3 8 12 13 14 15 1 2 6];
    ConditionOrder = [1:2:6 2:2:6];
else
    SwitchSuffix = '';
    %     Ai Ac Vi Vc Ti Tc
    %     PositionToFill = [1 10 15 2 4 11 7 9 14];
    %     ConditionOrder = 1:6;
    
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
                    'A_i','A_c',...
                    'V_i','V_c',...
                    'T_i','T_c'...
                    };
            end
        end
        
        for iROI = 1:5 %numel(ROI)
            
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
        
        %% Plot with color coding to tell which model wins
        close all
        clc
        
        for iROI = 1:numel(Likelihood_norm)
            
            %% FFX
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
            
            opt.FigName = sprintf('BestModel-FFX-3Models-%s-%s-PCM_{grp}-%s-%s-%s-%s-%s', ...
                ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot},...
                UpTriSuffix, SwitchSuffix);
            
            figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
            
            TmpColorMap = ColorMap;
            TmpColorMap((max(Data2Plot)+2):end,:)=[];
            colormap(TmpColorMap)
            
            Img2Plot = squareform(Data2Plot);
            if UpperTri
                Img2Plot = triu(Img2Plot);
            end
            
            for i=1:3
                
                tmp = Img2Plot;
                
                
                switch i
                    case 1
                        suffix = '';
                    case 2
                        suffix = '-CvsI';
                        tmp(1:2,3:6) = 0;
                        tmp(3:4,5:6) = 0;
                    case 3
                        suffix = '-C&I';
                        tmp(1,2) = 0;
                        tmp(3,4) = 0;
                        tmp(5,6) = 0;
                end
                
                
                clf
                
                imagesc(tmp)
                
                % Add white lines
                Add_lines_frame(UpperTri)
                
                axis square
                box off
                
                Label_axis(UpperTri,CondNames(ConditionOrder))
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName suffix '.tif'] ), '-dtiff')
                %             print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName, '.svg']  ), '-dsvg')
                
            end
            close all
            
            %% RFX
            Data2Plot = ones(15,3);
            Alpha2Plot = zeros(15,1);
            for iComp = 1:numel(M_all)
                
                loglike = Likelihood{iROI,ihs}(:,2:end-1,iComp);
                
                [alpha,exp_r,xp,pxp,bor] = spm_BMS(loglike);
                
                Data2Plot(PositionToFill(iComp),:) = pxp;
                Alpha2Plot(PositionToFill(iComp),:) = bor;
            end
            
            
            %%
            opt.FigName = sprintf('BestModel-RFX-3Models-%s-%s-PCM_{grp}-%s-%s-%s-%s-%s', ...
                ROI(iROI).name, hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot},...
                UpTriSuffix, SwitchSuffix);
            
            figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
            
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
            
            for i=1:3
                
                tmp = Img2Plot;
                
                
                switch i
                    case 1
                        suffix = '';
                    case 2
                        suffix = '-CvsI';
                        tmp(1:2,3:6,:) = 1;
                        tmp(3:4,5:6,:) = 1;
                    case 3
                        suffix = '-C&I';
                        tmp(1,2,:) = 1;
                        tmp(3,4,:) = 1;
                        tmp(5,6,:) = 1;
                end
                
                
                image(tmp)
                
                % Add white lines
                Add_lines_frame(UpperTri)
                
                axis square
                box off
                
                Label_axis(UpperTri,CondNames(ConditionOrder))
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName suffix '.tif'] ), '-dtiff')
                %             print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName, '.svg']  ), '-dsvg')
                
            end
            
        end
        
        
        %% Color wheel
        close all
        
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
        
    end
end

end


function Add_lines_frame(UpperTri)
hold on
if UpperTri
    plot([2.5 2.5],[0.5 2.5],'color',[.5 .5 .5],'linewidth', 3)
    plot([4.5 4.5],[0.5 4.5],'color',[.5 .5 .5],'linewidth', 3)
    plot([2.5 6.5],[2.5 2.5],'color',[.5 .5 .5],'linewidth', 3)
    plot([4.5 6.5],[4.5 4.5],'color',[.5 .5 .5],'linewidth', 3)
    plot([0.51 6.51],[0.5 6.5],'k','linewidth', 1)
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
plot([0.51 6.51],[0.5 0.5],'k','linewidth', 1)
plot([6.5 6.5],[0.51 6.51],'k','linewidth', 1)
end

function Label_axis(UpperTri,CondNames)
if UpperTri
    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', CondNames, ...
        'ytick', 1:6,'yticklabel', CondNames, 'YAxisLocation','right',...
        'XAxisLocation','top',...
        'ticklength', [0.02 0.02], 'fontsize', 18)
else
    set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', CondNames, ...
        'ytick', 1:6,'yticklabel', CondNames, ...
        'ticklength', [0.02 0.02], 'fontsize', 18)
end
end