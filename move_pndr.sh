#!/bin/bash
# Example usage: `source movePndr.sh "/pnfs/uboone/scratch/users/jdevries/sample_generation/pndr_files/ccqe_contained" "/uboone/app/users/jdevries/pndr_files/ccqe_contained_v06_25_00" "containedCCQE"`
#source movePndr.sh "/pnfs/uboone/scratch/users/jdevries/cosmic_data/pndr" "/pnfs/uboone/scratch/users/jdevries/cosmic_data_pndr" "CosmicData"

# Grab the input parameters.
source_dir=$1
pndr_dir=$2
pndr_label=$3

counter=0

for i in `ls ${source_dir} | sort -V`
do
    cd $source_dir/$i
    counter=$[$counter+1]

    # Get the file identifier and use this for the output root files.
    fileIdentifier=$counter # $[`echo $i | grep -oP '(?<=_)\d+(?=_reco1\.)'`]
    #outputFile=${pndr_dir}/Pandora_Events_${pndr_label}_$fileIdentifier.pndr;

    cp $source_dir/$i/Pandora_Events.pndr ${pndr_dir}/Pandora_Events_${pndr_label}_$fileIdentifier.pndr

    echo -ne " > Copying: ${source_dir}/Pandora_Events_${fileIdentifier}.pndr"\\r
done
echo -ne \\n
