#!/bin/bash
fc=4184
echo "hithere"
for i in $(seq 1 15) ; 
do 
    #echo "$fc * 0.5"
    #echo "22" | gmx genrestr -f memb0.gro -n index.ndx -o restr$i.itp -fc $fc $fc $fc 
    cat templateA.itp | sed "s/MARK/$fc/g" > Arestr$i.itp
    cat templateB.itp | sed "s/MARK/$fc/g" > Brestr$i.itp
    fc=$( echo "$fc * 0.5" | bc )
done 
