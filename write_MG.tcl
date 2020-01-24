mol new PSFFILE
mol addfile PDBFILE
set sel [atomselect top "resname MG"]
$sel writepdb build_files/MG.pdb
exit 
