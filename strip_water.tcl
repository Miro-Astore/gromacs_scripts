set sel [atomselect top "not water and not name POT K NA SOD CLA CL"]
$sel writepdb waterless.pdb
$sel writepsf waterless.psf
exit 
