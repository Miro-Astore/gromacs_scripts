#first step is getting the protein restr files
#################
#USAGE genrestr_sequence grofile.gro topol.top pdbfile.pdb psffile.psf 
#################
#make sure the pdb files contain the whole system. they don't need the right termini but they need all elements proteins ligands and lipids
#note weird sed delimiters is because it won't distinguish /'s from directories properly so we use ^ instead 

#TODO make this script more modular. sure make a seperate one for proteins but you don't need to do the same thing for each ligand /lipid
#TODO make script insensetive to pdb or gro residue numbering can use gmx editconf -resnr option to renumber residues in the writing pdb step

temp_gmx_back=$GMX_MAXBACKUP
export GMX_MAXBACKUP=-1
mkdir -p ../topol_backups
mkdir -p build_files
prot_topfile="/home/miro/Downloads/toppar/top_all36_prot.rtf"
#backup topology files but don't replace anything
cp -n ../topol*itp ../topol_backups/
#revert to original topology files
cp ../topol_backups/* ../
mkdir -p ../relax
#cp ../relax/* ../
gmx grompp -f ions.mdp -c $1 -p $2 -o ionized.tpr -maxwarn 1

export temp_vmdopt=$VMDNOOPTIX
export temp_vmdcuda=$VMDNOCUDA 
export VMDNOCUDA=1
export VMDNOOPTIX=1
PROTEINPDBFILE="$3"
PROTEINPSFFILE="$4"
echo $PROTEINPDBFILE
echo $PROTEINPSFFILE
cat read_chain_reses.tcl | sed "s^PDBFILE^$PROTEINPDBFILE^g" | sed "s^PSFFILE^$PROTEINPSFFILE^g" > build_files/read_chain_reses.tcl
vmd -dispdev text -e  build_files/read_chain_reses.tcl 
for i in $(cat build_files/chain_residues.txt );
do 
	chain=$(echo $i |  awk -F_ '{print $1}' )
	resids=$(echo $i |  awk -F_ '{print $2}' )
	#13 is the default protein group for this system for some reason weird. this will probably change in other systems
	#see when we switched to a new gro file it went to 2. need to know how it decides index group placements. probably something to do with how they appear in the pdb file that was parsed to pdb2gmx. do things consistently
	echo -e "1 & r$resids\nq"  | gmx make_ndx -f ionized.tpr  -o build_files/out.ndx 

	chain_n=$(cat build_files/out.ndx | grep "^\[" | wc -l)
	chain_n=$(( $chain_n - 1 ))
	echo $chain_n | gmx editconf -f ionized.tpr -o build_files/building_gro$chain.pdb -n build_files/out.ndx -conect

	fc=4184
	for i in $(seq 1 15 ); do 
		echo 2 | gmx genrestr -f build_files/building_gro$chain.pdb -o ../relax/relax$chain\_$i.itp -fc $fc
		fc=$(echo "scale=1;$fc / 2 " | bc -l )
	done 
	rm build_files/out.ndx 
	#rm build_files/building_gro$chain.pdb
done 

cat write_POPC.tcl | sed "s^PDBFILE^$PROTEINPDBFILE^g" | sed "s^PSFFILE^$PROTEINPSFFILE^g" > build_files/write_POPC.tcl
vmd -dispdev text -e build_files/write_POPC.tcl  
echo -e "0 & ! a H*\nq" | gmx make_ndx -f build_files/POPC.pdb  -o build_files/out.ndx 
chain_n=$(cat build_files/out.ndx | grep "^\[" | wc -l)
chain_n=$(( $chain_n - 1 ))

fc=4184
for i in $(seq 1  15 ); 
do 

	echo -e "$chain_n\nq" | gmx genrestr -f build_files/POPC.pdb -n build_files/out.ndx -o ../relax/relaxL_$i.itp -fc $fc
	fc=$(echo "scale=1;$fc / 2 " | bc -l )
done
rm build_files/out.ndx

cat write_ATP.tcl | sed "s^PDBFILE^$PROTEINPDBFILE^g" | sed "s^PSFFILE^$PROTEINPSFFILE^g" > build_files/write_ATP.tcl
vmd -dispdev text -e build_files/write_ATP.tcl  
echo -e "0 & ! a H*\nq" | gmx make_ndx -f build_files/ATP.pdb  -o build_files/out.ndx 
chain_n=$(cat build_files/out.ndx | grep "^\[" | wc -l)
chain_n=$(( $chain_n - 1 ))

fc=4184
for i in $(seq 1  15 ); do 

	echo -e "$chain_n\nq" | gmx genrestr -f build_files/ATP.pdb -n build_files/out.ndx -o ../relax/relaxR2_$i.itp -fc $fc
	fc=$(echo "scale=1;$fc / 2 " | bc -l )
done
rm build_files/out.rndx

cat write_MG.tcl | sed "s^PDBFILE^$PROTEINPDBFILE^g" | sed "s^PSFFILE^$PROTEINPSFFILE^g" > build_files/write_MG.tcl
vmd -dispdev text -e build_files/write_MG.tcl  
vmd -dispdev text -e write_MG.tcl  
echo -e "0 & ! a H*\nq" | gmx make_ndx -f build_files/MG.pdb  -o build_files/out.ndx 
chain_n=$(cat build_files/out.ndx | grep "^\[" | wc -l)
chain_n=$(( $chain_n - 1 ))
fc=4184
#this number defines the number of relaxation steps
for i in $(seq 1  15 ); 
do 
	echo -e "$chain_n\nq" | gmx genrestr -f build_files/MG.pdb -n build_files/out.ndx -o ../relax/relaxR_$i.itp -fc $fc
	fc=$(echo "scale=1;$fc / 2 " | bc -l )
done
export VMDNOCUDA=$temp_vmdocuda
export VMDNOOPTIX=$temp_vmdopt


for i in $(ls .. | grep topol | grep itp); 
do 

	#getting chain number/identity
	chain_id=$(echo $i | grep -o "chain_.*.itp" | sed "s^chain\_^^g" | sed "s^\.itp^^g")
	for j in $(seq 1 15); 
	do
		echo -e "#ifdef RELAX${chain_id}_${j}
#include \"relax/relax${chain_id}_${j}.itp\"
#endif" >> ../$i

	done
done 
GMX_MAXBACKUP=$temp_gmx_back
