function trdata = norm_calc_tr(trdata, cvmat, tr, opt)

% Eucledian image normalization
if opt.scaling.img.eucledian 
    for i=1:size(trdata, 1)
        trdata(i,:) = trdata(i,:) / norm(trdata(i,:));
    end
end

% Image mean centering and normalization (std=1)
if opt.scaling.img.zscore 
    trdata = zscore(trdata, 0, 2);
end

% Feature mean centering
if opt.scaling.feat.mean 
    mnval = mean(trdata);
    for i=1:size(trdata, 1)
        trdata(i,:) = trdata(i,:) - mnval;
    end
end

% Feature scaling into [-1 1] range
if opt.scaling.feat.range 
    minval = min(trdata);
    maxval = max(trdata);
    for i=1:size(trdata, 1)
        trdata(i,:) = 2 * (trdata(i,:) - minval) ./ (maxval - minval) - 1 ;
    end
end

% Feature session specific mean centering
if opt.scaling.feat.sessmean 
    sess = cvmat(tr,2);
    sess_list = unique(sess);
    for isess = 1:numel(sess_list)
        sess_to_center = find(sess==sess_list(isess));
        mnval = mean(trdata(sess_to_center,:));
        for i=1:numel(sess_to_center)
            trdata(sess_to_center(i),:) = trdata(sess_to_center(i),:) - mnval;
        end
    end
end