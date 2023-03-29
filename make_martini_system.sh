#gmx editconf -f thyroglobulin_cg.pdb -d 2.5  -bt cubic -o thyroglobulin_cg_box.gro -c yes
#gmx grompp -p topol.top -f minimization.mdp -c thyroglobulin_cg_box.gro -o minimization-vac.tpr
#gmx mdrun -deffnm minimization-vac -v
#gmx solvate -cp minimization-vac.gro -cs water.gro -radius 0.21 -o solvate.gro  -p topol.top
#gmx grompp -f gromacs_scripts/ions.mdp -c solvate.gro -p topol.top -o ions.tpr -maxwarn 2
#echo "W \n" | gmx genion -s ions.tpr -p topol.top -o ionized.gro -pname NA -nname CL -neutral -conc 0.15
#
#gmx grompp -p topol.top -c ionized.gro -f minimization.mdp -o minimization.tpr

gmx mdrun -deffnm minimization -v
gmx grompp -p topol.top -c minimization.gro -f equilibration.mdp -o equilibration.tpr -maxwarn 2
gmx mdrun -deffnm equilibration -v
#gmx grompp -p system.top -c equilibration.gro -f dynamic.mdp -o dynamic.tpr -maxwarn 1
#gmx mdrun -deffnm dynamic -v
