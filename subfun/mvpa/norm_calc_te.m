function tedata = norm_calc_te(trdata_ori, tedata, cvmat, tr, te, opt)

% Eucledian image normalization
if opt.scaling.img.eucledian 
    for i=1:size(trdata_ori, 1)
        trdata_ori(i,:) = trdata_ori(i,:) / norm(trdata_ori(i,:));
    end
    for i=1:size(tedata, 1)
        tedata(i,:) = tedata(i,:) / norm(tedata(i,:));
    end
end

% Image mean centering and normalization (std=1)
if opt.scaling.img.zscore 
    trdata_ori = zscore(trdata_ori, 0, 2);
    tedata = zscore(tedata, 0, 2);
end

% Feature mean centering
if opt.scaling.feat.mean 
    mnval = mean(trdata_ori);
    for i=1:size(tedata, 1)
        tedata(i,:) = tedata(i,:) - mnval;
    end
end

% Feature scaling into [-1 1] range
if opt.scaling.feat.range 
    minval = min(trdata_ori);
    maxval = max(trdata_ori);
    for i=1:size(tedata, 1)
        tedata(i,:) = 2 * (tedata(i,:) - minval) ./ (maxval - minval) - 1 ;
    end
end

% Feature session specific mean centering
if opt.scaling.feat.sessmean 
    sess = cvmat(te);
    sess_list = unique(sess);
    for isess = 1:numel(sess_list)
        sess_to_center = find(sess==sess_list(isess));
        mnval = mean(tedata(sess_to_center,:));
        for i=1:numel(sess_to_center)
            tedata(sess_to_center(i),:) = tedata(sess_to_center(i),:) - mnval;
        end
    end
end