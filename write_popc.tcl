mol new ionized.psf
mol addfile ionized.pdb
set sel [atomselect top "resname POPC"]
$sel writepdb POPC.pdb
exit 
