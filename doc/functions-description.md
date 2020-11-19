# Data analysis workflow

I indicate here the different folders where the code is kept. I try to indicate
and in which order the scripts (or other manual interventions) have to be run.

## Preprocessing of EPIs

`code/preprocess/`

1. `CpFromSrc.m` : gets the file from the BIDS and unzips some of them
2. `CreateVDM.m` : creates the voxel displacement map using the fieldmap
3. `RealignAndUwarp.m` : realign and unwarp the EPIs
4. `SliceTime.m` : does the slice timing.
5. `SmoothNative.m` : smooths the data. They will only be used to create an
   inclusive mask for the subject level GLM. See FFX_native.m.
6. `RunsPerSes.m` : checks how many sessions (days) and run per session there
   was for each subject store the results in mat file in the root folder.

## Running subject level GLM

`code/ffx/`

1. `FFX_native.m` : runs the subject level GLM. It is run a first time to get on
   smoothed images to get an inclusive mask (GLM-mask) that will be used for a
   second pass.
2. `FFX_RSA.m`: whitens the beta from the subject level GLM using the RSA
   toolbox machinery

## Preprocessing anatomical

`code/cbs/` or `sub-xx/code/cbs/` `segment-layer.LayoutXML` : high-res
segmention and layering using the CBS tools

---

`_What we have so far:_`

-   beta images (SPM)
-   mid cortex vtk surfaces (CRUISE + inflation)
-   layers level-sets

---

## Processing the beta images

`code/preprocess_betas/`

1. `CpBetas.m` : isolate the betas of interest from the subject level GLM and
   copies them in a separate folder (also takes meanEPI and GLM mask)
2. `mancoreg.m` : This function comes from uses
   [SPM-RG](https://github.com/Remi-Gau/SPM-RG) and allows a manual
   coregistration to align meanEPI to high-res structural. This is required,
   because even if we had co-registered 0.8 mm structural and EPI at the very
   beginning, MIPAV will transform the structural independently during
   pre-processing and segmentation; so we need to co-register structural and
   functional here again). This is all due to the fact that SPM and MIPAV rely
   on different transformation matrices from the image header.
3. `CoregMean2AnatCBS.m` : coregister meanEPI to high res anat and applies
   transformation to betas of interest
4. Check coregistration with FSLview to flip back and forth between mean EPI and
   structural. Redo 2 and 3 until you get an adequate coregistration.
5. `ResliceBetas.m` : if the coregistration is adequate we reslice the betas to
   the 0.4 mm resolution of the high-res structural

## Mapping the beta images on surfaces

`code/cbs` or `sub-xx/code/cbs/``

1. `map_beta_2_surf.LayoutXML` : maps each high-res beta image onto the layers
   The layers level-sets were computed for the whole brain but they are mapped
   on the surfaces of each hemisphere: there is a 1 to 1 correspondence (I.e
   they are in the same space) between the whole brain level-sets of the layers
   and the level that was used to generate the mid-cortex surface VTK file.
2. `Extract_mapped_target_betas.m` : copies vtk files out of the folder
   structure created by the CBS tools. Renames them so that we know which vtk
   file corresponds to which beta image. Calls the recursive function
   Extract_mapped_betas_VTK.m.
3. `ExtractFeatSurf.m` : extracts data (i.e. beta values for vertex in a
   particular surface-layer) from all the VTK. Relies on parfor and brute force
   but fast “textscan” rather than the slower read_vtk.m . Requires to know how
   many vertices the VTK files have. Saves the data for the whole surface and
   for each beta dimension are [vertex, layer, beta]. Also saves the list of
   vertices that have data at each depth.

## Extracting Data

`code/roi`

1. `Extract_vert_of_interest_ROI.m` : get the vertices of interest for each ROI
   (reads them from the surface binary mask).

in the cbs folder to extract beta values mapped on surfaces

## BOLD profiles

`code/bold_profiles/FeatPool/surf`

1. `bold_profiles_surf_pool_hs.m` : compute the bold profiles and does the
   laminar GLM for each ROI, condition, contrast. Saves the values and the betas
   of the laminar GLM for each subject. Feature pooling from each hemisphere is
   done there.
2. `bold_profiles_surf_pool_hs_grp_avg.m` : compile results from all subjects
   and does the group averaging

`code/figures/FeatPool/BOLD/surf/`

1. `All_ROIs_profile_surf_pool_hs_plot.m` : plots the results of all ROIs. Calls
   sub-function for plotting and to do the permutation test.

## MVPA

`code/mvpa/FeatPool/surf`

1. `MVPA_surf_pool_hs.m` : Runs the MVPA analysis at the laminar level and whole
   ROI level. Does it for all the classifications and ROIs. Calls to
   sub-function in code/subfun/mvpa. Adapted from Agoston scripts. Many options
   for permutation, feature and image scaling, learning curves, feature
   selection, grid-search... Feature pooling from each hemipshere is done there.
   Saves one mat file / subject / classification / ROI the accuracies for all
   cross-validation for the whole ROI and each layer.

1. `MVPA_surf_pool_grp_avg.m` : averages accuracies across subjects and does
   the laminar GLM over them.

`code/figures/FeatPool/MVPA/surf/`

1. `All_ROIs_MVPA_surf_pool_hs_plot.m` : plots the results of all ROIs. Calls
   sub-function for plotting and to do the permutation test.

## Unpooled analysis

### Surface based

folder : `src/mvpa/surf/`

`MVPA_surf.m`
`MVPA_surf_grp_avg.m`

## Surface registration

`code/surfreg` For the surface registration, a lot of the JIST layouts use .txt
files as inputs that list with their fullpath the files to use. Those .txt files
can be generated via the command line, a bash script, or matlab.

1. `FindMedianLevelSet.m` : identify for the left and right hemisphere the
   median subject to use as target for the first round of the surface
   registration
2. `PreProcess.LayoutXML` : preprocess the mid-cortical surface level set and
   the high-res T1 map of all subject to get them ready for the first round of
   surface registration
3. `MMSR1/2.LayoutXML`: Runs the actual surface registration
4. `avg_inter.LayoutXML` : Creates a first group surface average that will be
   used as target in the second round of the registration

## Pattern component model

Run by the script: `pcm/bold_PCM_3X3Models.m`

The `surf` and `vol` contains the scripts to extract the data from the ROI in
the volume data or in the surface data before or after whitening (spatial
multivariate normalization done by the RSA toolbox).

## MVPA

The scripts are all in the `mvpa` folder.

Options for the MVPA are set in the `subfun/mvpa/get_mvpa_options.m`

