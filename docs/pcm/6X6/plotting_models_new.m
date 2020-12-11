clear all

x1 = rand(100,1)
x2 = rand(100,1)
 D1 = pdist([x1 x2]', 'euclidean');  

y1 = [-50:1:50]';
y2= [50:-1:-50]';
 D2 = pdist([y1 y2]', 'euclidean');  


figure

% M_ori{3}.Ac(:,:,1) = [1 0; 0 0 ]'
% M_ori{3}.Ac(:,:,2) = [0 0 ;0 1]'

M{1}.Ac(:,:,1) = [1 0;0 0;0 0];
M{1}.Ac(:,:,2) = [0 0;1 0;0 0];
M{1}.Ac(:,:,3) = [0 0;0 0;1 0];
M{1}.Ac(:,:,4) = [0 0;0 0;0 1];


for k = 1:1%length(M)

    figure(k);
    A = 0; 
    zz =k;
    theta = 1 : 1: M{zz}.numGparams;
    theta = ones(1,M{zz}.numGparams);
    for i = 1 : M{zz}.numGparams

            A = A + theta(i)* M{zz}.Ac(:,:,i);
    end

        subplot(M{zz}.numGparams,4,4*(i-1)+1);
        imagesc(M{zz}.Ac(:,:,i))
        subplot(M{zz}.numGparams,4,4*(i-1)+2);
        imagesc(A)
        subplot(M{zz}.numGparams,4,4*(i-1)+3);
        imagesc(A')
        subplot(M{zz}.numGparams,4,4*(i-1)+4)
        imagesc(A*A')

    end
end






Features_to_add =

     1     1     1     2
     2     1     1     3
     3     1     1     4
     1     2     1     5
     2     2     1     6
     3     2     1     7
     1     3     1     8
     2     3     1     9
     3     3     1    10
     1     4     1    11
     2     4     1    12
     3     4     1    13
     1     5     1    14
     2     5     1    15
     3     5     1    16
     1     1     2    17
     2     1     2    18
     3     1     2    19
     1     2     2    20
     2     2     2    21
     3     2     2    22
     1     3     2    23
     2     3     2    24
     3     3     2    25
     1     4     2    26
     2     4     2    27
     3     4     2    28
     1     5     2    29
     2     5     2    30
     3     5     2    31