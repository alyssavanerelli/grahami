# software and data needed
## software
1. [RepeatModeler](http://www.repeatmasker.org/RepeatModeler/) and [RepeatMasker](http://www.repeatmasker.org/RMDownload.html) with all dependencies and [RepBase](https://www.girinst.org/repbase/)
2. MAKER MPI 
3. [Augustus](http://bioinf.uni-greifswald.de/augustus/)
4. BUSCO
5. [SNAP](http://korflab.ucdavis.edu/software.html)
6. [BEDtools](https://bedtools.readthedocs.io/en/latest/)

## data/resources
1. assembled reference genome, in fasta format
2. protein sequences from related species, in fasta format
 

# make control files
```
module load singularity

srun -p p_ccib_1 singularity exec /projects/f_geneva_1/programs/maker:2.31.11-repbase.sif maker -CTL
```

run interactive job on login node

will crease 3 files. only required to modify maker_opts.ctl

do not modify maker_exe.ctl

**will modify this control file each run - _make new file each time_**

# round 1
## modify control file
input genome, protein homology evidence, repeat masker model org (_Anolis carolinensis?_)

**how to find repeat masker model organism**

go to code

use `FamDB` to search database for transposable element and repetitive DNA families.

commands are:
```
pip3 install --user h5py
wget https://raw.githubusercontent.com/Dfam-consortium/FamDB/master/famdb.py
famdb.py -i dfam.h5 names Anolis
```





# round 2
