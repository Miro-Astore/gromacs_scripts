#first step is getting the protein restr files
#################
#USAGE bash genrestr_sequence topol.top pdbfile.pdb psffile.psf restr_groups.txt
#################
#make sure the pdb file is generated from the tpr file and output by editconf -conect
#note weird sed delimiters is because it won't distinguish /'s from directories properly so we use ^ instead 

#TODO make this script more modular. sure make a seperate one for proteins but you don't need to do the same thing for each ligand /lipid
#TODO make script insensetive to pdb or gro residue numbering can use gmx editconf -resnr option to renumber residues in the writing pdb step


#logic of script 
#read in system psf/pdb combo created using make_psf.sh 
#get chains, exclude X
#write out chains 
#do genrestr on the chains -H
#add relax clauses to the topol .itp files

#backup everything and disable gmx backups
temp_gmx_back=$GMX_MAXBACKUP
export GMX_MAXBACKUP=-1
mkdir -p topol_backups
#backup topology files but don't replace anything
cp -n topol*itp topol_backups/
#revert to original topology files
cp topol_backups/* ./
mkdir -p relax
#cp ../relax/* ../
#gmx grompp -f ions.mdp -c $1 -p $2 -o ionized.tpr -maxwarn 1

PROTEINPDBFILE="ionized.pdb"
PROTEINPSFFILE="ionized.psf"
TOPOLIST="restr_groups.txt"

export temp_vmdopt=$VMDNOOPTIX
export temp_vmdcuda=$VMDNOCUDA 
export VMDNOCUDA=1
export VMDNOOPTIX=1
#PROTEINPDBFILE="$2"
#PROTEINPSFFILE="$3"
echo $PROTEINPDBFILE
echo $PROTEINPSFFILE

cat gromacs_scripts/output_chains.tcl | sed "s^PDBFILE^$PROTEINPDBFILE^g" | sed "s^PSFFILE^$PROTEINPSFFILE^g" > output_chains.tcl
vmd -dispdev text -e output_chains.tcl 
sed -i "s/X//g" chain_out.txt 

restr_line=1

for chain in $(cat chain_out.txt );
do 
	echo -e "chain $chain\nq\n" | gmx make_ndx -f glob0.tpr -o out.ndx 


	echo -e "0\n" | gmx editconf -f glob0.tpr -o building_gro$chain.pdb -n out.ndx 
	echo $restr_line
	topol_file=$( cat $TOPOLIST | sed "$restr_line q;d" );
	restr_line=$(($restr_line + 1))
	echo $restr_line

	echo -e "0 & ! a H*\nq\n" | gmx make_ndx -f building_gro$chain.pdb -o out_restr.ndx 
	chain_n=$(cat out_restr.ndx | grep "^\[" | wc -l)
	#chain_n=$(cat index.ndx | grep "^\[" | awk '/ Protein-H /{ print NR; exit }' )
	chain_n=$(( $chain_n - 1 ))

	fc=4184
	for i in $(seq 1 15 ); do 
		echo -e "$chain_n\n" | gmx genrestr -f building_gro$chain.pdb -o relax/relax$chain\_$i.itp -fc $fc -n out_restr.ndx
		fc=$(echo "scale=1;$fc / 2 " | bc -l )

		echo -e "#ifdef RELAX$i
#include \"relax/relax${chain}_${i}.itp\"
#endif" >> $topol_file
	done

	#rm building_gro$chain.pdb
done
export VMDNOCUDA=$temp_vmdocuda
export VMDNOOPTIX=$temp_vmdopt
GMX_MAXBACKUP=$temp_gmx_back

