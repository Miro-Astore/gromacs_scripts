mol new PSFFILE 
mol addfile PDBFILE
set sel [atomselect top "water"]
$sel writepsf psf_buildfiles/waterpdb.psf
mol delete all
mol new PSFFILE 
mol addfile PDBFILE
set sel [atomselect top "lipid"]
$sel writepsf psf_buildfiles/lipid.psf
exit
