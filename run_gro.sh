#!/bin/bash

minimisation
gmx grompp -f memb0.mdp -o memb0.tpr -c converted.gro -r converted.gro -p topol.top 
gmx mdrun -v -deffnm memb0

#eq 

#for i in $(seq 1 15); 
#do 
#    echo $i
#    gmx grompp -f memb$i.mdp -o memb$i.tpr -c memb$(( $i - 1 )).gro -r converted.gro -n index.ndx -p topol.top 2>&1 | tee memb$i\_setup.log
#    sleep 6
#    gmx mdrun -v -deffnm memb$i -nb gpu -tunepme yes  2>&1 | tee  memb$i.log

#done

#prod

#gmx grompp -f memb16.mdp -o memb16.tpr -c memb15.gro -n index.ndx -p topol.top 2>&1 | tee memb16_setup.log
#gmx mdrun -v -deffnm memb16 -nb gpu -tunepme yes  2>&1 | tee  memb16.log
#gmx grompp -f memb17.mdp -o memb17.tpr -c memb16.gro -n index.ndx -p topol.top 2>&1 | tee memb17_setup.log
#gmx mdrun -v -deffnm memb17 -nb gpu -tunepme yes  2>&1 | tee  memb17.log
#gmx grompp -f memb18.mdp -o memb18.tpr -c memb17.gro -n index.ndx -p topol.top 2>&1 | tee memb18_setup.log
#gmx mdrun -v -deffnm memb18 -nb gpu -tunepme yes  2>&1 | tee  memb18.log
#gmx grompp -f memb_prod.mdp -o memb19.tpr -c memb18.gro -n index.ndx -p topol.top 2>&1 | tee memb19_setup.log
#gmx mdrun -v -deffnm memb19 -nb gpu -tunepme yes  2>&1 | tee  memb19.log
#gmx grompp -f memb_prod.mdp -o memb20.tpr -c memb19.gro -n index.ndx -p topol.top 2>&1 | tee memb20_setup.log
#gmx mdrun -v -deffnm memb20 -nb gpu -tunepme yes  2>&1 | tee  memb20.log
