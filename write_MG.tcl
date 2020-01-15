mol new ionized.psf
mol addfile ionized.pdb
set sel [atomselect top "resname MG"]
$sel writepdb MG.pdb
exit 
