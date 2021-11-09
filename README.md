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
