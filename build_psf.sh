#not really that useful
x=0
for i in $(ls topol*itp); 
do
perl ~/md/top2psf.pl -p $i -o out$x.psf 
x=$((x + 1))
done 
