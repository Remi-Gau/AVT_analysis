function Plot_BOLD_MVPA_all_ROIs(ToPlot)

fontsize = 6;

SubPlots = {...
    [1 7] [2 8] [3 9] [4 10] [5 11] [6 12];...
    13, 14, 15, 16, 17, 18;...
    19,20, 8;...
    9, 10;...
    };

line_colors = [...
    0 .2 1;...
    0 .8 1;...
    0.2 1 0;...
    .35 1 0;...
    .5 1 0;...
    .65 1 0;...
    .8 1 0;...
    ];

NbROI = numel(ToPlot.ROIs_name);

if isempty(ToPlot.ToPermute)
    suffix = '_ttest';
else
    suffix = '_perm';
end

    Name = strrep([ToPlot.TitSuf '--' ToPlot.Name], ' ', '_');
    Name = strrep(Name, '_', '-');

    fig = figure('Name', Name, 'Position', [100, 100, 1000, 700], 'Color', [1 1 1], 'Visible', ToPlot.Visible);
    
    set(gca,'units','centimeters')
    pos = get(gca,'Position');
    ti = get(gca,'TightInset');
    
    set(fig, 'PaperUnits','centimeters');
    set(fig, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    set(fig, 'PaperPositionMode', 'manual');
    set(fig, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    
    set(fig, 'Visible', ToPlot.Visible)

for iCdt = 1:numel(ToPlot.Legend)

    for MVPA_BOLD = 1:2
        
        ToPlot.Cst = 0;
        ToPlot.MVPA_BOLD = MVPA_BOLD;
        
        % plot profiles
        subplot (5,6,SubPlots{1,MVPA_BOLD})
        PlotRectangle(6,fontsize)
        subplot(5,6,SubPlots{1,MVPA_BOLD})
        hold on
        if MVPA_BOLD==2
            l=errorbar(...
                repmat((1:6)',1,NbROI)+repmat(linspace(-.15,.15,7),6,1),...
                ToPlot.MVPA.MEAN(:,:,iCdt),...
                ToPlot.MVPA.SEM(:,:,iCdt));
        else
            l=errorbar(...
                repmat((1:6)',1,NbROI)+repmat(linspace(-.15,.15,7),6,1),...
                ToPlot.profile.MEAN(:,:,iCdt),...
                ToPlot.profile.SEM(:,:,iCdt));
        end
        for iLine=1:numel(l)
            set(l(iLine),'color', line_colors(iLine,:))
        end
        
        if MVPA_BOLD==1
            legend(ToPlot.ROIs_name, 'location', 'NorthWest')
            t=ylabel('Param. est. [a u]');
        else
            t=ylabel('Decoding accuracy');
        end
        set(t,'fontsize',fontsize);
        
        if MVPA_BOLD==2
            plot([0.5 6.5], [0.5 0.5], '--k')
        else
            plot([0.5 6.5], [0 0], '--k')
        end
        
        ax = axis;
        axis([0.75 6.25 ax(3) ax(4)])
        
        if MVPA_BOLD==2
            title(['MVPA' ToPlot.Legend{iCdt}])
        else
            title(['BOLD' ToPlot.Legend{iCdt}])
        end
        
        set(gca,'tickdir', 'out', 'xtick', [] , ...
            'xticklabel', ' ', 'ticklength', [0.01 0.01], ...
            'fontsize', fontsize)
        
        
        % plot betas constant
        subplot (5,2,SubPlots{2,MVPA_BOLD})
        hold on
        if MVPA_BOLD==2
            tmp = ToPlot.MVPA.beta(:,:,1,iCdt);
        else
            tmp = ToPlot.profile.beta(:,:,1,iCdt);
        end
        plot_betas(tmp,ToPlot,fontsize)
        
        ylabel(sprintf('constant\nParam. est. [a u]'));
        set(t,'fontsize',fontsize);
        
        
        
        % plot betas linear
        subplot (5,2,SubPlots{3,MVPA_BOLD})
        hold on
        if MVPA_BOLD==2
            tmp = ToPlot.MVPA.beta(:,:,2,iCdt);
        else
            tmp = ToPlot.profile.beta(:,:,2,iCdt)*-1;
        end
        plot_betas(tmp,ToPlot,fontsize)
        
        ylabel(sprintf('linear\nParam. est. [a u]'));
        set(t,'fontsize',fontsize);
        
        
        % plot whole ROI
        subplot (5,2,SubPlots{4,MVPA_BOLD})
        hold on
        if MVPA_BOLD==2
            tmp = ToPlot.MVPA.grp(:,:,iCdt);
        else
            tmp = ToPlot.ROI.grp(:,:,iCdt);
        end
        ToPlot.Cst = 1;
        plot_betas(tmp,ToPlot,fontsize)
        
        ylabel(sprintf('whole ROI\nParam. est. [a u]'));
        set(t,'fontsize',fontsize);
        
    end
    
    mtit(sprintf(Name),'xoff', 0, 'yoff', +0.03, 'fontsize', fontsize+4)
    
    print(fig, fullfile(ToPlot.FigureFolder, ['All_ROIs_BOLD-MVPA_' strrep(Name,'\n','-'), suffix, '.tif']), '-dtiff')
    
end


end


function plot_betas(tmp,ToPlot,fontsize)

Alpha = 0.05;

Xpos = [1 2 4:8];

% plot spead
tmp_cell = mat2cell(tmp,size(tmp,1),ones(1,size(tmp,2)));
h = plotSpread(tmp_cell, 'distributionMarkers',{'.'},...
    'xValues', (Xpos)+.2, 'binWidth', 1, 'spreadWidth', 1);
set(h{1}, 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 1)

% plot mean+SEM
errorbar(Xpos-.2, nanmean(tmp), nansem(tmp), 'b. ')

% plot zero line
if ToPlot.Cst
    plot([0 9], [0.5 0.5], '--k')
else
    plot([0 9], [0 0], '--k')
end

set(gca, 'tickdir', 'out', 'xtick', Xpos,'xticklabel',ToPlot.ROIs_name, ...
    'ticklength', [0.01 0.01], 'fontsize', fontsize)

axis tight
ax = axis;

if ToPlot.MVPA_BOLD==2 && ToPlot.Cst
    tmp=tmp-.5;
end

% now compute p values and print them
if ~isempty(ToPlot.ToPermute)
    for iPerm = 1:size(ToPlot.ToPermute,1)
        tmp2 = ToPlot.ToPermute(iPerm,:);
        tmp2 = repmat(tmp2',1,size(tmp,2));
        Perms(iPerm,:) = mean(tmp.*tmp2); %#ok<*SAGROW>
    end
end

if isfield(ToPlot, 'OneSideTTest')
    
    if ~isempty(ToPlot.ToPermute)
        if strcmp(ToPlot.OneSideTTest,'left')
            %             P = sum(Perms<mean(tmp))/numel(Perms);
        elseif strcmp(ToPlot.OneSideTTest,'right')
            %             P = sum(Perms>mean(tmp))/numel(Perms);
        elseif strcmp(ToPlot.OneSideTTest,'both')
            
            P = sum( ...
                abs( Perms ) > ...
                repmat( abs(mean(tmp)), size(Perms,1),1)  ) ...
                / size(Perms,1) ;
        end
    else
        [~,P] = ttest(tmp, 0, 'alpha', 0.05, 'tail', ToPlot.OneSideTTest);
    end
else
    
    if ~isempty(ToPlot.ToPermute)
        P = sum( ...
            abs( Perms ) > ...
            repmat( abs(mean(tmp)), size(Perms,1),1)  ) ...
            / size(Perms,1) ;
    else
        [~,P] = ttest(tmp, 0, 'alpha', 0.05);
    end
    
end

for iP = 1:numel(P)
    Sig = [];
    if P(iP)<0.001
        Sig = sprintf('p<0.001 ');
    else
        Sig = sprintf('p=%.3f ',P(iP));
    end
    
    t = text(Xpos(iP)-.2,ax(4)+ax(4)*.2,sprintf(Sig));
    set(t,'fontsize',fontsize-1);
    
    if P(iP)<Alpha
        set(t,'color','r');
    end
end

axis([0.5 8.5 ax(3) ax(4)+ax(4)*.25])

end
