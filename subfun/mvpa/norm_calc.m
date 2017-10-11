function [trdata, tedata] =  norm_calc(trdata, tedata, cvmat, tr, te, opt)

% Eucledian image normalization
if opt.scaling.img.eucledian 
    for i=1:size(trdata, 1)
        trdata(i,:) = trdata(i,:) / norm(trdata(i,:));
    end
    for i=1:size(tedata, 1)
        tedata(i,:) = tedata(i,:) / norm(tedata(i,:));
    end
end

% Image mean centering and normalization (std=1)
if opt.scaling.img.zscore 
    trdata = zscore(trdata, 0, 2);
    tedata = zscore(tedata, 0, 2);
end

% Feature mean centering
if opt.scaling.feat.mean 
    mnval = mean(trdata);
    for i=1:size(trdata, 1)
        trdata(i,:) = trdata(i,:) - mnval;
    end
    for i=1:size(tedata, 1)
        tedata(i,:) = tedata(i,:) - mnval;
    end
end

% Feature scaling into [-1 1] range
if opt.scaling.feat.range 
    minval = min(trdata);
    maxval = max(trdata);
    for i=1:size(trdata, 1)
        trdata(i,:) = 2 * (trdata(i,:) - minval) ./ (maxval - minval) - 1 ;
    end
    for i=1:size(tedata, 1)
        tedata(i,:) = 2 * (tedata(i,:) - minval) ./ (maxval - minval) - 1 ;
    end
end

% Feature session mean centering
if opt.scaling.feat.sessmean 
    tr_sess =  cvmat(tr,2);
    tr_sess_list = unique(tr_sess);
    for isess = 1:numel(tr_sess_list)
        tr_sess_to_center = find(tr_sess==tr_sess_list(isess));
        mnval = mean(trdata(tr_sess_to_center,:));
        for i=1:numel(tr_sess_to_center)
            trdata(tr_sess_to_center(i),:) = trdata(tr_sess_to_center(i),:) - mnval;
        end
    end
    
    te_sess = cvmat(te,2);
    te_sess_list = unique(te_sess);
    for isess = 1:numel(te_sess_list)
        te_sess_to_center = find(te_sess==te_sess_list(isess));
        mnval = mean(tedata(te_sess_to_center,:));
        for i=1:numel(te_sess_to_center)
            tedata(te_sess_to_center(i),:) = tedata(te_sess_to_center(i),:) - mnval;
        end
    end
end