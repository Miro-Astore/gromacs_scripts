#!/bin/bash
#PBS -P r16 #PBS -q gpuvolta
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
module purge
module load intel-mkl/2020.2.254
module load openmpi/4.0.3
module load cuda/11.0.3
module load python3-as-python

export PATH=$PATH:/scratch/f91/ma2374/plumed-2.8.0/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scratch/f91/ma2374/plumed-2.8.0/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/scratch/f91/ma2374/plumed-2.8.0/lib/pkgconfig
export PLUMED_KERNEL=/scratch/f91/ma2374/plumed-2.8.0/lib/libplumedKernel.so

FLAGS="-O3 -march=native -DNDEBUG -g"
export ins_dir=$(pwd)

LIBS="$MKL/lib/intel64/libmkl_intel_lp64.so;$MKL/lib/intel64/libmkl_intel_thread.so;$MKL/lib/intel64/libmkl_core.so;$MKL/../compiler/lib/intel64/libiomp5.so;$MKL/../compiler/lib/intel64/libirc.so;$MKL/../compiler/lib/intel64/libsvml.so;$MKL/../compiler/lib/intel64/libimf.so;$MKL/../compiler/lib/intel64/libintlc.so"


#cd $PBS_O_WORKDIR

mkdir -p build
cd build

#cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DBUILD_SHARED_LIBS=OFF -DGMX_PREFER_STATIC_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PBS_O_WORKDIR

#cmake -DCMAKE_INSTALL_PREFIX=$PBS_O_WORK_DIR -DGMX_FFT_LIBRARY=mkl -DCMAKE_CXX_FLAGS="${FLAGS}" -DCMAKE_C_FLAGS="${FLAGS}" -DMKL_LIBRARIES="${LIBS}" -DMKL_INCLUDE_DIR=$MKL/include -DGMX_MPI=on -DCMAKE_C_COMPILER=mpicc -DCMAKE_LINKER=mpicc -DCMAKE_CXX_COMPILER=mpic++ -DGMX_HWLOC=OFF ..

#using stock c compiler 
#cmake -DCMAKE_INSTALL_PREFIX=/scratch/f91/ma2374/programs/gromacs -DGMX_FFT_LIBRARY=mkl   -DMKL_LIBRARIES=$LIBS -DMKL_INCLUDE_DIR=$MKL/include -DGMX_MPI=on -DCMAKE_C_COMPILER=mpicc -DCMAKE_LINKER=mpicc -DCMAKE_CXX_COMPILER=mpic++ -DGMX_HWLOC=OFF ..

#using gadi optimised c compiler
cmake -DCMAKE_INSTALL_PREFIX=/scratch/f91/ma2374/programs/gromacs -DGMX_GPU=CUDA -DGMX_FFT_LIBRARY=mkl   -DMKL_LIBRARIES=$LIBS -DMKL_INCLUDE_DIR=$MKL/include -DGMX_MPI=on -DCMAKE_LINKER=mpicc -DCMAKE_CXX_COMPILER=mpic++ -DGMX_HWLOC=OFF ..

make
make check
make install
source $PBS_O_WORKDIR/gromacs/bin/GMXRC
