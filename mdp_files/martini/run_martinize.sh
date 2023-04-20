#conda activate martinize
martinize2 -f snap_martini_ready.pdb -x thyroglobulin_cg.pdb -o topol.top -ff martini3001 -ss  $(cat ss.txt) -elastic
