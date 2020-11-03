% set colors{tr} model simulation pcm

% 1 true model
% 2 shares some components
% 3 no components in common

parcol = parula(3);
for tr = 1:size(Y_ms_n, 1)
  switch tr
    case 1
      colors{tr}{1} = parcol(1, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(3, :);
      colors{tr}{4} = parcol(3, :);
      colors{tr}{5} = parcol(3, :);
      colors{tr}{6} = parcol(3, :);
      colors{tr}{7} = parcol(3, :);
      colors{tr}{8} = parcol(3, :);
      colors{tr}{9} = parcol(3, :);
      colors{tr}{10} = parcol(2, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(2, :);
      colors{tr}{13} = parcol(2, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 2
      colors{tr}{1} = parcol(3, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(1, :);
      colors{tr}{4} = parcol(3, :);
      colors{tr}{5} = parcol(3, :);
      colors{tr}{6} = parcol(2, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(3, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(2, :);
      colors{tr}{11} = parcol(3, :);
      colors{tr}{12} = parcol(3, :);
      colors{tr}{13} = parcol(2, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(3, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 3
      colors{tr}{1} = parcol(3, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(3, :);
      colors{tr}{4} = parcol(1, :);
      colors{tr}{5} = parcol(3, :);
      colors{tr}{6} = parcol(2, :);
      colors{tr}{7} = parcol(3, :);
      colors{tr}{8} = parcol(2, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(3, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(3, :);
      colors{tr}{13} = parcol(2, :);
      colors{tr}{14} = parcol(3, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 4
      colors{tr}{1} = parcol(3, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(3, :);
      colors{tr}{4} = parcol(3, :);
      colors{tr}{5} = parcol(1, :);
      colors{tr}{6} = parcol(3, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(2, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(3, :);
      colors{tr}{11} = parcol(3, :);
      colors{tr}{12} = parcol(2, :);
      colors{tr}{13} = parcol(3, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 5
      colors{tr}{1} = parcol(2, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(2, :);
      colors{tr}{4} = parcol(3, :);
      colors{tr}{5} = parcol(3, :);
      colors{tr}{6} = parcol(2, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(3, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(1, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(2, :);
      colors{tr}{13} = parcol(2, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 6
      colors{tr}{1} = parcol(3, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(3, :);
      colors{tr}{4} = parcol(2, :);
      colors{tr}{5} = parcol(2, :);
      colors{tr}{6} = parcol(2, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(1, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(3, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(2, :);
      colors{tr}{13} = parcol(2, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 7
      colors{tr}{1} = parcol(3, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(2, :);
      colors{tr}{4} = parcol(2, :);
      colors{tr}{5} = parcol(3, :);
      colors{tr}{6} = parcol(1, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(2, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(2, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(3, :);
      colors{tr}{13} = parcol(2, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 8
      colors{tr}{1} = parcol(2, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(2, :);
      colors{tr}{4} = parcol(2, :);
      colors{tr}{5} = parcol(3, :);
      colors{tr}{6} = parcol(2, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(2, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(2, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(2, :);
      colors{tr}{13} = parcol(1, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 9
      colors{tr}{1} = parcol(2, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(2, :);
      colors{tr}{4} = parcol(2, :);
      colors{tr}{5} = parcol(3, :);
      colors{tr}{6} = parcol(2, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(2, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(2, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(2, :);
      colors{tr}{13} = parcol(1, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(2, :);
      colors{tr}{17} = parcol(3, :);
    case 10
      colors{tr}{1} = parcol(2, :);
      colors{tr}{2} = parcol(3, :);
      colors{tr}{3} = parcol(2, :);
      colors{tr}{4} = parcol(2, :);
      colors{tr}{5} = parcol(2, :);
      colors{tr}{6} = parcol(2, :);
      colors{tr}{7} = parcol(2, :);
      colors{tr}{8} = parcol(2, :);
      colors{tr}{9} = parcol(2, :);
      colors{tr}{10} = parcol(2, :);
      colors{tr}{11} = parcol(2, :);
      colors{tr}{12} = parcol(2, :);
      colors{tr}{13} = parcol(2, :);
      colors{tr}{14} = parcol(2, :);
      colors{tr}{15} = parcol(2, :);
      colors{tr}{16} = parcol(1, :);
      colors{tr}{17} = parcol(3, :);
  end
end
