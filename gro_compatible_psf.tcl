#this script grabs an individual chain fed into it by genrestr_sequence.sh and then generates a psf/pdb combo with the right terminals
# no silly you need both chains so you can add the right termini.

file mkdir build_files
mol new ../mutated_systems/I37R/I37R.psf
mol addfile ../mutated_systems/I37R/I37R.pdb
set sel [atomselect top "segname AP1"]
$sel writepdb build_files/AP1.pdb

set sel [atomselect top "segname BP1"]
$sel writepdb build_files/BP1.pdb

set sel [atomselect top "not protein"]
$sel writepdb build_files/not_prot.pdb
$sel writepsf build_files/not_prot.psf

#we have to remake the psf file in case the termini of the protein was changed by the mutator plugin.

package require psfgen 
resetpsf 

# I don't have a license to distribute the topology so you will need to provide it 
#topology TOPFILE
topology /home/miro/Downloads/toppar/top_all36_prot.rtf
pdbalias atom ILE CD1 CD 

#readpsf build_files/AP1.psf
#coordpdb build_files/AP1.pdb
#
segment AP1 { 
	pdb build_files/AP1.pdb
	first NTER
	last CT2
}  
coordpdb build_files/AP1.pdb AP1


segment BP1 { 
	pdb build_files/BP1.pdb
	first NNEU
	last CTER
}
coordpdb build_files/BP1.pdb BP1

guesscoord
regenerate angles dihedrals

writepdb build_files/vis_prot.pdb
writepsf build_files/vis_prot.psf
resetpsf

readpsf build_files/vis_prot.psf
readpsf build_files/not_prot.psf

coordpdb build_files/vis_prot.pdb
coordpdb build_files/not_prot.pdb


writepdb build_files/vis.pdb
writepsf build_files/vis.psf
exit
