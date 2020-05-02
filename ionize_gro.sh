#!/bin/bash
gmx grompp -f ions.mdp -c solvate.gro -p topol.top -o ions.tpr -maxwarn 1
gmx genion -s ions.tpr -p topol.top -o ionized.gro -pname NA -nname CL -neutral -conc 0.15
