mol new ./global_wtfit_3.pdb 
set sel [atomselect top "all"]
set segnames [$sel get chain]
set segnames [lsort -uniq $segnames]
foreach seg $segnames { 
	set sel [atomselect top "chain $seg"]
	$sel writepdb $seg\P1.pdb
}

package require psfgen 
resetpsf
topology /home/miro/Downloads/toppar/top_all36_prot.rtf
pdbalias ILE CD1 CD 
pdbalias residue HIS HSD
foreach seg $segnames { 
	segment $seg\P1 {
		pdb $seg\P1.pdb
		first NONE 
		last NONE 
	}
	coordpdb $seg\P1.pdb $seg\P1
	guesscoord
	writepsf out.psf 

	writepdb out.pdb
}
exit 
