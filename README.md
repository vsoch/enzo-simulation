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

You can then shell into the image to look around, here I am using sudo with `--writable` so I can make changes.

```
sudo singularity shell --writable enzo.img
```

## Run Enzo Jobs.

Tba! :)
