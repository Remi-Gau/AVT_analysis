%%
clc; clear;

% Creates sounds for all possible subjects
addpath(fullfile(pwd, 'CIPIC_hrtf_database'));
anthropDir = fullfile(pwd, 'CIPIC_hrtf_database', 'anthropometry');


SamplingRate = 192000 ;

azSampledAngles = -25:5:25 ; % angles at which hrir are sampled
interpAngles = -20:0.5:20 ; % angles at which hrir are to be interpolated
DefaultAnglesPlayed = [-25:5:-10 -9:1:9 10:5:25];

% Number of locations where sounds are going to be played.
AnglesPlayed = [-12 -10 -8 -5 -4 -3 -1 0 1 3 4 5 8 10 12];
NbLoc = length(AnglesPlayed);

SubjList = dir(fullfile(pwd, 'CIPIC_hrtf_database', 'standard_hrir_database', 'subject*'));

mkdir('Sounds');
mkdir(fullfile(pwd,'Sounds'));

SoundLengthList= {'50'};


%%
for iSndLgth=1:numel(SoundLengthList)

    SoundLength = SoundLengthList{iSndLgth};
    StimDuration = str2num(SoundLength)/1000 ; % In second


    for iSubj = 14 %1:length(SubjList)
        matchedSubj = SubjList(iSubj).name(end-2:end);
        disp(matchedSubj)

        mkdir(fullfile(pwd,'Sounds', SubjList(iSubj).name))

        hrirSubjDir = fullfile(pwd, 'CIPIC_hrtf_database', 'standard_hrir_database', ['subject_' matchedSubj]) ;

        % Interpolate the missing azimuth angles by using the relevant function in
        % the HRTF folder
        [hrirInt_l,hrirInt_r] = interpolateHRIR(hrirSubjDir, azSampledAngles, interpAngles, 0);

        for j=1:10

            for i=1:NbLoc
                % Audio stim creation by selecting closest interpolated HRIR
                % find hrir closest to aXDegr
                hrirIndex = find(abs(interpAngles - AnglesPlayed(i)) == min(abs(interpAngles - AnglesPlayed(i)))) ;

                hrirL = hrirInt_l(:, hrirIndex) ;
                hrirR = hrirInt_r(:, hrirIndex) ;

                % Sounds
                Sound = rand(1, SamplingRate * StimDuration);
                TukeyWin = tukeywin(length(Sound),0.15)';

                soundL = filter(hrirL', 1, Sound) ;
                soundR = filter(hrirR', 1, Sound) ;

                SoundFinal = [soundL.*TukeyWin ; soundR.*TukeyWin] ; % Saves
                SoundFinal = SoundFinal/max(abs(SoundFinal(:))) ; % scale sound [-1,1]

                wavwrite(SoundFinal', SamplingRate, fullfile(pwd, 'Sounds', ...
                    SubjList(iSubj).name, ['Sound_' SoundLength 'ms' ...
                    '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min') '_Deg_' ...
                    num2str(j) '_Rep.wav']));
            end
        end

    end

end

%% creates names list
clc

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


