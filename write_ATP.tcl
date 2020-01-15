mol new ionized.psf
mol addfile ionized.pdb
set sel [atomselect top "resname ATP"]
$sel writepdb POPC.pdb
exit 
