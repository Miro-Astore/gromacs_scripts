package require psfgen

readpsf not_prot.psf
readpsf testprot_formatted_autopsf.psf

coordpdb not_prot.pdb
coordpdb testprot_formatted_autopsf.pdb

writepsf merged.psf
writepdb merged.pdb
exit
