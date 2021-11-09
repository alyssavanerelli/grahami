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

# bwa
align illumina reads to current genome with bwa

creates bam file

# split by scaffold
first need to split genome into scaffolds because of memory issues

# pilon loop
making a loop file that will extract chr from fasta file, extract chr from bam file, index bam file, and run pilon for each scaffold in the genome separately
