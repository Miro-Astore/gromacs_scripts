mol new PSFFILE
mol addfile PDBFILE
set sel [atomselect top "resname ATP"]
$sel writepdb build_files/ATP.pdb
exit 
