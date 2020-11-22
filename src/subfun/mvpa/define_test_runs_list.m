function varargout = define_test_runs_list(opt, iSub, listValidRuns)
    %
    % Defines the test runs to leave out for each cross-validation
    %
    % - the simplest is a leave-one-run-out and assumes that all runs are
    %   equivalent, no matter what session they were acquired in.
    % - a more complicated cross-validation scheme leaves out one run from
    %   each session. 
    %
    
    RunPerSes = ReturnNbRunsPerSession();
    RunPerSes = RunPerSes.RunsPerSes(iSub, :);
    
    if nargin < 3 || isempty(listValidRuns)
      listValidRuns = 1:sum(RunPerSes);
    end

    % Test sets for the different CVs
    if opt.runs.curve

        error('learning curves are not implemented');

%         for i = 1:size(CV_id, 1)
%             % Limits to CV max;
%             TestSessList{i, 1} = nchoosek(...
%               CV_id(i, :), ...
%               floor(opt.runs.proptest * NbSess2Incl));
%             
%             TestSessList{i, 1} = TestSessList{i, 1}(randperm(size(TestSessList{i, 1}, 1)), :);
%             
%             if size(TestSessList{i, 1}, 1) >  opt.runs.maxcv
%                 TestSessList{i, 1} = TestSessList{i, 1}(1:opt.runs.maxcv, :);
%             end
%             if opt.permutation.test
%                 TestSessList{i, 1} = cartProd;
%             end
%         end

    else

        if opt.runs.loro

            RunsList = (1:sum(RunPerSes))';

        else

            sets = { ...
                    1:RunPerSes(1), ...
                    RunPerSes(1) + 1:RunPerSes(1) + RunPerSes(2), ...
                    RunPerSes(1) + RunPerSes(2) + 1:sum(RunPerSes)};

            [x, y, z] = ndgrid(sets{:});

            cartProd = [x(:) y(:) z(:)];

            RunsList = cartProd; % take all possible CVs

            clear cartProd sets x y Idx;

            if opt.permutation.test % limits the number of CV for permutation
                cartProd = cartProd(randperm(size(cartProd, 1)), :);
                RunsList = cartProd(1:opt.runs.maxcv, :);
            end
        end

    end
    
    RunsToRemove = setxor(unique(RunsList(:)), listValidRuns);
    RunsList(any(ismember(RunsList, RunsToRemove), 2), :) = [];
    
    varargout{1} = {RunsList};

end
