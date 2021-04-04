% (C) Copyright 2020 Remi Gau
function PlotRoiData(Data, ConditionVec, RunVec)

    %%
    fig_h = figure( ...
                   'name', 'test', ...
                   'Position', [50 50 1200 600], ...
                   'Color', [1 1 1]);

    colormap(SeismicColorMap());
    %     colormap(gray);

    subplot(1, 12, 1:2);

    imagesc([RunVec ConditionVec]);

    set(gca, ...
        'ytick', [], ...
        'xtick', [1, 2], 'xticklabel', {'Runs', 'Conditions'});

    subplot(1, 12, 3:7);

    hold on;

    % Reorganize  by session
    %     for i = 1:max(RunVec)
    %         tmp = Y{iSub, ihs}(RunVec == i, :);
    %         Data = [Data; tmp];
    %     end

    % Sort by condition 1 of each run
    for i = 1:max(RunVec)

        RowToSort = find(all([ConditionVec == 1 RunVec == i], 2));

        [~, I] = sort(Data(RowToSort, :)); %#ok<FNDSB>

        Data(RunVec == i, :) = Data(RunVec == i, I);

    end

    % Sort by mean acroos run and conditions
    %         [~, I] = sort(mean(Data));
    %         Data = Data(:, I);

    imagesc(imgaussfilt(Data, [.0001 3]), [-10 10]);
    %     imagesc(Data, [-5 5])

    axis tight;

    set(gca, 'ytick', [], 'xtick', []);

    title('Y sorted session wise as f(A_{ipsi})');
    title('Y as f(mean(act))');

    subplot(1, 12, 8:12);

    YY = Data * Data';
    MAX = min(abs([max(YY(:)) min(YY(:))]));

    imagesc(YY, [MAX * -1 MAX]);

    axis tight;

    title('Y*Y^T');

    set(gca, 'ytick', [], 'xtick', []);

    mtit(fig_h.Name, 'fontsize', 12, 'xoff', 0, 'yoff', .05);

end
