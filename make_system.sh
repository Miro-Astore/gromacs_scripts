
#gmx pdb2gmx -f l.pdb -o memb.gro -ff charmm36-nov2016-newvs -water tip3 -vsite hydrogens
#gmx pdb2gmx -f out2.pdb -o prot.gro -ff charmm36-mar2019 -water tip3 -ter -his -ss
gmx pdb2gmx -f 6hhj_autopsf.pdb -o prot.gro -ff charmm36-mar2019 -water tip3 -ss yes
gmx editconf -f prot.gro -o box.gro -c yes -d 1.4
gmx solvate -cp box.gro -cs spc216 -o solvate.gro   -p topol.top

gmx grompp -f gromacs_scripts/ions.mdp -c solvate.gro -p topol.top -o ions.tpr -maxwarn 1
gmx genion -s ions.tpr -p topol.top -o ionized.gro -pname K -nname CL -neutral -conc 0.15

#optional really but included for visulisation/posterity, index ndx included because we might have a funky thermostat
echo -e "q\n" | gmx make_ndx  -f ionized.gro -o index.ndx

gmx grompp -f gromacs_scripts/ions.mdp -c ionized.gro -p topol.top -o visualise.tpr 

gmx editconf -f visualise.tpr -o ionized.pdb -conect

sed -i "s/ENDMDL//g" ionized.pdb

rm visualise.tpr
