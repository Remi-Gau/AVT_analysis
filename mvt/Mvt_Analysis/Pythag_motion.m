function [dxyz]=Pythag_motion(input_rpfile, plotting)
% Kenny Vaden
% March 23, 2012  (mod for redistrib 2013/02/20)
%
% SUMMARY: script used to calculate pythagorean displacement and motion,
%          based on the motion parameters output by SPM realignment.
%
%  INPUT: realignment parameters textfile    (rp*.txt)
% OUTPUT: pythagorean motion & displacement  (4 columns)
%
%   GOAL: reduce # of control variable DFs, improve GLM control for head motion.
%
% USEAGE: copy the subject's rp*.txt (motion parameter textfile) to the directory that
%         this script is located in, then edit the input filename below, and run using
%         a call as shown in this example:
%
%         > cd /images/vaden/example_dir/; clear all; pythag_motion.m



% % % % % % % % % % % % % % % % % % %

% does the input file exist?
if ~exist(input_rpfile,'file'); error(sprintf('file not found: %s',input_rpfile)); end;

if nargin<2; plotting = 0; end;


% read in motion parameters
motion_params = dlmread(input_rpfile);
motion_paramz = motion_params; % backup copy

% adjust params or minimum (so negative values don't throw off magnitude of motion)
for dd = 1:6; motion_params(:,dd) = motion_params(:,dd) - min(motion_params(:,dd)); end;

% PYTHAGOREAN THM
clear dxyz;
% displacement: translation dxyz(:,1), rotation dxyz(:,2)
dxyz(:,1) = (motion_params(:,1).^2 + motion_params(:,2).^2 + motion_params(:,3).^2).^0.5;
dxyz(:,2) = (motion_params(:,4).^2 + motion_params(:,5).^2 + motion_params(:,6).^2).^0.5;

% first order derivatives of translation dxyz(:,3) and rotation dxyz(:,4)
dxyz(:,3) = [ 0; diff(dxyz(:,1)) ];
dxyz(:,4) = [ 0; diff(dxyz(:,2)) ];

% center displacement vectors
dxyz(:,1) = dxyz(:,1) - mean(dxyz(:,1));
dxyz(:,2) = dxyz(:,2) - mean(dxyz(:,2));

% plotting - optional (disabled by default)
if (plotting == 1);
    
    subplot(2,1,1);
    for i = 1:3; plot(motion_paramz(:,i),'Color',[0.8 0.8 0.8],'linewidth',2); hold on; end;
    plot(dxyz(:,1),'r','linewidth',2); hold on;
    plot(dxyz(:,3),'k','linewidth',2); hold on;
    V = axis;
    yrange = V(4) - V(3); yadj = 0.25 * yrange;
    axis([V(1) V(2) V(3)-yadj V(4)]);
    title ('Pythagorean Displacement: Translation','FontSize',11,'FontWeight','Bold');
    ylabel('Translation {mm}','FontSize',11);
    xlabel('Volume #','FontSize',11);
    legend('Location','SouthEast','Orientation','horizontal','x translation','y translation','z translation','displacement','derivative');
    legend('boxoff');
    hold off;
        
    subplot(2,1,2)
    for i = 4:6; plot(motion_paramz(:,i),'Color',[0.8 0.8 0.8],'linewidth',2); hold on; end;
    plot(dxyz(:,2),'r','linewidth',2); hold on;
    plot(dxyz(:,4),'k','linewidth',2); hold on;
    V = axis;
    yrange = V(4) - V(3); yadj = 0.25 * yrange;
    axis([V(1) V(2) V(3)-yadj V(4)]);
    title ('Pythagorean Displacement: Rotation','FontSize',11,'FontWeight','Bold');
    ylabel('Rotation Angle {degrees}','FontSize',11);
    xlabel('Volume #','FontSize',11);
    legend('Location','SouthEast','Orientation','horizontal','pitch','roll','yaw','displacement','derivative');
    legend('boxoff');
    hold off;
    
    % filename
    [dname,fname,extn] = fileparts(input_rpfile);
    plotfile = fullfile(dname,sprintf('pythag_%s.tiff',fname));
    
    % save the graph as tif graphic file
    set(gcf, 'Position', [100 100 900 550]);
    saveas(gcf, plotfile, 'tiffn');
    disp(sprintf('file saved: %s',plotfile));
    
end

% save displacement and first order derivatives to one file
% [dname,fname,extn] = fileparts(input_rpfile); % filename
% outtxtfile = fullfile(dname,sprintf('pythag_%s.txt',fname));
% dlmwrite(outtxtfile, dxyz, 'delimiter','\t');
% disp(sprintf('file saved: %s',outtxtfile));
% 
% disp(sprintf('\nprogram complete ... \n'));

end