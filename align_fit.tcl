
set sel [atomselect 0 "name CA"]
set res [$sel get resid ]


set sel1 [atomselect 1 "name CA and resid $res"]
set res [$sel1 get resid ]

set sel [atomselect 0 "name CA and resid $res"]
set M [measure fit $sel $sel1]
set sel [atomselect 0 "all"]

$sel move $M 

