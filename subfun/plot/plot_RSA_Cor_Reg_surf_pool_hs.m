function plot_RSA_Cor_Reg_surf_pool_hs(StartDir, SubLs, ToPlot, ranktrans, isplotranktrans)


if nargin < 4 || isempty(ranktrans)
    ranktrans = 0;
end

if nargin < 5 || isempty(isplotranktrans)
    isplotranktrans = 0;
end


NbSub = numel(SubLs);

load(fullfile(StartDir, 'sub-02', 'roi', 'surf','sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex') % to know how many ROIs we have

ColorMap = brain_colour_maps('hot_increasing');
FigDim = [100, 100, 1000, 1500];

RSA_dir = fullfile(StartDir, 'figures', 'RSA');
Reg_dir = fullfile(StartDir, 'figures', 'Regression');
Cor_dir = fullfile(StartDir, 'figures', 'Correlation');

if ranktrans
    ranktrans_suffix = 'ranktrans-1';
else
    ranktrans_suffix = 'ranktrans-0';
end

if isplotranktrans
    plotranktrans_suffix = 'plotranktrans-1';
else
    plotranktrans_suffix = 'plotranktrans-0';
end


%     'subjectRDMs_CV', 'subjectRDMs_CV_sens', 'subjectRDMs_CV_side',...

%     'subjectRDMs', 'subjectRDMs_sens', 'subjectRDMs_side', ...

%     'GrpBetaReg_sens', 'GrpBetaReg_cv_sens', 'GrpBetaReg_day_cv_sens', ...

%     'GrpBetaReg_side', 'GrpBetaReg_cv_side', 'GrpBetaReg_day_cv_side', ...

%     'GrpBetaReg', 'GrpBetaReg_cv', 'GrpBetaReg_day_cv'


% subjectRDMs{iROI,iToPlot,1} Euclidian
% subjectRDMs{iROI,iToPlot,2} Spearman
% subjectRDMs{iROI,iToPlot,3} Euclidian by hand
% subjectRDMs{iROI,iToPlot,4} Spearman by hand

% subjectRDMs_CV{iROI,iToPlot,1} RSA toolbox Euclidian - All CV
% subjectRDMs_CV{iROI,iToPlot,2} RSA toolbox Euclidian - Day CV
% subjectRDMs_CV{iROI,iToPlot,3} by hand Euclidian - All CV
% subjectRDMs_CV{iROI,iToPlot,4} by hand Spearman - All CV
% subjectRDMs_CV{iROI,iToPlot,5} by hand Euclidian - Day CV
% subjectRDMs_CV{iROI,iToPlot,6} by hand Spearman - Day CV

% GrpBetaReg{iROI,iToPlot,1} Regression
% GrpBetaReg{iROI,iToPlot,2} Correlation
% GrpBetaReg_cv{iROI,iToPlot,1} Regression  - All CV
% GrpBetaReg_cv{iROI,iToPlot,2} Correlation - All CV
% GrpBetaReg_day_cv{iROI,iToPlot,1} Regression - Day CV
% GrpBetaReg_day_cv{iROI,iToPlot,2} Correlation - Day CV

for target=0:1
    
    if target
        load(fullfile(StartDir,'results','profiles','surf','RSA','RSA_targets_grp_results_2.mat'))
    else
        load(fullfile(StartDir,'results','profiles','surf','RSA','RSA_grp_results_2.mat'))
    end
    
    %% RSA
    
    for i = 1:3
        
        switch i
            case 1
                if target
                    CondNames = {...
                        'Targ A contra','Targ A ipsi',...
                        'Targ V contra','Targ V ipsi',...
                        'Targ T contra','Targ T ipsi'...
                        };
                    FigName = 'Targets VS Targets';
                else
                    CondNames = {...
                        'A contra','A ipsi',...
                        'V contra','V ipsi',...
                        'T contra','T ipsi'...
                        }; %#ok<*UNRCH>
                    FigName = 'Stim VS Stim';
                end
                Dest_dir = fullfile(RSA_dir, 'Cdt');
                Data_2_plot = {subjectRDMs, subjectRDMs_CV};
                
            case 2
                if target
                    CondNames = {'(Contra-Ipsi)_{Targ_A} ','(Contra-Ipsi)_{Targ_V}','(Contra-Ipsi)_{Targ_T}'};
                    FigName = 'Targets - Side VS Side';
                else
                    CondNames = {'(Contra-Ipsi)_A ','(Contra-Ipsi)_V','(Contra-Ipsi)_T'};
                    FigName = 'Side VS Side';
                end
                Dest_dir = fullfile(RSA_dir, 'Side');
                Data_2_plot = {subjectRDMs_side, subjectRDMs_CV_side};
                
            case 3
                if target
                    CondNames = {...
                        'Targets - (A-V)_{Contra}','Targets - (A-T)_{Contra}','Targets - (V-T)_{Contra}',...
                        'Targets - (A-V)_{Ipsi}','Targets - (A-T)_{Ipsi}','Targets - (V-T)_{Ipsi}'};
                    FigName = 'Targets - Sens VS Sens';
                else
                    CondNames = {...
                        '(A-V)_{Contra}','(A-T)_{Contra}','(V-T)_{Contra}',...
                        '(A-V)_{Ipsi}','(A-T)_{Ipsi}','(V-T)_{Ipsi}'};
                    FigName = 'Sens VS Sens';
                end
                
                Dest_dir = fullfile(RSA_dir, 'Sens');
                Data_2_plot = {subjectRDMs_sens, subjectRDMs_CV_sens};
        end
        
        for RDM_to_plot = 1:8;
            
            for iToPlot = 1:numel(ToPlot)
                
                close all
                
                %% Plot group average
                clear RDM
                
                switch RDM_to_plot
                    
                    case 1
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{1}{iROI,iToPlot,1};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Euclidian distance';
                        
                    case 2
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{1}{iROI,iToPlot,2};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Spearman distance';
                        
                    case 3
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,1};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'RSA toolbox Euclidian - All CV';
                        
                    case 4
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,2};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'RSA toolbox Euclidian - Day CV';
                        
                    case 5
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,3};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Euclidian - All CV handmade';
                        
                    case 6
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,4};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Spearman - All CV handmade';
                        
                    case 7
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,5};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Euclidian - Day CV handmade';
                        
                    case 8
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,6};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Spearman - Day CV handmade';
                end
                
                clear Data
                
                % Plot
                figure('name', [FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1])
                
                rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);
                
                rename_subplot([3 3],CondNames,{ROI.name}')
                
                Name = sprintf('%s - %s - %s8%s - %s', DataName, FigName, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);
                title_print(Name,Dest_dir)
                
                %% Plot subjects
                clear RDM
                
                for iROI=1:numel(ROI)
                    switch RDM_to_plot
                        case 1
                            RDM = Data_2_plot{1}{iROI,iToPlot,1};
                        case 2
                            RDM = Data_2_plot{1}{iROI,iToPlot,2};
                        case 3
                            RDM = Data_2_plot{2}{iROI,iToPlot,1};
                        case 4
                            RDM = Data_2_plot{2}{iROI,iToPlot,2};
                        case 5
                            RDM = Data_2_plot{2}{iROI,iToPlot,3};
                        case 6
                            RDM = Data_2_plot{2}{iROI,iToPlot,4};
                        case 7
                            RDM = Data_2_plot{2}{iROI,iToPlot,5};
                        case 8
                            RDM = Data_2_plot{2}{iROI,iToPlot,6};
                    end
                    
                    if ranktrans
                        for iSubj=1:NbSub
                            RDM(:,:,iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM(:,:,iSubj),1));
                        end
                    end
                    
                    % Plot
                    figure('name', ['Sujbects - ' FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1])
                    
                    rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);
                    
                    rename_subplot([4 3],CondNames,{SubLs.name}')

                    Name = sprintf('Subjects - %s - %s - %s - %s8%s - %s', ROI(iROI).name, DataName, FigName, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);
                    title_print(Name,fullfile(Dest_dir, 'Subjects'))
                end
                
            end
            
        end
        
        
        
        %% Correlation and regression
        switch i
            case 1
                Data_2_plot = {GrpBetaReg, GrpBetaReg_cv, GrpBetaReg_day_cv};
                SubFolder = 'Cdt';
            case 2
                Data_2_plot = {GrpBetaReg_side, GrpBetaReg_cv_side, GrpBetaReg_day_cv_side};
                SubFolder = 'Side';
            case 3
                Data_2_plot = {GrpBetaReg_sens, GrpBetaReg_cv_sens, GrpBetaReg_day_cv_sens};
                SubFolder = 'Sens';
        end
        
        for RDM_to_plot = 1:6;
            
            for iToPlot = 1:numel(ToPlot)
                
                close all
                
                %% Plot group average
                clear RDM
                
                if ~mod(RDM_to_plot,2)==0
                    Dest_dir = fullfile(Reg_dir, SubFolder);
                else
                    Dest_dir = fullfile(Cor_dir, SubFolder);
                end
                
                switch RDM_to_plot
                    
                    case 1
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{1}{iROI,iToPlot,1};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Regression';
                        
                    case 2
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{1}{iROI,iToPlot,2};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Correlation';
                        
                    case 3
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,1};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Regression - All CV';
                        
                    case 4
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{2}{iROI,iToPlot,2};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Correlation - All CV';
                        
                    case 5
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{3}{iROI,iToPlot,1};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Regression - Day CV';
                        
                    case 6
                        for iROI=1:numel(ROI)
                            Data = Data_2_plot{3}{iROI,iToPlot,2};
                            RDM(:,:,iROI) = Extract_rankTransform_RDM(Data, NbSub, ranktrans);
                        end
                        DataName = 'Correlation - Day CV';
                        
                end
                
                % Plot
                figure('name', [FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1])
                
                CLIM = [min(RDM(:)) max(RDM(:))];
                
                rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);
                %                 for iROI=1:numel(ROI)
                %                     subplot(3,3,iROI)
                %                     colormap(ColorMap);
                %                     imagesc(RDM(:,:,iROI),CLIM)
                %                     axis square
                %                 end
                
                rename_subplot([3 3],CondNames,{ROI.name}')
                
                %                 subplot(3,3,iROI+1)
                %
                %                 colormap(ColorMap);
                %                 imagesc(repmat(linspace(CLIM(2),CLIM(1),400)', [1,200]), CLIM)
                %                 axis square
                %                 set(gca,'tickdir', 'out', 'xtick', [],'xticklabel',  [], ...
                %                     'ytick', linspace(1,400,5),...
                %                     'yticklabel', linspace(CLIM(2),CLIM(1),5), ...
                %                     'ticklength', [0.01 0.01], 'fontsize', 8, 'YAxisLocation','right')
                %                 box off
                
                Name = sprintf('%s - %s - %s8%s - %s', DataName, FigName, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);
                title_print(Name,Dest_dir)
                
                %% Plot subjects
                clear RDM
                
                for iROI=1:numel(ROI)
                    switch RDM_to_plot
                        case 1
                            RDM = Data_2_plot{1}{iROI,iToPlot,1};
                        case 2
                            RDM = Data_2_plot{1}{iROI,iToPlot,2};
                        case 3
                            RDM = Data_2_plot{2}{iROI,iToPlot,1};
                        case 4
                            RDM = Data_2_plot{2}{iROI,iToPlot,2};
                        case 5
                            RDM = Data_2_plot{3}{iROI,iToPlot,1};
                        case 6
                            RDM = Data_2_plot{3}{iROI,iToPlot,2};
                    end
                    
                    if ranktrans
                        for iSubj=1:NbSub
                            RDM(:,:,iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(RDM(:,:,iSubj),1));
                        end
                    end
                    
                    CLIM = [min(RDM(:)) max(RDM(:))];
                    
                    % Plot
                    figure('name', ['Sujbects - ' FigName ' - ' DataName ' - ' ToPlot{iToPlot}], 'Position', FigDim, 'Color', [1 1 1])
                    
                    rsa.fig.showRDMs(RDM, gcf, isplotranktrans, [], 1, [], [], ColorMap);
                    %                     for iSubj=1:NbSub
                    %                         subplot(4,3,iSubj)
                    %                         colormap(ColorMap);
                    %                         imagesc(RDM(:,:,iSubj),CLIM)
                    %                         axis square
                    %                     end
                    
                    rename_subplot([4 3],CondNames,{SubLs.name}')
                    
                    %                     subplot(4,3,iSubj+1)
                    %
                    %                     colormap(ColorMap);
                    %                     imagesc(repmat(linspace(CLIM(2),CLIM(1),400)', [1,200]), CLIM)
                    %                     axis square
                    %                     set(gca,'tickdir', 'out', 'xtick', [],'xticklabel',  [], ...
                    %                         'ytick', linspace(1,400,5),...
                    %                         'yticklabel', linspace(CLIM(2),CLIM(1),5), ...
                    %                         'ticklength', [0.01 0.01], 'fontsize', 8, 'YAxisLocation','right')
                    %                     box off
                    
                    Name = sprintf('Subjects - %s - %s - %s - %s8%s - %s', ROI(iROI).name, DataName, FigName, ToPlot{iToPlot}, ranktrans_suffix, plotranktrans_suffix);
                    title_print(Name,fullfile(Dest_dir, 'Subjects'))                    
                end
                
            end
            
        end
        
    end
    
end

end


function RDM = Extract_rankTransform_RDM(Data, NbSub, ranktrans)

if ranktrans
    for iSubj=1:NbSub
        tmp(:,:,iSubj) = rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(Data(:,:,iSubj),1));
    end
else
    tmp = Data;
end
IsAllZero = ~squeeze(all(all(tmp==0,1),2));
RDM = nanmean(tmp(:,:,IsAllZero), 3);

end


function title_print(Name,Dest_dir)
mtit(sprintf(strrep([Name ' - 2'], '8','\n')), 'fontsize', 10, 'xoff',0,'yoff',.025);
Name = strrep(Name, '8', ' - ');
% saveFigure(fullfile(Dest_dir, strrep([Name '.pdf'], ' ', '_')));
print(fullfile(Dest_dir, strrep([Name '.tiff'], ' ', '_')), '-dtiff')
% print(fullfile(Dest_dir, strrep([Name '.pdf'], ' ', '_')), '-dpdf')
end
