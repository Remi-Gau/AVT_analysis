%%
clc; clear;

SamplingRate = 192000 ;

% Number of locations where sounds are going to be played.
AnglesPlayed = [-5 5];
NbLoc = length(AnglesPlayed);

StartDirectory = pwd;

SoundLengthList= {'2000'};

load(fullfile(StartDirectory, 'MIT_hrtf_database', 'normal_hrir_interpolated_el0.mat'));


%%
for iSndLgth=1:numel(SoundLengthList)
    
    SoundLength = SoundLengthList{iSndLgth};
    StimDuration = str2num(SoundLength)/1000 ; % In seconds
    
        
        for i=1:NbLoc
            
            hrirL = hrirL_int(:, find(azimuth_int==AnglesPlayed(i))) ;
            hrirR = hrirR_int(:, find(azimuth_int==AnglesPlayed(i))) ;
            
            % Sounds
            Sound = rand(1, SamplingRate * StimDuration);
            TukeyWin = tukeywin(length(Sound),0.15)';
            
            soundL = filter(hrirL', 1, Sound) ;
            soundR = filter(hrirR', 1, Sound) ;
            
            SoundFinal = [soundL.*TukeyWin ; soundR.*TukeyWin] ; % Saves
            SoundFinal = SoundFinal/max(abs(SoundFinal(:))) ; % scale sound [-1,1]
            
%             wavwrite(SoundFinal', SamplingRate, fullfile(StartDirectory, ...
%                 ['Sound_' SoundLength 'ms' ...
%                 '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min') '_Deg_' ...
%                 num2str(j) '_Rep.wav']));

            audiowrite(fullfile(StartDirectory, ...
                ['Sound_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min') '_Deg.wav']), ...
                SoundFinal', SamplingRate);
            end

    
end

