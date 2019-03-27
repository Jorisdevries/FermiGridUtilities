#!/bin/bash
# Example usage: `source movePndr.sh "/pnfs/uboone/scratch/users/jdevries/sample_generation/pndr_files/ccqe_contained" "/uboone/app/users/jdevries/pndr_files/ccqe_contained_v06_25_00" "containedCCQE"`

# Grab the input parameters.
source_dir=$1 #grid output directory that contains lots of subdirectories
pndr_dir=$2
project_name=$3
pndr_label=$4
is_data=$5

fileIdentifier=0
cwd=`pwd`

if [[ -f pot_runlist.txt  ]];
then
    rm pot_runlist.txt
fi

prefix=$(samweb list-files "defname: $project_name" | head -n1)
file_start=$(echo $prefix | cut -f1 -d"_")

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

    file_size_kb=$(du -k "Pandora_Events.pndr" | cut -f1)
    job_status=$(cat larStage0.stat)

    if [[ $file_size_kb == 0 || $job_status != 0 ]];
    then
       continue 
    fi

    file_names=$(cat condor_lar_input.list)
    echo "$file_names" >> $pot_runlist_location

    #only move pndr file if POT information has been succesfully written to runlist
    cp Pandora_Events.pndr ${pndr_dir}/Pandora_Events_${pndr_label}_${fileIdentifier}.pndr

    fileIdentifier=$[$fileIdentifier+1]
done
echo -ne \\n

echo "Number of .pndr files succesfully created: $fileIdentifier"

echo "Calculating summed POT..."

duplicate_entries=$(sort $pot_runlist_location | uniq -cd | wc -l)

if [[ $duplicate_entries != 0 ]];
then
    echo "WARNING: DUPLICATE ENTRIES IN POT RUNLIST. POT IS OVERESTIMATED."
fi

cd $cwd
lineNumber=0

if [[ $is_data == true ]]; then
    #Note: for data samples newer than Neutrino 2016 supply the -v2 flag
    getDataInfo.py -v2 --file-list $pot_runlist_location | tee saved_pot_output.txt
else
    if [[ -f pot_sums.txt  ]];
    then
        rm pot_sums.txt
    fi

    while read line; do
        if [[ -f latest_sumpot.txt  ]];
        then
            rm latest_sumpot.txt
        fi

        echo -ne " > Processing file $lineNumber"\\r

        getMCPOT_skipcheck.py -f $line &>/dev/null

        output=$(cat latest_sumpot.txt) 
        pot_number=$(echo ${output##*:})
        pot_value=$(echo $pot_number | sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g')
        echo $pot_value >> pot_sums.txt

        lineNumber=$[$lineNumber+1]
    done <$pot_runlist_location

    pot_sum=$(paste -sd+ pot_sums.txt | bc)
    echo "Final POT sum: $pot_sum" | tee saved_pot_output.txt
fi
