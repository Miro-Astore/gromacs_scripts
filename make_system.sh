source $HOME/.bashrc
rm \#*\#
#gmx pdb2gmx -f l.pdb -o memb.gro -ff charmm36-nov2016-newvs -water tip3 -vsite hydrogens
#gmx pdb2gmx -f out2.pdb -o prot.gro -ff charmm36-mar2019 -water tip3 -ter -his -ss
vmd -dispdev text 1unp.pdb -e gromacs_scripts/select_proteins.tcl 
vmd -dispdev text prot.pdb -e gromacs_scripts/name_chains.tcl 
echo "Protein_chain_A" > restr_groups.txt 
gmx pdb2gmx -f  chains_named.pdb -o prot.gro -ff charmm36-jul2017 -water tip3 -ss yes
gmx editconf -f prot.gro -o box.gro -c yes -d 2.0
gmx solvate -cp box.gro -cs spc216 -o solvate.gro   -p topol.top

gmx grompp -f gromacs_scripts/ions.mdp -c solvate.gro -p topol.top -o ions.tpr -maxwarn 1
echo "SOL \n" | gmx genion -s ions.tpr -p topol.top -o ionized.gro -pname K -nname CL -neutral -conc 0.15

#optional really but included for visulisation/posterity, index ndx included because we might have a funky thermostat
echo -e "q\n" | gmx make_ndx  -f ionized.gro -o index.ndx

gmx grompp -f gromacs_scripts/ions.mdp -c ionized.gro -p topol.top -o visualise.tpr 

gmx editconf -f visualise.tpr -o ionized.pdb -conect

#echo "SOL \n" | gmx genion -s ions.tpr -p topol.top -o ionized.gro -pname K -nname CL -neutral -conc 0.15
gmx grompp -f gromacs_scripts/ions.mdp -c ionized.gro -p topol.top -o ions.tpr -maxwarn 1
gmx editconf -f ions.tpr -o ionized.pdb -conect
#gmx pdb2gmx -f  chains_named.pdb -o prot.gro -ff charmm36-jul2017 -water tip3 -ss yes
bash gromacs_scripts/make_psf.sh ionized.pdb ionized.psf
vmd -dispdev text ionized.psf ionized.pdb -e gromacs_scripts/name_chains.tcl 
mv chains_named.psf ionized.psf 
mv chains_named.pdb ionized.pdb 

sed -i "s/ENDMDL//g" ionized.pdb

