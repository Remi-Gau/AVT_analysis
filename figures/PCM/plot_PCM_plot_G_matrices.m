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

set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')


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

for iToPlot = 1:2 %numel(ToPlot)
    
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
                
                G_Mat_all_ROIs{iROI,ihs} = G_hat;
                
            end
        end
        
        %% G matrix recap figures
        close all
        
        FigDim = [50, 50, 600, 600];
        ColorMap = seismic(1000);
        
        for iROI = 1:numel(G_Mat_all_ROIs)
            
            clc
            
            for iScale = 1%:2
                
                if iScale==1
                    Scaling = '';
                    H = 1;
                    Mat2Plot = mean(G_Mat_all_ROIs{iROI,1},3);
                    Mat2Plot = H*Mat2Plot*H';
                else
                    Scaling = 'Scaled-log_10-';
                    %                   H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
                    H = 1;
                    Mat2Plot = mean(G_Mat_all_ROIs{iROI,1},3);
                    Mat2Plot = H*Mat2Plot*H';
                    
                    % normalize the data
                    Sign = sign(Mat2Plot);
                    Mat2Plot = abs(Mat2Plot); %take absolute values to avoid problems when going to log scale
                    Min2Keep = min(Mat2Plot(:));
                    Mat2Plot = Mat2Plot/(min(Mat2Plot(:))); %normalize by minimum value
                    Mat2Plot = log10(Mat2Plot); % log scale
                    Mat2Plot = Mat2Plot.*Sign; % put the sign back in
                    
                end
                
                opt.FigName = sprintf('%s-PCM_{grp}-%s-%s-%s-%s', ROI(iROI).name,...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                fig = figure('name', ['Recap-G-matrix-' Scaling opt.FigName], ...
                    'Position', FigDim, 'Color', [1 1 1]);

                % adapts color scale so that 0 is white
                MIN = min(Mat2Plot(:));
                MAX = max(Mat2Plot(:));
                [AbsMax,Idx] = max(abs([MIN MAX]));
                Scale = linspace(-1*AbsMax,AbsMax,size(ColorMap,1))';
                if Idx==2
                    Idx = Scale<MIN;
                    NewColorMap = ColorMap(~Idx,:);
                else
                    Idx = Scale>MAX;
                    NewColorMap = ColorMap(~Idx,:);
                end
                
                colormap(NewColorMap);
                imagesc(Mat2Plot);
                hold on
                
                set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', CondNames, ...
                    'ytick', 1:6,'yticklabel', CondNames, ...
                    'ticklength', [0.02 0.02], 'fontsize', 18)
                
                %                 t=title(ROI(iROI).name);
                %                 set(t, 'fontsize', 12);
                
                colorbar
                
                % Add white lines
                Pos = 2.5;
                for  i=1:2
                    plot([Pos Pos],[0.52 6.52],'w','linewidth', 2)
                    plot([0.52 6.52],[Pos Pos],'w','linewidth', 2)
                    Pos = Pos + 2 ;
                end
                plot([0.5 0.5],[0.51 6.51],'k','linewidth', 1)
                plot([6.5 6.5],[0.51 6.51],'k','linewidth', 1)
                plot([0.51 6.51],[0.5 0.5],'k','linewidth', 1)
                plot([0.51 6.51],[6.5 6.5],'k','linewidth', 1)
                
%                 axis tight
                axis square
                box off
                
                %                 mtit(fig.Name, 'fontsize', 12, 'xoff',0,'yoff',.035)
                
                print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif']  ), '-dtiff')
                %                 print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.svg']  ), '-dsvg')
                
                %%
                if iScale==2
                    % Create a scale with the original values
                    fig = figure('name', ['Scale-G-matrix-' Scaling opt.FigName], ...
                        'Position', [50, 50, 700, 600], 'Color', [1 1 1]);
                    
                    colormap(NewColorMap)
                    
                    imagesc(repmat(linspace(MAX,MIN,1000)',1,100))
                    
                    NbYtick = 10;
                    set(gca,'tickdir', 'out', 'xtick',[],'xticklabel', [], ...
                        'ytick', linspace(1,1000,NbYtick),...
                        'yticklabel', floor(linspace(MAX,MIN,NbYtick)*10^3)/10^3, ...
                        'ticklength', [0.01 0.01], 'fontsize', 12)
                    
                    ax = gca;
                    axPos = ax.Position;
                    axes('Position',axPos);
                    
                    imagesc(repmat(linspace(MAX,MIN,1000)',1,100))
                    
                    % get the Y scale unnormalized
                    %                     linspace(MAX,MIN,NbYtick)
                    %                     abs(linspace(MAX,MIN,NbYtick))
                    %                     10.^abs(linspace(MAX,MIN,NbYtick))
                    %                     10.^abs(linspace(MAX,MIN,NbYtick))*Min2Keep
                    %                     10.^abs(linspace(MAX,MIN,NbYtick))*Min2Keep.*sign(linspace(MAX,MIN,NbYtick))
                    YTickLabel = linspace(MAX,MIN,NbYtick);
                    YTickLabel = 10.^(abs(linspace(MAX,MIN,NbYtick)))*Min2Keep.*sign(YTickLabel);
                    YTickLabel = floor(YTickLabel*10^4)/10^4;
                    
                    set(gca,'tickdir', 'out', 'xtick',[],'xticklabel', [], ...
                        'ytick', linspace(1,1000,NbYtick),...
                        'yticklabel', YTickLabel, ...
                        'YAxisLocation','right',...
                        'ticklength', [0.01 0.01], 'fontsize', 14)
                    
                    %                     print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.tif']  ), '-dtiff')
                    %                     print(gcf, fullfile(PCM_dir, 'Cdt', [fig.Name, '.svg']  ), '-dsvg')
                    
                end
                
            end
            
        end
        
    end
end
