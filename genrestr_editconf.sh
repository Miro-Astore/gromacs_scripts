#echo q | gmx make_ndx -f ionized.gro
#for i in $(echo " MG POPC ATP");

PROTEINPDBFILE="10_added_autopsf.pdb"
PROTEINPSFFILE="10_added_autopsf.psf"
cat read_chain_reses.tcl | sed "s/PDBFILE/$PROTEINPDBFILE/g" | sed "s/PSFFILE/$PROTEINPSFFILE/g" > /tmp/read_chain_reses.tcl
vmd -dispdev text -e  /tmp/read_chain_reses.tcl 
for i in $(cat /tmp/chain_residues.txt );
do 
	chain=$(echo $i |  awk -F_ '{print $1}' )
	resids=$(echo $i |  awk -F_ '{print $2}' )
	#13 is the default protein group for this system for some reason weird.
	echo -e "13 & r$resids\nq"  | gmx make_ndx -f ionized.tpr  -o /tmp/out.ndx 

	chain_n=$(cat out.ndx | grep "^\[" | wc -l)
	#echo $chain_n | gmx editconf -f ionized.tpr -o /tmp/building_gro$chain.pdb -n /tmp/out.ndx -conect
	echo $chain_n | gmx editconf -f ionized.tpr -o /tmp/building_gro$chain.gro -n /tmp/out.ndx 
	gmx genrestr 

	rm /tmp/out.ndx 
	rm /tmp/building_gro$chain.pdb
done 

