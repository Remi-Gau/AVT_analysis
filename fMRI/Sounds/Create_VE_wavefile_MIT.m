%%
clc; clear;

SamplingRate = 192000 ;

% Number of locations where sounds are going to be played.
AnglesPlayed = [-15 -12 -10 -8 -5 -4 -3 -1 0 1 3 4 5 8 10 12 15];
NbLoc = length(AnglesPlayed);

%interpolate_hrir('mit', SamplingRate, AnglesPlayed, 0, 0)

SoundLengthList= {'200', '100', '80', '50'};

mkdir(fullfile(pwd, 'Sounds', 'MIT'));

load(fullfile(pwd, 'MIT_hrtf_database', 'normal_hrir_interpolated_el0.mat'));


%%
for iSndLgth=1:numel(SoundLengthList)
    
    SoundLength = SoundLengthList{iSndLgth};
    StimDuration = str2num(SoundLength)/1000 ; % In seconds
    TargetDuration = StimDuration/3 ; % In seconds
    
    for j=1:10
        
        for i=2:NbLoc-1
            
            hrirL = hrirL_int(:, i) ;
            hrirR = hrirR_int(:, i) ;
            
            % Sounds
            Sound = rand(1, SamplingRate * StimDuration);
            TukeyWin = tukeywin(length(Sound),0.15)';
            
            soundL = filter(hrirL', 1, Sound) ;
            soundR = filter(hrirR', 1, Sound) ;
            
            SoundFinal = [soundL.*TukeyWin ; soundR.*TukeyWin] ; % Saves
            SoundFinal = SoundFinal/max(abs(SoundFinal(:))) ; % scale sound [-1,1]
            
            wavwrite(SoundFinal', SamplingRate, fullfile(pwd, 'Sounds', ...
                'MIT', ['Sound_' SoundLength 'ms' ...
                '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min') '_Deg_' ...
                num2str(j) '_Rep.wav']));
            
            % Targets
            Target = rand(1, SamplingRate * TargetDuration);
            TukeyWinTarget = tukeywin(length(Target),0.15)';
            
            targetL = filter(hrirL', 1, Target) ;
            targetR = filter(hrirR', 1, Target) ;
            
            TargetFinal = [targetL.*TukeyWinTarget ; targetR.*TukeyWinTarget] ;
            TargetFinal = TargetFinal/max(abs(TargetFinal(:))) ; % scale sound [-1,1]
            
            TargetFinal = [TargetFinal zeros(size(TargetFinal)) TargetFinal]; %#ok<AGROW>
            
            wavwrite(TargetFinal', SamplingRate, fullfile(pwd, 'Sounds', ...
                'MIT', ['Target_' SoundLength 'ms' '_Location_' ...
                strrep(num2str(AnglesPlayed(i)), '-', 'min')  '_Deg_' ...
                num2str(j) '_Rep.wav']));
        end
    end
    
end

