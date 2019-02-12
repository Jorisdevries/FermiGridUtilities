#!/bin/bash
# Example usage: `source movePndr.sh "/pnfs/uboone/scratch/users/jdevries/sample_generation/pndr_files/ccqe_contained" "/uboone/app/users/jdevries/pndr_files/ccqe_contained_v06_25_00" "containedCCQE"`

# Grab the input parameters.
source_dir=$1 #grid output directory that contains lots of subdirectories
pndr_dir=$2
project_name=$3
pndr_label=$4

fileIdentifier=0
cwd=`pwd`

if [[ -f pot_runlist.txt  ]];
then
    rm pot_runlist.txt
fi

prefix=$(samweb list-files "defname: $project_name" | head -n1)
prefix=${prefix%.root}
prefix=${prefix##*_}

touch pot_runlist.txt
pot_runlist_location=$(readlink -f pot_runlist.txt)

for i in `find ${source_dir} -mindepth 1 -type d`
do
    cd $i

    echo -ne " > Processing output from subdirectory $fileIdentifier"\\r

    if [[ ! -f Pandora_Events.pndr ]];
    then
       continue 
    fi

    #convert .root file name in output subdirectory to its original samweb name so its metadata can be checked
    file_name=$(find -name "PhysicsRun-*.root")
    file_name=${file_name:2}
    file_name=${file_name%$prefix*}
    suffix="${prefix}.root"
    file_name=${file_name}$suffix

    #get run and subrun information
    output=$(samweb get-metadata $file_name)

    #continue if file not found
    if [[ -z $output ]];
    then
        continue
    fi

    run_info=$(echo $output | sed 's/^.*\(Runs.*Parents\).*$/\1/')
    run_info_2=$(echo $run_info | sed 's/(physics)//g')
    run_info_3=$(echo $run_info_2 | sed 's/Runs: //g')
    clean_run_info=$(echo $run_info_3 | sed 's/ Parents//g')
    spaced_run_info=$(echo "$clean_run_info" | tr "." " ")
    final_run_info=$(echo $spaced_run_info | sed -e 's/ /&\n/2;P;D')

    echo "$final_run_info" >> $pot_runlist_location

    #only move pndr file is POT information has been succesfully written to runlist
    cp Pandora_Events.pndr ${pndr_dir}/Pandora_Events_${pndr_label}_${fileIdentifier}.pndr

    fileIdentifier=$[$fileIdentifier+1]
done
echo -ne \\n

echo "Number of .pndr files succesfully created: $fileIdentifier"
echo "POT counting output:"

duplicate_entries=$(sort pot_runlist.txt | uniq -cd | wc -l)

if [[ $duplicate_entries != 0 ]];
then
    echo "WARNING: DUPLICATE ENTRIES IN POT RUNLIST. POT IS OVERESTIMATED."
fi

#Note: for data samples newer than Neutrino 2016 supply the -v2 flag
cd $cwd
getDataInfo.py --run-subrun-list $pot_runlist_location | tee saved_pot_output.txt

