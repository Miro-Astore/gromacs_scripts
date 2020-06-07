mol new connected.pdb autobonds off
set sel [atomselect top all]
$sel writepsf connected_psf.psf
$sel writepdb connected_psf.pdb

mol new unconnected.pdb autobonds off
set sel [atomselect top all]
$sel writepsf unconnected_psf.psf
$sel writepdb unconnected_psf.pdb
exit 
