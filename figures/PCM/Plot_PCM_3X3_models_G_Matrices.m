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
visible = 'on';
FigDim = [50, 50, 1200, 600];

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


Comp_suffix{1} = '3X3_Contra';
Comp_suffix{end+1} = '3X3_Ipsi';

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
        
        MinMax = [];
        
        for iROI = 1:5 %:numel(ROI)
            
            for ihs=1:NbHS
                
                for iComp = 1:2
                    
                    ls_files_2_load = dir(fullfile(Save_dir, ...
                        sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s_201*.mat', ...
                        Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                        ToPlot{iToPlot}, Split_suffix, Comp_suffix{iComp})));
                    
                    disp(fullfile(Save_dir,ls_files_2_load(end).name))
                    load(fullfile(Save_dir,ls_files_2_load(end).name),...
                        'M','G_hat','G_pred_cr')
                    
                    M_all{iComp,1} = M;
                    G_hat_all{iComp,1} = G_hat;
                    G_pred_cr_all{iComp,1} =  G_pred_cr;
                    
                    clear M G G_hat T_group G_pred_gr T_cross G_pred_cr
                end
                
                c = pcm_indicatorMatrix('allpairs' ,1:size(M_all{1}{1}.Ac,1));
                %                 H = eye(size(M{1}.Ac,1))-ones(size(M{1}.Ac,1))/size(M{1}.Ac,1);
                H = 1;
                
                opt.SubLs = SubLs;
                
                
                %% Plot G matrices
                for iModel=1:2

                    for iComp = 1:numel(Comp_suffix)
                        
                        G_hat = G_hat_all{iComp,1};
                        G_pred_cr = G_pred_cr_all{iComp,1};
                        
                        if iModel==1
                            Mat2Plot(:,:,iComp) = H*mean(G_hat,3)*H';
                        else
                            Mat2Plot(:,:,iComp) = H*mean(G_pred_cr{end},3)*H';
                        end
                        
                    end
                                        
                    [ NewColorMap ] = Create_non_centered_diverging_colormap(Mat2Plot, ColorMap);
                    MIN = min(Mat2Plot(:));
                    MAX = max(Mat2Plot(:));
                    if MIN>0
                        MIN=0;
                    end
                    if MAX<0
                        MAX=0;
                    end
                    CLIM = [MIN MAX];
                    
                    Title = strrep(ROI(iROI).name, '_thresh','');
                    if iModel==1
                        Title = [Title ' - G_{emp}'];
                    else
                        Title = [Title ' - G_{pred}-free'];
                    end
                    
                    opt.FigName = sprintf('%s-%s-PCM_{grp}-%s-%s-%s', ...
                        strrep(Title, ' ',''), ...
                        hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                    
                    figure('name', [opt.FigName], 'Position', FigDim, 'Color', [1 1 1], 'visible', visible);
                    colormap(NewColorMap)
                    
                    for iComp = 1:numel(Comp_suffix)

                        subplot(1,2,iComp)
                        imagesc(Mat2Plot(:,:,iComp), CLIM);
                        axis square
                        colorbar
                        
                        switch iComp
                            case 1
                                CdtToSelect = 2:2:6;
                            case 2
                                CdtToSelect = 1:2:5;  
                        end
                        
                        set(gca,'tickdir', 'out', 'xtick', 1:3,'xticklabel', {CondNames{CdtToSelect}}, ...
                            'ytick', 1:3,'yticklabel', {CondNames{CdtToSelect}}, ...
                            'ticklength', [0.01 0], 'fontsize', 16)
                        
                        t = title(Title);
                        set(t, 'fontsize', 16);
                        
                    end
                    
                    print(gcf, fullfile(PCM_dir, 'Cdt', '3X3_models', [opt.FigName '.tif'] ), '-dtiff')
                    
                end
                
            end
            
        end
    end
end

