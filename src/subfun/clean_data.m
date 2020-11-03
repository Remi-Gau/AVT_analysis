function [data, idx] = clean_data(data, dim, idx)

  if nargin < 3
    idx = [];
  end

  switch dim

    % remove any column with at least one nan
    case 2

      idx = find(any(isnan(data)));
      data(:, idx) = [];

      % checks which rows are just made of nans or zeros
    case 1

      rows = ...
          any([ ...
               all(isnan(data), 2) ...
               all(data == 0, 2)] ...
              , 2);

      if any(rows)

        warning('We have some NaNs or zeros issue: ignore if sub-06');

        idx = [idx rows];

      end
  end

end
