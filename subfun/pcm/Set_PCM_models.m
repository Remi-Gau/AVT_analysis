function [Models_A, Models_V, h] = Set_PCM_models(Components, print, PCM_dir, FigDim)

h = [];

CondNames = {...
    'A contra','A ipsi',...
    'V contra','V ipsi',...
    'T contra','T ipsi'...
    };

fprintf('Preparing the different models\n')

%%
% Models_A(1).Cpts = 1;
Models_A(1).Cpts = [2];
Models_A(end+1).Cpts = [3 4 5];
Models_A(end+1).Cpts = [6];
Models_A(end+1).Cpts = [8];
Models_A(end+1).Cpts = [9 10];

% Models_A(end+1).Cpts = [2 6];
% Models_A(end+1).Cpts = [3 4 5 6];
% Models_A(end+1).Cpts = [2 8];
% Models_A(end+1).Cpts = [3 4 5 8];
% Models_A(end+1).Cpts = [2 9 10];
% Models_A(end+1).Cpts = [3 4 5 9 10];
% 
% Models_A(end+1).Cpts = [2 6 8];
% Models_A(end+1).Cpts = [3 4 5 6 8];
% Models_A(end+1).Cpts = [2 6 9 10];
% Models_A(end+1).Cpts = [3 4 5 6 9 10];


for iMod=1:numel(Models_A)
    Models_A(iMod).Cpts(Models_A(iMod).Cpts==5) = [];
    Models_A(iMod).Cpts(Models_A(iMod).Cpts>5) = Models_A(iMod).Cpts(Models_A(iMod).Cpts>5)-1;
end

%%
% Models_V(1).Cpts = 1;
Models_V(1).Cpts = [2];
Models_V(end+1).Cpts = [3 4 5];
Models_V(end+1).Cpts = [7];
Models_V(end+1).Cpts = [8];
Models_V(end+1).Cpts = [11 12];

% Models_V(end+1).Cpts = [2 7];
% Models_V(end+1).Cpts = [3 4 5 7];
% Models_V(end+1).Cpts = [2 8];
% Models_V(end+1).Cpts = [3 4 5 8];
% Models_V(end+1).Cpts = [2 11 12];
% Models_V(end+1).Cpts = [3 4 5 11 12];
% 
% Models_V(end+1).Cpts = [2 7 8];
% Models_V(end+1).Cpts = [3 4 5 7 8];
% Models_V(end+1).Cpts = [2 7 11 12];
% Models_V(end+1).Cpts = [3 4 5 7 11 12];

for iMod=1:numel(Models_V)
    Models_V(iMod).Cpts(Models_V(iMod).Cpts==5) = [];
    Models_V(iMod).Cpts(Models_V(iMod).Cpts>5) = Models_V(iMod).Cpts(Models_V(iMod).Cpts>5)-1;
end

%%
if print
    h(1) = figure('name', 'Models ROI_A', 'Position', FigDim, 'Color', [1 1 1]);
    for iMod=1:numel(Models_A)
        
        mat = sum(cat(3,Components(Models_A(iMod).Cpts).mat),3);
        
        subplot(3,5,iMod);
        
        colormap('gray');
        
        imagesc(mat)
        
        axis on
        set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
            'ytick', 1:6,'yticklabel', CondNames, ...
            'ticklength', [0.01 0], 'fontsize', 4)
        box off
        axis square
        
        Title = strrep(num2str(Models_A(iMod).Cpts),'  ', ' ');
        Title = strrep(Title,'  ', ' ');
        t=title(strrep(Title,' ', '+'));
        set(t, 'fontsize', 6);
        
    end
    mtit('Models for auditory ROIs', 'fontsize', 12, 'xoff',0,'yoff',.035);
%     print(gcf, fullfile(PCM_dir, 'Cdt', 'Models_for_auditory_ROIs.tif'), '-dtiff')
    
    
    h(2) = figure('name', 'Models ROI_V', 'Position', FigDim, 'Color', [1 1 1]);
    for iMod=1:numel(Models_V)
        
        mat = sum(cat(3,Components(Models_V(iMod).Cpts).mat),3);
        
        subplot(3,5,iMod);
        
        colormap('gray');
        
        imagesc(mat)
        
        axis on
        set(gca,'tickdir', 'out', 'xtick', 1:6,'xticklabel', [], ...
            'ytick', 1:6,'yticklabel', CondNames, ...
            'ticklength', [0.01 0], 'fontsize', 4)
        box off
        axis square
        
        Title = strrep(num2str(Models_V(iMod).Cpts),'  ', ' ');
        Title = strrep(Title,'  ', ' ');
        t=title(strrep(Title,' ', '+'));
        set(t, 'fontsize', 6);
        
    end
    mtit('Models for visual ROIs', 'fontsize', 12, 'xoff',0,'yoff',.035);
%     print(gcf, fullfile(PCM_dir, 'Cdt', 'Models_for_visual_ROIs.tif'), '-dtiff')
    
end

end

