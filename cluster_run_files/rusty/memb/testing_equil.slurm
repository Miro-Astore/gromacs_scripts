#!/bin/bash
#SBATCH -D ./
#SBATCH -J equil
#SBATCH -o out.out
#SBATCH -o err.out
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --constraint=v100

cp out.out out.old
cp err.out err.old

##SBATCH -p=gpu
##SBATCH -c=16
##SBATCH -C=a100,ib
##SBATCH --mem=8000
##SBATCH --gpus=1
##SBATCH -o out.out
##SBATCH -e error.err
##SBATCH --job-name=equilibration
## -J  for short hand 

module load gromacs/skylake-singlegpunode-2022
env

#cd $PBS_O_WORKDIR

export OMP_NUM_THREADS=$SLURM_JOB_CPUS_PER_NODE
gmx grompp -f memb0.mdp -o memb0.tpr -c ionized.gro -n index.ndx -p topol.top  -r ionized.gro
gmx mdrun -v -ntmpi 1 -ntomp $OMP_NUM_THREADS -deffnm memb0 2>&1 
#
for i in $(seq 2 6); 
do 
gmx grompp -maxwarn 2 -f memb$i\.mdp -o memb$i\.tpr -c memb$(( $i - 1 ))\.gro -r memb$(( $i - 1 ))\.gro -n index.ndx -p topol.top 
gmx mdrun -v -ntmpi 1 -ntomp $OMP_NUM_THREADS -deffnm memb$i 
last_err=$?
echo $last_err 
done
#

gmx grompp -f memb_prod.mdp -o memb_prod1.tpr -c memb6.gro   -p topol.top  -n index.ndx

#if the runs have finished submit the next job
source $HOME/.bashrc
if [  -f memb16.gro  ] ; then nbatch memb1.slurm  ; fi
