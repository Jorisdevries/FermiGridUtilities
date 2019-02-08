#!/bin/bash

user_name=$1
project_name=$2

#directory corresponding to the stage name in the project.py xml file
if [ -d "/pnfs/uboone/scratch/users/$user_name/$project_name/pndr" ]; then
    rm -rf /pnfs/uboone/scratch/users/$user_name/$project_name/pndr/*
else
    mkdir -p "/pnfs/uboone/scratch/users/$user_name/$project_name/pndr"
fi

#directory for collected pndr output
if [ -d "/pnfs/uboone/scratch/users/$user_name/${project_name}_collected_pndr" ]; then
    rm -rf /pnfs/uboone/scratch/users/$user_name/${project_name}_collected_pndr/*
else
    mkdir -p "/pnfs/uboone/scratch/users/$user_name/${project_name}_collected_pndr"
fi

#make sure the work directory exists for the user
if [ !  -d "/pnfs/uboone/scratch/users/$user_name/work/" ]; then
    mkdir -p "/pnfs/uboone/scratch/users/$user_name/work/"
fi
