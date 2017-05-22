Bootstrap: docker
From: ubuntu:14.04

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

# Download repo
git clone https://github.com/vsoch/enzo-simulation
# Likely we will move scripts here to prepare for running, not done yet

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

%runscript

echo "Vanessa will write me when she tries stuff out!"

# Build and Submission Procedure:
# ./scripts/gen_job_dirs.sh
# ./scripts/submit_jobs.sh
