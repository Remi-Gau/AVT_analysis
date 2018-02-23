function Plot_BOLD_MVPA_all_ROIs(ToPlot)

fontsize = 9;

% if size(ToPlot.profile.MEAN,3)==3
%     m=4;
%     n=6;
%     SubPlots = {...
%         [1 7] [2 8] [3 9] [4 10] [5 11] [6 12];...
%         13, 14, 15, 16, 17, 18;...
%         19, 20, 21, 22, 23, 24;...
%         25, 26, 27 ,28, 29, 30;...
%         };
% elseif size(ToPlot.profile.MEAN,3)==2
%     m=4;
%     n=4;
%     SubPlots = {...
%         [1 5] [2 6] [3 7] [4 8];...
%         9, 10, 11, 12;...
%         13, 14, 15, 16;...
%         17, 18, 19 ,20;...
%         };
% end

m=4;
n=2;
SubPlots = {...
    [1 3] [2 4];...
    5, 6;...
    7, 8;...
    9, 10;...
    };

line_colors = [...
    37,52,148;...
    65,182,196;...
    0,94,45;...
    89,153,74;...
    110,188,111;...
    184,220,143;...
    235,215,184;...
    ]/255;
ToPlot.line_colors=line_colors;

NbROI = numel(ToPlot.ROIs_name);

if isempty(ToPlot.ToPermute)
    suffix = '_ttest';
else
    suffix = '_perm';
end

Name = strrep([ToPlot.TitSuf '--' ToPlot.Name], ' ', '_');
Name = strrep(Name, '_', '-');

for iCdt = 1:size(ToPlot.Legend,1)
    
    fig = figure('Name', [Name '\n' ToPlot.Titles{iCdt,1}], ...
        'Position', [100, 50, 1300, 750], 'Color', [1 1 1], 'Visible', ToPlot.Visible);
    
    set(gca,'units','centimeters')
    pos = get(gca,'Position');
    ti = get(gca,'TightInset');
    
    set(fig, 'PaperUnits','centimeters');
    set(fig, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    set(fig, 'PaperPositionMode', 'manual');
    set(fig, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    
    set(fig, 'Visible', ToPlot.Visible)
    
    for iColumn = 1:2
        
        MVPA_BOLD = 1+ToPlot.IsMVPA(iCdt,iColumn);
        ToPlot.Cst = 0;
        ToPlot.MVPA_BOLD = MVPA_BOLD;
        
        % plot profiles
        subplot(m,n,SubPlots{1,iColumn})
        %         subplot(m,n,SubPlots{1,(iCdt-1)*2+iColumn})
        PlotRectangle(6,fontsize)
        subplot(m,n,SubPlots{1,iColumn})
        
        hold on
        
        if MVPA_BOLD==2
            plot([-5 15], [0.5 0.5], '-k','linewidth',.8)
        else
            plot([-5 15], [0 0], '-k','linewidth',.8)
        end
        
        if iColumn==2
            l=errorbar(...
                repmat((1:6)',1,NbROI)+repmat(linspace(-.2,.2,7),6,1),...
                ToPlot.MVPA.MEAN(:,:,iCdt),...
                ToPlot.MVPA.SEM(:,:,iCdt));
            l2=plot(...
                repmat((1:6)',1,NbROI)+repmat(linspace(-.2,.2,7),6,1),...
                ToPlot.MVPA.MEAN(:,:,iCdt));
        else
            l=errorbar(...
                repmat((1:6)',1,NbROI)+repmat(linspace(-.2,.2,7),6,1),...
                ToPlot.profile.MEAN(:,:,iCdt),...
                ToPlot.profile.SEM(:,:,iCdt));
            l2=plot(...
                repmat((1:6)',1,NbROI)+repmat(linspace(-.2,.2,7),6,1),...
                ToPlot.profile.MEAN(:,:,iCdt));
        end
        for iLine=1:numel(l)
            set(l(iLine),'color', line_colors(iLine,:))
            set(l2(iLine),'color', line_colors(iLine,:),'linewidth',2)
        end
        
        axis tight
        ax = axis;
        if isfield(ToPlot,'MinMax')
            MIN = ToPlot.MinMax{1,iCdt}(iColumn,1);
            MAX = ToPlot.MinMax{1,iCdt}(iColumn,2);
        else
            MIN = ax(3)-0.02;
            MAX = ax(4)+0.02;
        end
        axis([0.4 6.6 MIN MAX])
        
        title(ToPlot.Legend{iCdt,iColumn})
        
        set(gca,'tickdir', 'out', 'xtick', [] , ...
            'xticklabel', ' ', 'ticklength', [0.01 0.01], ...
            'fontsize', fontsize-1)
        
        if MVPA_BOLD==1
            t=ylabel('B Param. est. [a u]');
        else
            t=ylabel('Decoding accuracy');
        end
        set(t,'fontsize',fontsize); clear t
        
        
        % plot betas constant
        %         subplot (m,n,SubPlots{2,(iCdt-1)*2+iColumn})
        subplot(m,n,SubPlots{2,iColumn})
        hold on
        if iColumn==2
            tmp = ToPlot.MVPA.beta(:,:,1,iCdt);
        else
            tmp = ToPlot.profile.beta(:,:,1,iCdt);
        end
        if isfield(ToPlot,'MinMax')
            ToPlot.MIN = ToPlot.MinMax{2,iCdt}(iColumn,1);
            ToPlot.MAX = ToPlot.MinMax{2,iCdt}(iColumn,2);
        end
        plot_betas(tmp,ToPlot,fontsize)
        
%         if iColumn==1 && iCdt==1
            t=ylabel(sprintf('constant\nS Param. est. [a u]'));
            set(t,'fontsize',fontsize);
%         end
        
        
        % plot betas linear
        %         subplot (m,n,SubPlots{3,(iCdt-1)*2+iColumn})
        subplot(m,n,SubPlots{3,iColumn})
        hold on
        if iColumn==2
            tmp = ToPlot.MVPA.beta(:,:,2,iCdt);
        else
            tmp = ToPlot.profile.beta(:,:,2,iCdt)*-1;
        end
        if isfield(ToPlot,'MinMax')
            ToPlot.MIN = ToPlot.MinMax{3,iCdt}(iColumn,1);
            ToPlot.MAX = ToPlot.MinMax{3,iCdt}(iColumn,2);
        end
        plot_betas(tmp,ToPlot,fontsize)
        
%         if iColumn==1 && iCdt==1
            t=ylabel(sprintf('linear\nS Param. est. [a u]'));
            set(t,'fontsize',fontsize);
%         end
        
        
        % plot whole ROI
        %         subplot (m,n,SubPlots{4,(iCdt-1)*2+iColumn})
        %  subplot(m,n,SubPlots{4,iColumn})
        %         hold on
        %         if iColumn==2
        %             ToPlot.Cst = 1;
        %             tmp = ToPlot.MVPA.grp(:,:,iCdt);
        %         else
        %             tmp = ToPlot.ROI.grp(:,:,iCdt);
        %         end
        %
        %         plot_betas(tmp,ToPlot,fontsize)
        %
        %         if iColumn==1 && iCdt==1
        %             ylabel(sprintf('whole ROI\nS Param. est. [a u]'));
        %             set(t,'fontsize',fontsize);
        %         end
        
    end
    
    mtit(ToPlot.Titles{iCdt,1},'xoff', 0, 'yoff', +0.04, 'fontsize', fontsize+4)
    
    print(fig, fullfile(ToPlot.FigureFolder, ['All_ROIs_' strrep(fig.Name,'\n','-'), suffix, '.tif']), '-dtiff')
    
end



end


function plot_betas(tmp,ToPlot,fontsize)

Alpha = 0.05;

Xpos = [1 3 6:2:14];

% plot zero line
if ToPlot.Cst
    plot([-25 25], [0.5 0.5], '-k','LineWidth', .8)
else
    plot([-25 25], [0 0], '-k','LineWidth', .8)
end

% plot spead
tmp_cell = mat2cell(tmp,size(tmp,1),ones(1,size(tmp,2)));
for i=1:numel(Xpos)
    distributionPlot(tmp_cell{i}, 'xValues', Xpos(i), 'color', ToPlot.line_colors(i,:), ...
        'distWidth', 1.2, 'showMM', 0, ...
        'globalNorm', 2)
    h = plotSpread(tmp_cell{i}, 'distributionMarkers',{'.'},...
        'xValues', (Xpos(i)), 'binWidth', 1, 'spreadWidth', 1);
    set(h{1}, 'MarkerSize', 7, 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'k', 'LineWidth', 1)
end

% plot mean+SEM
plot(Xpos-.8, nanmean(tmp), 'k. ', 'MarkerSize', 7)
for i=1:numel(Xpos)
    plot([Xpos(i)-.8;Xpos(i)-.8], ...
        [nanmean(tmp(:,i))+nansem(tmp(:,i));nanmean(tmp(:,i))-nansem(tmp(:,i))], ' k','LineWidth', 1.2 )
end


axis tight
ax = axis;
if isfield(ToPlot,'MinMax')
    MIN = ToPlot.MIN;
    MAX = ToPlot.MAX;
else
    MIN = ax(3);
    MAX = ax(4)*1.2;
end

if ToPlot.MVPA_BOLD==2 && ToPlot.Cst
    tmp=tmp-.5;
end

% now compute p values and print them
if ~isempty(ToPlot.ToPermute)
    for iPerm = 1:size(ToPlot.ToPermute,1)
        tmp2 = ToPlot.ToPermute(iPerm,:);
        tmp2 = repmat(tmp2',1,size(tmp,2));
        Perms(iPerm,:) = mean(tmp.*tmp2);  %#ok<*AGROW>
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
    if mod(iP,2)==0
        Y_offset = -.1;
    else
        Y_offset = 0;
    end
    
    Sig = []; %#ok<NASGU>
    if P(iP)<0.001
        Sig = sprintf('p<0.001 ');
    else
        Sig = sprintf('p=%.3f ',P(iP));
    end
    
    t = text(...
        Xpos(iP)-.8,...
        MAX + MAX*0.005 + Y_offset*(MAX-MIN),...
        sprintf(Sig));
    set(t,'fontsize',fontsize-2);
    
    if P(iP)<Alpha
        set(t,'fontweight','bold','fontsize',fontsize-1.5);
        %         set(t,'color','r','fontweight','bold');
    end
end


axis([-.4 14.8 MIN MAX])



set(gca, 'tickdir', 'out', 'xtick', Xpos,'xticklabel',ToPlot.ROIs_name, ...
    'ticklength', [0.01 0.01], 'fontsize', fontsize-1, 'FontName','Arial')

end
