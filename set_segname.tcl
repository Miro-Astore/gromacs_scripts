mol new PSFFILE
set sel [atomselect top all]
$sel set segname SEGNAME
$sel writepsf PSFFILE
