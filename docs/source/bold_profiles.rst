BOLD profiles
*************
  
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