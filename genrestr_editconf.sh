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
	#13 is the default protein group for this system for some reason weird. this will probably change in other systems
	echo -e "13 & r$resids\nq"  | gmx make_ndx -f ionized.tpr  -o /tmp/out.ndx 

	chain_n=$(cat /tmp/out.ndx | grep "^\[" | wc -l)
	chain_n=$(( $chain_n - 1 ))
	echo $chain_n | gmx editconf -f ionized.tpr -o /tmp/building_gro$chain.pdb -n /tmp/out.ndx -conect
	#echo $chain_n | gmx editconf -f ionized.tpr -o /tmp/building_gro$chain.gro -n /tmp/out.ndx 
	fc=4184
	for i in $(seq 1 ); do 
		echo 2 | gmx genrestr -f /tmp/building_gro$chain.pdb -o relax$chain\_$i.itp -fc $fc
		fc=$(echo "scale=1;$fc / 2 " | bc -l )
	done 
	rm /tmp/out.ndx 
	#rm /tmp/building_gro$chain.pdb
done 

