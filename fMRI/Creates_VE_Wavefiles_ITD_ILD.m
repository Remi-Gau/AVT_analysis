clear all;
clc;

% Creates lateralized sound with ITD and/or ILD
setup.headwidth = 17;
setup.circumference = 59;

setup.headradius=setup.circumference/(2*pi);   % in metres

stim.loc = [10 4]; % in degrees
stim.duration = 0.05;
stim.audio.freq = 192000; % sampling frequency
audstim = repmat(rand(stim.audio.freq * stim.duration,1),1,1); % size Samples x 2

stim.ITD.soundspeed = 343; % in m/sec at 20C temperature

stim.audio.type = 'ITD'; %'ITD' 'ILD' 'ILDITD'

stim.ITD.level = sind(unique(abs(stim.loc))) * setup.headwidth / stim.ITD.soundspeed;

%delay = headRadius * (sind(azimuth) + (azimuth * pi / 180)) / soundSpeed;

switch stim.audio.type
    case {'ITD' 'ILDITD'}
        timeshift = round(stim.audio.freq * stim.ITD.level); % time shift for ITD manipulation
        
    otherwise
        timeshift = 0;
end

switch stim.audio.type
    case {'ILD' 'ILDITD'}
        audstimfft=fft(audstim,4*length(audstim));
        freq=linspace(0,stim.audio.freq/2,length(audstimfft)/2);
        % can't compute where the denominator goes through a pole
        %         Hl=[(1+cosd(max(stim.loc)+90))*freqall+2*stim.ITD.soundspeed/setup.headradius]./[freqall+2*stim.ITD.soundspeed/setup.headradius];
        %         Hr=[(1+cosd(max(stim.loc)-90))*freqall+2*stim.ITD.soundspeed/setup.headradius]./[freqall+2*stim.ITD.soundspeed/setup.headradius];
        for ss=1:length(stim.loc)
            Hl=[(1+cosd(stim.loc(ss)+90))*freq+2*stim.ITD.soundspeed/setup.headradius]./[freq+2*stim.ITD.soundspeed/setup.headradius];
            Hr=[(1+cosd(stim.loc(ss)-90))*freq+2*stim.ITD.soundspeed/setup.headradius]./[freq+2*stim.ITD.soundspeed/setup.headradius];
            Hlf=[Hl fliplr(Hl)];
            Hrf=[Hr fliplr(Hr)];
            
            audstiml=real(ifft(Hlf'.*audstimfft));
            audstimr=real(ifft(Hrf'.*audstimfft));
            audstimlear(:,ss)=audstiml(1:length(audstim));
            audstimrear(:,ss)=audstimr(1:length(audstim));
        end
    case {'ITD'}
        %audstimlear=repmat(audstim,[1 length(stim.loc)]);
        %audstimrear=repmat(audstim,[1 length(stim.loc)]);
end

SoundList = {};

switch stim.audio.type
    case {'ITD' 'ILDITD'}
        for ss=1:length(stim.loc)
            stim.audio.left{ss}(:,1) = audstim; % left ear; left sound
            stim.audio.left{ss}(:,2) = [zeros(timeshift(ss), 1); audstim(1:end-timeshift(ss),1)]; % right ear; left sound
            stim.audio.right{ss}(:,1) = [zeros(timeshift(ss), 1); audstim(1:end-timeshift(ss),1)]; % left ear; right sound
            stim.audio.right{ss}(:,2) = audstim(:,1); % right ear; right sound
            stim.audio.centre{ss}(:,1:2) = repmat(audstim, 1, 2);  % both ears; central sound
            
            wavwrite(stim.audio.left{ss}, stim.audio.freq, ...
                fullfile(pwd, ['Sound_ITD_Location_min', num2str(stim.loc(ss)) , '_Deg.wav']));
            
            SoundList{end+1,1} = ['Sound_ITD_Location_min', num2str(stim.loc(ss)) , '_Deg.wav'];
            
            wavwrite(stim.audio.right{ss}, stim.audio.freq, ...
                fullfile(pwd, ['Sound_ITD_Location_', num2str(stim.loc(ss)) , '_Deg.wav']));
            
            SoundList{end+1,1} = ['Sound_ITD_Location_', num2str(stim.loc(ss)) , '_Deg.wav'];
        end
end

B=[];
A = char(SoundList);
for i=1:size(A,1)
    B(i,:) = strrep(A(i,:), '.wav', ' ');
end
[repmat(['sound {wavefile { filename = "'], size(SoundList,1),1) A repmat(['"; } ; } '], size(SoundList,1),1) B repmat(';', size(SoundList,1),1)]
fprintf('\n')

