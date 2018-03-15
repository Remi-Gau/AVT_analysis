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
                
                
            end
        end
        
        %% Plot RSA
        close all
        
        A = {'A1' 'PT' 'V1' 'V2' 'V3'};
        
        for ihs=1:NbHS
            
            for i=0:2
                
                if i==1
                    Rank_trans = 'ranktrans-';
                elseif i==2
                    Rank_trans = 'ranktrans-reset-';
                else
                    Rank_trans = 'raw-';
                end
                
                opt.FigName = sprintf('%s-PCM_{grp}-%s-%s-%s', ...
                    hs_suffix{ihs}, Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                fig = figure('name', ['Grp_avg_RDM_-' Rank_trans  opt.FigName] ,'Position', opt.FigDim , 'Color', [1 1 1]);
                
                if i>0
                    rsa.fig.showRDMs(Grp_RDM_RSA{ihs}, gcf, i, [], 1, [], [], ColorMap);
                end                

                if i==0
                    for iROI = 1:size(Grp_RDM_RSA{ihs},3)
                        tmp = Grp_RDM_RSA{ihs}(:,:,iROI);
                        subplot(3,2,iROI)
                        colormap(ColorMap)
                        imagesc(tmp)
                        colorbar
                        axis square
                    end
                    
                elseif i==2
                    for iROI = 1:size(Grp_RDM_RSA{ihs},3)
                        
                        tmp = Grp_RDM_RSA{ihs}(:,:,iROI);
                        tmp = rsa.util.rankTransform_equalsStayEqual(tmp,1);
                        MIN = min(tmp(:));
                        for iCdt = 1:size(tmp,2)
                            tmp(iCdt,iCdt)=MIN;
                        end
                        
                        subplot(3,2,iROI)
                        colormap(ColorMap)
                        imagesc(tmp)
                        axis square
                    end
                end
                
                rename_subplot([3 2],CondNames,A)
                
                subplot(3,2,1)
                axis square
                
                mtit(strrep(fig.Name, '_',' '), 'fontsize', 12, 'xoff',0,'yoff',.035)
                
                print(gcf, fullfile(StartDir, 'figures','RSA', 'Cdt', [fig.Name, '.tif'] ), '-dtiff')
                
            end
            
            
        end
    end
end