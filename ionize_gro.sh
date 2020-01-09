gmx grompp -f ions.mdp -c converted.gro -p topol.top -o ions.tpr -maxwarn 1
gmx genion -s ions.tpr -p topol.top -o ionized.gro -neutral
