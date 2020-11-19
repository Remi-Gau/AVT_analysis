#!/bin/bash

# small script to reorganize the data in separate folder to prepare for ingestion
# by datalad and uploading on gin

clear

src_dir='/home/remi/Dropbox/PhD/Experiments/AVT/derivatives'


subjects_list="$(ls $src_dir | grep sub)"

echo $src_dir
echo $subjects_list

target_dir='/home/remi/gin/AVT/derivatives'
space='surf'

mkdir $target_dir/libsvm-$space

for iSubject in $subjects_list;
do

	echo "\Moving files for subject $iSubject \n"

	mkdir $target_dir/libsvm-$space/$iSubject

	cd $ls $src_dir/$iSubject/results/SVM

	files_list="$(ls *results_$space*.mat)"

	echo $files_list
		
	for iFile in $files_list;
	do
		echo $iFile

		cp -v $src_dir/$iSubject/results/SVM/$iFile \
		   $target_dir/libsvm-$space/$iSubject/$iFile
		
	done

done


