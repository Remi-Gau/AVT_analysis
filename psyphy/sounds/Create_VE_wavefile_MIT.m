%%
clc; clear;

SamplingRate = 192000 ;

% Number of locations where sounds are going to be played.
AnglesPlayed = [-12 -10 -8 -5 -4 -3 -1 0 1 3 4 5 8 10 12];
NbLoc = length(AnglesPlayed);

StartDirectory = pwd;

SoundLengthList= {'50'};

load(fullfile(StartDirectory, 'MIT_hrtf_database', 'normal_hrir_interpolated_el0.mat'));


%%
for iSndLgth=1:numel(SoundLengthList)
    
    SoundLength = SoundLengthList{iSndLgth};
    StimDuration = str2num(SoundLength)/1000 ; % In seconds
    
    for j=1:10
        
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
                ['Sound_' SoundLength 'ms' ...
                '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min') '_Deg_' ...
                num2str(j) '_Rep.wav']), ...
                SoundFinal', SamplingRate);
        end
    end
    
end

return

% %% creates names list
% clc

SoundLengthList= {'50'};

for iSndLgth=1:numel(SoundLengthList)
    
    TEMP = {'50'};
    
    SoundList={};
    
    SoundLength = SoundLengthList{iSndLgth};
    
    for j=1:10
        
        for i=1:NbLoc
            SoundList{end+1,1} = ['Sound_' SoundLength 'ms' ...
                '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min') '_Deg_' ...
                num2str(j) '_Rep.wav']; %#ok<AGROW>
            
        end
        
    end
    
    B=[];
    A = char(SoundList);
    for i=1:size(A,1)
        B(i,:) = strrep(A(i,:), '.wav', ' '); %#ok<AGROW>
    end
    fprintf('array{\n')
    disp(...
        [repmat(['sound {wavefile { filename = "'], size(SoundList,1),1) A repmat(['"; } ; } '], size(SoundList,1),1) B repmat(';', size(SoundList,1),1)]) %#ok<NOPTS>
    fprintf(['} SOUNDS' TEMP{iSndLgth} ';\n\n'])
    
    
end

