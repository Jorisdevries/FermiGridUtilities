#!/bin/bash
#Example usage: source create_smart_runlist.sh "prod_reco_optfilter_extbnb_v11_mcc8_dev" 2500 

project_name=$1
max=$2

#file_list=$(samweb list-files "defname: $project_name and availability: physical" | grep "PhysicsRun-.*_reco2.root")
file_list=$(samweb list-files "defname: $project_name and availability: physical")

counter=0

for i in $file_list 
do
    if [ $counter -gt $max ];
    then
        break
    fi 

    file_path=`samweb locate-file $i`
    file_path=${file_path%(*}
    file_path=${file_path##*:}

    echo $file_path/$i >> temp.txt
    echo -ne " > Writing: file $counter" \\r

    counter=$[$counter+1]
done

if [[ -f runlist.txt  ]];
then
    rm runlist.txt
fi

sed '/^\s*$/d' temp.txt > runlist.txt
rm temp.txt

echo -ne \\n
