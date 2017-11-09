%
% min translation
% max translation
% min TR-to-TR translation
% max TR-to-TR translation
% mean TR-to-TR translation +/- STD
%
% min rotation
% max rotation
% min TR-to-TR rotation
% max TR-to-TR rotation
% mean TR-to-TR rotation +/- STD
%
% max displacement
% mean displacement +/- STD
% max TR-to-TR displacement
% mean TR-to-TR displacement +/- STD
% number of points where TR-to-TR displacement exceeds a threshold
%
%
% Sounds like you have your answer, but if your analysis needs sensitivity
% to rotation and translation from SPM motion vectors, you might also be
% interested in the "Pythagorean Pythagorean Displacement and Motion Regressors" toolbox,
% on NITRC (http://www.nitrc.org/projects/pythagoras). It contains a single
% Matlab script that calculates head position and motion based on the rp*.txt
% motion summary generated during SPM-realignment, which keeps rotation and
% translation distinct for each vector. We've used those motion estimates to
% calculate subject differences in head motion similar to those suggested
% by Donald McLaren, although those were not built into the script per se.
%
%
% See Power et al. 2012, doi: 10.1016/j.neuroimage.2011.10.018.
% Spurious but systematic correlations in functional connectivity MRI networks arise from subject motion.
%
% Wilke Neuroimage 59 (2012)
% you can download the script after a brief registration at
% www.medizin.uni-tuebingen.de/kinder/en/research/neuroimaging/software/

%%
clear all; close all; clc;

CutOff=.4; % Threshold for detect excessive movement (rule of thumb is one voxel)

Collect = {};

cd ..

StartFolder = pwd;

mkdir(fullfile(pwd, 'Mvt_Analysis'))

XP_Folder = fullfile(pwd, 'Subjects_Data');

SubjectList = ['01'
               '02';
               '03';
               '06';
               '08';
               '09';
               '10';
               '11';
               '12'];        
        

%%   
for SubjInd = 1:size(SubjectList,1)
    
    close all;
    
    SubjID = SubjectList(SubjInd,:);
    fprintf('\n\nAnalyzing subject %s \n\n', SubjID);
    
    SubjFolder = fullfile(XP_Folder, SubjID);
    NiftiSourceFolder = fullfile(SubjFolder, 'Nifti', '1000');
    
    cd(NiftiSourceFolder)
    
    FileList = dir;
    IsFolder = [FileList(:).isdir];
    IsFolder(1:2) = 0;
    NbRuns = sum(IsFolder);
    IsRun = find(IsFolder);
    
    MovementRecap(SubjInd).SubjID=SubjID;   
    
    for IndRun=1:NbRuns
        fprintf('Session %i \n', IndRun)
        
        %%
        cd(FileList(IsRun(IndRun)).name)
        RP_File = dir('rp*.txt');
        RealignParameters = load(RP_File(1).name);
        
       
        figure('name', ['Realignment: Subject ' SubjID ' ; Run ' num2str(IndRun)], ...
            'Position', [0, 0, 1700, 1200], 'Visible', 'off', 'Color',[1 1 1])
        
        %%
        subplot(3,2,1)
        hold on;
        grid on;
        plot(1:length(RealignParameters(:,2)), RealignParameters(:,1), 'b', ...
            1:length(RealignParameters(:,2)), RealignParameters(:,2), 'g', ...
            1:length(RealignParameters(:,2)), RealignParameters(:,3), 'r', 'linewidth', 1)
        plot([1 size(RealignParameters,1)], [CutOff CutOff], '--r', ...
            [1 size(RealignParameters,1)], [-CutOff -CutOff], '--r')
        axis([1 size(RealignParameters,1) -CutOff*2 CutOff*2]);
        set(gca, 'FontSize', 8)
        xlabel('Volume #', 'FontSize', 8);
        ylabel('Translations (mm)', 'FontSize', 8);
        legend('Location','BestOutside','Orientation','vertical', 'x','y','z');
        legend('boxoff');

        
        subplot(3,2,2)
        hold on;
        grid on;
        plot(1:length(RealignParameters(:,2)), RealignParameters(:,4), 'b', ...
            1:length(RealignParameters(:,2)), RealignParameters(:,5), 'g', ...
            1:length(RealignParameters(:,2)), RealignParameters(:,6), 'r', 'linewidth', 1)
        V = axis;
        axis([1 size(RealignParameters,1) V(3) V(4)]);
        set(gca, 'FontSize', 8)
        xlabel('Volume #','FontSize', 8);
        ylabel('Rotations (rad)','FontSize', 8);
        legend('Location','BestOutside','Orientation','vertical', 'Pitch','Roll','Yaw');
        legend('boxoff');


        
        %%
        dxyz = Pythag_motion(fullfile(pwd,RP_File(1).name), 0);
        
        MovementRecap(SubjInd).Trans{IndRun} = dxyz(:,1);
        MovementRecap(SubjInd).Rot{IndRun} = dxyz(:,2);
        
        subplot(3,2,3);
        hold on;
        grid on;
        plot(dxyz(:,1),'r','linewidth', 1);
        plot(dxyz(:,3),'k','linewidth', 1);
        plot([1 size(RealignParameters,1)], [CutOff CutOff], '--r', ...
            [1 size(RealignParameters,1)], [-CutOff -CutOff], '--r')
        V = axis;
        axis([V(1) size(dxyz,1) -CutOff*2 CutOff*2]);
        set(gca, 'FontSize', 8)
        ylabel('Displacement: Translation (mm)','FontSize', 8);
        xlabel('Volume #','FontSize', 8);
        legend('Location','BestOutside','Orientation','vertical', 'Displacement','Derivative');
        legend('boxoff');

        % 'Mean scan to scan translation'
        MovementRecap(SubjInd).TR2TR_Trans{IndRun}=dxyz(:,3); 
        
        subplot(3,2,4)
        hold on;
        grid on;
        plot(dxyz(:,2),'r','linewidth',1);
        plot(dxyz(:,4),'k','linewidth',1);
        V = axis;
        yrange = V(4) - V(3); yadj = 0.25 * yrange;
        axis([V(1) size(dxyz,1) V(3)-yadj V(4)]);
        set(gca, 'FontSize', 8)
        ylabel('Displacement: Rotation Angle (deg)','FontSize', 8);
        xlabel('Volume #','FontSize', 8);
        legend('Location','BestOutside','Orientation','vertical', 'Displacement','Derivative');
        legend('boxoff');
        
        % 'Mean scan to scan rotation'
        MovementRecap(SubjInd).TR2TR_Rot{IndRun}=dxyz(:,4);
        
        % min translation
        % max translation
        % min TR-to-TR translation
        % max TR-to-TR translation
        % mean TR-to-TR translation +/- STD
        MovementRecap(SubjInd).Recaptable(IndRun,1:6) = [ min(dxyz(:,1)) max(dxyz(:,1)) ...
                                                            min(dxyz(:,3)) max(dxyz(:,3)) ...
                                                            mean(dxyz(:,3)) std(dxyz(:,3))];
        % min rotation
        % max rotation
        % min TR-to-TR rotation
        % max TR-to-TR rotation
        % mean TR-to-TR rotation +/- STD
        MovementRecap(SubjInd).Recaptable(IndRun,7:12) = [ min(dxyz(:,2)) max(dxyz(:,2)) ...
                                                            min(dxyz(:,4)) max(dxyz(:,4)) ...
                                                            mean(dxyz(:,4)) std(dxyz(:,4))];
        
        
        %%
        try
        [td, sts, davg] = mw_mfp(fullfile(pwd,RP_File(1).name), 1, 0, 0, 0, 0, 0, 1, []);
        
        % 'Mean scan to scan displacement'
        MovementRecap(SubjInd).TR2TR_Disp{IndRun}=sts{1};
        
        % 'Absolute maximum displacement'
        MovementRecap(SubjInd).AbsDisp{IndRun}=td{1};
        
        ExceedThresh=find(sts{1}>CutOff);
        TEMP=zeros(size(sts{1}));
        TEMP(ExceedThresh)=sts{1}(ExceedThresh);
        
        % 'Number of points where scan to scan motion exceeds voxel size'
        
        subplot(3, 2, [5 6])
        hold on;
        grid on;
        plot(td{1}, 'b', 'linewidth', 1);
        plot([1 size(RealignParameters,1)], [mean(td{1}) mean(td{1})], '-.b', 'linewidth', 1)
        bar(sts{1}, 'g');
        plot([1 size(RealignParameters,1)], [mean(sts{1}) mean(sts{1})], '-.g', 'linewidth', 1)
        if ~isempty(ExceedThresh)
            bar(TEMP, 'r');
        end
        plot([1 size(RealignParameters,1)], [CutOff CutOff], '--r')
        
        
        axis([1 size(RealignParameters,1) 0 max([CutOff*2 max(td{1}) max(sts{1})]) ]);
        V=axis;
        set(gca, 'FontSize', 8)
        ylabel('Total displacement (mm)','FontSize', 8);
        xlabel('Volume #','FontSize', 8);
        legend('Location','BestOutside','Orientation','vertical', 'Overall', 'Mean overall', 'Scan to scan', 'Mean scan to scan');
        legend('boxoff');
        
        text(size(RealignParameters,1)/5, V(4)-V(4)/10, ...
            ['Absolute maximum displacement: ' num2str(sprintf('%3.2f', max(td{1}))) ' mm'], ...
            'FontSize', 8)
        
        % max displacement
        % mean displacement +/- STD
        % max TR-to-TR displacement
        % mean TR-to-TR displacement +/- STD
        % number of points where TR-to-TR displacement exceeds a threshold
        MovementRecap(SubjInd).Recaptable(IndRun,13:19) = [ max(td{1}) ...
                                                            mean(td{1}) std(td{1}) ...
                                                            max(sts{1}) ...
                                                            mean(sts{1}) std(sts{1}) ...
                                                            length(ExceedThresh)];
        catch
        end
            

        %%
        cd ..
         
%         % save displacement and first order derivatives to one file
%         outtxtfile = fullfile(pwd,['Pythag_RealignParam_Total_Displacement_Run_', num2str(IndRun), '_', RP_File(1).name]);
%         dlmwrite(outtxtfile, [dxyz td{1}' sts{1}'], 'delimiter','\t');
%         %fprintf('File saved: %s \n\n',outtxtfile);
%         
%         % save the graph as tif graphic file
%         print(gcf, ['MovementAnalysisRun' num2str(IndRun) '.tif'], '-dtiffnocompression')
%         %fprintf('File saved: %s \n\n', ['MovementAnalysisRun' num2str(IndRun) '.tif']);
%         
%         clear dxyz td sts ExceedThresh TEMP
        print(gcf, fullfile(StartFolder, 'Mvt_Analysis', ['Subject_' SubjID '_Run_' num2str(IndRun) '.tif']), '-dtiffnocompression')
        
        
    end
    
    MovementRecap(SubjInd).Recaptable
    
    cd(StartFolder)
end


%%
SubjectList = ['01'
               '02';
               '03';
               '06';
               '08';
               '09';
               '10';
               '11';
               '12'];        
        
 Legends = {' ' 'min translation' 'max translation' 'min TR-to-TR translation' 'max TR-to-TR translation' 'mean TR-to-TR translation' 'STD TR-to-TR translation' ...
 'min rotation' 'max rotation' 'min TR-to-TR rotation' 'max TR-to-TR rotation' 'mean TR-to-TR rotation' 'STD TR-to-TR rotation' ...
 'max displacement' 'mean displacement' 'STD displacement' 'max TR-to-TR displacement' 'mean TR-to-TR displacement' 'STD TR-to-TR displacement' 'TR-to-TR displacement exceed threshold'};

SavedTxt = strcat('MvtRecap.csv');
fid = fopen (SavedTxt, 'w');

for i=1:length(Legends)
    fprintf (fid, '%s,', Legends{i});
end

fprintf (fid, '\n');

for SubjInd=1:length(MovementRecap)
    fprintf (fid, '\n\n');
    fprintf (fid, ['Subject ' SubjectList(SubjInd,:) '\n']);
    for Run=1:size(MovementRecap(SubjInd).Recaptable,1)
        fprintf (fid, ['Run ' num2str(Run) ',']);
        fprintf (fid, '%f,', MovementRecap(SubjInd).Recaptable(Run,:));
        fprintf (fid, '\n');
    end
end

fclose (fid);
