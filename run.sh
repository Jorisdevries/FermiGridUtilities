#!/bin/bash

# Usage: `source run.sh`

# Set the configurable parameters.
user_name="jdevries"                                                                        # your username
project_name="jdevries_goodruns_run1_bnb_unblinded"                                         # a samweb project definition
larsoft_release_name="v06_26_01_10"                                                         # the LArSoft release you are using to reconstruct events
tarball_path="/pnfs/uboone/resilient/users/jdevries/tarballs/larsoft_v06_26_01_10.tar"      # fully-qualified path to your LArAoft release tarball
max_files=4000                                                                             # the maximum number of files to process
events_per_file=500                                                                     # number of events per file to process
prestage=false                                                                              # whether to stage the files in the provided samweb project before running the scripts
file_prefix="Neutrino2016_BNB_WithDQM"                                                                  # what to call the output files
resumbit=false                                                                              # whether to resubmit failed jobs 
resumbit_cycles=3                                                                           # how many resubmit cycles to use

# Run the batch script.
source create_dataset.sh "$user_name" "$project_name" "$larsoft_release_name" "$tarball_path" "$max_files" "$events_per_file" "$prestage" "$file_prefix" "$resumbit" "$resumbit_cycles" 
