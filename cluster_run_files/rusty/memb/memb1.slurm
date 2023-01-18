#!/bin/bash
#SBATCH -D ./
#SBATCH -J prod
#SBATCH -o out.out
#SBATCH -e err.out
#SBATCH --partition=ccb
##SBATCH --partition=preempt
##SBATCH --qos=preempt
#SBATCH --requeue
#SBATCH --constraint=rome,ib
# Set the number of tasks per node (=MPI ranks)
#SBATCH --ntasks-per-node=30
#SBATCH --time 4-0:00:00
# Request 10 node(s)
#SBATCH --nodes=10
# Set the number of threads per rank (=OpenMP threads)
#SBATCH --cpus-per-task=4

cp out.out out.old
cp err.out err.old

##SBATCH -p=gpu
##SBATCH -c=16
##SBATCH -C=a100,ib
##SBATCH --mem=8000
##SBATCH --gpus=1
##SBATCH -o out.out
##SBATCH -e error.err
##SBATCH --job-name=equilibration
## -J  for short hand 


module purge
module load cuda

module load modules/2.1-alpha2  
module load openmpi/4.0.7
module load gromacs/mpi-2022.3

export job_root_name="memb_prod1"
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

#!/bin/bash


line=$(squeue -h -j $SLURM_JOBID -O timelimit) # Leading '-' aids parsing.
line=$(echo -$line)

parts=( 0 0 0 0 )
index=3

while [ ${#line} -gt 0 ]; do
  parts[${index}]=${line##*[-:]}
    line=${line%[-:]*}
      ((index--))
      done

root=$(echo ${parts[*]})


d=$(echo $root | awk  '{print $1}')

h=$(echo $root | awk  '{print $2}')
m=$(echo $root | awk  '{print $3}')
s=$(echo $root | awk  '{print $4}')

sleep_time=$(( $d * 86400 + $h*3600 + $m * 60 + $s ))
sleep_time=$( echo "$sleep_time * 0.95" |  bc -l )
h_time=$( echo "$sleep_time / 3600" | bc -l )

#just doing this so we can see benchmarks over time and keep track of things.
cp $job_root_name.log $job_root_name_backup.log

if [ -f $job_root_name.cpt ]
then
#gmx mdrun -v -cpi $job_root_name.cpt -ntmpi $SLURM_GPUS_PER_NODE -ntomp $OMP_NUM_THREADS -deffnm $job_root_name -maxh $h_time &
mpirun --map-by socket:pe=$OMP_NUM_THREADS gmx_mpi mdrun -v -maxh $h_time  -deffnm $job_root_name -cpi $job_root_name.cpt &
md_proc=$!
else 
#gmx grompp -f memb_prod.mdp -o $job_root_name.tpr -c memb6.gro   -p topol.top  -n index.ndx

mpirun --map-by socket:pe=$OMP_NUM_THREADS gmx_mpi mdrun -v -maxh $h_time -deffnm $job_root_name &
md_proc=$!

fi 

echo $last_err
echo $sleep_time

#if the job has run for more than an hour resubmit it 

#wait till the md process has finished and if it has exitted without errors resubmit this script to restart from a checkpoint

tail --pid=$md_proc -f /dev/null

last_err=$?

line=$(squeue -h -j $SLURM_JOBID -O timeused) # Leading '-' aids parsing.
line=$(echo -$line)

parts=( 0 0 0 0 )
index=3

while [ ${#line} -gt 0 ]; do
  parts[${index}]=${line##*[-:]}
    line=${line%[-:]*}
      ((index--))
      done

root=$(echo ${parts[*]})


used_d=$(echo $root | awk  '{print $1}')

used_h=$(echo $root | awk  '{print $2}')

total_h=$(( $used_d * 24 + $used_h))

alias nbatch="sbatch -J $( echo "$(echo $SLURM_SUBMIT_DIR | awk -F/ '{print $(NF-2)$(NF-1)$NF}' | sed "s^_^^g" | sed "s^memb^^g" | sed "s^plumed^^g" | sed "s^CFTR^^g" | sed "s^simreadysystems^^")$(echo $1 | sed "s^\.pbs^^g" | sed "s^_^^g" | sed "s^memb^^g"  |sed "s^glob^^g" | sed "s^window^^g" )" | tail -c 11 ) "


nbatch () {
    sbatch -J $( echo "$(pwd | awk -F/ '{print $(NF-2)$(NF-1)$NF}' | sed "s^_^^g" | sed "s^memb^^g" | sed "s^plumed^^g" | sed "s^CFTR^^g" | sed "s^simreadysystems^^")$(echo $1 | sed "s^\.pbs^^g"  | sed "s^\.slurm^^g" | sed "s^_^^g" | sed "s^memb^^g"  | sed "s^glob^^g" | sed "s^window^^g" )" | tail -c 9 ) $1
}


if [  $total_h -gt 0 ] ; 
then 
echo 'hi'
nbatch memb1.slurm
elif [ -f $job_root_name.gro ] ;
then
nbatch process_traj.slurm
fi
exit 
