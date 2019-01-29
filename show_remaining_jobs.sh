xml_name=$1

jobStatus=$(project.py --xml $xml_name --status)
jobStatusArray=($(awk -F: '{$1=$1} 1' <<<"${jobStatus}"))

jobsIdle=${jobStatusArray[21]}
jobsRunning=${jobStatusArray[23]}

while [ $jobsIdle != 0 ] || [ $jobsRunning != 0 ] 
do
    jobStatus=$(project.py --xml $xml_name --status)
    jobStatusArray=($(awk -F: '{$1=$1} 1' <<<"${jobStatus}"))

    jobsIdle=${jobStatusArray[21]}
    jobsRunning=${jobStatusArray[23]}

    echo -ne "\r\033[K > Jobs remaining: $jobsIdle idle and $jobsRunning running"
    sleep 5
done
echo -ne \\n
