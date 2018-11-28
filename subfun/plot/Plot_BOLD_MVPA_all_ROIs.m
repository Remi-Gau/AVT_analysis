function Plot_BOLD_MVPA_all_ROIs(ToPlot)

fontsize = 9;

m=ToPlot.m;
n=ToPlot.n;
SubPlots=ToPlot.SubPlots;

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

if size(SubPlots,2)==3
    figdim = [50, 50, 1800, 800];
elseif size(SubPlots,2)==2
    figdim = [50, 50, 1200, 600];
end

for iRow = 1:size(ToPlot.Legend,1)
    
    fig = figure('Name', [Name '\n' ToPlot.Titles{iRow,1}], ...
        'Position', figdim, 'Color', [1 1 1], 'Visible', ToPlot.Visible);
    
    set(gca,'units','centimeters')
    pos = get(gca,'Position');
    ti = get(gca,'TightInset');
    
    set(fig, 'PaperUnits','centimeters');
    set(fig, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    set(fig, 'PaperPositionMode', 'manual');
    set(fig, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
    
    set(fig, 'Visible', ToPlot.Visible)
    
    for iColumn = 1:size(SubPlots,2)
        
        MVPA_BOLD = 1+ToPlot.IsMVPA(iRow,iColumn);
        ToPlot.Cst = 0;
        ToPlot.MVPA_BOLD = MVPA_BOLD;
        

        % plot profiles
        subplot(m,n,SubPlots{1,iColumn})
        PlotRectangle(6,fontsize-1)
        subplot(m,n,SubPlots{1,iColumn})
        
        hold on
        
        if MVPA_BOLD==2
            plot([-5 15], [0.5 0.5], '-k','linewidth',.8)
        else
            plot([-5 15], [0 0], '-k','linewidth',.8)
        end
        
        l=errorbar(...
            repmat((1:6)',1,NbROI)+repmat(linspace(-.2,.2,NbROI),6,1),...
            ToPlot.profile(iRow,iColumn).MEAN,...
            ToPlot.profile(iRow,iColumn).SEM);
        l2=plot(...
            repmat((1:6)',1,NbROI)+repmat(linspace(-.2,.2,NbROI),6,1),...
            ToPlot.profile(iRow,iColumn).MEAN);
        for iLine=1:numel(l)
            set(l(iLine),'color', line_colors(iLine,:))
            set(l2(iLine),'color', line_colors(iLine,:),'linewidth',2)
        end
        
        axis tight
        ax = axis;
        if isfield(ToPlot,'MinMax')
            MIN = ToPlot.MinMax{1,iRow}(iColumn,1);
            MAX = ToPlot.MinMax{1,iRow}(iColumn,2);
        else
            MIN = ax(3)-0.02;
            MAX = ax(4)+0.02;
        end
%         MIN = ax(3)-0.02;
%         MAX = ax(4)+0.02;
        axis([0.4 6.6 MIN MAX])
        
        t = title(ToPlot.Legend{iRow,iColumn});
        set(t,'fontsize',fontsize+1); clear t
        
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
        subplot(m,n,SubPlots{2,iColumn})
        
        hold on
        
        Data = ToPlot.profile(iRow,iColumn).beta(:,:,1);
        
        if isfield(ToPlot,'MinMax')
            ToPlot.MIN = ToPlot.MinMax{2,iRow}(iColumn,1);
            ToPlot.MAX = ToPlot.MinMax{2,iRow}(iColumn,2);
        end
        plot_betas(Data,ToPlot,fontsize,iRow,1)
        
        t=ylabel(sprintf('constant\nS Param. est. [a u]'));
        set(t,'fontsize',fontsize);
        
        
        
        % plot betas linear
        subplot(m,n,SubPlots{3,iColumn})
        
        hold on
        
        Data = ToPlot.profile(iRow,iColumn).beta(:,:,2);
        if MVPA_BOLD==1
            Data=Data*-1;
        end
        
        if isfield(ToPlot,'MinMax')
            ToPlot.MIN = ToPlot.MinMax{3,iRow}(iColumn,1);
            ToPlot.MAX = ToPlot.MinMax{3,iRow}(iColumn,2);
        end
        plot_betas(Data,ToPlot,fontsize,iRow,2)
        
        t=ylabel(sprintf('linear\nS Param. est. [a u]'));
        set(t,'fontsize',fontsize);
        
    end
    
    mtit(ToPlot.Titles{iRow,1},'xoff', 0, 'yoff', +0.04, 'fontsize', fontsize+4)
    
    print(fig, fullfile(ToPlot.FigureFolder, ['All_ROIs_' strrep(fig.Name,'\n','-'), suffix, '.tif']), '-dtiff')
    
    
end



end


function plot_betas(Data, ToPlot, fontsize, iCdt, S_param)

Alpha = 0.05/numel(ToPlot.ROIs_name);

Xpos = [1 3 6:2:14];
Xpos = Xpos(1:numel(ToPlot.ROIs_name));

% plot zero line
if ToPlot.Cst
    plot([-25 25], [0.5 0.5], '-k','LineWidth', .8)
else
    plot([-25 25], [0 0], '-k','LineWidth', .8)
end

% plot spead
tmp_cell = mat2cell(Data,size(Data,1),ones(1,size(Data,2)));
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
plot(Xpos-.8, nanmean(Data), 'k. ', 'MarkerSize', 7)
for i=1:numel(Xpos)
    plot([Xpos(i)-.8;Xpos(i)-.8], ...
        [nanmean(Data(:,i))+nansem(Data(:,i));nanmean(Data(:,i))-nansem(Data(:,i))], ' k','LineWidth', 1.2 )
end


axis tight
ax = axis;
if isfield(ToPlot,'MinMax')
    MIN = ToPlot.MIN;
    MAX = ToPlot.MAX;
else
    MIN = ax(3);
    MAX = ax(4)*1.1;
end

if ToPlot.MVPA_BOLD==2 && ToPlot.Cst
    Data=Data-.5;
end


for iROI = 1:size(Data,2)
    
    [~, P, ~] = run_t_perm_test(ToPlot, iCdt, iROI, S_param, Data(:,iROI));
    
    Sig = []; %#ok<NASGU>
    if P<0.001
        Sig = sprintf('p<0.001 ');
    else
        Sig = sprintf('p=%.3f ',P);
    end
    
    t = text(...
        Xpos(iROI)-.8,...
        MAX,...
        sprintf(Sig));
    set(t,'fontsize',fontsize-2);
    
    if P<Alpha
        set(t,'fontweight','bold','fontsize',fontsize-1.5);
        %         set(t,'color','r','fontweight','bold');
    end
end


axis([-.4 Xpos(end)+.8 MIN MAX])



set(gca, 'tickdir', 'out', 'xtick', Xpos,'xticklabel',ToPlot.ROIs_name, ...
    'ticklength', [0.01 0.01], 'fontsize', fontsize-1, 'FontName','Arial')

end
