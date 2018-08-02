# Audio-visual-tactile 7 tesla

Data analysis work flows

code/preprocess/
	CreateVDM: creates the voxel displacement map using the fieldmap
	RealignAndUwarp: uses the VDM to realign and unwarp the EPIs
	SliceTime

code/ffx/
	FFX_native: run on smoothed images first to get inclusive mask
	FFX_RSA: whitens the beta from the first level GLM using the RSA toolbox machinery
	
code/cbs/ or sub-xx/code/cbs/
	segment-layer.LayoutXML: high-res segmention and layering

What we have:
	- beta images (SPM)
	- mid cortex vtk surfaces (CRUISE + inflation)
	- layers level-sets

code/preprocess_betas/
	CpBetas: isolate the betas of interest from the 1rst level GLM and copies them in a separate folder (also takes meanEPI and GLM mask)
	mancoreg: uses manual coregistration to align meanEPI to high-res structural
	(this is required, because even if we had co-registered 0.8 mm structural and EPI at the very beginning., MIPAV will transform the structural independently during pre-processing and segmentation; so we need to co-register structural and functional here again)
	CoregMean2AnatCBS: coregister meanEPI to high res anat and applies transformation to betas of interest

Check coregistration with FSLview to flip back and forth between mean EPI and structural

	ResliceBetas: if the coregistration is adequate we reslice the betas to the 0.4 mm resolution of the high-res structural




code/cbs or sub-xx/code/cbs/
	map_beta_2_surf.LayoutXML: maps each high-res beta image onto the layers

The layers level-sets were computed for the whole brain but they are mapped on the surfaces of each hemisphere: there is a 1 to 1 correspondence (I.e they are in the same space) between the whole brain level-sets of the layers and the level that was used to generate the mid-cortex surface VTK file.


	Extract_mapped_target_betas: copies vtk files out of the folder structure created by the CBS tools. Renames them so that we know which vtk file corresponds to which beta image
		Calls recursive function Extract_mapped_betas_VTK
	ExtractFeatSurf: extracts data (i.e. beta values for vertex in a particular surface-layer) from all the VTK. Relies on parfor and brute force but fast “textscan” rather than the slower read_vtk. Requires to know how many vertices the VTK files have. Saves the data for the whole surface and for each beta dimension are [vertex,layer,beta]. Also saves the list of vertices that have data at each depth.

code/roi
	Extract_vert_of_interest_ROI: get the vertices of interest for each ROI (reads them from the surface binary mask)



	
	
	
code/bold_profiles/FeatPool/surf
	bold_profiles_surf_pool_hs: compute the bold profiles and does the laminar GLM for each ROI, condition, contrast. Saves the values and the betas of the laminar GLM for each subject. Feature pooling from each hemisphere is done there.
	bold_profiles_surf_pool_hs_grp_avg: compile results from all subjects and does the group averaging


code/figures/FeatPool/BOLD/surf/
	All_ROIs_profile_surf_pool_hs_plot: plots the results of all ROIs. Calls sub-function for plotting and to do the permutation test.


code/mvpa/FeatPool/surf
	MVPA_surf_pool_hs: Runs the MVPA analysis at the laminar level and whole ROI level. Does it for all the classifications and ROIs. Calls to sub-function in code/subfun/mvpa. Adapted from Agoston scripts. Many options for permutation, feature and image scaling, learning curves, feature selection, grid-search... Feature pooling from each hemipshere is done there. Saves one mat file  / subject / classification / ROI the accuracies for all cross-validation for the whole ROI and each layer.
	MVPA_surf_pool_hs_grp_avg: averages accuracies across subjects and does the laminar GLM over them.

code/figures/FeatPool/MVPA/surf/
	All_ROIs_MVPA_surf_pool_hs_plot: plots the results of all ROIs. Calls sub-function for plotting and to do the permutation test.





code/surfreg

For the surface registration, a lot of the JIST layouts use .txt files as inputs that list with their fullpath the files to use. Those .txt files can be generated via the command line, a bash script, or matlab.

	FindMedianLevelSet.m: identify for the left and right hemisphere the median subject to use as target for the first round of the surface registration

	PreProcess.LayoutXML: preprocess the mid-cortical surface level set and the high-res T1 map of all subject to get them ready for the first round of surface registration

	MMSR1/2.LayoutXML: Runs the actual surface registration

	avg_inter.LayoutXML: Creates a first group surface average that will be used as target in the second round of the registration


sub-??/code/






	

	
	
	




