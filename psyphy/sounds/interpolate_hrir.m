function interpolate_hrir(database, fs, azimuth_int, elevation_int, debug)
%   Interpolates head-related impulse response (hrir) functions of the MIT 
% or CIPIC database optionally along azimuth and/or elevation values.
%
% If you do not want to interpolate along a given dimension, put scalar 
% instead of the interpolation values. The function also changes the sampling
% rate specified by fs. Note that interpolation can be done only on grids 
% that might be an issue with the MIT database, where azimuths are sampled 
% in different increments at different elevations. 
%
% Note:
% The values for interpolation must be within the sampled locations of the 
% original measurements, and error is thrown if it is not ensured. However,
% we have to note that the interpolation is not done using all the original
% samples (due to technical reasons), but only on a reduced number of samples
% that are closest to the interpolation range (found by dsearchn). We still
% might want to interpolate within the reduced samples effectively used, so
% a warning is displayed if it is not the case. Here is an example: 
%
% azimuth_int = [-22:0.5:22]; % values for interpolation range
% azimuth = [-80 -65 -55 -45:5:45 55 65 80]; % sampled locations in the database
% azimuth = azimuth(unique(dsearchn(azimuth', azimuth_int'))) % effectively used samples
%
% azimuth =
%
%   -20   -15   -10    -5     0     5    10    15    20
%
% Warning is displayed, since azimuth_int is outside of azimuth
%
% Solution 1:
% azimuth_int = [-20:0.5:20];
% azimuth = [-80 -65 -55 -45:5:45 55 65 80];
% azimuth = azimuth(unique(dsearchn(azimuth', azimuth_int')))
%
% azimuth =
%
%   -20   -15   -10    -5     0     5    10    15    20
%
% Solution 2:
% azimuth_int = [-23:0.5:23];
% azimuth = [-80 -65 -55 -45:5:45 55 65 80];
% azimuth = azimuth(unique(dsearchn(azimuth', azimuth_int')))
%
% azimuth =
%
%   -25   -20   -15   -10    -5     0     5    10    15    20    25
%
% Sampled locations in the MIT database:
% --------------------------------------
%
%     Elevation    Number of     Azimuth 
%                Measurements   Increment
%       -40           56           6.43
%       -30           60           6.00
%       -20           72           5.00
%       -10           72           5.00
%         0           72           5.00
%        10           72           5.00
%        20           72           5.00
%        30           60           6.00
%        40           56           6.43
%        50           45           8.00
%        60           36          10.00
%        70           24          15.00
%        80           12          30.00
%        90            1           x.xx 
%
% Sampled locations in the CIPIC database:
% ----------------------------------------
%
%   Azimuth = -80 -65 -55 -45:5:45 55 65 80;
%   Elevation = -45+5.625*(0:49);
%
% 28-10-2015 AM

if nargin < 5
    debug = 0; % figures are plotted in debug mode (it is now working in the current version)
end

if nargin < 4
    elevation_int = 0; % grid for interpolation or scalar if no interpolation
end

if nargin < 3
%     azimuth_int = -45:0.5:45; % grid for interpolation or scalar if no interpolation
     azimuth_int =[ -15 -12 -10  -8  -5  -4  -3  -1  0 1  3 4 5 8 10 12 15]
end

if nargin < 2
    fs = 192000; % frequency for resampling the original signal
end

close all

% Set path
% rootdir = fullfile(pwd, '..');
rootdir = pwd;
databasedir = fullfile(rootdir, [upper(database) '_hrtf_database']);
if ~isdir(databasedir)
    error('%s database is not found', upper(database));
end
        
switch database
    case 'mit'
        % Sampled elevation angles in the MIT database
        fname = getfname(databasedir, 'elev*');
        elevation = sort(cellfun(@str2num, strrep(fname, 'elev', ''))); % format and convert to double
        
        % Calculations separately for large and normal pinna
        pinna = {'L' 'large'; 'R' 'normal'}; % see MIT documentation
        
        % Read data in
        for p=1:length(pinna) % 2 for normal
            fprintf('%s pinna\n', pinna{p,2});
            [hrirR, hrirL, azimuth] = deal(cell(length(elevation), 1));
            for el=1:length(elevation) % 5 for 0°
                fprintf('elevation %d\n', elevation(el));
                % Sampled azimuth angles in the MIT database
                switch abs(elevation(el))
                    case {0 10 20}
                        azimuth{el} = -180:5:175;
                    case 30
                        azimuth{el} = -180:6:174;
                    case 40
                        azimuth{el} = -180:6.43:175;
                    case 50
                        azimuth{el} = -176:8:176;
                    case 60
                        azimuth{el} = -180:10:170;
                    case 70
                        azimuth{el} = -180:15:165;
                    case 80
                        azimuth{el} = -180:30:150;
                    case 90
                        azimuth{el} = 0;
                end
                                
                % Create left and right hrir
                workdir = fullfile(databasedir, ['elev', num2str(elevation(el))]);
                fname = getfname(workdir, [pinna{p,1} '*.wav']);
                wavazimuth = cellfun(@(x) str2num(x(end-7:end-5)), fname); % azimuth saved in wav file names
                for az=1:length(azimuth{el})
                    % Match azimuth with azimuth saved in file names
                    if azimuth{el}(az) < 0
                        id = find(wavazimuth == round(azimuth{el}(az) + 360));
                    else
                        id = find(wavazimuth == round(azimuth{el}(az)));
                    end
%                     [hrirR{el}(:,az), wavfs] = audioread(fullfile(workdir, fname{id})); % only wavread works with old Matlab versions
                    [hrirR{el}(:,az), wavfs] = wavread(fullfile(workdir, fname{id}));
                end
                fprintf('files read...');
                
                % Sanity check plot: visual inspection suggests, that the hrir is similar to the corresponding 
                % CIPIC one, but looks a bit cleaner & smoother
%                 if debug
%                     azid = ismember(azimuth{el}, -180:5:175);
%                     tid = 1:200; % time samples
%                     sanity_plot(hrirR{el}(tid,azid), azimuth{el}(azid), tid);
%                 end

                hrirR{el} = resample(hrirR{el}, fs, wavfs); % we upsample to be on the safe side
                fprintf('upsampling done\n');
                
                % Sanity check plot: visual inspection suggests that the upsampling is roughly ok
                % - there are some minor differences though...
%                 if debug
%                     az = ismember(azimuth{el}, -180:5:175);
%                     t = 1:2:400; % time samples
%                     sanity_plot(hrirR{el}(t,az), azimuth{el}(az), t);
%                 end
                
                hrirL{el} = fliplr(circshift(hrirR{el}, [-1, 2])); % recordings are assumed to be symmetrical, see MIT documentation
%                 hrirL{el} = fliplr(hrirR{el});
            end
            
            % Save hrir data
            %             save(fullfile(databasedir, [pinna{p,2} '_hrir']), 'hrirL', 'hrirR', 'azimuth', 'elevation', 'fs');
            %             fprintf('hrir data saved\n');
            
            % Check that the interpolation range is within the originally sampled locations 
            if min(elevation_int) < min(elevation) || max(elevation_int) > max(elevation)
                error('elevation_int is out of the originally recorded elevation locations');
            end
            
            % Find interested hrirs
            el =  unique(dsearchn(elevation, elevation_int'));
            elevation2 = elevation(el); % update elevation
            
            
            az = cell(size(el));
            for i=1:length(el)
                % Check that the interpolation range is within the originally sampled locations 
                if min(azimuth_int) < min(azimuth{el(i)}) || max(azimuth_int) > max(azimuth{el(i)})
                    error('azimuth_int is out of the originally recorded azimuth locations');
                end
                az{i} = unique(dsearchn(azimuth{el(i)}', azimuth_int'));
                hrirL{el(i)} = hrirL{el(i)}(:,az{i});
                hrirR{el(i)} = hrirR{el(i)}(:,az{i});
            end
            if length(elevation2) > 2 && range(cellfun(@(x) size(x, 1), az)) > 0 % ~all(cellfun(@(x) isempty(setdiff(x, az{1})), az))
                error('interpolation not possible due to the different sample sizes at the given azimuths/elevations')
            else
                azimuth2 = azimuth(el);
            end
            hrirL = hrirL(el);
            hrirR = hrirR(el);

            % Interpolate hrir (as a 3D array)
            fprintf('\ninterpolation is in process\n');
            if length(elevation_int) == 1
                [hrirL_int, shiftL] = interp_hrir(hrirL{:}, azimuth2{1}(az{1}), azimuth_int, [], [], debug);
                [hrirR_int, shiftR] = interp_hrir(hrirR{:}, azimuth2{1}(az{1}), azimuth_int, [], [], debug);
                filespec = sprintf('el%d', elevation_int(1));
            elseif length(elevation_int) == 2
                hrirL_int = cell(size(hrirL));
                for i=1:2
                   [hrirL_int{i}, shiftL] = interp_hrir(hrirL{i}, azimuth2{i}(az{i}), azimuth_int, [], [], debug);
                end
                hrirL_int = cat(3, hrirL_int{:});
                hrirR_int = cell(size(hrirR));
                for i=1:2
                   [hrirR_int{i}, shiftR] = interp_hrir(hrirR{i}, azimuth2{i}(az{i}), azimuth_int, [], [], debug);
                end
                hrirR_int = cat(3, hrirR_int{:});
                filespec = sprintf('el%d%d', elevation_int(1), elevation_int(2));
            elseif length(azimuth_int) == 1
                [hrirL_int, shiftL] = interp_hrir(cat(2, hrirL{:}), elevation2, elevation_int, [], [], debug);
                [hrirR_int, shiftR] = interp_hrir(cat(2, hrirR{:}), elevation2, elevation_int, [], [], debug);
                filespec = sprintf('az%d', azimuth_int(1));
            elseif length(elevation_int) > 2 && length(azimuth_int) > 2
                [hrirL_int, shiftL] = interp_hrir(cat(3, hrirL{:}), azimuth2{1}(az{1}), azimuth_int, elevation2, elevation_int, debug);
                [hrirR_int, shiftR] = interp_hrir(cat(3, hrirR{:}), azimuth2{1}(az{1}), azimuth_int, elevation2, elevation_int, debug);
                filespec = sprintf('az%d_el%d', max(azimuth_int), max(elevation_int));
            else
                error('interpolation is not implemented for this specific case, are yo usure you want to do that?')
            end
            fprintf('done...');
            
            % Sanity check plot: visual inspection suggests that the interpolation works well
%             if debug
%                 az = ismember(azimuth_int, -180:5:175); % -45:5:45 for CIPIC comparison
%                 el = find(ismember(elevation_int, -20:2:20));
%                 t = 1:2:400; % time samples
%                 figure;
%                 for i=1:length(el)
%                     plot_hrir(hrirR_int(t,az,el(i)), azimuth_int(az), t);
%                 end
%             end
            
            % Save interpolated hrir data
            hrirL_int = reshape(hrirL_int, [], length(azimuth_int), length(elevation_int)); % make sure that data is in the correct format
            hrirR_int = reshape(hrirR_int, [], length(azimuth_int), length(elevation_int));
            save(fullfile(databasedir, [pinna{p,2} '_hrir_interpolated_' filespec]), 'hrirL_int', 'hrirR_int', 'azimuth_int', 'elevation_int', 'fs');
            fprintf('data saved\n\n');
        end
        
    case 'cipic'
        % Load anthropometric data (only id is used)
        load(fullfile(databasedir, 'anthropometry', 'anthro.mat'));
        
        for s=1:length(id) % 12 for normal
            
            fprintf('Subject %d\n', id(s))
            
            % Load subject specific hrir files (only hrir_l and hrir_r are used)
            workdir = fullfile(databasedir, 'standard_hrir_database', sprintf('subject_%03d', id(s)));
            load(fullfile(workdir, 'hrir_final.mat'));
            
            % Sampled azimuth and elevation angles in CIPIC
            azimuth = [-80 -65 -55 -45:5:45 55 65 80];
            elevation = -45+5.625*(0:49);
            
            % Check that the interpolation range is within the originally sampled locations 
            if min(azimuth_int) < min(azimuth) || max(azimuth_int) > max(azimuth)
               error('azimuth_int is out of the originally recorded azimuth locations');
            end
            if min(elevation_int) < min(elevation) || max(elevation_int) > max(elevation)
               error('elevation_int is out of the originally recorded elevation locations');
            end
            
            % Find interested hrirs
            az = unique(dsearchn(azimuth', azimuth_int'));
            azimuth = azimuth(az); % update azimuth
            el = unique(dsearchn(elevation', elevation_int'));
            elevation = elevation(el); % update elevation
            hrirL = permute(hrir_l(az,el,:), [3 1 2]);
            hrirR = permute(hrir_r(az,el,:), [3 1 2]);
            [ntimes, nazimuths, nelevations] = size(hrirL); % get dimensions
            
            % Sanity check plot
%             if debug
%                 t = 1:200; % time samples
%                 figure;
%                 for i=1:length(elevation)
%                     plot_hrir(hrirR(t,:,i), azimuth, t);
%                 end
%             end
            
            % Upsample hrir (matrix-cell-matrix conversion needed, because resample works only on 2D arrays)
            fprintf('upsampling is in process...');
            if ismember(1, [nazimuths nelevations])
                hrirL = resample(squeeze(hrirL), fs, 44100);
                hrirR = resample(squeeze(hrirR), fs, 44100);
            else
                hrirL = squeeze(mat2cell(hrirL, ntimes, nazimuths, ones(nelevations, 1)));
                hrirR = squeeze(mat2cell(hrirR, ntimes, nazimuths, ones(nelevations, 1)));
                for i=1:nelevations
                    hrirL{i} = resample(hrirL{i}, fs, 44100);
                    hrirR{i} = resample(hrirR{i}, fs, 44100);
                end
                hrirL = cat(3, hrirL{:});
                hrirR = cat(3, hrirR{:});
            end
            fprintf('done\n');
            
            % Interpolation
            fprintf('interpolation is in process\n');
            if length(elevation_int) > 2 && length(azimuth_int) > 2
                [hrirL_int, shiftL] = interp_hrir(hrirL, azimuth, azimuth_int, elevation, elevation_int, debug);
                [hrirR_int, shiftR] = interp_hrir(hrirR, azimuth, azimuth_int, elevation, elevation_int, debug);
                filespec = sprintf('az%d_el%d%d', max(azimuth_int), min(elevation_int), max(elevation_int));
            else
                error('both azimuth and elevation grids should be provided, since the original hrirs will be anyway included in the interpolated dataset')
            end
            fprintf('\ndone...');

            % Sanity check plot: visual inspection suggests that the interpolation works well
%             if debug
%                 az = ismember(azimuth_int, -45:5:45);
%                 el = find(ismember(elevation_int, -20:2:20));
%                 t = 1:2:400; % time samples
%                 figure;
%                 for i=1:length(el)
%                     plot_hrir(hrirR_int(t,az,el(i)), azimuth_int(az), t);
%                 end
%             end
            
            % Save data
            hrirL_int = reshape(hrirL_int, [], length(azimuth_int), length(elevation_int)); % make sure that data is in the correct format
            hrirR_int = reshape(hrirR_int, [], length(azimuth_int), length(elevation_int));
            save(fullfile(workdir, ['hrir_interpolated_' filespec '.mat']), 'hrirL_int', 'hrirR_int', 'azimuth_int', 'elevation_int', 'fs');
            fprintf('data saved\n\n');
        end
end

end

function plot_hrir(hrir, azimuth, time)

[X, Y] = meshgrid(azimuth, time);
surf(X, Y, hrir);
% set(gcf, 'Position', [0 0 960 1080]); % 960 0 960 1080
xlabel('azimuth');
ylabel('time samples');
zlabel('sound level');
fprintf('[Press any key ... ');
pause;
fprintf(']\n');

end

function [hrir_int, shift_int] = interp_hrir(hrir, X, Xq, Y, Yq, debug)
% function [hrir_int, shift_int] = interp_hrir(hrir, X, Xq, Y, Yq, debug)
%
% Interpolates head-related impulse responses by
%    (a) time aligning
%    (b) using interp2/interp3
%    (c) restoring the time alignment
% Also returns the shift needed for time alignment
%
% Copyright (C) 2001 The Regents of the University of California
%
% 24-10-2013 AM adapted to do interpolation flexibly in 1 or 2 dimensions (X, Y)

% Make sure that hrir has correct dimensions
[ntimes, ndim2, ndim3] = size(hrir);
if ndim2 ~= length(X) || ndim3 > 1 && ndim3 ~= length(Y)
    error('wrong number of angles for the impulse response array');
end

% Check whether sample values are outside of query values for interpolation
if min(Xq) < min(X) || max(Xq) > max(X)
    warning('Query values for interpolation are out of the sampled values, see the help of interpolate_hrir');
end
if ndims(hrir) == 3
    if min(Yq) < min(Y) || max(Yq) > max(Y)
        warning('Query values for interpolation are out of the sampled values, see the help of interpolate_hrir');
    end
end
 
% Make sure that all the other variables are in column format
X = X(:)'; % row vector
Xq = Xq(:)'; % row vector
if ndims(hrir) == 3
    Y = Y(:); % column vector
    Yq = Yq(:); % column vector
end
times = (1:ntimes)'; % column vector

% Align hrir in time
[hrir_aligned, shift] = timealign(hrir);

% Interpolate shift
switch ndims(hrir)
    case 2
        shift_int = interp1(X, shift, Xq, 'spline');
    case 3
        shift_int = interp2(X, Y, shift, Xq, Yq, 'spline');
end

% if debug
%     figure;
%     for i=1:size(shift, 2)
%         clf;
%         subplot(1,2,1);
%         imagesc(azimuth, times, hrir_aligned(:,:,i));
%         title('Time-aligned input');
%         colormap gray;
%         subplot(1,2,2);
%         plot(azimuth, shift(:,i), 'o-');
%         title('Delays');
%         fprintf('[Press any key ... ');
%         pause;
%         fprintf(']\n');
%     end
% end

% Interpolate hrir
switch ndims(hrir)
    case 2
        hrir_int = interp2(X, times, hrir_aligned, Xq, times, 'cubic');
    case 3
        hrir_int = interp3(X, times, Y', hrir_aligned, Xq, times, Yq', 'cubic');
end

% Restore shift
[ntimes, ndim2, ndim3] = size(hrir_int);
for i=1:ndim2
    for j=1:ndim3
        hrir_int(:,i,j) = delaysinc(hrir_int(:,i,j), shift_int(j,i));
    end
end

end

function [haligned, shift] = timealign(h, leadin)
% [haligned, shift] = timealign(h, [leadin]);
% 
% Time aligns the columns of the impulse response array h.
% Begins by searching backward from global peak to 20% point.
% Then looks for an earlier peak no less than 30% in size.
% Precedes the peak by leadin samples.  Note that shift can
% be fractional.
% Copyright (C) 2001 The Regents of the University of California
%
% 23-10-2015 AM change in peak factors for more precise onset

if nargin < 1,
   fprintf('Format: [haligned, shift] = timealign(h, [leadin])\n');
   return;
end;

if nargin < 2,
   leadin = 10;
end;

[ntimes, ndim2, ndim3] = size(h);
peakfactor = 0.05; % 0.2
secondpeakfactor = 0.1; % 0.3
upfactor = 8;
kback = leadin * upfactor;

haligned = zeros(size(h));
shift = zeros(ndim3, ndim2);
for i=1:ndim3
    for j=1:ndim2                    % Back off from global peak
        hup = resample(h(:,j,i),upfactor,1);
        [hmax, kmax] = max(hup);
        kk = kmax;
        while kk > 0,
            kk = kk - 1;
            if hup(kk) < peakfactor*hmax,
                konset = kk;
                break;
            end;
        end;
        if kk == 0,
            fprintf('Error #1 in timealign: Problem finding the onset\n');
            konset = 1;
        end;
        
        [hmax2, kmax2] = max(hup(1:konset)); % Look for weaker earlier peak
        if hmax2 > secondpeakfactor*hmax,
            kk = kmax2;
            while kk > 0,
                kk = kk - 1;
                if hup(kk) < peakfactor*hmax2,
                    konset = kk;
                    break;
                end;
            end;
            if kk == 0,
                fprintf('Error #2 in timealign: Problem finding the onset\n');
                konset = 1;
            end;
        end;
        
        kstart = konset - kback;
        if kstart < 1,
            fprintf('Error #3 in timealign: Problem finding the onset\n');
            kstart = 1;
        end;
        
        hdown = resample(hup(kstart:upfactor*ntimes), 1, upfactor);
        haligned(:,j,i) = [hdown; zeros(ntimes-length(hdown), 1)];
        shift(i,j) = konset / upfactor;
    end
end

end

function delayed_sig = delaysinc(sig, ndelay)
% delayed_sig = delaysinc(sig, ndelay)
%    uses sinc interpolation to delay sig by ndelay samples,
%    where ndelay does NOT have to be an integer;
%    advances if ndelay < 0
% Copyright (C) 2001 The Regents of the University of California

if nargin < 2,
  fprintf('Format: delayed_sig = delaysinc(sig, ndelay)\n');
	return;
end;

colvec = 1;
if size(sig,1) == 1,
  colvec = 0;
	sig = sig';
end;

N = length(sig);
h = sinc((-N:N)-ndelay)';
delayed_sig = conv(sig,h);
delayed_sig = delayed_sig((N+1):2*N);

if ~colvec,
  delayed_sig = delayed_sig';
end

end

