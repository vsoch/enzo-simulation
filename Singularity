Bootstrap: docker
From: ubuntu:14.04

%environment
PATH=$PATH:/enzo/bin
export PATH

%post

# Install vim and spack
apt-get update && apt-get install -y vim git wget
apt-get install -y python python-pip 
apt-get install -y gfortran g++
apt-get install -y libhdf5-serial-dev
apt-get install -y csh libcr-dev mpich2 
apt-get install -y  mpich2-doc mercurial

mkdir -p /data/jobs

# Download repo
git clone https://github.com/vsoch/enzo-simulation
mv enzo-simulation /code
# Likely we will move scripts here to prepare for running, not done yet

# Tell user python version
echo "Python version:"
python --version

# http://enzo-project.org/
cd / && wget https://bitbucket.org/enzo/enzo-dev/get/enzo-2.5.tar.bz2
mkdir enzo && tar xvjf enzo-2.5.tar.bz2 -C enzo --strip-components 1
cd enzo && ./configure # requires csh
cd /enzo/src/enzo

# What machine configurations are available?
# ls Make.mach.* 
# what version HDf5? 
# dpkg -l | grep hdf5

make machine-linux-gnu
make show-config
echo "Configuration with linux-gnu shown above."

%runscript

echo "Usage: singularity exec -B /scratch/data:/data enzo.img /code/scripts/create_job_dirs.sh 10"
echo "       singularity exec -B /scratch/data:/data enzo.img /code/scripts/launch_jobs.sh 10"
