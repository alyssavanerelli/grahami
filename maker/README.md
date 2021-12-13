# software and data needed
## software
1. [RepeatModeler](http://www.repeatmasker.org/RepeatModeler/) and [RepeatMasker](http://www.repeatmasker.org/RMDownload.html) with all dependencies and [RepBase](https://www.girinst.org/repbase/)
2. MAKER MPI 
3. [Augustus](http://bioinf.uni-greifswald.de/augustus/)
4. BUSCO
5. [SNAP](http://korflab.ucdavis.edu/software.html)
6. [BEDtools](https://bedtools.readthedocs.io/en/latest/)

_maker, RepeatModeler, and RepeatMasker are included with singularity that is already installed_

## data/resources
1. assembled reference genome, in fasta format
2. protein sequences from related species, in fasta format


# make control files
```
module load singularity

srun -p p_ccib_1 singularity exec /projects/f_geneva_1/programs/maker:2.31.11-repbase.sif maker -CTL
```

this will create 3 files
1. **maker_bopts.ctl**
2. **maker_exe.ctl**
3. **maker_opts.ctl**

we are only required to modify maker_opts.ctl

do not modify maker_exe.ctl

**will modify this control file each run - _make new file each time_**

# round 1
## modify control file
input genome, protein homology evidence, repeat masker model org (_Anolis carolinensis_)

**how to find repeat masker model organism**

launch `singularity` and search for species name. more detail in code

## make .sh files to run maker

**`r1maker_sub.sh`**
- This script will submit maker using the protein homology sequences to annotate the genome
- This is the first script to be submitted
- Used 2 whole cores to run this 

**`r1maker_gff.sh`**
- This script will create gff files to be used in `r1maker_aug.sh` and `r1maker_bsh.sh`
- This is the second script to be submitted after `r1maker_sub.sh` finishes
- After this finishes, the remaining scripts can be submitted

**`r1maker_aug.sh`**
- Can be run after `r1maker_gff.sh` finishes because it uses some files created here as input




run after bsh

Augustus configuration

This will train Augustus gene models through BUSCO using the vertebrata_odb10 dataset

```
#path to vertebrata_odb10
/projects/f_geneva_1/alyssa/grahami/busco
```

busco -i /projects/f_geneva_1/alyssa/grahami/anolis_cristatellu_20Oct2018_jSags.fasta -c 16 -l vertebrata_odb10 -o HiC_2 -m genome


**`r1maker_bsh.sh`**


**`r1maker_trans_aug.sh`**

Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database

## Important Info
- After round 1 of maker has completed, copy the original control file: `maker_opts.ctl` to `maker_opts_r1.ctl`
- Now for the next round, just modify the original `maker_opts.ctl` file
- The `maker_exe.ctl` and `maker_bopts.ctl` can remain the unmodified

# round 2
This round will not due the annotation via protein homology because this was completed in the first round and does not need to be done again.

This will train the programs to better recognize new _grahami_ genes

**1. modify control file**

little description

**2. submit `r2maker_sub.sh`**

blah





