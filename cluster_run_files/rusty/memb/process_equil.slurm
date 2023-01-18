#!/bin/bash
#SBATCH -D ./
#SBATCH -J equil
#SBATCH -o proc.out
#SBATCH -o proc.err
#SBATCH --partition=ccb
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2

source $HOME/.bashrc

pwd
membs="equil.xtc"
out_file="sum_equil.xtc"

#gmx trjcat -o equil.xtc -f memb[3-8].xtc  -cat 
echo $membs
#echo -e "0\n" | gmx trjconv -f $membs -s memb0.tpr -o sum\_temp1.xtc -pbc whole -dt 100 
echo -e "0\n" | gmx trjconv -f $membs -s memb0.tpr -o sum\_temp1.xtc -pbc whole 
echo -e "1\n1\n0\n" | gmx trjconv -center yes  -f sum\_temp1.xtc -s memb0.tpr -o sum\_temp2.xtc -pbc cluster
rm sum\_temp1.xtc

echo -e "1\n0\n" | gmx trjconv -f sum\_temp2.xtc  -s memb0.tpr -o sum\_temp3.xtc -pbc res -center yes
rm sum\_temp2.xtc 

echo -e "1\n1\n0\n" | gmx trjconv -f sum\_temp3.xtc   -s memb0.tpr -o sum\_temp4.xtc -pbc cluster -center yes 

rm sum\_temp3.xtc

echo -e "1\n0\n" | gmx trjconv -f sum\_temp4.xtc -o $out_file -center yes -pbc mol -s memb0.tpr
rm sum\_temp4.xtc


rmgro 
rm \#sum.xtc\#
rm \#sum_sum.xtc\#
