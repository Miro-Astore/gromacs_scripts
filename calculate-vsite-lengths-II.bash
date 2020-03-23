#!/bin/bash

#source $HOME/scripts/functions.bash

#Designed to work with GROMACS ffbonded.itp
function grab-bond-angle() {
    awk -v a1=$2 -v a2=$3 -v a3=$4 'BEGIN {
        mode=0
        bond1="" ; bond2="" ; angle=""
    }
    {
        # Skip all-line comments.
        if ( $1 == ";" ) {
            next
        }
        # Bonds
        if ( mode==0 ) {
            # Grab pair 1
            if ( ($1 == a1 && $2 == a2) || ($1 == a2 && $2 == a1) )  {
                bond1=$4
                print "...matching line found: ", $0 > "/dev/stderr"
            }
            #grab pair 2
            if ( ($1 == a2 && $2 == a3) || ($1 == a3 && $2 == a2) ) {
                bond2=$4
                print "...matching line found: ", $0 > "/dev/stderr"
            }
            #both bonds found
            if ( bond1 != "" && bond2 != "" ) {
                mode=1
            } else {
                next
            }
        }
        # Angles
        if (mode == 1 ) {
            # Grab angle
            if ($2 == a2 && ( ($3 == a3 && $1 == a1) || ($1==a3 && $3==a1) ) ) {
                angle=$5
                print "...matching line found: ", $0 > "/dev/stderr"
                exit
            }
        }
    }
    END {
        if ( bond1=="" || bond2 == "" || angle=="" ) {
            print " = = ERROR: at least one of the parameters are missing!" > "/dev/stderr"
            print " = = Bond1:", bond1, "Bond2:", bond2, "Angle:", angle > "/dev/stderr"
        }
        print bond1, bond2, angle
    } ' $1
}

function get-atom-mass () {
    case ${1:0:1} in
        C) echo 12.0107 ;;
        N) echo 14.0067 ;;
        O) echo 15.9994 ;;
        H) echo  1.0079 ;;
        *)
            echo " == ERROR: the atom type does not begin with a C/N/H..." > /dev/stderr
            exit
            ;;
    esac
}

if [[ "$2" == "" ]] ; then
    echo "Edition 2017.
This script will estimate the expected vsite constraint length,
based on geometries found in the reference ffbonded itp file.
For details, see Feenstra, Hess, and Berendsen, J. Comput. Chem. 1999

Give as arguments a trio of atom types that should be converted,
e.g. 'CX N3 H' from the Amber 14sb forcefield.
The itp can be inserted afterwards after the [ bondtypes ] segment.
Usage: ./script <ref-ffbonded.itp> [trio 1] [trio 2]...
e.g. ./script ../charmm36.ff/ffbonded.itp ./lig-bonded.itp ./vsites.itp 'CX N3 H'
The expected output will contain a line of the form MCH3 CTL2 2 0.####
"
    echo "Technically, the script goes through the following trigonometry:
in the following example, we wish to obtain the distance CT2 - MCH3.

     - - - MCH3
   /        |
CT2 - CT3 - CoMass
   \        |
     - - - MCH3

MCH3 - MCH3 is known from the reference forcefield, CoMass bisects this line.
CT2 - CT3 is known from the ligand forcefield.
We can determine CT2 - CoMass either by using the angle and mass parameters of the Hydrogens,
or estimating it from other known entities.

Rather than setting the parameters based on CHARMM-type defaults,
we calculate the expected CT2-CoMass from the CT3--H bonded parameter.
"
    exit
fi

#ccomdist=0.0076796
#ncomdist=0.0061643
bFirst=1
reffile=$1
shift

while [ $# -gt 0 ] ; do
    nargs=$(echo $1 | awk '{print NF}')
    echo "# args: $nargs"

  if [ $nargs == 3 ] ; then
    a1=$(echo $1 | awk '{print $1}')
    a2=$(echo $1 | awk '{print $2}')
    a3=$(echo $1 | awk '{print $3}')
    shift

    if [[ "${a1:0:1}" == "H" ]] ; then
        # Order H-X-X
        tmp=$a1 ; a1=$a3 ; a3=$tmp ; unset tmp
    fi

    #Grab the bond and angle lines from the reference file.
    bonded_vals=$(grab-bond-angle $reffile $a1 $a2 $a3)
    bond1=$(echo $bonded_vals | cut -f1 -d" ")
    bond2=$(echo $bonded_vals | cut -f2 -d" ")
    angle=$(echo $bonded_vals | cut -f3 -d" ")
    pi=3.141592652589
    arad=$(echo " $angle*$pi/180.0" | bc -l )
    #Determine the nature of the -XH3 group, and mass of all atoms
    m2=$(get-atom-mass $a2) ; m3=$(get-atom-mass $a3)

    if [[ ${a2:0:1} == "O" ]] ; then
        echo " = = = Interpreting $a1-$a2-$a3 to be an X-O-H constraint request."
        #This is a hydroxyl constraint.
        echo " = = Term to write: "
        odist=$(= sqrt[$bond1^2+$bond2^2-2.0*$bond1*$bond2*cos[$arad]])
        echo " $a1 $a3 2 $odist"

    else
        echo " = = = Interpreting $a1-$a2-$a3 to be an -XH3 virtual site request."
        #Assume primary -CH3 or -NH3
        dum=M${a2:0:1}H3
        # Now assume Order X-X-H
        # Get MXH3-MXH3 distance, by using moment of inertia of the complete group.
        echo " ...Masses of XH3 group: $m2 $m3"
        mratio=$( echo  "3*$m3/(3*$m3+$m2 )" | bc -l )
        #mmdist=$( echo  "($mratio)^0.5 *s($arad)*$bond2*2.0" | bc -l  )
		echo "test"
        mmdist=$( echo  "$mratio^0.5 *s($arad)" | bc -l  )
		echo "test"
		echo $mmdist
        comdist=$(echo " $mratio*-1*c($arad)*$bond2 " | bc -l )
        cmdist=$( echo "(($bond1+$comdist)^2+($mmdist*0.5)^2)^0.5" | bc -l  )

        echo " ...XH3 mass ratio: $mratio -- MXH3dist: $mmdist -- COM ext.: $comdist -- final constraint length: $cmdist"
        echo " For comparison from reffile: " $(grep "$dum.*$dum" $reffile)
        echo " = = Term to write: "
        echo " $a1 $dum 2 $cmdist"
    fi

  else
    echo "= = ERROR: the input argument is not a pair or a trio of atoms! $1 "
    break
  fi
done

echo "Done"
