function PlotROIForFig(DATA)


if nargin<1
    error('No data to plot')
    return; %#ok<UNRCH>
end

Fontsize = 12;

Transparent = 1;

% Color for Subjects
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


%%

Name = strrep(DATA.Name, ' ', '_');
Name = strrep(Name, '_', '-');
Visible = DATA.Visible;

Mean = DATA.Data.whole_roi_MEAN;
ErrorBar = DATA.Data.whole_roi_SEM;

NbCdts = size(Mean,2);

switch NbCdts
    case 9
        m=3; n=3;
    case 6
        if DATA.MVPA
            m=2; n=3;
        else
            m=3; n=2;
        end
    case 3
        m=1; n=3;
end
SubPlotOrder = DATA.SubPlotOrder;
Legend = DATA.Legend;

if DATA.PlotSub
    Subjects = DATA.Data.whole_roi_grp;
    NbSubjects = size(Subjects,1);
end

ToPermute = DATA.ToPermute;
if isempty(ToPermute)
    suffix = '_ttest';
else
    suffix = '_perm';
end

Scatter = linspace(0,.3,NbSubjects);

if DATA.PlotSub
    MAX = max(Subjects(:));
    MIN = min(Subjects(:));
else
    MAX = max(Mean(:)+ErrorBar(:));
    MIN = min(Mean(:)+ErrorBar(:));
end

%%
fig = figure('Name', Name, 'Position', [100, 100, 1500, 1000], 'Color', [1 1 1], 'Visible', Visible);

box off

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(fig, 'PaperUnits','centimeters');
set(fig, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(fig, 'PaperPositionMode', 'manual');
set(fig, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

set(fig, 'Visible', Visible)

for iCdt = 1:NbCdts
    %% Plot main data
    subplot(m,n,iCdt)
    
    hold on; grid on;
    
    errorbar(1, Mean(SubPlotOrder(iCdt)),ErrorBar(SubPlotOrder(iCdt)), 'o', 'LineWidth', 1, 'Color', 'k')
    
    for SubjInd = 1:NbSubjects        
                plot(1.05+Scatter(SubjInd), Subjects(SubjInd,SubPlotOrder(iCdt)), ...
            'linestyle', 'none', ...
            'Marker', '.', 'MarkerEdgeColor', COLOR_Subject(SubjInd,:), ...
            'MarkerFaceColor', COLOR_Subject(SubjInd,:), 'MarkerSize', 28)
    end

    
    if DATA.MVPA
        plot([0 2], [0.5 0.5], '--k', 'LineWidth', 1)
    else
        plot([0 2], [0 0], '-k', 'LineWidth', 1)
    end
    
    
    if DATA.MVPA
        tmp = Subjects(:,SubPlotOrder(iCdt))-.5;
        ES =  abs(nanmean(Subjects(:,SubPlotOrder(iCdt))-.5)/nanstd(Subjects(:,SubPlotOrder(iCdt))-.5));
    else
        tmp = Subjects(:,SubPlotOrder(iCdt));
        ES =  abs(nanmean(Subjects(:,SubPlotOrder(iCdt)))/nanstd(Subjects(:,SubPlotOrder(iCdt))));
    end
    
    if ~isempty(ToPermute)
            for iPerm = 1:size(ToPermute,1)
                tmp2 = ToPermute(iPerm,:);
                Perms(iPerm,:) = mean(tmp'.*tmp2); %#ok<*SAGROW>
            end
    end
    
    if isfield(DATA, 'OneSideTTest')
        if ~isempty(ToPermute)
            if strcmp(DATA.OneSideTTest,'left')
                P = sum(Perms<mean(tmp))/numel(Perms);
            elseif strcmp(DATA.OneSideTTest,'right')
                P = sum(Perms>mean(tmp))/numel(Perms);
            elseif strcmp(DATA.OneSideTTest,'both')
                P = sum( abs((Perms-mean(Perms))) > abs((mean(tmp)-mean(Perms))) ) / numel(Perms) ;
            end
        else
            [~,P] = ttest(tmp, 0, 'alpha', 0.05, 'tail', DATA.OneSideTTest);
        end
    else
        if ~isempty(ToPermute)
            P = sum( abs((Perms-mean(Perms))) > abs((mean(tmp)-mean(Perms))) ) / numel(Perms) ;
        else
            [~,P] = ttest(tmp, 0, 'alpha', 0.05);
        end
    end
    
    
    Sig = [];
    if P<0.001
        Sig = sprintf('ES=%.3f \np<0.001 ',ES);
    else
        Sig = sprintf('ES=%.3f \np=%.3f ',ES, P);
    end
    
    t = text(1,MAX-MAX*25/100,sprintf(Sig));
    set(t,'fontsize',Fontsize-2);
    
    if P<0.05
        set(t,'color','r');
    end
    
    clear Sig
    
    
    set(gca,'tickdir', 'out', 'xtick', [] , ...
        'xticklabel', [], 'ticklength', [0.01 0.01], 'fontsize', Fontsize)

    t=ylabel(Legend{SubPlotOrder(iCdt)}{1});
    set(t,'fontsize',Fontsize+2);
    
    t=title(Legend{SubPlotOrder(iCdt)}{2});
    set(t,'fontsize',Fontsize);
    
    axis([0.95 1.4 MIN MAX])
    
    
    
end

mtit(sprintf(Name), 'xoff', 0, 'yoff', +0.03, 'fontsize', 12)
set(fig, 'Visible', Visible)

print(fig, fullfile(DATA.FigureFolder, strcat(strrep(Name,'\n','-'), suffix, '.pdf')), '-dpdf')
print(fig, fullfile(DATA.FigureFolder, strcat(strrep(Name,'\n','-'), suffix, '.tif')), '-dtiff')

end
