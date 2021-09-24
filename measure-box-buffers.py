
import MDAnalysis as mda
import numpy as np
from MDAnalysis.lib.mdamath import make_whole
from MDAnalysis.analysis.distances import self_distance_array
import sys

def calc_fragment_dimensions(listFragments):
    x=None
    for frag in listFragments:
        if x is None:
            x = make_whole(frag)
        else:
            x = np.append(x, make_whole(frag), axis=0 )
    return x.max(axis=0) - x.min(axis=0)
    #return np.max( self_distance_array( x ) )

fileTOP='./seg.psf'
fileTRJ='./sum.xtc'
#textSel='protein'
textSelection="protein and not name MN? 1MN? 2MN? 1MC? 2MC?"

u = mda.Universe(fileTOP,fileTRJ)
print("...Molecule loaded.",file=sys.stderr)
a = u.select_atoms(textSelection)
listFrags = a.fragments
print("...%i bonded fragments identified." % ( len(listFrags) ), file=sys.stderr)

if len(listFrags)>10:
    print('= = ERROR: More than ten discrete protein framgents detected. Something is wrong?',file=sys.stderr)
    sys.exit()

# = = = Only for rectangular boxes at present.

print("# Frame BufferXYZ")
u.trajectory[0]
DMaxBox=u.dimensions[0:3]
DMaxMol=calc_fragment_dimensions(listFrags)
runningMin = np.min(DMaxBox-DMaxMol)
for f in range(u.trajectory.n_frames):
    u.trajectory[f]
    #DMaxBox=np.min(u.dimensions[0:2])
    DMaxBox=u.dimensions[0:3]
    DMaxMol=calc_fragment_dimensions(listFrags)
    np.min(DMaxBox-DMaxMol)

    temp_min = np.min(DMaxBox-DMaxMol)
print(f, temp_min)
