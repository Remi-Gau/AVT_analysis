GLM
***
  
Scripts and functions related to subject level models.

----

.. automodule:: src 

.. autofunction:: convertSourceToRaw



## Running subject level GLM

`code/ffx/`

1. `FFX_native.m` : runs the subject level GLM. It is run a first time to get on
   smoothed images to get an inclusive mask (GLM-mask) that will be used for a
   second pass.
2. `FFX_RSA.m`: whitens the beta from the subject level GLM using the RSA
   toolbox machinery




