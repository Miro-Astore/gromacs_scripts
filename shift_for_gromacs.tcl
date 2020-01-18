mol new ../final_wt_ionized_added_loops_no_ters_cter_modelled_use_this_gmx_ready.psf
mol addfile ../final_wt_ionized_added_loops_no_ters_cter_modelled_use_this_gmx_ready.pdb
set sel [atomselect top "all"]
set gec [measure minmax $sel ]
set vec1 [lindex $gec 0]
set vec2 [lindex $gec 1]
set gec [vecsub $vec2 $vec1 ]
$sel moveby [vecscale -1.0 $gec]
#animate write gro centered.gro $sel
$sel writepsf ../centered.psf
$sel writepdb ../centered.pdb
exit
