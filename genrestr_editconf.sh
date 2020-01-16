#first step is getting the protein restr files

gmx grompp -f ions.mdp -c converted.gro -p topol.top -o ionized.tpr -maxwarn 1

export temp_vmdopt=$VMDNOOPTIX
export temp_vmdcuda=$VMDNOCUDA 
export VMDNOCUDA=1
export VMDNOOPTIX=1
PROTEINPDBFILE="ionized.pdb"
PROTEINPSFFILE="ionized.psf"
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

	fc=4184
	for i in $(seq 1 15 ); do 
		echo 2 | gmx genrestr -f /tmp/building_gro$chain.pdb -o relax$chain\_$i.itp -fc $fc

		fc=$(echo "scale=1;$fc / 2 " | bc -l )
	done 
	rm /tmp/out.ndx 
	#rm /tmp/building_gro$chain.pdb
done 

vmd -dispdev text -e write_popc.tcl  
echo -e "0 & ! a H*\nq" | gmx make_ndx -f POPC.pdb  -o /tmp/out.ndx 
chain_n=$(cat /tmp/out.ndx | grep "^\[" | wc -l)
chain_n=$(( $chain_n - 1 ))

for i in $(seq 1  15 ); do 

	echo -e "$chain_n\nq" | gmx genrestr -f POPC.pdb -n /tmp/out.ndx -o relaxL_$i.itp -fc $fc
done
rm /tmp/out.ndx
vmd -dispdev text -e write_ATP.tcl  
echo -e "0 & ! a H*\nq" | gmx make_ndx -f ATP.pdb  -o /tmp/out.ndx 
chain_n=$(cat /tmp/out.ndx | grep "^\[" | wc -l)
chain_n=$(( $chain_n - 1 ))

for i in $(seq 1  15 ); do 

	echo -e "$chain_n\nq" | gmx genrestr -f ATP.pdb -n /tmp/out.ndx -o relaxR2_$i.itp -fc $fc
done
rm /tmp/out.rndx

vmd -dispdev text -e write_MG.tcl  
echo -e "0 & ! a H*\nq" | gmx make_ndx -f MG.pdb  -o /tmp/out.ndx 
chain_n=$(cat /tmp/out.ndx | grep "^\[" | wc -l)
chain_n=$(( $chain_n - 1 ))

for i in $(seq 1  15 ); do 
	echo -e "$chain_n\nq" | gmx genrestr -f MG.pdb -n /tmp/out.ndx -o relaxR_$i.itp -fc $fc
done
export VMDNOCUDA=$temp_vmdocuda
export VMDNOOPTIX=$temp_vmdopt
