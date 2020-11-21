Extracting data
***************

## Extracting Data

### ROIs

`surf/roi`

1. `ExtractVerticesOfInterestROI.m` :

get the vertices of interest for each ROI (reads them from the surface binary
mask).

in the cbs folder to extract beta values mapped on surfaces

### mapped betas

```
src/data_management/ExtractMappedBetaFromVTK.m
```

Extracts data (i.e. beta values for vertex in a particular surface-layer) from
all the VTK. Relies on parfor and brute force but fast `textscan` rather than
the slower `read_vtk.m`. Requires to know how many vertices the VTK files have.
Saves the data for the whole surface and for each beta dimension are [vertex,
layer, beta]. Also saves the list of vertices that have data at each depth.




