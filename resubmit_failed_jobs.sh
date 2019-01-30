xml_name=$1

failedJobs=100
counter=1

while [ $failedJobs != 0 ] 
do
    echo "Resubmit cycle $counter"

    project.py --xml $xml_name --stage pndr --check
    rm makeup.txt
    project.py --xml $xml_name --stage pndr --makeup > makeup.txt
    failedJobs=$(tail -n1 makeup.txt | awk -F= 'END{ split($0,arr," "); print arr[4]  }')

    source show_remaining_jobs.sh $xml_name 
    counter=$[$counter+1]
done
