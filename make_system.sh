rm memb.gro
rm topol.top
rm box.gro
rm ionized.gro
rm solv.gro 
rm solvate.gro
rm ions.tpr

gmx pdb2gmx -f l.pdb -o memb.gro -ff charmm36-nov2016-newvs -water tip3 -vsite hydrogens
gmx editconf -f memb.gro -o box.gro -c yes -box 10.0 10.0 9.0  
gmx solvate -cp box.gro -cs spc216 -o water.gro  -radius 0.7 -p topol.top
gmx editconf -f water.gro -o solvate.gro -c yes -box 11.0 11.0 9.0  

bash ./gromacs_scripts/ionize_gro.sh
