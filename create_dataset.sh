#!/bin/bash

#example usage: source create_dataset.sh jdevries jdevries_run1_neutrino2016 v06_26_01_10 /uboone/app/users/jdevries/larsoft_v06_26_01_10/local.tar 100 100 false Neutrino2016 
user_name=$1 		        # your username
project_name=$2 	        # a samweb project definition
larsoft_release_name=$3     # the LArSoft release you are using to reconstruct events
tarball_path=$4 	        # fully-qualified path to your LArAoft release tarball
max_files=$5 		        # the maximum number of files to process
events_per_file=$6          # number of events per file to process
prestage=$7 		        # whether to stage the files in the provided samweb project before running the scripts
file_prefix=$8 		        # what to call the output files
resumbit=$9                 # whether to resubmit failed jobs 
resumbit_cycles=$10         # how many resubmit cycles to use

#sanity check on tarball (very important)
if [[ $tarball_path != /pnfs/uboone/resilient/users/* ]];
then
    echo "ERROR: your tarball is not in /pnfs/uboone/resilient/ and will not work. Aborting."
    exit 1
fi

#setup project
echo "Setting up project..."
source setup_project.sh $user_name $project_name $prestage

#create or clean necessary directories
echo "Creating/cleaning directories..."
source create_or_clean_directories.sh $user_name $project_name

#create a runlist containing all the reco2 file paths
echo "Creating runlist..."
source create_smart_runlist.sh $project_name $max_files 
runlist_location=$(find `pwd` -name runlist.txt)

#create custom xml file to create pndr files for this project from its reco2 files
echo "Creating xml file..."
xml_name=pndr_writer_${project_name}.xml

if [[ -f $xml_name  ]];
then
    rm $xml_name
fi

total_number_events=$(($max_files * $events_per_file))

sed -e s,PROJECT_NAME,$project_name, -e s,LARSOFT_RELEASE_NAME,$larsoft_release_name, -e s,USER_NAME,$user_name, -e s,TARBALL_PATH,$tarball_path, -e s,RUNLIST_PATH,$runlist_location, -e s,MAX_FILES,$max_files, -e s,TOTAL_EVENTS,$total_number_events, pndr_writer.xml > $xml_name 

#submit jobs
echo "Submitting jobs..."
project.py --xml $xml_name --stage pndr --submit &> /dev/null
sleep 5
source show_remaining_jobs.sh $xml_name 

#unpack job output
echo "Checking jobs (and unpacking job output)..."
project.py --xml $xml_name --stage pndr --check &> /dev/null

#echo "Resubmitting failed jobs..."
if [[ $resubmit ]];
then
    source resubmit_failed_jobs.sh $xml_name $resumbit_cycles
fi

#collect pndr output files in a separate directory
echo "Moving .pndr files and constructing POT runlist..."
source move_pndr_and_count_pot.sh /pnfs/uboone/scratch/users/$user_name/$project_name/pndr /pnfs/uboone/scratch/users/$user_name/${project_name}_collected_pndr $file_prefix

echo -ne \\n
