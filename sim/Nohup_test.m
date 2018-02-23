for i=1:10
    pause(10);
    sprintf('Loop %i',i);
    recipient = matlabmail('remi_gau@hotmail.com', sprintf('Loop %i',i), sprintf('Loop %i',i));
end

