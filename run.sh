#!/bin/bash

# Usage: `source run.sh`

# Set the configurable parameters.
user_name="jdevries"                                                                        # your username
project_name="prodgenie_bnb_intrinsic_nue_cosmic_uboone_mcc8.7_reco2"                       # a samweb project definition
larsoft_release_name="v06_85_00"                                                            # the LArSoft release you are using to reconstruct events
qualifier="e15:prof"                                                                        # the qualifier associated to your LArSoft release
tarball_path="/pnfs/uboone/resilient/users/jdevries/tarballs/larsoft_v06_85_00.tar"         # fully-qualified path to your LArAoft release tarball
max_files=95                                                                                # the maximum number of files to process
events_per_file=50                                                                          # number of events per file to process
number_files_per_job=10                                                                     # number of files to process per grid job
prestage=false                                                                              # whether to stage the files in the provided samweb project before running the scripts
file_prefix="Test"                                                                          # what to call the output files
resumbit=false                                                                              # whether to resubmit failed jobs 
resumbit_cycles=3                                                                           # how many resubmit cycles to use
is_data=true                                                                                # whether files are data
fcl_file_name="makePndr.fcl"                                                                # name of the .fcl file to use (fully qualified or in local directory)

# Run the batch script.
source create_dataset.sh "$user_name" "$project_name" "$larsoft_release_name" "$qualifier" "$tarball_path" "$max_files" "$events_per_file" "$number_files_per_job" "$prestage" "$file_prefix" "$resumbit" "$resumbit_cycles" "$is_data" "$fcl_file_name" 
