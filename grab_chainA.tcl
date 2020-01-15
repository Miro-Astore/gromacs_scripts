mol new ionized.gro 
set sel [atomselect top "protein and  resid 1 to 700"]
$sel writepdb chainA.pdb
