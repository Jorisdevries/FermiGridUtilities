xml_name=$1
max=$2

failedJobs=100
counter=1

"Resubmitting for a maximum of $max cycles"

while [ $failedJobs != 0 ] 
do
    if [ $counter -gt $max ];
    then
        break
    fi

    echo "Resubmit cycle $counter"

    if [[ $counter != 1]];
    then
        project.py --xml $xml_name --stage pndr --check
    fi

    rm makeup.txt
    project.py --xml $xml_name --stage pndr --makeup > makeup.txt
    failedJobs=$(tail -n1 makeup.txt | awk -F= 'END{ split($0,arr," "); print arr[4]  }')

    source show_remaining_jobs.sh $xml_name 
    counter=$[$counter+1]
done
