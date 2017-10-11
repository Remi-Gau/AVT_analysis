function idfeat = feat_select(trdata, trlabel, opt)

% Treshold for selection (0-1)
threshold = opt.fs.threshold;

% Number of data per class and number of features
n = size(trdata, 1) / 2;
m = size(trdata, 2);

% Separate data to the 2 classes
c1data = trdata(trlabel==min(trlabel),:);
c2data = trdata(trlabel==max(trlabel),:);

switch opt.fs.type
    case 'ttest'
        % One-sample t-stat
        t = [mean(c1data)./sqrt(var(c1data)/n); mean(c2data)./sqrt(var(c2data)/n)]; 
        
        % Select features
        score = sort(abs(t), 2, 'descend'); % abs for 2-sided selection
        idfeat = t > repmat(score(:,round(m*threshold)), 1, m);
        idfeat = idfeat(1,:) | idfeat(2,:); % union of voxels with greatest t-values
        
    case 'ttest2'
        % Two-sample t-stat
        t = (mean(c1data)-mean(c2data)) ./ sqrt((var(c1data)+var(c2data))/n);
        
        % Select features 
        score = sort(abs(t), 'descend'); % abs for 2-sided selection
        idfeat = t > score(round(m*threshold)) | t <= -score(round(m*threshold)); % voxels with greatest t-values
        
    case 'wilcoxon'
        % not implemented yet...
end


