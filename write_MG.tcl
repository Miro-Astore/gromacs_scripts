mol new PSFFILE
mol addfile PDBFILE
set sel [atomselect top "resname MG"]
$sel writepdb /tmp/MG.pdb
exit 
