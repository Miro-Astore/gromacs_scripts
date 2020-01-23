#!/bin/bash
gro_file="../ionized.gro"
top_file="../topol.top"
top_root_dir=$(dirname $(readlink -f $top_file))
psf_file="../I37R.psf"
pdb_file="../I37R.pdb"

mkdir -p psf_buildfiles

#grab only the section that contains roots of topol.itp files, ignore comments and include statements 

list_itp=$(cat $top_file  | awk '/\[\s*molecules\s*\]/{y=1;next}y' | grep -v "^;" | grep -v "^\#" | grep -v "SOL" | awk '{print $1}')

echo "package require psfgen" > psf_buildfiles/merge_elements.tcl


#convert sanely 
for i in $( echo $list_itp);
do 
	segname=$( echo $i | sed "s^\s^^g" | grep -o "_.*$" | sed "s^\_^^g" )
	perl top2psf.pl -p $top_root_dir/topol_$i.itp -o psf_buildfiles/$i.psf
	natoms=$(cat psf_buildfiles/$i.psf | grep NATOM | awk '{print $1}')
	python ./padding_0s_for_top2psf.py psf_buildfiles/$i.psf  $natoms
	cat set_segname.tcl | sed "s^PSFFILE^psf_buildfiles/$i.psf^g" | sed "s/SEGNAME/$segname/g" > psf_buildfiles/set_segname.tcl 
	vmd -dispdev text -e psf_buildfiles/set_segname.tcl 
	echo "readpsf psf_buildfiles/$i.psf" >> psf_buildfiles/merge_elements.tcl
done

# make a psf of the water in the system
cat write_water.tcl | sed -e "s^PSFFILE^$psf_file^g" | sed -e "s^PDBFILE^$pdb_file^g" > psf_buildfiles/write_water.tcl
vmd -dispdev text -e  psf_buildfiles/write_water.tcl

echo "readpsf psf_buildfiles/waterpdb.psf" >> psf_buildfiles/merge_elements.tcl
echo "writepsf ../ionized.psf" >> psf_buildfiles/merge_elements.tcl
echo "exit" >> psf_buildfiles/merge_elements.tcl
vmd -dispdev text -e psf_buildfiles/merge_elements.tcl 
