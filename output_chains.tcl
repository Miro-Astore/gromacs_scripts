mol new PDBFILE autobonds off 
mol addfile PDBFILE

set sel [atomselect  top all]
set c [$sel get chain]
set c [lsort -uniq $c]

set out [open chain_out.txt w ]
puts $out "$c"
close $out

exit 
