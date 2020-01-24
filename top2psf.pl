#!/usr/bin/perl

#NB THIS SCRIPT SHOULD NOT BE USED IN ACTUAL MD SIMULATIONS BUT FOR VISUALISATION PURPOSES ONLY, IT WILL NOT REPRODUCE ANGLES AND DIHEDRALS
#NB
#NB
#NB 
#NB
# Adapted from Graham Smith's script gmx2mmc
# modified by Marc Baaden (080901)
# COPYRIGHT MARC BAADEN
# modified by Miro A. Astore 2020
# LICENSE BSD-3
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
#2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
#3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# this script makes a Charmmm/Xplor psf file from a GROMACS .top file
# it uses atom types, charges, masses and bond information !

$psf_res_offset=0; 

%arghash=@ARGV;
$topfile=$arghash{"-p"}; 
$pdbfile=$arghash{"-P"}; 
$psffile=$arghash{"-o"}; 

$usage_message="
NAME
        Perl script c_top2psf.pl MB080901a
 
SYNOPSIS
        c_top2psf.pl -p <topfile> -o <psffile>
        c_top2psf.pl -P <pdbfile> -o <psffile>
 
        This is a perl script to convert a GROMACS topology file
        (.TOP/.ITP)  or alternatively  a  PDB  file with Connect
	records  in  a Charmmm/Xplor  psf file  using the infor-
	mation about atom types, charges, masses and bonds. Then
	one can use VMD to visualize pdb+psf and verify whether
	the bonding topology is ok.
 
OPTIONS
        -p <topfile>
                <topfile> is a  gromacs topology file as produced
	by pdb2gmx (or it could be an itp),  containing atom type
	and charge information (no #include'd files please!)
 
 	-P <pdbfile>
		<pdbfile> is a file in PDB format with connect
	records. The expected format looks like
	ATOM      1 NA1  X       1      -8.849   0.122   1.276  0.000
	[..]
	CONNECT    2 CA   3 7 95
	[..]

        -o <psffile>
                <psffile> is the output solute file in MMC format
 
SETTINGS
	psf_res_offset
		this added to residue numbers, wherever they come
	from, before writing to psf file
 
AUTHOR
        Marc Baaden <baaden\@smplinux.de>, based on a script by
        Graham Smith.
\n"; 

###
### Command line arguments and initial info
###

# check arguments 
if ( $#ARGV != 3 || ($topfile eq "" && $pdbfile eq "") || $psffile eq "" ) { 
  die "$usage_message"; 
}

if ($topfile) { print "\nconverting from gmx top.... $topfile\n";
} elsif ($pdbfile) { print "\nconverting from PDB........ $pdbfile\n";};

# print a bit of info about non-command-line arguments
print "\npsf_res_offset............. $psf_res_offset\n"; 
print "\nreading input files........ \n"; 

###
### Read input files and open output PSF
###

# in case of a PDB file, we only read relevant lines
if ($pdbfile) { $starttop=0;
open(TOP,"$pdbfile") || die "cant open $pdbfile $usage_message"; 
 } elsif ($topfile) {
open(TOP,"$topfile") || die "cant open $topfile $usage_message"; 
};
my $lin_num=1;
while(my $line=<TOP>) {
	# Parsing for Gromacs topology
	if ($topfile) {
	unless ($line =~ /^\s*(#|;|$)/) {
                ### Calculate some indices
		if    ($line =~ /\[\s*atoms\s*\]/) {$starttop=@toplines}
		elsif ($line =~ /\[\s*bonds\s*\]/) {$finishtop=@toplines}
		elsif ($line =~ /\[\s*pairs\s*\]/) {$finishbon=@toplines}
		else {push @toplines,$line};
#if we haven't yet found the atoms section don't do anything. This lin_num variable will only be used if we don't find a bonds statement, indicating a system  of monatomic  molecules
		if ($starttop) {
		$lin_num = $lin_num + 1
	}
	};
	# Parsing for PDB file
	} elsif ($pdbfile) {
	unless ($line =~ /^\s*(#|;|$)/) {
                ### Calculate some indices
		if    ($line =~ /^\s*ATOM/) {
		       push @toplines,$line;
		       $finishtop=@toplines;
		       }
		elsif ($line =~ /^\s*CONNECT/) {
		       ($dummy,$atnr,$attyp,@rest)=split ' ',$line;
		       $attyplist{$atnr}=$attyp;
		       foreach $tmp (@rest) {
			 # connection info is the 2 atom numbers and 1 dummy nb
			 push @toplines,"$atnr $tmp 1";
		         }
		       $finishbon=@toplines;
		       }
		else {};
	};
	}
}
close TOP;

# append to existing psf file , or create new one
#if ( -e $psffile ) { 
#  # get last residue number and offset from there 
#  $psf_res_offset=`tail -1 $psffile | cut -c46-50`;
#  open(LINE_PSF,">>$psffile") || die "cant open $psffile $usage_message"; 
#  print "appending to............... $psffile
#last residue found......... $psf_res_offset"; 
#} else {
#  # create new psf file 
#  $psf_res_offset=0;  
#  open(LINE_PSF,">$psffile") || die "cant open $psffile $usage_message"; 
#}
#prefer to create a new one 
# create new psf file 
$psf_res_offset=0;  
open(LINE_PSF,">$psffile") || die "cant open $psffile $usage_message"; 

#if the topology file contained bonds do one thing if it is not do something else
#needed because otherwise finishtop will not be defined properly and things get funky otherwise
if ($finishtop) {
	$totnbat=$finishtop-$starttop;
	$totnbbd=$finishbon-$finishtop;
} else {
	$finishtop=$lin_num;
	$totnbat=$finishtop-$starttop;
	$totnbbd=0;
}

# debug and info - print some stuff
 print "DEBUG - starttop........... $starttop
DEBUG - finishtop.......... $finishtop
DEBUG - number of atoms.... $totnbat
DEBUG - number of bonds.... $totnbbd\n";

print "input files read...........\n\nconverting................. "; 


###
### WRITE ATOM SECTION OUTPUT
###

# set page length to a big value
select((select(LINE_PSF), $= = "999999")[0]);

for ($i=$starttop ; $i<$finishtop ; $i++)
{
# get 1 line topology info
  $_=$toplines[$i]; 
  s/^ +//g;  # remove whitespace at start of line, if any

  if ($topfile) {
  ($Tatnr,$Tattype,$Tresnr,$Tresname,$Tatname,$Tcgnr,$Tq,$Tm) = 
    split(/\s+/,$_);
  } elsif ($pdbfile) {
  ($dummy,$Tatnr,$Tatname,$Tresname,$Tresnr,$Tx,$Ty,$Tz,$Tq) = 
    split(/\s+/,$_); 
#  $Tattype="X";
  $Tattype= $attyplist{$Tatnr};
  $Tm="1.0";
  };
# output
  write (LINE_PSF); 
#      13 MAIN 1    GLN  C    C      0.260000       1.00800           0
#      23 MAIN    2  GLU    C    C  0.380000000012.0110000000
#	printf LINE_PSF ("%8d MAIN%4d%4s%4s %4s %13.10f%13.10f\n",$Tatnr,$Tresnr,$Tresname,$Tatname,$Tattype,$Tq,$Tm);
}

###
### WRITE BONDS SECTION OUTPUT
###

# write heading
select((select(LINE_PSF), $~ = "LINE_PSF_2_TOP")[0]);
write(LINE_PSF);

select((select(LINE_PSF), $~ = "LINE_PSF_2")[0]);

for ($i=$finishtop ; $i<$finishbon ; $i=$i+4)
{
	# initialize
	($Batnr1a,$Batnr1b,$Batnr2a,$Batnr2b,$Batnr3a,$Batnr3b,$Batnr4a,$Batnr4b)=("","","","","","","","");
# get 1 line topology info
# remove whitespace at start of line, if any
  $_=$toplines[$i];   s/^ +//g; ($Batnr1a,$Batnr1b,$Bfunctyp) = split(/\s+/,$_); 
  if($i+1<$finishbon) { $_=$toplines[$i+1]; s/^ +//g; ($Batnr2a,$Batnr2b,$Bfunctyp) = split(/\s+/,$_)};
  if($i+2<$finishbon) { $_=$toplines[$i+2]; s/^ +//g; ($Batnr3a,$Batnr3b,$Bfunctyp) = split(/\s+/,$_)}; 
  if($i+3<$finishbon) { $_=$toplines[$i+3]; s/^ +//g; ($Batnr4a,$Batnr4b,$Bfunctyp) = split(/\s+/,$_)}; 
# output
  write (LINE_PSF); 
}

select((select(LINE_PSF), $~ = "LINE_PSF_3")[0]);
write(LINE_PSF);

print "done
last atom read............. $Tatnr $Tattype $Tatname
from residue............... $Tresnr $Tresname\n\n"; 

###
### FORMATS USED
###

# PSF file heading
format LINE_PSF_TOP =
PSF 
       4 !NTITLE
 REMARKS TOPOLOGY CREATED BY PERL SCRIPT (MARC BAADEN)
 REMARKS contact baaden@smplinux.de


@>>>>>>> !NATOM
$totnbat
.

# PSF file atom information
format LINE_PSF = 
##@       1 MAIN@ 1    GLN  N    N      0.260000       1.00800           0
@>>>>>>> MAIN @<<<<@<<<<@<<<<@<<<<@##.########## @##.##########
$Tatnr,$Tresnr,$Tresname,$Tatname,$Tattype,$Tq,$Tm
.	

# PSF file bond data header
format LINE_PSF_2_TOP = 

@>>>>>>> !NBOND: bonds
$totnbbd
.	

# PSF file bond data
format LINE_PSF_2 = 
@>>>>>>>@>>>>>>>@>>>>>>>@>>>>>>>@>>>>>>>@>>>>>>>@>>>>>>>@>>>>>>>
$Batnr1a,$Batnr1b,$Batnr2a,$Batnr2b,$Batnr3a,$Batnr3b,$Batnr4a,$Batnr4b
.	

#we also need to add lines that say no angles and dihedrals and groups because vmd psfgen is annoying like that 
format LINE_PSF_3 = 
0 !NTHETA: angles
0 !NPHI: dihedrals
0 !NIMPHI: impropers
0 !NDON: donors
0 !NACC: acceptors
0 !NNB
.

