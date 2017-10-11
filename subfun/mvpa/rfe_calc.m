function [idfeat, acc] = rfe_calc(data, idfeat, label, session, nsplits, args, opt)
% [idfeat, acc] = rfe_calc(data, label, session, nsplit, args)
% Recursive feature elimination to reduce features to the most discriminative voxels

% RFE parameters
nRFE = opt.rfe.nreps; 
threshold = opt.rfe.threshold^(1/nRFE);

% Preallocate vars of feature set at each level of RFE
idfeat = repmat(idfeat, [nRFE+1, 1]); % feature indexes
acc = zeros(nRFE, 2); % accuracy results

% CV options (with 2 examples in fold)
% A) inherent CV works roughly as nchoosek with all combinations
% e.g. -v 6 -> spl = nchoosek(1:12, 2); 
% B) equal number of classes in each fold is a bit over-optimistic (+10%)
% e.g. -v 6 -> in addition, spl = spl(spl(:,1)<7 & spl(:,2)>6,:); 
% C) same session is much more over-optimistic (+30-40%!!)

% Unique session ids
sid = unique(session);

% Run RFE
for i=1:nRFE
    % Feature weights and labels (predicted+test) at each split
    absw = zeros(nsplits, size(data, 2));
    checkw = zeros(nsplits, size(data, 2));
    pred = zeros(size(data, 1)/nsplits, nsplits);
    
    for j=1:nsplits 
        % Determine training and test sets
        [te, tr] = deal(sid(j)==session, sid(j)~=session);
        [trdata, tedata] = deal(data(tr,idfeat(i,:)), data(te,idfeat(i,:)));
        [trlabel, telabel] = deal(label(tr), label(te));
        
        % Train machine and make predictions
        model = svmtrain(trlabel, trdata, args);
        [predlabel, accuracy, decvalue] = svmpredict(telabel, tedata,  model);

        % Compute the weights of features (voxels)
        w = model.SVs' * model.sv_coef;
        absw(j,idfeat(i,:)) = abs(w);
        checkw(j,idfeat(i,:)) = w;
        
        % Compare predictions to test labels
        pred(:,j) = predlabel == telabel;
    end
    
    % Determine most discriminative voxels
    score = mean(absw, 1); % for all voxels!
    subscore = sort(score(idfeat(i,:)), 'descend');
    wtreshold = subscore(round((length(subscore) * threshold)));
    idfeat(i+1,score<wtreshold) = false;
    
    % Calculate accuracy
    try
        acc(i,:) = mean(reshape(mean(pred, 2), [], 2), 1);
    catch
        acc(i,:) = [mean(pred(repmat(telabel==1,1,size(pred,2)))) ...
                    mean(pred(repmat(telabel==-1,1,size(pred,2))))];
    end
    
end


end


