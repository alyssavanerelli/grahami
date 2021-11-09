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

will do separately for each illumina read

# split by scaffold
first need to split genome into scaffolds because of memory issues

# pilon
## pilon_loop
making a loop file that will extract chr from fasta file, extract chr from bam file, index bam file, and run pilon for each scaffold in the genome separately

will redirect output to different folders

## run_loop
make file to run the loop with input

# gap_summary_stats
create a file pulling number of gaps filled from slurm output files

convert to csv

download from OnDemand and input into excel

shows how well pilon worked

"Corrected 1996 snps; corrected 58 small insertions totaling 818 bases, 375 small deletions totaling 7991 bases"

total snps:small insertions:small deletions

# create final genome
merge all pilon fasta files into one genome file
