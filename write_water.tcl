mol new PSFFILE 
mol addfile PDBFILE
set sel [atomselect top "water"]
$sel writepsf psf_buildfiles/waterpdb.psf
exit
