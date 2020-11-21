Preprocessing
*************
  
List of functions in the ``src`` folder.  

----

.. automodule:: src 

.. autofunction:: convertSourceToRaw


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

## Preprocessing anatomical

`code/cbs/` or `sub-xx/code/cbs/` `segment-layer.LayoutXML` : high-res
segmention and layering using the CBS tools



