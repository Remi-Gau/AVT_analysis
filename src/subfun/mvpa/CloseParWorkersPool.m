function CloseParWorkersPool(KillGcpOnExit)
    % CLOSEPARWORKERSPOOL Check matlab version and closes pool of workers for
    % parallel work

    MatlabVer = version('-release');
    if str2double(MatlabVer(1:4)) > 2013
        if KillGcpOnExit
            delete(gcp); %#ok<DPOOL>
        end
    else
        if KillGcpOnExit
            matlabpool close; %#ok<DPOOL>
        end
    end

end
