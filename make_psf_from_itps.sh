#!/bin/bash
gro_file="../ionized.gro"
top_file="../topol.top"
top_root_dir=$(dirname $(readlink -f $top_file))
psf_file="../I37R.psf"
pdb_file="../I37R.pdb"

mkdir -p psf_buildfiles

#grab only the section that contains roots of topol.itp files, ignore comments and include statements 

list_itp=$(cat $top_file  | awk '/\[\s*molecules\s*\]/{y=1;next}y' | grep -v "^;" | grep -v "^\#" | grep -v "SOL" | awk '{print $1}')
echo $list_itp

#convert sanely 
for i in $( echo $list_itp);
do 
	perl top2psf.pl -p $top_root_dir/topol_$i.itp -o psf_buildfiles/$i.psf
	natoms=$(cat psf_buildfiles/$i.psf | grep NATOMS | awk '{print $NF}')
	python ./padding_0s_for_top2psf.py psf_buildfiles/$i.psf  $natoms
done

# make a psf of the water in the system
cat write_water.tcl | sed -e "s^PSFFILE^$psf_file^g" | sed -e "s^PDBFILE^$pdb_file^g" > psf_buildfiles/write_water.tcl
vmd -dispdev text -e  psf_buildfiles/write_water.tcl

