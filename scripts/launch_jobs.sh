#!/bin/bash

# Load singularity
module load singularity
enzo="/scratch/users/vsochat/DATA/enzo.img"

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

host_data_dir="/scratch/users/vsochat/DATA/physics"
compiler_version="1.10.2"
compiler_vendor="gcc"
optimization_level="high"
export host_data_dir compiler_vendor compiler_version optimization_level

job=0
while [ ${job} -lt ${num} ]; do
    job_dir="${host_data_dir}/jobs/${job}"
    if [ ! -e "${job_dir}/RunFinished" ]; then
        echo "Submitting job ${job_num}..."
        qsub -N "${compiler_vendor}_${compiler_version}_${optimization_level}_${job_num}" -o ${job_dir} run_job.sh $job
	fi;
	job=$(expr ${job} + 1)
done;
