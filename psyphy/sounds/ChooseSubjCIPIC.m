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