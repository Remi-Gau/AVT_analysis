# Audio-visual-tactile 7 tesla
---

## Replotting figures
Can be done with this function for the BOLD and MVPA profiles:
`code/figures/FeatPool/All_ROIs_BOLD_MVPA_surf_plot.m`

Can be done with this function for the PCM:
`code/figures/PCM/All_ROIs_BOLD_MVPA_surf_plot.m`

## Dependencies for the fMRI and psychophysics experiment:
- Presentation (?????)
- HRTF (MIT and HPC...)
- piezzo stimulator (??????)
- palamedes to analyze (?????)
- nansuite
- herrorbar

## Dependencies for analysis:

Many extra matlab functions from github and the mathwork file exchange are needed and are listed in the `dependencies.txt` file and in the table below. Yeah this weird, tiring and cumbersome but that's matlab weirdness for you.

| Matlab, toolbox and other dependencies                                                                                                            | Used version | Purpose                    |
|---------------------------------------------------------------------------------------------------------------------------------------------------|--------------|----------------------------|
| [Matlab](https://www.mathworks.com/products/matlab.html)                                                                                          | 2016a        |                            |
| SPM12                                                                                                                                             | v6685        | preprocessing, GLM, ...    |
| [SPM-RG](https://github.com/Remi-Gau/SPM-RG)                                                                                                      | N/A          | manual coregistration      |
| [nansuite](https://fr.mathworks.com/matlabcentral/fileexchange/6837-nan-suite)                                                                    | V1.0.0       |                            |
| [distributionPlot](https://fr.mathworks.com/matlabcentral/fileexchange/23661-violin-plots-for-plotting-multiple-distributions-distributionplot-m) | v1.15.0      | violin plots for matlab    |
| [plotSpread](https://fr.mathworks.com/matlabcentral/fileexchange/37105-plot-spread-points-beeswarm-plot)                                          | v1.2.0       | plot datta spread          |
| [shadedErrorBar](https://fr.mathworks.com/matlabcentral/fileexchange/26311-raacampbell-shadederrorbar)                                            | v1.65.0      | shaded error bar           |
| [herrorbar](https://fr.mathworks.com/matlabcentral/fileexchange/3963-herrorbar)                                                                   | V1.0.0       | horizontal error bar       |
| [mtit](https://fr.mathworks.com/matlabcentral/fileexchange/3218-mtit-a-pedestrian-major-title-creator)                                            | v1.1.0       | main title for figures     |
| [matlab_for_CBS_tools](https://github.com/Remi-Gau/matlab_for_cbs_tools)                                                                          | NA           | import CBS-tools VTK files |
| [brain_colours](https://github.com/CPernet/brain_colours)                                                                                         | NA           | brain color maps           |
| [RSA toolbox](https://github.com/rsagroup/rsatoolbox)  |   |   |
| [PCM toolbox](https://github.com/jdiedrichsen/pcm_toolbox)  | v1.3  |   |

### Installing dependencies

You can use the [matlab package manager](https://github.com/mobeets/mpm) to download all the "small" dependencies in some sort of environment with a command like:

```matlab
mpm install -i /home/remi/github/AVT_analysis/dependencies.txt -c AVT
```

After that you can simply add to your path by typing
```matlab
mpm init -c AVT
```

or manually add them by doing
```matlab
mpm_folder = fileparts(which('mpm'));
addpath(genpath(fullfile(mpm_folder, 'mpm-packages', 'mpm-collections', 'AVT')));
```

#### Compiling mex file for pcm
You might need to compile a a mex file to run the PCM if you are on a linux OS.

```matlab
cd(fullfile('mpm_folder', 'mpm-packages', 'mpm-collections', 'AVT', 'pcm_toolbox'))
mex traceABtrans.c
```

## Recreating figures

### For BOLD and MVPA analysis
The script `figures/FeatPool/All_ROIs_BOLD_MVPA_surf_plot.m` will plot the main figures of the publication if the variable `plot_main` is set to true. Otherwise this will plot all the results on the same figures.

### For PCM
Use the script `figures/PCM/Plot_PCM_3X3_models_FamComp_Likelihoods.m`

