#!/bin/bash

clear

StartDir=`pwd`

SubList="$(ls | grep sub)"

echo $StartDir

for Subject in $SubList;
do

	echo "\nCompressing files for subject $Subject \n"


	FileList="$(ls $StartDir/$Subject/ffx_nat/betas/6_surf/Beta_*.vtk)"
		
	for File in $FileList;
	do
		echo $File	
		
		# Compress
		gzip -v $File			
		#tar -jcvf S3rBetaFiles.tar.bz2 $FileList

		# Decompress
		#gunzip -v $File
		
	done


	FileList="$(ls $StartDir/$Subject/ffx_nat/betas/6_surf/targets/Beta_*.vtk)"
		
	for File in $FileList;
	do
		echo $File	
		
		# Compress
		gzip -v $File			
		#tar -jcvf S3rBetaFiles.tar.bz2 $FileList

		# Decompress
		#gunzip -v $File
		
	done


	FileList="$(ls $StartDir/$Subject/ffx_rsa/betas/6_surf/Beta_*.vtk)"
		
	for File in $FileList;
	do
		echo $File	
		
		# Compress
		gzip -v $File			
		#tar -jcvf S3rBetaFiles.tar.bz2 $FileList

		# Decompress
		#gunzip -v $File
		
	done

done


