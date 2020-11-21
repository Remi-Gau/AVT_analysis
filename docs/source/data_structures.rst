Data structures
***************

Left and right hemisphere can be denoted by:

-   L/R
-   lh/rh
-   or lcr/rcr
-   or lhs/rhs

Conditions are denoted by XTypeZ (e.g AstimL):

-   X: sensory modality (A/V/T)
-   Type: Stim, Targ
-   Z: side of presentation (L/R)

Surfaces are either inflated (inf suffix) or not. Surface results of laminar GLM
are decomposed in:

-   Cst → constant
-   Lin → linear
-   Quad → quadratic

Raw data are stored in as [BIDS](http://bids.neuroimaging.io/)

Most images stored as 4D nifti and compressed (gunzip).

## Subject level

Each subject is in a `sub-xx` folder.

### Anatomical

`derivative/sub-xx/anat`

-   Structural data for that subject

`derivative/sub-xx/anat/cbs`

-   High-res (.4 mm)3 segmentation
-   Layerings (volume and level sets)
-   Mid-cortical depth VTK surfaces

`derivative/sub-xx/anat/spm`

-   Segmentation w/ backward and forward deformation field to MNI

### Probability maps

`derivative/sub-xx/pmap` Probability maps for that subject:

-   Brought to native space
-   Co-registered to high-res structural and resliced
-   Mapped to surfaces
-   Thresholded for visual ROIs (final binary masks)

### ROI

`derivative/sub-xx/roi/vol/mni`

-   Volume ROI brought to native space

`derivative/sub-xx/roi/vol/mni/upsamp`

-   Volume ROI co-registered to high-res structural
-   Volume ROI resliced to high-res structural
-   Volume ROI created from surface binary masks

`derivative/sub-xx/roi/surf`

-   `sub-xx_ROI_VertOfInt.mat`: has the list of all the vertices belonging to a
    given ROI.
-   binary surface masks of A1 delineation and PT

### Figures

`derivative/sub-xx/fig` Subject specific figures

### Code

`derivative/sub-xx/code/cbs` Subject specific scripts or layout. Mostly
MIPAV-CBS tools stuff.

`derivative/sub-xx/code/cbs/surfcoreg` Preprocessed data for the surface
coregistration

-   preprocess_bold → stimuli data
-   preprocess_targets → target data
-   preprocess_roi → probability maps
-   preprocess_roi_2 → ROI binary mask

### Results

`derivative/sub-xx/results` Subject specific results or extracted data

`derivative/sub-xx/results/SVM` MVPA results `derivative/sub-xx/results/PCM/vol`
PCM\*.mat : extracted data for PCM or RSA in volume

`derivative/sub-xx/results/PCM/profiles` Data\*.mat : results of the BOLD
profile in volumes

`derivative/sub-xx/results/profiles/surf` Data\*.mat : results of the BOLD
profile in surfaces

`derivative/sub-xx/results/profiles/surf/cdt` VTK surfaces of the mass
univariate laminar GLM for profile fitting for the all conditions (3 surfaces -
constant, linear, quadratic – for each)

`derivative/sub-xx/results/profiles/surf/side` Same but for the contra-ipsi
contrast for each condition

`derivative/sub-xx/results/profiles/surf/cross-sens` Same but for the between
sensory modalities contrast

`derivative/sub-xx/results/profiles/surf/rasters` Sub-xx-SurfRasters.mat
contains all the rasters for that subject.

### GLM

`derivative/sub-xx/ffx-xxx` SPM first level GLM analysis for that subject:

-   ffx_nat: native space
-   ffx_nat_smooth: same but smoothed (to get inclusive mask for other first
    level GLMs)
-   ffx_rsa: beta images whitened using rsa toolbox (whitening only performed on
    subpart of the images containing all our ROIs)
-   ffx_trim: GLM with matched number of target and stimuli for each condition
    (for target VS stim MVPA and RSA)

`derivative/sub-xx/ffx-xxx/betas`

-   betas of interest co-registered to high-res structural
-   resliced and compressed
-   volume data (BOLD*.mat or Features*.mat) extracted for each ROI

`derivative/sub-xx/ffx-xxx/betas/6_surf`

-   each beta (for the stimuli) mapped onto 6 cortical surfaces
-   mean effect of each condition for each layer
-   `sub-xx_features_xhs_6_surf.mat` contains all the data extracted from valid
    vertices
-   `sub-xx_features_yhs_6_surf.mat` contains all the data extracted from one
    hemisphere y and from valid vertices across all 6 layers.

`derivative/sub-xx/ffx-xxx/betas/6_surf/targets` Same as above but for targets

## Group level

### ROI

`derivative/roi_mni` All the binary masks of the ROI used (in MNI space)

### Group level GLM

`derivative/rfx` SPM second level analysis (done with normalized con image from
ffx_nat_smooth).

### Probability maps

`derivative/pmaps` Whole brain probability maps in MNI space

`derivative/pmaps/BT` From the [brainetome atlas]

`derivative/pmaps/Ret` From the [probabilistic retinotopic atlas]

`derivative/pmaps/archives` Original pmaps for each hemisphere

### Surface registration

`derivative/surfreg` Surface registration data and results Often contain .txt
files listing the input files for a given JIST layout (see for example
List_files_to_avg)

`derivative/surfreg/preprocess` Preprocess of the level-set and the T1 map

`derivative/surfreg/MMSR1` First round of surface registration

`derivative/surfreg/avginter` Intermediate surface group average to create a new
target for the next round of MMSR

`derivative/surfreg/MMSR2` Final round of surface registration

`derivative/surfreg/uncrop` up sample data to perform high-res surface
registration

`derivative/surfreg/GrpAvgT1` high-res surface registration of T1 maps

`derivative/surfreg/GrpAvgT1_low_res` low-res surface registration of T1 maps

`derivative/surfreg/GrpAvgROI` same for ROI probability maps

`derivative/surfreg/GrpAvgBOLD` low-res surface registration of BOLD data for
the stimuli for each sampled cortical depth

`derivative/surfreg/GrpAvgTargets` same for targets

`derivative/surfreg/*/[LR]H` data for the left and right hemisphere

-   `GrpSurf_xstimy_layer_z_yh.vtk` : VTK surfaces with data for all subjects
    for stimulus X in layer Z of hemisphere Y.
-   `mean*.vtk` : files contain averages performed across subjects but within
    layers.
-   `*mask*.vtk` : files indicate the number of subject with valid data for each
    vertex.
-   `*smoothdata.vtk` : refers to vtk files surface smoothed with FWHM=1.5 mm

`derivative/surfreg/*/[LR]H/NoGLM` Data average across subjects and layers

`derivative/surfreg/*/[LR]H/NoGLM/Baseline` Results of group level laminar GLM
for the [Cdt – Fix] contrast

`derivative/surfreg/*/[LR]H/NoGLM/CrossSide` Results of group level laminar GLM
for the [Cdt_ipsi – Cdt_contra] contrast

`derivative/surfreg/*/[LR]H/NoGLM/CrossSens` Results of group level laminar GLM
for the [Cdt-1ipsi/contra – Cdt-2ispi/contra] contrast
