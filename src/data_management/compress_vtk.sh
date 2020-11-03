#!/bin/bash

clear

data_dir=`pwd`

SubList="$(ls | grep sub)"

echo $data_dir

for iSubject in $SubList;
do

	echo "\nCompressing files for subject $iSubject \n"


	FileList="$(ls $data_dir/$iSubject/ffx_nat/betas/6_surf/Beta_*.vtk)"
		
	for File in $FileList;
	do
		echo $File	
		
		# Compress
		gzip -v $File			
		#tar -jcvf S3rBetaFiles.tar.bz2 $FileList

		# Decompress
		#gunzip -v $File
		
	done


	FileList="$(ls $data_dir/$iSubject/ffx_nat/betas/6_surf/targets/Beta_*.vtk)"
		
	for File in $FileList;
	do
		echo $File	
		
		# Compress
		gzip -v $File			
		#tar -jcvf S3rBetaFiles.tar.bz2 $FileList

		# Decompress
		#gunzip -v $File
		
	done


	FileList="$(ls $data_dir/$iSubject/ffx_rsa/betas/6_surf/Beta_*.vtk)"
		
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


