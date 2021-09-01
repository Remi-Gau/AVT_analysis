Processing beta images
**********************

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