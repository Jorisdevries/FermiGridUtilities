#!/bin/bash

#example usage: source create_dataset.sh jdevries jdevries_run1_neutrino2016 v06_26_01_10 /uboone/app/users/jdevries/larsoft_v06_26_01_10/local.tar 100 false 
user_name=$1 		#your username
project_name=$2 	#a samweb project definition
larsoft_release_name=$3 #the LArSoft release you are using to reconstruct events
tarball_path=$4 	#fully-qualified path to your LArAoft release tarball
max_files=$5 		#the maximum number of files to process
prestage=$6 		#whether to stage the files in the provided samweb project before running the scripts

#setup project
echo "Setting up project..."
source setup_project.sh $project_name $prestage

#create or clean necessary directories
echo "Creating/cleaning directories..."

if [ -d "/pnfs/uboone/scratch/users/$user_name/$project_name/pndr" ]; then
    rm -rf /pnfs/uboone/scratch/users/$user_name/$project_name/pndr/* 
else
    mkdir -p "/pnfs/uboone/scratch/users/$user_name/$project_name/pndr"
fi

if [ !  -d "/pnfs/uboone/scratch/users/$user_name/work/" ]; then
    mkdir -p "/pnfs/uboone/scratch/users/$user_name/work/"
fi

#create a runlist containing all the reco2 file paths
echo "Creating runlist..."
source create_smart_runlist.sh $project_name $max_files 
runlist_location=$(find `pwd` -name runlist.txt)

#create custom xml file to create pndr files for this project from its reco2 files
echo "Creating xml file..."
xml_name=pndr_writer_${project_name}.xml
rm $xml_name

sed -e s,PROJECT_NAME,$project_name, -e s,LARSOFT_RELEASE_NAME,$larsoft_release_name, -e s,USER_NAME,$user_name, -e s,TARBALL_PATH,$tarball_path, -e s,RUNLIST_PATH,$runlist_location, -e s,MAX_FILES,$max_files, pndr_writer.xml > $xml_name 

#submit jobs
echo "Submitting jobs..."
project.py --xml $xml_name --stage pndr --submit &> /dev/null
sleep 5
source show_remaining_jobs.sh $xml_name 

#echo "Resubmitting failed jobs..."
#source resubmit_failed_jobs.sh $xml_name

echo -ne \\n
