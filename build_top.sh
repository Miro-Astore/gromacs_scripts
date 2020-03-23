cd ..
#gmx pdb2gmx -vsite hydrogens -f ionized.pdb -o ionized.gro -ter -ff /usr/local/gromacs/share/gromacs/top/charmm36-mar2019.ff -water tip3p -p topol.top 
gmx pdb2gmx -vsite hydrogens -f ionized.pdb -o ionized.gro -ff charmm36-mar2019 -ter  -water tip3p -p topol.top 
#gmx pdb2gmx -vsite hydrogens -f prot_test.pdb -o prot_test.gro -ter  -water tip3p -p topol.top 
