xml_name=$1

jobStatus=$(project.py --xml $xml_name --status)
jobStatusArray=($(awk -F: '{$1=$1} 1' <<<"${jobStatus}"))

jobsIdle=${jobStatusArray[21]}
jobsRunning=${jobStatusArray[23]}

#sometimes the job status command fails and this regex checks whether $jobsIdle and $jobsRunning are numbers
isNumber='^[0-9]+$'

previousIdle=$jobsIdle
previousRunning=$jobsRunning

while [ "$jobsIdle" != 0 ] || [ "$jobsRunning" != 0 ] 
do
    jobStatus=$(project.py --xml $xml_name --status)
    jobStatusArray=($(awk -F: '{$1=$1} 1' <<<"${jobStatus}"))

    jobsIdle=${jobStatusArray[21]}
    jobsRunning=${jobStatusArray[23]}

    #check if number otherwise revert, wait and try again
    if ! [[ $jobsIdle =~ $isNumber && $jobsRunning =~ $isNumber ]] ;
    then
        jobsIdle=$previousIdle
        jobsRunning=$previousRunning

        sleep 5
        continue
    fi

    previousIdle=$jobsIdle
    previousRunning=$jobsRunning

    echo -ne "\r\033[K > Jobs remaining: $jobsIdle idle and $jobsRunning running"
    sleep 5
done
echo -ne \\n
