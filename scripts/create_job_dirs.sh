#!/bin/bash

# Get number of jobs
if [ $# -lt 1 ]; then
    echo "You need to pass the number of jobs."
    exit 1
fi;

num="$1"

#User input validation
case ${num} in
    ''|*[!0-9]*) echo "You must pass a number as the first argument."; exit 2;;
    *) ;;
esac

base_dir="/data"

job=0
while [ ${job} -lt ${num} ]; do
    echo "Creating job directory ${job}"
    mkdir -p ${base_dir}/jobs
    cp -r "${base_dir}/${job_type}/Init" "${base_dir}/jobs/${job}"
    job=$(expr ${job} + 1)
done;
