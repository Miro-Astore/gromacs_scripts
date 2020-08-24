#USAGE
# bash gromacs_scripts/make_psf.sh ionized.pdb ionized.psf
gmx editconf -f memb0.tpr -o ionized.pdb -conect
cat $1 | grep -v END | grep -v SOL | grep -v "\sK\s" | grep -v "\sCL\s" | grep -v "\sNA\s" > connected.pdb
cat ionized.pdb | grep -v END | grep -E 'SOL|\sNA\s|\sK\s|\sCL\s' > unconnected.pdb

n_atoms=$(cat ionized.pdb | grep "^ATOM" | wc -l )


vmddisp () {
	tempvmdc=$VMDNOCUDA 
	tempvmdo=$VMDNOOPTIX 
	export VMDNOCUDA=1 
	export VMDNOOPTIX=1 
	vmd -dispdev text -e "$@"
	export VMDNOCUDA=$tempvmdc
	export VMDNOOPTIX=$tempvmdo 
}

vmddisp gromacs_scripts/write_conect_psfs.tcl

head -n +$(( -2 + $(grep -m1 -n NBOND connected_psf.psf | cut -d: -f1) )) connected_psf.psf > connected_atoms_psf.txt
tail -n +$(( 0 + $(grep -m1 -n NBOND connected_psf.psf | cut -d: -f1) )) connected_psf.psf > connected_bonds_psf.txt

head -n +$(( -1 + $(grep -m1 -n NBOND unconnected_psf.psf | cut -d: -f1) )) unconnected_psf.psf  > t_unconnected_atoms_psf.txt
tail -n +$(( 1 + $(grep -m1 -n NATOM t_unconnected_atoms_psf.txt | cut -d: -f1) )) t_unconnected_atoms_psf.txt > unconnected_atoms_psf.txt

cat connected_atoms_psf.txt unconnected_atoms_psf.txt connected_bonds_psf.txt > $2

sed -i "s/[0-9]*\s*\!NATOM/$n_atoms  !NATOM/g"  $2

