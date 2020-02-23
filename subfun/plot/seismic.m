function rgb = seismic(n)

% seismic(n) creates a colormap, ranging from dark blue via white to dark red.
%
% Nico Sneeuw
% Munich, 31/08/94

if nargin == 0, n = size(get(gcf,'colormap'),1); end

m = ceil(n/3);
top = ones(m,1);
bot = zeros(m,1);
up = (0:m-1)'/m;
down = flipud(up);

r = [bot; up; 1; top; down];
g = [bot; up; 1; down; bot];
b = [up; top; 1; down; bot];
rgb = [r g b];

% rgb-map has size 4m+1 now. The central part will be extracted.

xlarge = 4*m+1-n;
xblue = round(xlarge/2);
xred = xlarge - xblue;
rgb([1:xblue 4*m-xred+2:4*m+1],:) = [];


% SavedTxt = '/home/rxg243/Programs/Paraview/ParaView-4.1.0-Linux-64bit/bin/seismic.xml';
% SavedTxt = 'D:\Dropbox\PhD\Experiments\MVPA_A_V_T\derivatives\code\subfun\plot\seismic.xml';
% fid = fopen (SavedTxt, 'w');
% 
% fprintf (fid, '<ColorMaps>\n');
% fprintf (fid, '<ColorMap space="Diverging" indexedLookup="false" name="seismic">\n');
% for i=1:size(rgb,1)  
%     fprintf (fid, '<Point x="%i" o="1" r="%f" g="%f" b="%f"/> \n',i,rgb(i,1),rgb(i,2),rgb(i,3));
% end    
% fprintf (fid, '<NaN r="1.0" g="1.0" b="1.0"/>\n');
% fprintf (fid, '</ColorMap>\n');
% fclose (fid);

%   <ColorMap space="Diverging" indexedLookup="false" name="Diverging">
%     <Point x="0" o="0" r="0.231373" g="0.298039" b="0.752941"/>
%     <Point x="0.5" o="0" r="0.865003" g="0.865003" b="0.865003"/>
%     <Point x="1" o="1" r="0.705882" g="0.0156863" b="0.14902"/>
%     <NaN r="0.247059" g="0" b="0"/>
%   </ColorMap>
% </ColorMaps>