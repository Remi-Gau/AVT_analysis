%% V & T / Ipsi & Contra in A1 and PT
Conditions = 3:6;
RoisToSelect = {'A1', 'PT'};
Parameters = {'Cst', 'Lin'};
StimName = {'VStim'; 'TStim'};
[model, fid] = ReturnLmmSpecAndData( ...
                                    Beta, ...
                                    RoisToSelect, ...
                                    Parameters, ...
                                    IpsiContra, ...
                                    Conditions, ...
                                    true);

% CdtNames = cellfun(@(x) x(1:5),IpsiContra, 'UniformOutput', false);
model = EstimateLmm(model);

[c, message] = ReturnContrast('F_CdtXSide', model, StimName);
[PVAL, F, DF1, DF2] = FTestAndPrint(model, c, message, fid);

if PVAL < 0.05

    fprintf(1, 'Test ipsi and contra separately \n');

    for iParam = 1:numel(Parameters)

        for iSide = 1:numel(SIDE)

            Conditions = {{[StimName{1} SIDE{iSide}]; Parameters{iParam}}; ...
                          {[StimName{2} SIDE{iSide}]; Parameters{iParam}} };

            [c, message] = ReturnContrast('F_Cdt', model, Conditions);
            [PVAL, F, DF1, DF2] = FTestAndPrint(model, c, message, fid);

            if PVAL < 0.05

                for iRoi = 1:numel(RoisToSelect)

                    Conditions = {{[StimName{1} SIDE{iSide}]; Parameters{iParam}; RoisToSelect{iRoi}}; ...
                                  {[StimName{2} SIDE{iSide}]; Parameters{iParam}; RoisToSelect{iRoi}}};

                    c = ReturnContrast('F_Cdt', model, Conditions);

                    idx1 = logical(model.X(:, logical(c(1, :))));
                    idx2 = logical(model.X(:, logical(c(2, :))));
                    betas = model.Y(idx1) - model.Y(idx2);

                    [~, PVAL, ~, STATS] = ttest(betas, 0, 'tail', 'both');
                    fprintf(1, '\n');

                    message = sprintf('T Contrast; Conditions: %s - %s', ...
                                      strjoin({StimName{1}, SIDE{iSide}, Parameters{iParam}}, ' '), ...
                                      strjoin({StimName{2}, SIDE{iSide}, Parameters{iParam}}, ' '));

                    pattern.screen = '%s\n%s\t t(%i)= %f\t p = %f\n';
                    fprintf(fid, pattern.screen, ...
                            RoisToSelect{iRoi}, ...
                            message, ...
                            STATS.df, ...
                            STATS.tstat, PVAL);

                end

            end

        end
    end

end

return

%% (V - T) / Ipsi and Contra in A1 and PT
Conditions = 3:4;
[model, fid] = ReturnLmmSpecAndData( ...
                                    BetaCrossSens, ...
                                    RoisToSelect, ...
                                    Parameters, ...
                                    CrossSens, ...
                                    Conditions, ...
                                    false);
model = EstimateLmm(model);
[c, message] = ReturnContrast('F_CdtXSide', model, Conditions, CrossSens);
% [PVAL, F, DF1, DF2] = TestAndPrint(model, c, message, fid);
