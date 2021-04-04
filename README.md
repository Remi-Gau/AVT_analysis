# Audio-visual-tactile 7 tesla

Code for the analysis of the AVT fMRI high-res experiment.

## Dependencies

### fMRI and psychophysics experiment

-   Presentation (?????)
-   HRTF (MIT and HPC...)
-   piezzo stimulator (??????)
-   palamedes to analyze (?????)

### fMRI analysis

You will need matlab and SPM12 to make use of this code.

| Matlab, toolbox and other dependencies                   | Used version | Purpose                 |
| -------------------------------------------------------- | ------------ | ----------------------- |
| [Matlab](https://www.mathworks.com/products/matlab.html) | 2016a        |                         |
| SPM12                                                    | v6685        | preprocessing, GLM, ... |

Other functions from github and the mathwork file exchange are needed. All of
them are shipped with this repo in the `lib` folder or can be pulled from github
as submodules.

So to install all the code and its dependencies you simply to run:

```
git clone --recurse-submodules https://github.com/Remi-Gau/AVT_analysis.git
```

## Set up

When in the root folder simply run `initEnv` from the matlab prompt to add all
relevant folders to the matlab path.

### Settings

Files used to stored settings are in the following folders:

```
src/settings/
lib/laminar_tools/src/settings/
```

### Compiling mex file for PCM analysis

You might need to compile a a mex file to run the PCM if you are on Linux.

```matlab
cd(fullfile('lib', 'pcm_toolbox'))
mex traceABtrans.c
```

## Recreating figures

### For BOLD and MVPA analysis

The script `src/figures/PlotBoldProfile.m` will plot the main figures for BOLD
profile results.
