function Get_dependencies(Dir)

matlab_code_dir = fullfile(Dir, 'Dropbox', 'Code','MATLAB', 'From_Web');
github_code_dir = fullfile(Dir, 'github');

% Might be need for the PCM: https://fr.mathworks.com/matlabcentral/fileexchange/42885-nearestspd
addpath(genpath(fullfile(matlab_code_dir, 'nearestSPD')))

% https://fr.mathworks.com/matlabcentral/fileexchange/6837-nan-suite
addpath(genpath(fullfile(matlab_code_dir, 'nansuite')))

% Binomial test: https://fr.mathworks.com/matlabcentral/fileexchange/24813-mybinomtest-s-n-p-sided
addpath(genpath(fullfile(matlab_code_dir, 'myBinomTest')))

%% Plotting
% [violin plots for matlab]
% (https://fr.mathworks.com/matlabcentral/fileexchange/23661-violin-plots-for-plotting-multiple-distributions-distributionplot-m)
addpath(genpath(fullfile(matlab_code_dir, 'distributionPlot')))

% [plot spread function]
% (https://fr.mathworks.com/matlabcentral/fileexchange/37105-plot-spread-points-beeswarm-plot)
addpath(genpath(fullfile(matlab_code_dir, 'plotSpread')))

%[Shaded error bar](https://fr.mathworks.com/matlabcentral/fileexchange/26311-raacampbell-shadederrorbar)
addpath(genpath(fullfile(matlab_code_dir, 'shadedErrorBar')))

%[Horizontal error bar](https://fr.mathworks.com/matlabcentral/fileexchange/3963-herrorbar)
addpath(genpath(fullfile(matlab_code_dir, 'herrorbar')))

%[ternary plots for
%matlab](https://fr.mathworks.com/matlabcentral/fileexchange/7210-ternary-plots)
addpath(genpath(fullfile(matlab_code_dir, 'ternary2')))

%Main title for figures: https://fr.mathworks.com/matlabcentral/fileexchange/3218-mtit-a-pedestrian-major-title-creator
addpath(genpath(fullfile(matlab_code_dir, 'mtit')))


%% Github
%[prevalence permutation test](https://github.com/allefeld/prevalence-permutation)
addpath(genpath(fullfile(github_code_dir, 'prevalence-permutation-1.1.0')))

%[PCM toolbox](https://github.com/jdiedrichsen/pcm_toolbox)
addpath(genpath(fullfile(github_code_dir, 'pcm_toolbox')))

%[RSA toolbox](https://github.com/rsagroup/rsatoolbox)
addpath(genpath(fullfile(github_code_dir, 'rsatoolbox')))

%[brain color maps](https://github.com/CPernet/brain_colours)
% see also here http://neurostatscyrilpernet.blogspot.com/2016/08/brain-colours.html
addpath(genpath(fullfile(github_code_dir, 'plot_tools', 'color_maps')))

%[matlab_for_CBS_tools](https://github.com/Remi-Gau/matlab_for_cbs_tools)
addpath(genpath(fullfile(github_code_dir, 'matlab_for_cbs_tools')))

end

