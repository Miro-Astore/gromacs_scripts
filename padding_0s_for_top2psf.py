#! /home/miro/miniconda/bin/python
import sys 
filename=sys.argv[1]
atom_num=int(sys.argv[2])
f=open(filename,'a+')

curr_num=1
padding_count=1
padding_limit=8
for i in range(atom_num):
    if (padding_count == padding_limit):
        f.write ('      0\n')     
        padding_count=1
    else:
        f.write ('      0')     
        padding_count=padding_count+1
f.close()

