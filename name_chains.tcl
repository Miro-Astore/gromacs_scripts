set sel [atomselect top "protein"]
$sel set chain A
$sel set segname AP1 
set sel [atomselect top "all"]
$sel writepdb chains_named.pdb
$sel writepsf chains_named.psf
exit
