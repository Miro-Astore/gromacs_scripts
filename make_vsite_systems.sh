## USAGE bash gromacs_scripts/make_vsite_systems.sh <SYSNAME> 
#rm memb.gro
#rm topol.top
#rm box.gro
#rm ionized.gro
#rm solv.gro 
#rm solvate.gro
#rm ions.tpr


vmddisp () {
	tempvmdc=$VMDNOCUDA 
	tempvmdo=$VMDNOOPTIX 
	export VMDNOCUDA=1 
	export VMDNOOPTIX=1 
	vmd -dispdev text -e "$@"
	export VMDNOCUDA=$tempvmdc
	export VMDNOOPTIX=$tempvmdo 
}

module load vmd 
module load gromacs/2020.1

	rm \#*\#

echo "$1"
echo "hi"
vmddisp gromacs_scripts/strip_water.tcl $1.psf $1.pdb 
echo -e "0\n2\n1\n0\n" | gmx pdb2gmx -f waterless.pdb -o memb.gro -ff charmm36m_newvs-may2020 -water tip3 -vsite hydrogens -ter 
gmx editconf -f memb.gro -o box.gro -c yes -box 11.2 11.2 18.2 
gmx solvate -cp box.gro -cs spc216 -o solvate.gro  -radius 0.7 -p topol.top
gmx grompp -f gromacs_scripts/ions.mdp -c solvate.gro -p topol.top -o ions.tpr -maxwarn 1
echo -e "q\n" | gmx make_ndx -f ions.tpr -o index.ndx 
SOL_line=$(cat index.ndx | grep "^\[" | awk '/ SOL /{ print NR; exit }' )
SOL_line=$(( $SOL_line - 1 ))

echo "$SOL_line\n" | gmx genion -s ions.tpr -p topol.top -o ionized.gro -pname K -nname CL -neutral -conc 0.15
gmx grompp -f gromacs_scripts/ions.mdp -c ionized.gro -p topol.top -o ions.tpr -maxwarn 1
gmx editconf -f ions.tpr -o ionized.pdb -conect
bash gromacs_scripts/make_psf.sh ionized.pdb ionized.psf
echo -e "q\n" | gmx make_ndx -f ions.tpr -o index.ndx 
rm \#*\#
	cp gromacs_scripts/mdp_files/memb/vsite/* . 
	cp gromacs_scripts/pbs_files/gadi/memb*pbs . 
	gmx grompp -f memb0.mdp -o memb0.tpr -c ionized.gro -p topol.top 
	echo -e "q\n" | gmx make_ndx  -f memb0.tpr -o index.ndx
#bash ./gromacs_scripts/genrestr_sequence_glob.sh ionized.pdb ionized.psf

