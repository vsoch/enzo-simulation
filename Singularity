Bootstrap: docker
From: ubuntu:14.04

%setup

# Need to download this first
# https://drive.google.com/file/d/0B3BA_GGofHK4NkpzOV9fTUg2VHM/view
# spack-enzo-package should be in $PWD before running bootstrap
cp -R spack-enzo-package $SINGULARITY_ROOTFS/

%environment
PATH=$PATH:/enzo/bin
export PATH

%post

# Install vim and spack
apt-get update && apt-get install -y vim git wget \
                                     python python-pip \ 
                                     gfortran g++ \
                                     libhdf5-serial-dev \
                                     csh libcr-dev mpich2 \ 
                                     mpich2-doc ssh mercurial

mkdir -p /data/jobs

# Tell user python version
echo "Python version:"
python --version

# http://enzo-project.org/
cd / && wget https://bitbucket.org/enzo/enzo-dev/get/enzo-2.5.tar.bz2
mkdir enzo && tar xvjf enzo-2.5.tar.bz2 -C enzo --strip-components 1
cd enzo && ./configure # requires csh
cd enzo/src/enzo

# What machine configurations are available?
# ls Make.mach.* 
# what version HDf5? 
# dpkg -l | grep hdf5

make machine-linux-gnu
make show-config
echo "Configuration with linux-gnu shown above."

# Build and Submission Procedure:
# 1. Execute build and installation of enzo
# cd /spack-enzo-package
# /bin/bash scripts/build.sh

# ./scripts/build.sh
# 2. Generate Job Directories
# ./scripts/gen_job_dirs.sh
# 3. Submit Jobs
# ./scripts/submit_jobs.sh
