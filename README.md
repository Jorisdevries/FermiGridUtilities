# FermiGridUtilities

This repository is a tool intended to speed up the process of creating .pndr files from any samweb definition containing a set of reco2 .root files.

# Usage

All the settings can be found in `run.sh`. The settings are:
* `user_name`: the Fermi services account to use to authenticate with Kerberos and get a grid certificate
* `project_name`: the name of the samweb project containing (only!) relevant reco2 .root files.
* `larsoft_release_name`: the LArSoft version used to process the files (see next item) e.g. v06_85_00.
* `qualifier`: the qualifier associated to your LArSoft release, e.g. e17:prof
* `tarball_path`: a fully-qualified path to a tarball of your local LArSoft install. This **must** exist in `/pnfs/uboone/resilient/`.
* `max_files`: the number of files to process.
* `events_per_file`: the number of events per file to process.
* `prestage`: whether to prestage the files in the supplied samweb definition before attempting to read them. This will take some time, but if your files are not staged nothing will happen.
* `file_prefix`: the file prefix to give to the output .pndr files. Output files will look like: `Pandora_Events_${file_prefix}_${counter}.pndr`.
* `resumbit`: whether to resubmit failed jobs. This setting is set to false as default, as it does not work for `pandora_writer.fcl`: the output root files are flagged as invalid output. This functionality has been retained for when the script is used with a .fcl file that produces valid .root output files. One resubmit cycle corresponds to `project.py --xml $xml_name --stage pndr --check` followed by `project.py --xml $xml_name --stage pndr --makeup`. Jobs will be resubmitted until all jobs have been processed succesfully, or until the maximum number of resubmit cycles has been reached, defined by `resumbit_cycles` below.
* `resumbit_cycles`: if resumbitting failed jobs, how many resubmission cycles to maximally allow. 
* `is_data`: whether the reco2 files are real data. Set to false for simulated data. This must be set correctly to allow POT to be counted accurately.
* `fcl_file_name`: the .fcl file to run on each reco2 file in the samweb definition. The repository comes prepackaged with `pandora_writer.fcl`.

The output files will end up in `/pnfs/uboone/scratch/users/${user_name}/${project_name}_collected_pndr`. All other necessary working directories will be created by the script, if they do not already exist. 

Usage is simply: `source run.sh`

# Output

What happens practically is that `pandora_writer.fcl` is run on each of the reco2 .root files in the supplied samweb definition and a `project.py` .xml file is automatically created according to the provided settings. 

The script will also fetch the correct grid certificates for you, submit the relevant grid jobs, and display their progress. In addition, POT information is collected **only** for those jobs that produces a usable .pndr as output and is reported as the script finishes running. The POT output is also saved to file in `saved_pot_output.txt`.

The resulting .pndr files are automatically retrieved from the grid output subdirectories and moved to `/pnfs/uboone/scratch/users/${user_name}/${project_name}_collected_pndr`.

# Debugging

It is possible for the kx509 user proxy to become corrupted. When this happens, you will see Python errors that end in 'TypeError: 'NoneType' object is not iterable'. To fix this issue, enter `jobsub_rm --user=$user_name` and remove the listed file for which the filename begins with `/tmp/x509up_`. After this, `run.sh` should work as normal.
