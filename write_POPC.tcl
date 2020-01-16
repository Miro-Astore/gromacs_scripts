mol new PSFFILE
mol addfile PDBFILE
set sel [atomselect top "resname POPC"]
$sel writepdb POPC.pdb
exit 
