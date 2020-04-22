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
#backup topology files but don't replace anything
cp -n ../*itp ../topol_backups/
cp -n ../*top ../topol_backups/
#revert to original topology files
cp ../topol_backups/* ../
mkdir -p ../relax
#cp ../relax/* ../
#for making the popc index  file 
echo -e  " 0 & ! a H* \n name 3 noh \n q\n"  | gmx make_ndx -f ../memb.gro -o ../popc.ndx


fc=4184
for i in $(seq 1  15 ); 
do 
	echo 3 | gmx genrestr -f ../memb.gro -o ../relax/relaxL_$i.itp -fc $fc -n ../popc.ndx 
	fc=$(echo "scale=1;$fc / 2 " | bc -l )
done


#i="../topol.top"

	#getting chain number/identity
	for j in $(seq 1 15); 
	do
sed  "368616 a #ifdef RELAXL_${j} \n#include \"relax/relaxL_${j}.itp\" \n#endif"  ../topol.top > temp.txt 
mv temp.txt ../topol.top

done
GMX_MAXBACKUP=$temp_gmx_back
