function [KillGcpOnExit] = OpenParWorkersPool(NbWorkers)
    % OPENPARWORKERSPOOL Check matlab version and opens pool of workers for
    % parallel work
    %   Detailed explanation goes here

    MatlabVer = version('-release');
    if str2double(MatlabVer(1:4)) > 2013
        pool = gcp('nocreate');
        if isempty(pool)
            KillGcpOnExit = 1;
            parpool(NbWorkers); %#ok<*DPOOL>
        else
            KillGcpOnExit = 0;
        end
    else
        if matlabpool('size') == 0 %#ok<*DPOOL>
            KillGcpOnExit = 1;
            matlabpool(NbWorkers);
        elseif matlabpool('size') ~= NbWorkers
            matlabpool close;
            matlabpool(NbWorkers);
            KillGcpOnExit = 0;
        else
            KillGcpOnExit = 0;
        end
    end

end
