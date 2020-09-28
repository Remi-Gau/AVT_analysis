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

You can use the [matlab package maanger](https://github.com/mobeets/mpm) to download all the "small" dependencies in some sort of environment with a command like:

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

## Data analysis workflow

I indicate here the different folders where the code is kept. I try to indicate and in which order the scripts (or other manual interventions) have to be  run.

### Preprocessing of EPIs
`code/preprocess/`
1. `CpFromSrc.m` : gets the file from the BIDS and unzips some of them
2. `CreateVDM.m` : creates the voxel displacement map using the fieldmap
3. `RealignAndUwarp.m` : realign and unwarp the EPIs
4. `SliceTime.m` : does the slice timing.
5. `SmoothNative.m` : smooths the data. They will only be used to create an inclusive mask for the subject level GLM. See FFX_native.m.
6. `RunsPerSes.m` : checks how many sessions (days) and run per session there was for each subject store the results in mat file in the root folder.

### Running subject level GLM
`code/ffx/`
1. `FFX_native.m` : runs the subject level GLM. It is run a first time to get on smoothed images to get an inclusive mask (GLM-mask) that will be used for a second pass.
2. `FFX_RSA.m`:  whitens the beta from the subject level GLM using the RSA toolbox machinery

### Preprocessing anatomical
`code/cbs/` or `sub-xx/code/cbs/`
`segment-layer.LayoutXML` : high-res segmention and layering using the CBS tools


---
`_What we have so far:_`
- beta images (SPM)
- mid cortex vtk surfaces (CRUISE + inflation)
- layers level-sets
---


### Processing the beta images
`code/preprocess_betas/`
1. `CpBetas.m` : isolate the betas of interest from the subject level GLM and copies them in a separate folder (also takes meanEPI and GLM mask)
2. `mancoreg.m` : This function comes from uses [SPM-RG](https://github.com/Remi-Gau/SPM-RG) and allows a manual coregistration to align meanEPI to high-res structural.
This is required, because even if we had co-registered 0.8 mm structural and EPI at the very beginning, MIPAV will transform the structural independently during pre-processing and segmentation; so we need to co-register structural and functional here again). This is all due to the fact that SPM and MIPAV rely on different transformation matrices from the image header.
3. `CoregMean2AnatCBS.m` : coregister meanEPI to high res anat and applies transformation to betas of interest
4. Check coregistration with FSLview to flip back and forth between mean EPI and structural. Redo 2 and 3 until you get an adequate coregistration.
5. `ResliceBetas.m` : if the coregistration is adequate we reslice the betas to the 0.4 mm resolution of the high-res structural

### Mapping the beta images on surfaces
`code/cbs` or `sub-xx/code/cbs/``
1. `map_beta_2_surf.LayoutXML` : maps each high-res beta image onto the layers
The layers level-sets were computed for the whole brain but they are mapped on the surfaces of each hemisphere: there is a 1 to 1 correspondence (I.e they are in the same space) between the whole brain level-sets of the layers and the level that was used to generate the mid-cortex surface VTK file.
2. `Extract_mapped_target_betas.m` : copies vtk files out of the folder structure created by the CBS tools. Renames them so that we know which vtk file corresponds to which beta image. Calls the recursive function Extract_mapped_betas_VTK.m.
3. `ExtractFeatSurf.m` : extracts data (i.e. beta values for vertex in a particular surface-layer) from all the VTK. Relies on parfor and brute force but fast “textscan” rather than the slower read_vtk.m . Requires to know how many vertices the VTK files have. Saves the data for the whole surface and for each beta dimension are [vertex, layer, beta]. Also saves the list of vertices that have data at each depth.

### Extracting Data
`code/roi`
1. `Extract_vert_of_interest_ROI.m` : get the vertices of interest for each ROI (reads them from the surface binary mask).

in the cbs folder to extract beta values mapped on surfaces


### BOLD profiles
`code/bold_profiles/FeatPool/surf`
1. `bold_profiles_surf_pool_hs.m` : compute the bold profiles and does the laminar GLM for each ROI, condition, contrast. Saves the values and the betas of the laminar GLM for each subject. Feature pooling from each hemisphere is done there.
2. `bold_profiles_surf_pool_hs_grp_avg.m` : compile results from all subjects and does the group averaging

`code/figures/FeatPool/BOLD/surf/``
1. `All_ROIs_profile_surf_pool_hs_plot.m` : plots the results of all ROIs. Calls sub-function for plotting and to do the permutation test.

### MVPA
`code/mvpa/FeatPool/surf`
1. `MVPA_surf_pool_hs.m` : Runs the MVPA analysis at the laminar level and whole ROI level. Does it for all the classifications and ROIs. Calls to sub-function in code/subfun/mvpa. Adapted from Agoston scripts. Many options for permutation, feature and image scaling, learning curves, feature selection, grid-search... Feature pooling from each hemipshere is done there. Saves one mat file  / subject / classification / ROI the accuracies for all cross-validation for the whole ROI and each layer.
2. `MVPA_surf_pool_hs_grp_avg.m` : averages accuracies across subjects and does the laminar GLM over them.

`code/figures/FeatPool/MVPA/surf/``
1. `All_ROIs_MVPA_surf_pool_hs_plot.m` : plots the results of all ROIs. Calls sub-function for plotting and to do the permutation test.

`code/surfreg`
For the surface registration, a lot of the JIST layouts use .txt files as inputs that list with their fullpath the files to use. Those .txt files can be generated via the command line, a bash script, or matlab.
1. `FindMedianLevelSet.m` : identify for the left and right hemisphere the median subject to use as target for the first round of the surface registration
2. `PreProcess.LayoutXML` : preprocess the mid-cortical surface level set and the high-res T1 map of all subject to get them ready for the first round of surface registration
3. `MMSR1/2.LayoutXML`: Runs the actual surface registration
4. `avg_inter.LayoutXML` : Creates a first group surface average that will be used as target in the second round of the registration

### Pattern component model
Run by the script: `pcm/bold_PCM_3X3Models.m`

The `surf` and `vol` contains the scripts to extract the data from the ROI in the volume data or in the surface data before or after whitening (spatial multivariate normalization done by the RSA toolbox).


### MVPA

The scripts are all in the `mvpa` folder.

Options for the MVPA are set in the `subfun/mvpa/get_mvpa_options.m`


## Data structure

Left and right hemisphere can be denoted by:
- L/R
- lh/rh
- or lcr/rcr
- or lhs/rhs

Conditions are denoted by XTypeZ (e.g AstimL):
- X: sensory modality (A/V/T)
- Type: Stim, Targ
- Z: side of presentation (L/R)

Surfaces are either inflated (inf suffix) or not.
Surface results of laminar GLM are decomposed in:
- Cst → constant
- Lin → linear
- Quad → quadratic

Raw data are stored in as [BIDS](http://bids.neuroimaging.io/)

Most images stored as 4D nifti and compressed (gunzip).

## Subject level

Each subject is in a `sub-xx` folder.

### Anatomical

`derivative/sub-xx/anat`
- Structural data for that subject

`derivative/sub-xx/anat/cbs`
- High-res (.4 mm)3 segmentation
- Layerings (volume and level sets)
- Mid-cortical depth VTK surfaces

`derivative/sub-xx/anat/spm`
- Segmentation w/ backward and forward deformation field to MNI


### Probability maps

`derivative/sub-xx/pmap`
Probability maps for that subject:
- Brought to native space
- Co-registered to high-res structural and resliced
- Mapped to surfaces
- Thresholded for visual ROIs (final binary masks)


### ROI

`derivative/sub-xx/roi/vol/mni`
- Volume ROI brought to native space

`derivative/sub-xx/roi/vol/mni/upsamp`
-  Volume ROI co-registered to high-res structural
-  Volume ROI resliced to high-res structural
-  Volume ROI created from surface binary masks

`derivative/sub-xx/roi/surf`
- `sub-xx_ROI_VertOfInt.mat`: has the list of all the vertices belonging to a given ROI.
- binary surface masks of A1 delineation and PT


### Figures

`derivative/sub-xx/fig`
Subject specific figures


### Code

`derivative/sub-xx/code/cbs`
Subject specific scripts or layout. Mostly MIPAV-CBS tools stuff.

`derivative/sub-xx/code/cbs/surfcoreg`
Preprocessed data for the surface coregistration
- preprocess_bold →  stimuli data
- preprocess_targets →  target data
- preprocess_roi →  probability maps
- preprocess_roi_2 → ROI binary mask


### Results

`derivative/sub-xx/results`
Subject specific results or extracted data

`derivative/sub-xx/results/SVM`
MVPA results
`derivative/sub-xx/results/PCM/vol`
PCM*.mat : extracted data for PCM or RSA in volume

`derivative/sub-xx/results/PCM/profiles`
Data*.mat : results of the BOLD profile in volumes

`derivative/sub-xx/results/profiles/surf`
Data\*.mat : results of the BOLD profile in surfaces

`derivative/sub-xx/results/profiles/surf/cdt`
VTK surfaces of the mass univariate laminar GLM for profile fitting for the all conditions (3 surfaces - constant, linear, quadratic – for each)

`derivative/sub-xx/results/profiles/surf/side`
Same but for the contra-ipsi contrast for each condition

`derivative/sub-xx/results/profiles/surf/cross-sens`
Same but for the between sensory modalities contrast

`derivative/sub-xx/results/profiles/surf/rasters`
Sub-xx-SurfRasters.mat contains all the rasters for that subject.


### GLM

`derivative/sub-xx/ffx-xxx`
SPM first level GLM analysis for that subject:
- ffx_nat: native space
- ffx_nat_smooth: same but smoothed (to get inclusive mask for other first level GLMs)
- ffx_rsa: beta images whitened using rsa toolbox (whitening only performed on subpart of the images containing all our ROIs)
- ffx_trim: GLM with matched number of target and stimuli for each condition (for target VS stim MVPA and RSA)

`derivative/sub-xx/ffx-xxx/betas`
-  betas of interest co-registered to high-res structural
-  resliced and compressed
-  volume data (BOLD*.mat or Features*.mat) extracted for each ROI

`derivative/sub-xx/ffx-xxx/betas/6_surf`
- each beta (for the stimuli) mapped onto 6 cortical surfaces
- mean effect of each condition for each layer
- `sub-xx_features_xhs_6_surf.mat` contains all the data extracted from valid vertices
- `sub-xx_features_yhs_6_surf.mat` contains all the data extracted from one hemisphere y and from valid vertices across all 6 layers.

`derivative/sub-xx/ffx-xxx/betas/6_surf/targets`
Same as above but for targets



## Group level

### ROI

`derivative/roi_mni`
All the binary masks of the ROI used (in MNI space)

### Group level GLM

`derivative/rfx`
SPM second level analysis (done with normalized con image from ffx_nat_smooth).

### Probability maps

`derivative/pmaps`
Whole brain probability maps in MNI space

`derivative/pmaps/BT`
From the [brainetome atlas]

`derivative/pmaps/Ret`
From the [probabilistic retinotopic atlas]

`derivative/pmaps/archives`
Original pmaps for each hemisphere

### Surface registration

`derivative/surfreg`
Surface registration data and results
Often contain .txt files listing the input files for a given JIST layout (see for example List_files_to_avg)

`derivative/surfreg/preprocess`
Preprocess of the level-set and the T1 map

`derivative/surfreg/MMSR1`
First round of surface registration

`derivative/surfreg/avginter`
Intermediate surface group average to create a new target for the next round of MMSR

`derivative/surfreg/MMSR2`
Final round of surface registration

`derivative/surfreg/uncrop`
up sample data to perform high-res surface registration

`derivative/surfreg/GrpAvgT1`
high-res surface registration of T1 maps

`derivative/surfreg/GrpAvgT1_low_res`
low-res surface registration of T1 maps

`derivative/surfreg/GrpAvgROI`
same for ROI probability maps

`derivative/surfreg/GrpAvgBOLD`
low-res surface registration of BOLD data for the stimuli for each sampled cortical depth

`derivative/surfreg/GrpAvgTargets`
same for targets

`derivative/surfreg/*/[LR]H`
data for the left and right hemisphere
- `GrpSurf_xstimy_layer_z_yh.vtk` : VTK surfaces with data for all subjects for stimulus X in layer Z of hemisphere Y.
- `mean*.vtk` : files contain averages performed across subjects but within layers.
- `*mask*.vtk` : files indicate the number of subject with valid data for each vertex.
- `*smoothdata.vtk` : refers to vtk files surface smoothed with FWHM=1.5 mm

`derivative/surfreg/*/[LR]H/NoGLM`
Data average across subjects and layers

`derivative/surfreg/*/[LR]H/NoGLM/Baseline`
Results of group level laminar GLM for the [Cdt – Fix] contrast

`derivative/surfreg/*/[LR]H/NoGLM/CrossSide`
Results of group level laminar GLM for the [Cdt_ipsi – Cdt_contra] contrast

`derivative/surfreg/*/[LR]H/NoGLM/CrossSens`
Results of group level laminar GLM for the [Cdt-1ipsi/contra – Cdt-2ispi/contra] contrast
