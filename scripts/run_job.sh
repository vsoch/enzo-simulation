#!/bin/bash

module load singularity
module unload gcc
module load gcc/4.8.1
module load openmpi/1.10.2/gcc

job_num=$1

host_data="/scratch/users/vsochat/DATA/physics"
enzo="/scratch/users/vsochat/DATA/enzo.img"

singularity run -B $host_data:/data $enzo $job_num
