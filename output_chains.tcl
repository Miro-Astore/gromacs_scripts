mol new PDBFILE autobonds off 
mol addfile PDBFILE

set sel [atomselect  top "not lipid and not water and not ion"]
set c [$sel get chain]
set c [lsort -uniq $c]

set out [open chain_out.txt w ]
puts $out "$c"
close $out

foreach temp_chain $c {

set chain_sel [atomselect top "chain $temp_chain"]
$chain_sel writepdb building_gro$temp_chain.pdb
}

exit 
