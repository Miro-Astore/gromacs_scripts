
#gmx pdb2gmx -f l.pdb -o memb.gro -ff charmm36-nov2016-newvs -water tip3 -vsite hydrogens
gmx pdb2gmx -f cut_autopsf.pdb -o cut.gro -ff charmm36-mar2019 -water tip3 -ter
gmx editconf -f cut.gro -o box.gro -c yes -d 1.2
gmx solvate -cp box.gro -cs spc216 -o solvate.gro  -radius 0.7 -p topol.top

gmx grompp -f gromacs_scripts/ions.mdp -c solvate.gro -p topol.top -o ions.tpr -maxwarn 1
gmx genion -s ions.tpr -p topol.top -o ionized.gro -pname NA -nname CL -neutral -conc 0.15

echo -e "q\n" | gmx make_ndx  -f ionized.gro -o index.ndx
