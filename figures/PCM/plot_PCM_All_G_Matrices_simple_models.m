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
        
        for iROI = 2 %numel(ROI)
            
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
                close all
                FigDim = [50, 50, 700, 700];
                
                
                %% Plot G matrices
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
                    
                    % plot pred G mat from each model
                    for iModel=[1 5 2:4]
                        
                        Title = strrep(ROI(iROI).name, '_thresh','');
                        
                        switch iModel
                            case 1
                                Title = [Title ' - G_{emp}'];
                            case 5
                                Title = [Title ' - G_{pred}-free'];
                            otherwise
                                Title = [Title ' - ' M{iModel}.name];
                        end
                        
                        Title = [Title ' - ' CondNames{CdtToSelect(1)} ' VS ' CondNames{CdtToSelect(2)}];
                        
                        
                        opt.FigName = sprintf('%s-%s-PCM_{grp}-%s-%s-%s', ...
                            strrep(Title, ' ',''), ...
                            hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                        
                        figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                        
                        
                        if iModel==1
                            Mat2Plot = H*mean(G_hat,3)*H';
                        else
                            Mat2Plot = H*mean(G_pred_cr{iModel},3)*H';
                        end
                        
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
                        
                        imagesc(Mat2Plot, CLIM);
                        
                        %                         try
                        %                             imagesc(Mat2Plot);
                        %                         catch
                        %                             warning('model %i has an imaginary G_pred_CV', iModel)
                        %                             imagesc(H*mean(real(G_pred_cr{iModel}),3)*H');
                        %                         end
                        colorbar
                        
                        set(gca,'tickdir', 'out', 'xtick', 1:2,'xticklabel', [], ...
                            'ytick', 1:2,'yticklabel', {CondNames{CdtToSelect}}, ...
                            'ticklength', [0.01 0], 'fontsize', 16)
                        

                        t = title(Title);
                        set(t, 'fontsize', 16);
                        
                        print(gcf, fullfile(PCM_dir, 'Cdt', [opt.FigName '.tif'] ), '-dtiff')
                        
                    end

                end

            end
        end
    end
end
