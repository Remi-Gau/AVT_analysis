function All_ROIs_BOLD_targets_surf_tables
clc; clear;

StartDir = fullfile(pwd, '..','..','..');
cd (StartDir)

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))
Get_dependencies('/home/rxg243/Dropbox/')
Get_dependencies('D:\Dropbox/')

FigureFolder = fullfile(StartDir, 'figures');

BOLD_resultsDir = fullfile(StartDir, 'results', 'profiles','surf');

SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers=6;

WithPerm = 1;
sets = {};
for iSub=1:NbSub
    sets{iSub} = [-1 1]; %#ok<*AGROW>
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];
if ~WithPerm
    ToPermute = [];
end

% ROIs = {
%     'A1'
%     'PT'
%     'V1'
%     'V2'
%     'V3'
%     'V4'
%     'V5'};
% NbROI = numel(ROIs);
% ROI_order_BOLD = [1 NbROI 2:NbROI-1];
% ROI_order_MVPA = [NbROI-1 NbROI 1:NbROI-2];

ROIs = {
    'A1'
    'PT'
    'V1'
    'V2'
    'V3'};
ROI_order_BOLD = [1 7 2:4];

TitSuf = {
    'Contra_&_Ipsi'
    'Contra_vs_Ipsi';...
    'Between_Senses';...
    };


% load BOLD 
load(fullfile(BOLD_resultsDir, strcat('ResultsSurfTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
AllSubjects_Data_BOLD = AllSubjects_Data;
clear AllSubjects_Data

load(fullfile(BOLD_resultsDir, strcat('ResultsSurfStimsTargetsPoolQuadGLM_l-', num2str(NbLayers), '.mat')), 'AllSubjects_Data') %#ok<*UNRCH>
AllSubjects_Data_BOLD_StimTarget = AllSubjects_Data;
clear AllSubjects_Data


SavedTxt = fullfile(FigureFolder, 'BOLD_targets_results');
if WithPerm
    SavedTxt = [SavedTxt '_perm.csv'];
else
    SavedTxt = [SavedTxt '_ttest.csv'];
end

fid = fopen (SavedTxt, 'w');

for iAnalysis= 1:numel(TitSuf)
    
    clear ToPrint
%     ToPrint.TitSuf = TitSuf{iAnalysis};
    ToPrint.ROIs_name = ROIs;
    ToPrint.OneSideTTest = {'both' 'both' 'both'};
    
    ToPrint.profile.beta=[];
    ToPrint.ROI.grp=[];
    
    ToPrint.ToPermute = ToPermute;
    
    
    %% Get BOLD
    switch iAnalysis
        
        case 1
            % Get BOLD data for Cdt-Fix Contra
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra);
            ToPrint = Get_data(ToPrint,Data,ROI_order_BOLD);
            
            ToPrint.IsMVPA = 0;
            ToPrint.Titles{1} = 'Auditory visual and tactile responses relative to fixation';
            ToPrint.Legend{1} = '[A-Fix]_{contra}';
            ToPrint.Legend{2} = '[V-Fix]_{contra}';
            ToPrint.Legend{3} = '[T-Fix]_{contra}';

            Print2TableROI(fid, ROIs, ToPrint)
            
            
            % Get BOLD data for Cdt-Fix Ipsi
            Data = cat(1,AllSubjects_Data_BOLD(:).Ispi);
            ToPrint = Get_data(ToPrint,Data,ROI_order_BOLD);
            
            ToPrint.Titles{1} = ' ';
            ToPrint.Legend{1} = '[A-Fix]_{ipsi}';
            ToPrint.Legend{2} = '[V-Fix]_{ipsi}';
            ToPrint.Legend{3} = '[T-Fix]_{ipsi}';
            
            Print2TableROI(fid, ROIs, ToPrint)
        
            
            
        case 3
            fprintf (fid, '\n\n\n\n\n');
            % Get BOLD data for Contra - Ipsi
            Data = cat(1,AllSubjects_Data_BOLD(:).Contra_VS_Ipsi);
            ToPrint = Get_data(ToPrint,Data,ROI_order_BOLD);
            
            ToPrint.IsMVPA = 0;
            ToPrint.Titles{1} = '[Contra-Ipsi]';
            ToPrint.Legend{1} = '[Contra-Ipsi]_A';
            ToPrint.Legend{2} = '[Contra-Ipsi]_V';
            ToPrint.Legend{3} = '[Contra-Ipsi]_T';
            
            Print2TableROI(fid, ROIs, ToPrint)

            
            
        case 2
            fprintf (fid, '\n\n\n\n\n');
            % Get BOLD data for between senses contrasts (contra)
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModContra);
            ToPrint = Get_data(ToPrint,Data,ROI_order_BOLD);
            
            ToPrint.IsMVPA = 0;
            
            ToPrint.Titles{1} = 'Contrast between sensory modalities';
            ToPrint.Legend{1} = '[A-V]_{contra}';
            ToPrint.Legend{2} = '[A-T]_{contra}';
            ToPrint.Legend{3} = '[V-T]_{contra}';
            
            Print2TableROI(fid, ROIs, ToPrint)

            % Get BOLD data for between senses contrasts (ipsi)
            Data = cat(1,AllSubjects_Data_BOLD(:).ContSensModIpsi);
            ToPrint = Get_data(ToPrint,Data,ROI_order_BOLD);
            
            ToPrint.IsMVPA = 0;
            
            ToPrint.Titles{1} = 'Contrast between sensory modalities';
            ToPrint.Legend{1} = '[A-V]_{ipsi}';
            ToPrint.Legend{2} = '[A-T]_{ipsi}';
            ToPrint.Legend{3} = '[V-T]_{ipsi}';
            
            Print2TableROI(fid, ROIs, ToPrint)
            
    end
    
    
end

fclose(fid);

cd(StartDir)

end

function Print2TableROI(fid, ROIs, ToPrint)

if ~isempty(ToPrint.ToPermute)
    Legends1 = {'', '', 'Constant', '','','','','','','','','','','','','','Linear','','','','','','','','','','','','','','Whole ROI'};
    Legends2 = {'', 'mean', '', '','STD','', '', 'p value', '', 'Hedge G bca','','',''};
else
    Legends1 = {'', '', 'Constant', '','','','','','','','','','','','','','','','','','Linear','','','','','','','','','','','','','','','','','','Whole ROI'};
    Legends2 = {'', 'mean', '', '','STD','', '', 't value','','p value', '', 'Hedge G bca','','',''};
end


if ~ToPrint.IsMVPA
    fprintf (fid, '%s\n', ToPrint.Titles{1});
else
    fprintf (fid, '\n\n');
end

% Legend 1
if ~ToPrint.IsMVPA
    fprintf (fid, 'BOLD profile,');
else
    fprintf (fid, 'Accuracy profile,');
end
for i=1:length(Legends1)
    fprintf (fid, '%s,', Legends1{i});
end
fprintf (fid, '\n');

% Legend 2
if ~ToPrint.IsMVPA
    fprintf (fid, '%s,', 'Contrast');
else
    fprintf (fid, '%s,', 'Classification');
end
fprintf (fid, '%s,','ROI');
for j=1:3
    for i=1:length(Legends2)
        fprintf (fid, '%s,', Legends2{i});
    end
    fprintf (fid, ',');
end

for iCdt = 1:size(ToPrint.profile.beta,4)
    
    % name of the classification or contrast
    fprintf (fid, '\n');
    fprintf (fid, '%s,', ToPrint.Legend{iCdt});
    
    for iROI = 1:numel(ROIs)
        
        % name of ROI
        fprintf (fid, '\n');
        fprintf (fid, ',%s,', ROIs{iROI});
        
        for S_param=1:3
            
            clear Data
            
            if S_param<3
                % 1rst dimension: subject
                % 2nd dimension: ROI
                % 3rd dimension: Cst, Lin
                % 4th dimension : different conditions (e.g A, V, T)
                Data = ToPrint.profile.beta(:,iROI,S_param,iCdt);
                if S_param==2
                    Data = Data*-1;
                end
            else
                % for whole ROI results
                Data = ToPrint.ROI.grp(:,iROI,iCdt);
            end
            
            % Print mean and STD
            fprintf (fid, ',%f,',nanmean(Data));
            fprintf (fid, ',(,');
            fprintf (fid, '%f,',nanstd(Data));
            fprintf (fid, '),,');
            
            % compute p value
            Alpha = 0.05;
            tmp = Data;
            if ToPrint.IsMVPA && S_param==3
                tmp = tmp-.5; % for the whole ROI accuracy, center it around .5
            end
            % now compute p values and print them
            % run permutation if needed
            if ~isempty(ToPrint.ToPermute)
                for iPerm = 1:size(ToPrint.ToPermute,1)
                    tmp2 = ToPrint.ToPermute(iPerm,:);
                    tmp2 = repmat(tmp2',1,size(tmp,2));
                    Perms(iPerm,:) = mean(tmp.*tmp2);  %#ok<*AGROW>
                end
            end
            
            % actual computation with one sided or not
            if isfield(ToPrint, 'OneSideTTest')
                
                % with sign permutation test
                if ~isempty(ToPrint.ToPermute)
                    if strcmp(ToPrint.OneSideTTest,'left')
                        %             P = sum(Perms<mean(tmp))/numel(Perms);
                        error('Not implemented')
                    elseif strcmp(ToPrint.OneSideTTest,'right')
                        %             P = sum(Perms>mean(tmp))/numel(Perms);
                        error('Not implemented')
                    elseif strcmp(ToPrint.OneSideTTest,'both')  
                        P = sum( ...
                            abs( Perms ) > ...
                            repmat( abs(mean(tmp)), size(Perms,1),1)  ) ...
                            / size(Perms,1) ;
                    end
                    
                else
                    % or ttest
                    [~,P,~,STATS] = ttest(tmp, 0, 'alpha', Alpha, 'tail', ToPrint.OneSideTTest{S_param});
                end
                
            else
                
                % If nothing is specified run a two sided test
                if ~isempty(ToPrint.ToPermute)
                    P = sum( ...
                        abs( Perms ) > ...
                        repmat( abs(mean(tmp)), size(Perms,1),1)  ) ...
                        / size(Perms,1) ;
                else
                    [~,P,~,STATS] = ttest(tmp, 0, 'alpha', Alpha);
                end
                
            end
            
            % print t value if t test
            if ~isempty(ToPrint.ToPermute)
            else
                fprintf (fid, '%f,,',STATS.tstat);
            end

             % print p value if t test
            if P<0.001
                fprintf (fid, '<.001,');
            else
                fprintf (fid, '%f,',P);
            end
            % Add a note in table to identify one sided tests
            if (isfield(ToPrint, 'OneSideTTest') && ~strcmp(ToPrint.OneSideTTest{S_param},'both'))
                fprintf (fid, '^a,');
            else
                fprintf (fid, ',');
            end
            
            % Print effect size
            CI = bootci(1000,{@(x) Unbiased_ES(x), tmp},'alpha',0.05,'type','bca');
            fprintf (fid, '[,%f,-,%f,]',CI(1),CI(2));
            fprintf (fid, ',');
            
            
        end
    end
end

end


function ToPrint = Get_data(ToPrint,Data,ROI_order)
ROI_idx = 1;
for iROI = ROI_order
    % Do not plot quadratic
    % 1rst dimension: subject
    % 2nd dimension: ROI
    % 3rd dimension: Cst, Lin
    % 4th dimension : different conditions (e.g A, V, T)
    ToPrint.profile.beta(:,ROI_idx,:,:) = shiftdim(Data(iROI).Beta.DATA(1:2,:,:),2);
    ToPrint.ROI.grp(:,ROI_idx,:) = Data(iROI).whole_roi_grp;
    ROI_idx = ROI_idx + 1;
end

end


function Data = Get_data_MVPA(ROIs,SubSVM,iSubSVM,SVM)
for iROI = 1:numel(ROIs)
    
    for iSVM = SubSVM(iSubSVM,:)
        
        Data(iROI).whole_roi_grp(:,iSVM+1-SubSVM(iSubSVM,1)) = SVM(iSVM).ROI(iROI).grp;
        
        Data(iROI).MEAN(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.MEAN(1:end)');
        Data(iROI).SEM(:,iSVM+1-SubSVM(iSubSVM,1)) = flipud(SVM(iSVM).ROI(iROI).layers.SEM(1:end)');
        Data(iROI).Beta.DATA(:,iSVM+1-SubSVM(iSubSVM,1),:) = ...
            reshape(SVM(iSVM).ROI(iROI).layers.Beta.DATA, [3,1,size(SVM(iSVM).ROI(iROI).layers.Beta.DATA,2)]);
        
    end
    
end
end

function du = Unbiased_ES(grp_data)
% from DOI 10.1177/0013164404264850
d = mean(grp_data)/std(grp_data);
nu = length(grp_data)-1;
G = gamma(nu/2)/(sqrt(nu/2)*gamma((nu-1)/2));
du = d*G;
end