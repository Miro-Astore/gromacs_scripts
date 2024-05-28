gmxbacktemp=$GMX_MAXBACKUP
export GMX_MAXBACKUP=-1
gro_file="../ionized.gro"
gro_file=$(readlink -f "$gro_file")
cd $( dirname $(readlink -f "$gro_file"))
echo $gro_file
echo -e 'q' | gmx make_ndx -f $gro_file -o index.ndx 
num_groups=$(cat index.ndx | grep "^\[" | wc -l )
SOL_line=$(cat index.ndx | grep "^\[" | awk '/ SOL /{ print NR; exit }' )
POT_line=$(cat index.ndx | grep "^\[" | awk '/ POT /{ print NR; exit }' )
CLA_line=$(cat index.ndx | grep "^\[" | awk '/ CLA /{ print NR; exit }' )
#have to subtract one from all of these because indexing of groups in index file starts from 0 
SOL_line=$(( $SOL_line - 1 )) 
POT_line=$(($POT_line - 1 ))
CLA_line=$(( $CLA_line - 1 ))
echo -e "$SOL_line | $POT_line | $CLA_line \n name $num_groups SOLVENT \n \n q \n" | gmx make_ndx -f $gro_file -n index.ndx  -o index.ndx 
MG_line=$(cat index.ndx | grep "^\[" | awk '/ MG /{ print NR; exit }' )
ATP_line=$(cat index.ndx | grep "^\[" | awk '/ ATP /{ print NR; exit }' )
MG_line=$(( $MG_line - 1 )) 
ATP_line=$(( $ATP_line - 1 )) 
echo -e "$MG_line | $ATP_line \n\n q \n " |  gmx make_ndx -f $gro_file -n index.ndx -o index.ndx
cd gromacs_scripts
GMX_MAXBACKUP=$gmxbacktemp
