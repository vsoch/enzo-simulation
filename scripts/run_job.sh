#!/bin/bash

module load singularity
module unload gcc
module load gcc/4.8.1
module load openmpi/1.10.2/gcc

job_num=$1

singularity run $enzo $job_num