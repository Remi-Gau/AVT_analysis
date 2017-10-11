% Simulated data dataset for PCM
% Remi Gau adapted from Johanna Zumer, 2017

clc; clear; close all

StartDir = fullfile(pwd, '..','..', '..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

NbFeatures = 1000;
NbCdt = 6;
NbSess = 20;
NbSubj = 10;

FigDim = [100, 100, 1700, 1500];

load(fullfile(pwd, sprintf('sim_pcm_models_components_weights.mat')),'theta_real', 'M', ...
    'Components', 'Models','meanadd', 'sigmodel');


for iMod=2:numel(M)-1
    
    M{iMod}.name = num2str(iMod-1);
    
end


for sm=1:length(sigmodel)
    
    load(fullfile(pwd, sprintf('sim_pcm_output_cv_demean_noise_%i.mat', sm)),'ms_mr');
    load(fullfile(pwd, sprintf('sim_pcm_output_cv_noise_%i.mat', sm)),'ms_mc');
    
    %     ms_mc{tr,sm}.Tgroup
    %     ms_mc{tr,sm}.theta
    %     ms_mc{tr,sm}.G_pred
    %     ms_mc{tr,sm}.Tcross
    %     ms_mc{tr,sm}.thetaCr
    %     ms_mc{tr,sm}.G_predcv
    
    for mean = 0:1
        
        if mean == 0
            mean_suffix = 'mean-corrected';
            tmp = ms_mr;
        else
            mean_suffix = 'mean-present';
            tmp = ms_mc;
        end
        
        
        
        %%
        for iCV = 0:1
            
            if iCV == 0
                CV_suffix = 'no ';
            else
                CV_suffix = '';
            end
            
                figure('name', sprintf('PCM - %sCV - noise=%i - %s', CV_suffix, sm, mean_suffix),...
                    'Position', FigDim, 'Color', [1 1 1]);
            
            iSubplot = 1;
            
            for tr=1:numel(M)-2
                
                tmp1 = mat2cell( repmat(Models(tr).Cpts,numel(M)-2,1), ones(numel(M)-2,1), numel(Models(tr).Cpts) );
                tmp1 = cellfun(@ismember,{Models(:).Cpts}',tmp1, 'UniformOutput', 0);
                tmp1 = cellfun(@sum,tmp1);
                
                colors = repmat('b',numel(M)-2,1);
                colors(find(tmp1)) = 'g';
                colors(tr) = 'r';
                colors = cellstr(colors);
                
                subplot(3,5,iSubplot)
                if iCV == 0
                    pcm_plotModelLikelihood(tmp{tr,sm}.Tgroup,M,'upperceil',tmp{tr,sm}.Tgroup.likelihood(:,2),'normalize',0,...
                        'colors', colors, 'style','bar');
                else
                    pcm_plotModelLikelihood(tmp{tr,sm}.Tcross,M,'upperceil',tmp{tr,sm}.Tgroup.likelihood(:,2),'normalize',0,...
                        'colors', colors, 'style','bar');
                end
                set(gca,'fontsize', 4)
                iSubplot = iSubplot+1;
                
                t=title(['Model ' num2str(tr)]);
                set(t,'fontsize', 8)
            end
            
            
            mtit(sprintf('PCM - %sCV - noise level=%i - %s', CV_suffix, sm, mean_suffix), 'fontsize', 12, 'xoff',0,'yoff',.035)
            
            print(gcf, fullfile(pwd, sprintf('sim_PCM-%sCV-noise=%i-%s', CV_suffix, sm, mean_suffix)), '-dtiff')
            
            
        end
        
        
    end
    
end


