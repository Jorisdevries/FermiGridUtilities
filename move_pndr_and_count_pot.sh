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

echo $prefix

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

    fileIdentifier=$[$fileIdentifier+1]

    cp Pandora_Events.pndr ${pndr_dir}/Pandora_Events_${pndr_label}_${fileIdentifier}.pndr

    file_name=$(find -name "PhysicsRun-*.root")
    file_name=${file_name:2}
    file_name=${file_name%$prefix*}
    suffix="${prefix}.root"
    file_name=${file_name}$suffix

    output=$(samweb get-metadata $file_name)
    run_info=$(echo "$output" | head -n29 | tail -n2)
    clean_run_info=$(echo "$run_info" | cut -c21- | cut -c -9)
    final_run_info=$(echo "$clean_run_info" | tr "." " ")

    echo "$final_run_info" >> $pot_runlist_location

    #echo -ne " > Copying: ${source_dir}/Pandora_Events_${fileIdentifier}.pndr"\\r
done
echo -ne \\n

echo "Number of .pndr files succesfully created: $fileIdentifier"
echo "POT counting output:"

#Note: for data samples newer than Neutrino 2016 supply the -v2 flag
cd $cwd
getDataInfo.py --run-subrun-list $pot_runlist_location | tee saved_pot_output.txt

