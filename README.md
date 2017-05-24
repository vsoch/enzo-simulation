# Enzo in Singularity

## Install Singularity
First you should install Singularity, and we will use development branch for latest features.

```
git clone -b development https://www.github.com/singularityware/singularity.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

## Create Enzo Image
The Singularity file will download the enzo package from bitbucket, and install/configure for ubuntu 14.04. The scripts for the running are included in this repo under [scripts](scripts). To create the image, do the following:

```
git clone https://github.com/vsoch/enzo-simulation
cd enzo-simulation
singularity create --size 4000 enzo.img
sudo singularity bootstrap enzo.img Singularity
```

### Looking around
You can then shell into the image to look around, here I am using sudo with `--writable` so I can make changes.

```
sudo singularity shell --writable enzo.img
```

The above is useful mostly during the development time of the image, when you have it locally (and thus have sudo) and want to try small tweaks to the image to test running it. It is best practice generally to represent all changes/tweaks in the build file ([Singularity](Singularity)) so that they are reproducible.

### The Runscript
The "runscript" of the container is "the thing the container does when you execute it." We can look at this runscript, which is linked at `/singularity`. Below we are using `exec` (execute) to issue a command to cat the file:

```
singularity exec enzo.img cat /singularity


# Get job number
if [ $# -lt 1 ]; then
    echo "You must pass the job number."
    echo "Usage: singularity run -B /scratch/data:/data enzo.img 10"
    exit 1
else
    num="$1"
    case ${num} in
        -h|--help|-H)
            echo "Usage: singularity run -B /host/data:/data enzo.img [num]
            echo "e.g.,  singularity run -B /scratch/data:/data enzo.img 10"
            exit 1;
        ''|*[!0-9]*) 
            echo "You must pass a number as the first argument."; exit 2;;
        *) ;;
    esac
fi;

# Create the job directory, if doesn't exist
jobdir="/data/jobs/${num}"
if [ ! -d "${jobdir}" ]; then
    echo "Creating job directory ${num}"
    cp -r /code/scripts/Init "${jobdir}"
fi

cd $jobdir
/bin/bash /code/scripts/job.pbs
```

Note that although we are looking at `/singularity`, this is a link to the actual file in the container metadata folder at `/.singularity.d/runscript`. Above, we see that the runscript is going to check for a numerical argument to indicate the run number. If the user has specified a flag for help (any in `-H|--help|-h`) then it will print out usage. If all goes well, then we set up the job output folder (copying files to `jobdir` from [scripts/Init](scripts/Init) and then launching the job by calling [this file](scripts/job.pbs). Note that these files are all added to the container, and the specific job script is also executed and inside the container. The only thing the user has to do is load the singularity module and then write some loop to execute N jobs. Doing this, and running, is discussed next.


## Run The Container
You next need to move your image onto the cluster where it is intended to be. The basic workflow is going to be to bind some data folder on my cluster (in the example, `/scratch/users/vsochat/DATA/physics` to where the container expects it's data directory to be (in this case, `/data`). The MPI run is going to work as follows:

 - The container acts as an executable, and manages the entire lifecycle of one job. This includes:
    - creating the job directory
    - launching the job (`.pbs`) script that loads required modules and issues the mpi command.
 - The container could also do a different / custom command, and in this case you would run `exec` and specify a script (on the host or in container) to run.

On your cluster, first load singularity (or have it on your path if your cluster doesn't use modules.

```
module load singularity
```

To start, we can be silly and just run the container, as most users would do. The following commands are equivalent:

```
 ./enzo.img 
You must pass the job number.
Usage: singularity run -B /scratch/data:/data enzo.img 10
```

And every good executable will have a `--help` argument. We can do any of the following:

```
singularity run enzo.img --help
singularity run enzo.img -H
singularity run enzo.img -h
```

or just execute the image itself!

```
./enzo.img --help
./enzo.img -H
./enzo.img -h
```

in all cases above, we see the help prompt:

```
Usage: singularity run -B /host/data:/data enzo.img [num]
e.g.,  singularity run -B /scratch/data:/data enzo.img 10
```

## Run Enzo Jobs
Now we are again sitting on our cluster, and remember that we have singularity loaded or on the path. Make sure this does not return empty!

```
which singularity

```

Now let's say we want to run 10 jobs. We want the container to use `/scratch/users/vsochat/DATA/physics` as our data directory (meaning the folder `jobs` with our enzo analyses, directories labeled 0-N) will be created inside. This is an important distinction - inside the container, operations will run relative to `/data`. However, from outside the container we have this directory represented as `/scratch/users/vsochat/DATA/physics.` Also note that our container is located one level above that at `/scratch/users/vsochat/DATA`. Thus, to run our job for N=10, we want to have the following scripts on our cluster, along with the image itself (enzo.img) that we built above:

 - [launch_jobs.sh](scripts/launch_jobs.sh)
 - [run_job.sh](scripts/run_jobs.sh)

The first is basically a for loop to send a bunch of commands to the batch manager with qsub, each submitting a script to run the file [run_jobs.sh](scripts/run_jobs.sh). You don't need to use bash scripts, or even this approach, the general idea is that you want to send the command our to your cluster nodes to load the modules on the host, load singularity, and then run the container. The script [scripts/launch_jobs.sh](scripts/launch_jobs.sh) is an example of the "for loop" part of this, run on the host:

```
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
```

Note that the script [run_job.sh](scripts/run_job.sh) is located outside the image, and called by qsub. It is this script that loads required modules (on the host) and then executes the container via a call to singularity, which has the main job script (job.pbs) inside. We bind the host data directory to `/data` in the container using the command `-B`, and we do this so that it is writable.

```
#!/bin/bash

module load singularity
module unload gcc
module load gcc/4.8.1
module load openmpi/1.10.2/gcc

job_num=$1

host_data="/scratch/users/vsochat/DATA/physics"
enzo="/scratch/users/vsochat/DATA/enzo.img"

singularity run -B $host_data:/data $enzo $job_num
```
