function rename_subplot(Subplots, subplots_names, title_names)
    for iSubplot = 1:length(title_names)
        subplot(Subplots(1), Subplots(2), iSubplot);

        axis on;
        set(gca, 'tickdir', 'out', 'xtick', 1:numel(subplots_names), 'xticklabel', [], ...
            'ytick', 1:numel(subplots_names), 'yticklabel', subplots_names, ...
            'ticklength', [0.01 0], 'fontsize', 8);

        t = title(title_names{iSubplot});
        set(t, 'fontsize', 10);
    end
end
