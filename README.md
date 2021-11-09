# grahami
code associated with grahami ref genome project

# fastqc
quality filtering reads

do this for each illumina read file
  
# sealer
use illumina short reads to fill in gaps in the current reference genome 

used illumina reads to fill in gaps in the HiC alignment

do this a few times using the new genome (with gaps filled) as input for the next run

# stats
calculate statistics for each step of the process

illumina reads, chicago, HiC, run1_sealer, run2_sealer

will calculate: scaffold length, N50, % gaps, etc.

# busco
need to create and activate a conda environment first

evaluating the completeness of the genome at each step

checks how many conserved vertebrate genes show up in our genomes

need to download the vertebrata genes - cannot remember how to do this ?

# pilon
## split
first need to split genome into scaffolds because of memory issues

split file into
