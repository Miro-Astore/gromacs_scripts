#!/bin/bash
#SBATCH --parititon=gpu
#SBATCH -o $j.out
#SBATCH -e $j.err
#SBATCH --time=24:00:00
#SBATCH --job-name=equilibration
# -J  for short hand 

module load gromacs/skylake-singlegpunode-2022

#cd $PBS_O_WORKDIR

export OMP_NUM_THREADS=12
gmx grompp -f memb0.mdp -o memb0.tpr -c ionized.gro -n index.ndx -p topol.top 
gmx mdrun -v -ntmpi $PBS_NGPUS -ntomp $OMP_NUM_THREADS -deffnm memb0 2>&1 
#
for i in $(seq 1 16); 
do 
gmx grompp -f memb$i\.mdp -o memb$i\.tpr -c memb$(( $i - 1 ))\.gro -r memb$(( $i - 1 ))\.gro -n index.ndx -p topol.top 
gmx mdrun -v -ntmpi $PBS_NGPUS -ntomp $OMP_NUM_THREADS -deffnm memb$i 
last_err=$?
echo $last_err 
done
#

#if the runs have finished submit the next job
source $HOME/.bashrc
if [  -f memb16.gro  ] ; then nsub memb1.pbs  ; fi
