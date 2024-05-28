module load gcc openmpi hwloc fftw cuda

mkdir build 
cmake .. -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_FFT_LIBRARY=fftw3 -DGMX_SIMD=AVX2_256 -DGMX_HWLOC=on -DGMX_GPU=ON -DCMAKE_INSTALL_PREFIX=/mnt/home/YOUR_INSTALL_LOCATION
make 
make check
make install 
