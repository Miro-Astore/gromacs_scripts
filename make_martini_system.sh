gmx editconf -f thyroglobulin_cg.pdb -d 2.5  -bt cubic -o thyroglobulin_cg_box.gro -c yes
gmx grompp -p topol.top -f minimization.mdp -c thyroglobulin_cg_box.gro -o minimization-vac.tpr
gmx mdrun -deffnm minimization-vac -v
gmx solvate -cp minimization-vac.gro -cs water.gro -radius 0.21 -o solvated.gro  -p topol.top
gmx grompp -p topol.top -c solvated.gro -f minimization.mdp -o minimization.tpr
gmx mdrun -deffnm minimization -v
gmx grompp -p system.top -c minimization.gro -f equilibration.mdp -o equilibration.tpr
gmx mdrun -deffnm equilibration -v
gmx grompp -p system.top -c equilibration.gro -f dynamic.mdp -o dynamic.tpr -maxwarn 1
gmx mdrun -deffnm dynamic -v
