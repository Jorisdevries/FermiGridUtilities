# FermiGridUtilities

This repository is a tool intended to speed up the process of creating .pndr files from any samweb definition containing a set of reco2 .root files.

# Usage

All the settings can be found in `run.sh`. The settings are:
* `user_name`: the Fermi servies account to use to authenticate with Kerberos and get a grid certificate
* `project_name`: the name of the samweb project containing (only!) relevant reco2 .root files
* `larsoft_release_name`: the LArSoft version used to process the files (see next item) e.g. v06_26_01_10
* `tarball_path`: a fully-qualified path to a tarball of your local LArSoft install. This **must** exist in `/pnfs/uboone/resilient/`.
* `max_files`: the number of files to process
* `events_per_file`: the number of events per file to process
* `prestage`: whether to prestage the files in the supplied samweb definition before attempting to read them. This will take some time, but if your files are not staged nothing will happen.
* `file_prefix`: the file prefix to give to the output .pndr files. Output files will look like: Pandora_Events_${file_prefix}_${counter}.pndr
* `resumbit`: whether to resubmit failed jobs. This does not work for .pndr files as the output root files are flagged as invalid. Set to false as default.
* `resumbit_cycles`: if resumbitting failed jobs, how many resubmission cycles to maximally allow

The output files will end up in `/pnfs/uboone/scratch/users/${user_name}/${project_name}_collected_pndr`. All other necessary working directories will be created by the script, if they do not already exist. Usage is simply: `source run.sh`

# Output

What happens practically is that `pandora_writer.fcl` is run on each of the reco2 .root files in the supplied samweb definition and a `project.py` .xml file is automatically created according to the provided settings. The script will also fetch the correct grid certificates for you and submit the relevant grid jobs, and display their progress. In addition, POT information is collected **only** for those jobs that produces a usable .pndr as output and is reported as the script finishes running. The POT output is also saved to file in `saved_pot_output.txt`. The produced .pndr files are automatically retreieved from the grid output subdirectories and moved to `/pnfs/uboone/scratch/users/${user_name}/${project_name}_collected_pndr`.
