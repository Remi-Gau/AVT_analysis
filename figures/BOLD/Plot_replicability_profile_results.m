clc; clear;

StartDir = fullfile(pwd, '..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))
Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

load(fullfile(StartDir,'RunsPerSes.mat'))

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

CondNames = {...
    'AStimL','AStimR',...
    'VStimL','VStimR',...
    'TStimL','TStimR'...
    %     'ATargL','ATargR';...
    %     'VTargL','VTargR';...
    %     'TTargL','TTargR';...
    };

Col = reshape(1:18,3,6)';

set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')
FigDim = [50, 50, 1300, 600];
ColorMap = seismic(1000);

HS = 'LR';

ROI(1).name = 'A1';
ROI(2).name = 'PT';
ROI(3).name = 'V1';
ROI(4).name = 'V2';
ROI(5).name = 'V3';




%% Plot results session by session
clc
close all

FigureFolder = fullfile(StartDir, 'figures', 'profiles', 'surf', 'replicability', 'run2run');
mkdir(FigureFolder)

set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')

FigDim = [50, 50, 1300, 600];


HS = 'LR';

for  iSub = [1:4 6:NbSub] %[1:4 6:NbSub]
    
    Col = reshape(1:(6*sum(RunPerSes(iSub).RunsPerSes)),...
        sum(RunPerSes(iSub).RunsPerSes),6)';
    
    Subcol = [0 cumsum(RunPerSes(iSub).RunsPerSes)];
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    Results_dir = fullfile(Sub_dir, 'results', 'profiles', 'surf', 'correlations');
    load(fullfile(Results_dir,[SubLs(iSub).name '-Day2DayCorrelation.mat']), ...
        'Profile_Mean', 'Profile_Median')
    
    close all
    
    for iROI = 1:5
        
        MAX_DAY = [];
        MIN_DAY = [];
        
        %% plot run to run
        for hs = 1:2
            
            Data2Plot = Profile_Median(:,:,hs,iROI);
            % Profile_Mean
            
            MAX = max(Data2Plot(:));
            MIN = min(Data2Plot(:));
            
            opt.FigNameRun = sprintf('%s - Run2RunCorrelation - Profile - %s - Hemisphere %s', ...
                SubLs(iSub).name, ROI(iROI).name, HS(hs));
            
            figure('name', opt.FigNameRun, ...
                'Position', FigDim, 'Color', [1 1 1]);
            
            iSubplotRun = 1;
            
            for iCdt = 1:numel(CondNames)
                
                tmp = Data2Plot(:,Col(iCdt,:));
                
                for iDay = 1:3
                    
                    subplot(3,6,iSubplotRun+6*(iDay-1))
                    hold on
                    
                    plot( repmat( (1:6)', 1, length(Subcol(iDay)+1:Subcol(iDay+1)) ), ...
                        tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)), ...
                        'color', [0.5, 0.5,0.5])
                    
                    plot(1:6, mean(tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)),2), '-k',...
                        'linewidth', 1.5)
                    
                    MAX_DAY(end+1) = max ( mean( tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)), 2  ) + ...
                        nanstd(tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)), 2 ) );
                    
                    MIN_DAY(end+1) = min ( mean( tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)), 2 )- ...
                        nanstd( tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)), 2 ) );
                    
                    plot([1 6],[0 0], '--k')
                    
                    axis tight
                    ax = axis;
                    axis([0.5 6.5 MIN MAX])
                    
                    if iDay==1
                        title(CondNames{iCdt})
                    end
                    
                    if iCdt == 1
                        if iDay==1
                            ylabel(['Day ' num2str(iDay)])
                        elseif iDay==2
                            ylabel(sprintf('Hemisphere %s\nDay %i' , HS(hs), iDay))
                        else
                            ylabel(['Day ' num2str(iDay)])
                        end
                    end
                    
                    set(gca,'tickdir', 'out', 'ticklength', [0.02 0.02], 'fontsize', 8, ...
                        'xtick', [0.75 1:6 6.25] ,'xticklabel', ...
                        {'WM' '' '' '' '' '' '' 'CSF'},...
                        'ytick', -5:1:5 ,'yticklabel', -5:1:5, 'ygrid', 'on')
                    
                end
                
                iSubplotRun = iSubplotRun + 1;
                
            end
            
            mtit(opt.FigNameRun, 'fontsize', 12, 'xoff',0,'yoff',.035)
            
            print(gcf, fullfile(FigureFolder, [strrep(opt.FigNameRun, ' ', '') '.tif']), '-dtiff')
            
        end
        
        
        %% plot day to day
        opt.FigNameDay = sprintf('%s - Day2DayCorrelation - Profile - %s', ...
            SubLs(iSub).name, ROI(iROI).name);
        
        figure('name', opt.FigNameDay, ...
            'Position', FigDim, 'Color', [1 1 1]);
        
        iSubplotDay = 1;
        
        for hs = 1:2
            
            Data2Plot = Profile_Median(:,:,hs,iROI);
            
            for iCdt = 1:numel(CondNames)
                
                subplot(2,6,iSubplotDay)
                hold on
                
                tmp = Data2Plot(:,Col(iCdt,:));
                
                for iDay = 1:3
                    
                    errorbar((1:6)+.2*(iDay-1), mean(tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)),2), ...
                        nanstd(tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)),2), ...
                        '-k')
                    
                    plot((1:6)+.2*(iDay-1), mean(tmp(:,(Subcol(iDay)+1):Subcol(iDay+1)),2), ...
                        '-k', 'linewidth', 1.5)
                    
                    plot([1 6],[0 0], '--k')
                    
                end
                
                axis tight
                ax = axis;
                axis([0.5 7.2 min(MIN_DAY) max(MAX_DAY)])
                
                set(gca,'tickdir', 'out', 'ticklength', [0.02 0.02], 'fontsize', 8, ...
                    'xtick', [0.75 1.2:6.2 6.65] ,'xticklabel', ...
                    {'WM' '' '' '' '' '' '' 'CSF'},...
                    'ytick', -5:1:5 ,'yticklabel', -5:1:5, 'ygrid', 'on')
                
                if hs==1
                    t = title(CondNames{iCdt});
                    set(t,'fontsize', 12)
                end
                
                if iCdt==1
                    t = ylabel(['Hemisphere ' HS(hs)]);
                    set(t,'fontsize', 12)
                end
                
                iSubplotDay = iSubplotDay + 1;
                
            end
        end
        
        mtit(opt.FigNameDay, 'fontsize', 12, 'xoff',0,'yoff',.035)
        
        print(gcf, fullfile(FigureFolder, [strrep(opt.FigNameDay, ' ', '') '.tif']), '-dtiff')
        
    end
end
