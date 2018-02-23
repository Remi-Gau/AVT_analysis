Tail = 'both';

% These are the betas I get from a GLM fit: 
% each line is a different component of my fit (constant, linear, quadratic
% component)
% each column is a different subject
betas = [
    1.9446    1.5435    0.8627    1.2894    1.8078    1.2949    1.1127    1.4449    1.4486    1.5122;...
    0.6798    0.3385    0.3208    0.3502    0.6196    0.2849    0.3484    0.5181    0.3869    0.5366;...
    0.0784    0.0682    0.0498    0.1462    0.1109    0.0619    0.0654    0.1144    0.0578    0.1367];
betas = betas';

% Gets all the possible permutations possible (via cartesian product): might
% no be necessary if you have "a lot" of subjects then you can just randomly permutate X number of times 
% but with 10 subejcts that's only 1024 permutations. 
for iSub=1:size(betas,1)
    sets{iSub} = [-1 1];
end
[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:});
ToPermute = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];


% Compute the null distributions: one for each o
for iPerm = 1:size(ToPermute,1)
    tmp2 = (ToPermute(iPerm,:))';
    Perms(iPerm,:) = mean(betas.*repmat(tmp2,1,size(betas,2),1)); %#ok<*SAGROW>
end

for i = 1:size(betas,2)
    if strcmp(Tail,'left')
        % check the proportion of permutation results that are inferior to
        % the mean of my sample
        P(i) = sum(Perms(:,i)<mean(betas(:,i)))/numel(Perms(:,i));
    elseif strcmp(Tail,'right')
        % same but the other way
        P(i) = sum(Perms(:,i)>mean(betas(:,i)))/numel(Perms(:,i));
    elseif strcmp(Tail,'both')
        % for the 2 tailed just compare to the distribution of absolute value of the distance 
        % between the result of each permutation to the mean of all
        % permutation results
        
        % Then you check the proportion of those distances are superior to
        % the distance between the mean of your sample and the mean of all
        % permutation results
        % P(i) = sum( abs((Perms(:,i)-mean(Perms(:,i)))) > abs((mean(betas(:,i))-mean(Perms(:,i)))) ) / numel(Perms(:,i)) ;
        
        % Actually not just take the absolute values: the above assumes
        % that your null distribution is symmetric
        P(i) = sum( abs(Perms(:,i)) > abs(mean(betas(:,i)) ) )  / numel(Perms(:,i)) ;
        
    end
end
P

% [~,P2] = ttest(betas, 0, 'alpha', 0.05, 'tail', Tail)
        

