function [m, n] = OptimizeSubplotNumber(mn)
  % UNTITLED Optimizes the number of subplot to have on a figure
  n  = round(mn^0.4);
  m  = ceil(mn / n);
end
