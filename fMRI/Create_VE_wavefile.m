%%
xSubj(1) = input('Head width? ');
xSubj(2) = input('Head heights? ');
xSubj(3) = input('Head depth? ');
xSubj(17) = input('Head circumference? ');
%xSubj = [17 23 22 59];

% Match subj head to database head
[matchedSubj]=choose_cipic_subject(xSubj,fullfile(pwd, 'CIPIC_hrtf_database'),1)

xSubj = [xSubj(1:3) xSubj(17)];
addpath(fullfile(pwd, 'CIPIC_hrtf_database'));
[matchedSubj] = matchSubject(xSubj,fullfile(pwd, 'CIPIC_hrtf_database', 'anthropometry'))

return

%% Creates sounds for all possible subjects
addpath(fullfile(pwd, 'CIPIC_hrtf_database'));
anthropDir = fullfile(pwd, 'CIPIC_hrtf_database', 'anthropometry');

SoundLength = '200'
StimDuration = .2 ; % In seconds
TargetDuration = StimDuration/3 ; % In seconds
SamplingRate = 192000 ;

Sound = rand(1, SamplingRate * StimDuration);
Target = rand(1, SamplingRate * TargetDuration);

TukeyWin = tukeywin(length(Sound),0.15)';
TukeyWinTarget = tukeywin(length(Target),0.15)';

azSampledAngles = -25:5:25 ; % angles at which hrir are sampled
interpAngles = -20:0.5:20 ; % angles at which hrir are to be interpolated
DefaultAnglesPlayed = [-25:5:-10 -9:1:9 10:5:25];


AnglesPlayed = [-10 -4 4 10]; % Number of locations where sounds are going to be played.
NbLoc = length(AnglesPlayed);

SubjList = dir(fullfile(pwd, 'CIPIC_hrtf_database', 'standard_hrir_database', 'subject*'));

mkdir('Sounds')
mkdir(fullfile(pwd,'Sounds'))

for iSubj = 1:length(SubjList)
    matchedSubj = SubjList(iSubj).name(end-2:end)
    
    mkdir(fullfile(pwd,'Sounds', SubjList(iSubj).name))
    
    hrirSubjDir = fullfile(pwd, 'CIPIC_hrtf_database', 'standard_hrir_database', ['subject_' matchedSubj]) ;
    
    % Interpolate the missing azimuth angles by using the relevant function in
    % the HRTF folder
    [hrirInt_l,hrirInt_r] = interpolateHRIR(hrirSubjDir, azSampledAngles, interpAngles, 0);
    
    for i=1:NbLoc
        % Audio stim creation by selecting closest interpolated HRIR
        % find hrir closest to aXDegr
        hrirIndex = find(abs(interpAngles - AnglesPlayed(i)) == min(abs(interpAngles - AnglesPlayed(i)))) ;
        
        hrirL = hrirInt_l(:, hrirIndex) ;
        hrirR = hrirInt_r(:, hrirIndex) ;
        
        
        % filter signal x by hrif
        soundL = filter(hrirL', 1, Sound) ;
        soundR = filter(hrirR', 1, Sound) ;
        
        SoundFinal = [soundL.*TukeyWin ; soundR.*TukeyWin] ; % Saves
        SoundFinal = SoundFinal/max(abs(SoundFinal(:))) ; % scale sound [-1,1]
        
        wavwrite(SoundFinal', SamplingRate, fullfile(pwd, 'Sounds', ...
            SubjList(iSubj).name, ['Sound_' SoundLength 'ms' '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min')  '_Deg.wav']));
        
        SoundList{i,1} = ['Sound_' SoundLength 'ms' '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min')  '_Deg.wav'];
        
        
        % filter signal x by hrif
        targetL = filter(hrirL', 1, Target) ;
        targetR = filter(hrirR', 1, Target) ;
        
        TargetFinal = [targetL.*TukeyWinTarget ; targetR.*TukeyWinTarget] ;
        TargetFinal = TargetFinal/max(abs(TargetFinal(:))) ; % scale sound [-1,1]
        
        TargetFinal = [TargetFinal zeros(size(TargetFinal)) TargetFinal];
        
        wavwrite(TargetFinal', SamplingRate, fullfile(pwd, 'Sounds', ...
            SubjList(iSubj).name, ['Target_' SoundLength 'ms' '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min')  '_Deg.wav']));
        
        TargetList{i,1} = ['Target_' SoundLength 'ms' '_Location_'  strrep(num2str(AnglesPlayed(i)), '-', 'min')  '_Deg.wav'];
    end
    
end

%% creates names list
B=[];
A = char(SoundList);
for i=1:size(A,1)
    B(i,:) = strrep(A(i,:), '.wav', ' ');
end
[repmat(['sound {wavefile { filename = "'], size(SoundList,1),1) A repmat(['"; } ; } '], size(SoundList,1),1) B repmat(';', size(SoundList,1),1)]
fprintf('\n')

B=[];
A = char(TargetList);
for i=1:size(A,1)
    B(i,:) = strrep(A(i,:), '.wav', ' ');
end
[repmat(['sound {wavefile { filename = "'], size(SoundList,1),1) A repmat(['"; } ; } '], size(SoundList,1),1) B repmat(';', size(SoundList,1),1)]
fprintf('\n')

return

%%
StimDuration = 3 ; % In seconds
SamplingRate = 192000 ;
Sound = rand(1, SamplingRate * StimDuration);

wavwrite([Sound;zeros(1, SamplingRate * StimDuration)]' , SamplingRate, fullfile(pwd, 'Left.wav'));
wavwrite([zeros(1, SamplingRate * StimDuration);Sound]' , SamplingRate, fullfile(pwd, 'Right.wav'));        