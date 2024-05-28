#!/bin/bash
#SBATCH -D ./
#SBATCH -J proc
#SBATCH -o proc.out
#SBATCH -o proc.err
#SBATCH --partition=ccb
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2




load modules/2.0-20220630
module load gromacs/singlegpunode-2022

 -e "1\n0" | gmx trjconv -f glob_prod1.xtc -s glob0.tpr -pbc whole -center yes  -o glob_temp.xtc 
rm glob_temp.xtc
echo -e "1\n1\n1" | gmx trjconv -f glob_prod1.xtc -s glob0.tpr -pbc cluster -center yes  -o sum.xtc

rm \#*\#
