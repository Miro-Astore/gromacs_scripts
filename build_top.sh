cd .. 
gmx pdb2gmx -f final_wt_ionized_added_loops_no_ters_cter_modelled_use_this_gmx_ready.pdb -o ionized.gro -ter -ff charmm36-mar2019.ff -water tip3p -p topol.top 
