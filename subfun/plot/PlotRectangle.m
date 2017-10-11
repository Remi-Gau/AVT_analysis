function PlotRectangle(NbLayers,Fontsize,LabelDepth)

if nargin<3 || isempty(LabelDepth)
    LabelDepth=1;
end

COLOR_Layer= flipud([
254,229,217;
252,187,161;
252,146,114;
251,106,74;
222,45,38;
165,15,21]);
COLOR_Layer = COLOR_Layer/255;

ax = gca;
axPos = ax.Position;
axPos(2) = axPos(2)-.02;
axPos(4) = .02;
axes('Position',axPos);

TEXT = round(linspace(0,100,NbLayers+2));
TEXT([1 end]) = [];
TEXT=fliplr(TEXT);

RecPos = linspace(0,0.9,NbLayers+1);

for i=1:size(COLOR_Layer,1)
    rectangle('Position', [RecPos(i) 0 diff(RecPos(1:2)) 1], 'facecolor', COLOR_Layer(i,:), 'edgecolor', 'w');
    if LabelDepth
        t = text(RecPos(i)+diff(RecPos(1:2))/2-.023,0.5,num2str(TEXT(i)));
        set(t,'fontsize',Fontsize-3);
    end
end

axis([0 0.9 0 1])

set(gca,'color', 'none', 'tickdir', 'out', 'xtick', [0 .9],'xticklabel',  {'wm/gm' 'gm/csf'}, ...
    'ytick', [],'yticklabel', [], ...
    'ticklength', [0.008 0], 'fontsize', 10)
end

