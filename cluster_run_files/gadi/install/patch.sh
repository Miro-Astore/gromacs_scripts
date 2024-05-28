#!/bin/bash
#PBS -P r16
#PBS -q gpuvolta
#PBS -l ngpus=1
#PBS -l ncpus=12
#PBS -l storage=scratch/f91
#PBS -l walltime=1:00:00
#PBS -o out.out
#PBS -e error.out

#PBS -l mem=16GB
#PBS -l wd
#PBS -m abe
#PBS -M yearlyboozefest@gmail.com
module load intel-mkl/2020.2.254
module load openmpi/4.0.3
module load cuda/11.0.3
module load python3-as-python
export PATH=$PATH:/scratch/f91/ma2374/plumed-2.8.0/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scratch/f91/ma2374/plumed-2.8.0/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/scratch/f91/ma2374/plumed-2.8.0/lib/pkgconfig
export PLUMED_KERNEL=/scratch/f91/ma2374/plumed-2.8.0/lib/libplumedKernel.so

plumed patch  -p 
