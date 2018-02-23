function [rho,slope]=Correlation_regression_raster_ind(Profiles,DesMat,iToPlot,X_sort)

    Y = Profiles';

    B = pinv(DesMat)*Y;
    
    Cst_tmp = B(1,:);
    Lin_tmp = B(2,:);
    
    if size(DesMat,2)>2
        Quad_tmp = B(3,:);
    end
    
    if iToPlot==1
        Y_sort=Cst_tmp; %#ok<*AGROW>
    elseif iToPlot==2
        Y_sort=Lin_tmp;
    elseif    iToPlot==3
        Y_sort=Quad_tmp;
    end


    R=corrcoef(X_sort,Y_sort);
    rho = R(1,2);
    beta = glmfit(X_sort, Y_sort, 'normal');
    slope = beta(2);

end
