#!/bin/bash
gro_file="../ionized.gro"
top_file="../topol.top"
top_root_dir=$(dirname $(readlink -f $top_file))
psf_file="../R352Q.psf"
pdb_file="../R352Q.pdb"

mkdir -p psf_buildfiles

#grab only the section that contains roots of topol.itp files, ignore comments and include statements 

list_itp=$(cat $top_file  | awk '/\[\s*molecules\s*\]/{y=1;next}y' | grep -v "^;" | grep -v "^\#" | grep -v "SOL" | awk '{print $1}')
	# exclude lipids because they are not well behaved
echo $list_itp

echo "package require psfgen" > psf_buildfiles/merge_elements.tcl


#convert sanely 
for i in $( echo $list_itp);
do 
	if [ $i = "Other_chain_L" ]
	then
		echo "readpsf psf_buildfiles/lipid.psf" >> psf_buildfiles/merge_elements.tcl
	else
	#using ,'s as delims because ^ is a part of the regex pattern we're using here
	#using the greedy nature of bash regex properly. Usually we would have to go and use perl or something and ew who wants to do that.
	segname=$( echo $i | sed "s,^.*_,,g")
	perl top2psf.pl -p $top_root_dir/topol_$i.itp -o psf_buildfiles/$i.psf
	natoms=$(cat psf_buildfiles/$i.psf | grep NATOM | awk '{print $1}')
	python ./padding_0s_for_top2psf.py psf_buildfiles/$i.psf  $natoms
	#give things a unique segname so we can differentiate them when we merge all the psf files back together. It gets mad otherwise. It would be nice to give them real segnames but vmd doesn't like trying to write psf file without a segname and that is going to be a whole other kettle of fish to try and deal with to be honest.  
	sed -i "s/MAIN/$segname   /g" psf_buildfiles/$i.psf
	echo "readpsf psf_buildfiles/$i.psf" >> psf_buildfiles/merge_elements.tcl
fi
done

# make a psf of the water in the system
cat write_water_lipids.tcl | sed -e "s^PSFFILE^$psf_file^g" | sed -e "s^PDBFILE^$pdb_file^g" > psf_buildfiles/write_water_lipids.tcl
vmd -dispdev text -e  psf_buildfiles/write_water_lipids.tcl

echo "readpsf psf_buildfiles/waterpdb.psf" >> psf_buildfiles/merge_elements.tcl
echo "writepsf ../ionized.psf" >> psf_buildfiles/merge_elements.tcl
echo "exit" >> psf_buildfiles/merge_elements.tcl
vmd -dispdev text -e psf_buildfiles/merge_elements.tcl 
