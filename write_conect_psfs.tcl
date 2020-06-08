mol new connected.pdb autobonds off
set sel [atomselect top all]
set c [$sel get chain]
set c [lsort -uniq $c]

foreach i $c {
	set t_sel [atomselect top "chain $i"]
	$t_sel set segname $i
}

$sel writepsf connected_psf.psf
$sel writepdb connected_psf.pdb

mol new unconnected.pdb autobonds off
set sel [atomselect top all]
$sel writepsf unconnected_psf.psf
$sel writepdb unconnected_psf.pdb
exit 
