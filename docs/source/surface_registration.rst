Surface registration
********************
  
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



