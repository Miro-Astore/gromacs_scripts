mol new ./global_wtfit_1.pdb 
set sel [atomselect top "all"]
set segnames [$sel get segname]
set segnames [lsort -uniq $segnames]
foreach seg $segnames { 
	set sel [atomselect top "segname $seg"]
	$sel set chain $seg
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
