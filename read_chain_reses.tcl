mol new PDBFILE
mol addfile PSFFILE
set sel [atomselect top "protein and name CA"]
set chains [ lsort -uniq [$sel get chain]]
set fp [open "/tmp/chain_residues.txt" "w"]

for {set i 0} { $i < [llength $chains]} {incr i} {
	set temp_chain [lindex $chains $i]
	set sel [atomselect top "protein and name CA and chain $temp_chain"]
	set reses [lsort -unique -integer [$sel get resid]]
	set first [lindex $reses 0]
	set last [lindex $reses end]
	puts -nonewline $fp "$temp_chain\_$first-$last\n"
}
close $fp
exit 
