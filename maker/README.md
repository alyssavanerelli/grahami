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
run interactive job on login node

will crease 4 files. only required to modify maker_opts.ctl

do not modify maker_exe.ctl

_optionally_ modify maker_evm.ctl and maker_bopts.ctl

**will modify this control file each run _make new file each time_**

# round 1
## modify control file
input genome, protein homology evidence

/projects/f_geneva_1/alyssa/grahami/annotation/AnoCar2.0_protein_GCF_000090745.1.faa
/projects/f_geneva_1/alyssa/grahami/annotation/PogVit1.1_protein_GCF_900067755.1.faa
/projects/f_geneva_1/alyssa/grahami/annotation/Shinisaurus_crocodilurus_gene.pep
/projects/f_geneva_1/alyssa/grahami/annotation/[sagrei]
