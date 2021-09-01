MVPA
****

Scripts and functions related to MVPA.

----

The scripts are all in the `mvpa` folder.

Options for the MVPA are set in the `subfun/mvpa/get_mvpa_options.m`



`code/mvpa/FeatPool/surf`

1. `MVPA_surf_pool_hs.m` : Runs the MVPA analysis at the laminar level and whole
   ROI level. Does it for all the classifications and ROIs. Calls to
   sub-function in code/subfun/mvpa. Adapted from Agoston scripts. Many options
   for permutation, feature and image scaling, learning curves, feature
   selection, grid-search... Feature pooling from each hemipshere is done there.
   Saves one mat file / subject / classification / ROI the accuracies for all
   cross-validation for the whole ROI and each layer.

1. `MVPA_surf_pool_grp_avg.m` : averages accuracies across subjects and does the
   laminar GLM over them.

`code/figures/FeatPool/MVPA/surf/`

1. `All_ROIs_MVPA_surf_pool_hs_plot.m` : plots the results of all ROIs. Calls
   sub-function for plotting and to do the permutation test.


   ## Unpooled analysis

### Surface based

folder : `src/mvpa/surf/`

`MVPA_surf.m` `MVPA_surf_grp_avg.m`




