#!/bin/bash

cd ../..

StartDir=`pwd`

SubList="$(ls | grep sub)"

for Subject in $SubList;
do

	echo "\nCompressing files for subject $Subject \n"

	cd $StartDir/$Subject

	SesList="$(ls | grep ses)"

	for Ses in $SesList;
	do
		cd $StartDir/$Subject/$Ses/func

		echo "\n\tCompressing files for session sh ./$Ses"

		#FileList="$(ls sub-*.nii)"
		FileList="$(ls uv*.nii)"
		#FileList="$(ls au*.nii)"
		#FileList="$(ls sau*.nii)"

		#FileList="$(ls au*.nii.gz)"
		#FileList="$(ls sau*.nii.gz)"


		for File in $FileList;
		do
			echo $File

			# Compress
			gzip -v $File
			#tar -jcvf S3rBetaFiles.tar.bz2 $FileList

			# Decompress
			#gunzip -v $File

		done

		cd ..

	done

done

