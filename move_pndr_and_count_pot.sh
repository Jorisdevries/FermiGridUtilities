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

    #convert .root file name in output subdirectory to its original samweb name so its metadata can be checked
    file_name=$(find -name "${file_start}*.root")
    file_name=${file_name:2}
    file_name=${file_name%$prefix*}
    suffix="${prefix}.root"
    file_name=${file_name}$suffix

    if [[ $is_data = True ]]; then
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
    else
        echo $file_name >> $pot_runlist_location
    fi

    #only move pndr file is POT information has been succesfully written to runlist
    cp Pandora_Events.pndr ${pndr_dir}/Pandora_Events_${pndr_label}_${fileIdentifier}.pndr

    fileIdentifier=$[$fileIdentifier+1]
done
echo -ne \\n

echo "Number of .pndr files succesfully created: $fileIdentifier"

echo "Calculating summed POT..."

cd $cwd

if [[ $is_data == true ]]; then
    duplicate_entries=$(sort $pot_runlist_location | uniq -cd | wc -l)

    if [[ $duplicate_entries != 0 ]];
    then
        echo "WARNING: DUPLICATE ENTRIES IN POT RUNLIST. POT IS OVERESTIMATED."
    fi

    #Note: for data samples newer than Neutrino 2016 supply the -v2 flag
    getDataInfo.py --run-subrun-list $pot_runlist_location | tee saved_pot_output.txt
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

        output=$(getMCPOT_skipcheck.py -f $line &>/dev/null)
        #last_line=$(echo "$output" | tail -n1) 

        last_line=$(cat latest_sumpot.txt | tail -n1) 
        pot_number=$(echo ${last_line##*:})
        pot_value=$(echo $pot_number | sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g')
        echo $pot_value >> pot_sums.txt
    done <$pot_runlist_location

    pot_sum=$(paste -sd+ pot_sums.txt | bc)
    echo "Final POT sum: $pot_sum" | tee saved_pot_output.txt
fi
