function [EyeData] = TobiiEyeTrackCalib(EyeData, Opt)

% This script requires the herrorbar function to run

SamplingFreq = Opt.SamplingFreq; % in Hz

ElevationLvls = Opt.ElevationLvls;
AzimuthLvls = Opt.AzimuthLvls;

CalibDur = Opt.CalibDur;
PreCalibDur = Opt.PreCalibDur;
PostCalibDur = Opt.PostCalibDur;
Color=Opt.Color;

PPD = Opt.PPD;

NbCalibPts = numel(ElevationLvls)*numel(AzimuthLvls);

NbSD = Opt.NbSDCalib;

FigDim = Opt.FigDim;


Time = EyeData.Time;
Pos_x = EyeData.Pos_x; 
Pos_y = EyeData.Pos_y; 
Pup_x_diameter = EyeData.Pup_x_diameter;
Pup_y_diameter = EyeData.Pup_y_diameter;
Blink = EyeData.Blink;
Marker = EyeData.Marker;


%% Calibration overview
CalibStart = find(Marker==1);
% Try to estimate when the calibration ended. If we mess up we take
% the last recorded time stamp as our calibration end.
CalibEnd = find(Time>Time(CalibStart)+NbCalibPts*(CalibDur+PreCalibDur+PostCalibDur)+2000, 1, 'first');
if isempty(CalibEnd)
    CalibEnd = numel(Time);
end

% Find the onset and offsets of the calibration tirals
TrialsStarts = find(Marker(1:CalibEnd),NbCalibPts*2,'first');

fprintf('Analysing calibration data\n')
CalibDataSamples = CalibStart:CalibEnd;
CalibtionDur = Time(CalibEnd)-Time(CalibStart);
PercentMissingDataCalib = round ( ( round(CalibtionDur/(1000/SamplingFreq)) - numel(CalibDataSamples) ) / numel(CalibDataSamples) * 100 );
fprintf(' Missing %i percent of %i seconds recording.\n', PercentMissingDataCalib, round(CalibtionDur/1000) )



%% A figure to show the raw data
% the red circle materialises the markers for the onset and offset
% of each fixation trial

figure('name', 'Overview fixation', 'position', FigDim)

xAxisLabel = Time(CalibDataSamples( round(linspace(1,length(CalibDataSamples),10))));

subplot(321)
hold on
plot(Time(CalibDataSamples), Pos_x(CalibDataSamples))
plot(Time(TrialsStarts), Pos_x(TrialsStarts),'or')
set(gca, 'xtick', xAxisLabel, ...
    'xticklabel', round(xAxisLabel/1000))
ylabel('raw X position (pixels)');
xlabel('time (s)');

subplot(322)
hold on
plot(Time(CalibDataSamples), Pup_x_diameter(CalibDataSamples))
plot(Time(TrialsStarts), Pup_x_diameter(TrialsStarts),'or')
set(gca, 'xtick', xAxisLabel, ...
    'xticklabel', round(xAxisLabel/1000))
ylabel('X pupil diameter');
xlabel('time (s)');

subplot(323)
hold on
plot(Time(CalibDataSamples), Pos_y(CalibDataSamples))
plot(Time(TrialsStarts), Pos_y(TrialsStarts),'or')
set(gca, 'xtick', xAxisLabel, ...
    'xticklabel', round(xAxisLabel/1000))
ylabel('raw Y position (pixels)');
xlabel('time (s)');

subplot(324)
hold on
plot(Time(CalibDataSamples), Pup_y_diameter(CalibDataSamples))
plot(Time(TrialsStarts), Pup_y_diameter(TrialsStarts),'or')
set(gca, 'xtick', xAxisLabel, ...
    'xticklabel', round(xAxisLabel/1000))
ylabel('Y pupil diameter');

subplot(325)
hold on
plot(Time(CalibDataSamples), Blink(CalibDataSamples))
plot(Time(TrialsStarts), Blink(TrialsStarts),'or')
set(gca, 'xtick', xAxisLabel, ...
    'xticklabel', round(xAxisLabel/1000))
ylabel('Blinks');

subplot(326)
hold on
plot(Time(CalibDataSamples), Blink(CalibDataSamples))
plot(Time(TrialsStarts), Blink(TrialsStarts),'or')
set(gca, 'xtick', xAxisLabel, ...
    'xticklabel', round(xAxisLabel/1000))
ylabel('Blinks');



%% Calibration
X_CalibrationGrid = nan(numel(ElevationLvls),numel(AzimuthLvls))';
Y_CalibrationGrid = nan(numel(ElevationLvls),numel(AzimuthLvls))';

% We plot the calibration grid and the calibration data
figure('name', 'Calibration', 'position', FigDim)
hold on

% We loop through every second marker which hopefully is a trial
% onset
for iTrial = 1:floor(numel(TrialsStarts)/2)

    % We get the offset of that trial
    IndexTimeEnd = TrialsStarts(2+(iTrial-1)*2);

    % We get the time point that was the closest to what must have
    % been the beginning of this fixation trial
    IndexTimeStart = find(Time<Time(IndexTimeEnd) - CalibDur, 1, 'last');

    % In case we went too far back in time before the beginning of
    % the recording
    if isempty(IndexTimeStart)
        IndexTimeStart=1;
    end

    if Time(IndexTimeEnd)-Time(IndexTimeStart)<CalibDur-500 || ...
            Time(IndexTimeEnd)-Time(IndexTimeStart)>CalibDur+PreCalibDur
        % We do nothing if the the duration of that calibration
        % trial is < to the calibration duration or >
        % than the calibration duration;
        % The values I use for that window are a bit arbitrary but
        % I seem to be getting good results with them.

    else
        % WE seem to have something that looks like an actual
        % fixation trial.

        Samples = IndexTimeStart:IndexTimeEnd; % Indices of the data points in for tht trial
        tmp_blink = Blink(Samples);
        Samples(tmp_blink>=0)=[]; % We remove the data points that are blinks

        if numel(Samples)>SamplingFreq/2 %We make sure that we have at least more than half a second worth of data

            X = Pos_x(Samples); % only take the valid position for x
            stdX = mad(X,1); % This is the average absolute distance to the median
            devX = abs(X - median(X)); % This is the absolute distance to the median

            Y = Pos_y(Samples); % same for y
            stdY = mad(Y,1);
            devY = abs(Y - median(Y));

            % This defines the threshold beyond which we exclude
            %  data points (3 times the mean deviation): anything
            %  beyond that is considered an outlier hopefully only
            %  due to recording instability
            Remove = find(any([devX>NbSD*stdX devY>NbSD*stdY],2));
            X(Remove)=[];
            Y(Remove)=[];
            clear Remove

            % We only continue if the average absolute distance to the
            % median is inferrior to a third of a degree (we want
            % hight reliability).
            if mad(X,1)<PPD/3 && mad(Y,1)<PPD/3

                % We store the median X and Y value of that
                % fixation trial.
                X_CalibrationGrid(iTrial)=median(X);
                Y_CalibrationGrid(iTrial)=median(Y);

                % We plot this trial as well as its median value
                % and mean absolute error to the median
                plot(X, Y, Color(iTrial))
                errorbar(median(X), median(Y), mad(Y,1), 'or')
                herrorbar(median(X), median(Y), mad(X,1), 'or')

            end

        end
    end
end

% We get the the mean value for each elevationa and azimuth position
X_CalibrationGrid = nanmean(X_CalibrationGrid,2)';
Y_CalibrationGrid = nanmean(Y_CalibrationGrid)';

% We keep track the offset for each dimension
EyeData.X_0ffset = median(X_CalibrationGrid);
EyeData.Y_0ffset = median(Y_CalibrationGrid);

% We keep some values for plotting.
X_0 = median(X_CalibrationGrid); % X offset
Delta_X = mean(diff(X_CalibrationGrid)); % mean number of pixel between 2 azimuth levels

Y_0 = median(Y_CalibrationGrid); % Y offset
Delta_Y = mean(diff(Y_CalibrationGrid)); % mean number of pixel between 2 elevation levels

% This is the index of the most left azimuth level wrt center of the
% screen
FarLeft = find(X_CalibrationGrid==X_0)-numel(X_CalibrationGrid);

% This is the index of the lowest elevation level wrt center of the
% screen
Bottom = find(Y_CalibrationGrid==Y_0)-numel(Y_CalibrationGrid);

% We plot the grid
for i=1:size(X_CalibrationGrid,2)
    plot([X_0+(FarLeft+i-1)*Delta_X X_0+(FarLeft+i-1)*Delta_X], [Y_0+Bottom*Delta_Y Y_0-Bottom*Delta_Y], '-k', 'linewidth', 2)
end
for i=1:size(Y_CalibrationGrid,1)
    plot([X_0+FarLeft*Delta_X X_0-FarLeft*Delta_X], [Y_0+(Bottom+i-1)*Delta_Y Y_0+(Bottom+i-1)*Delta_Y], '-k', 'linewidth', 2)
end

axis([X_0+(FarLeft-1)*Delta_X X_0-(FarLeft-1)*Delta_X ...
    Y_0+(Bottom-1)*Delta_Y Y_0-(Bottom-1)*Delta_Y])
set(gca, 'ytick', Y_0+Delta_Y*([1:numel(Y_CalibrationGrid)]+Bottom-1), 'yticklabel', ElevationLvls, ...
    'xtick', X_0+Delta_X*([1:numel(X_CalibrationGrid)]+FarLeft-1), 'xticklabel', AzimuthLvls)

% We finally center the value of the grid on 0
EyeData.X_CalibrationGrid = X_CalibrationGrid - EyeData.X_0ffset;
EyeData.Y_CalibrationGrid = Y_CalibrationGrid - EyeData.Y_0ffset;

% Stores some info for later on
EyeData.TrialsStarts = TrialsStarts;

EyeData.Bottom = Bottom;
EyeData.FarLeft = FarLeft;

EyeData.Delta_Y = Delta_Y;
EyeData.Delta_X = Delta_X;

end