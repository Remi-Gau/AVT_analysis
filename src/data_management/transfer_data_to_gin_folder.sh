#!/bin/bash

# small script to reorganize the data in separate folder to prepare for ingestion
# by datalad and uploading on gin

clear


space='surf'

src_dir='/home/remi/Dropbox/PhD/Experiments/AVT/derivatives'
echo $src_dir

target_dir='/home/remi/gin/AVT/derivatives'
echo $target_dir

## transfer results extracted from surfaces

subjects_list="$(ls $src_dir | grep sub)"
echo $subjects_list

mkdir $target_dir/libsvm-$space

for iSubject in $subjects_list;
do

	echo "\Moving files for subject $iSubject \n"

	mkdir $target_dir/cbstools_extractProfiles-$space/$iSubject
	mkdir $target_dir/cbstools_extractProfiles-$space/$iSubject/stats_ffx-stim
	mkdir $target_dir/cbstools_extractProfiles-$space/$iSubject/stats_ffx-targets

	cp -v $src_dir/$iSubject/ffx_nat/SPM.mat \
	      $target_dir/cbstools_extractProfiles-$space/$iSubject/stats_ffx-stim

	cp -v $src_dir/$iSubject/ffx_nat/betas/6_surf/$iSubject_features*.mat \
	      $target_dir/cbstools_extractProfiles-$space/$iSubject/stats_ffx-stim

	cp -v $src_dir/$iSubject/ffx_nat/betas/6_surf/targets/$iSubject_features*.mat \
	      $target_dir/cbstools_extractProfiles-$space/$iSubject/stats_ffx-targets

done

return

# Transfer BOLD profile results

mkdir $target_dir/cbstools_extractProfiles-$space
mkdir $target_dir/cbstools_extractProfiles-$space/group

cp -v $src_dir/results/profiles/surf/Results*.mat \
   $target_dir/cbstools_extractProfiles-$space/group

# Transfer MVPA results

subjects_list="$(ls $src_dir | grep sub)"
echo $subjects_list

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


