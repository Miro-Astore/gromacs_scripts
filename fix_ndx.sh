gro_file="../ionized.gro"
gmx make_ndx -f $gro_file -o index.ndx 
SOL_line=awk '/\[SOL\]/{ print NR; exit }' input-file
POT_line=awk '/\[POT\]/{ print NR; exit }' input-file
CLA_line=awk '/\[CLA\]/{ print NR; exit }' input-file
#have to subtract one from all of these because indexing of groups in index file starts from 0 
SOL_line=$((SOL_line - 1 )) 
POT_line=$(($POT_line - 1 )
CLA_line=$(( $CLA_line - 1 ))
echo -e "$SOL_line | $POT_line | $CLA_line\nq " | gmx make_ndx -f $gro_file.gro 
