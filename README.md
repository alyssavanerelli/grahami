# Assmebling _Anolis grahami_ Reference Genome

Code associated with grahami reference genome project.

Example code will be pasted below. For more information (slurm submission header) go to associated `.sh` file

# FastQC and Trimmomatic

**`FastQC`** is a quality control check. We run this before and after using `trimmomatic`. 

**`Trimmomatic`** is the program that filters and trims low quality reads from our raw reads

- Quality filter our reads
- Files need to be unzipped for this
- This needs to be done on each Illumina read file
  - Will submit a separate job for each read pair

<details><summary>EXAMPLE</summary>
<p>
  
  ```
  echo "load any Amarel modules that script requires"
  module purge                                    # clears out any pre-existing modules
  module load java                                # load any modules needed
  module load FastQC

  echo "Bash commands for the analysis you are going to run"

  readset="/projects/f_geneva_1/alyssa/grahami/DTG-SG-149"

  echo "fastqc initial quality analysis"
  fastqc -t 20 \
  ${readset}_R1_001.fastq \
  ${readset}_R2_001.fastq \
  -o /projects/f_geneva_1/alyssa/grahami/fastqc
  
  echo ""
  echo "trimmomatic"
  java -jar /projects/ccib/geneva/programs/trimmomatic/trimmomatic-0.39.jar PE \
  -threads 20 -phred33 -trimlog ${readset}_trim.log \
  ${readset}_R1_001.fastq ${readset}_R2_001.fastq \
  ${readset}_filtered.R1.fq ${readset}_filtered.unpaired.R1.fq \
  ${readset}_filtered.R2.fq ${readset}_filtered.unpaired.R2.fq \
  ILLUMINACLIP:/projects/ccib/geneva/programs/trimmomatic/adapters/TruSeq3-PE-2.fa:2:30:10:4 \
  LEADING:20 TRAILING:20 SLIDINGWINDOW:13:20 MINLEN:23
  
  echo ""
  echo "fastqc trimmomatic quality analysis"
  fastqc -t 20 \
  ${readset}_filtered.R1.fq \
  ${readset}_filtered.R2.fq \
  -o /projects/f_geneva_1/alyssa/grahami/fastqc
  ```

</p>
</details>

  
# sealer

Uses [abyss sealer](https://github.com/bcgsc/abyss/tree/master/Sealer) program

- Gap filling
- Uses illumina short reads to fill gaps in the current reference genome assembly
- run this through a few iterations using the previous run output as input for the next round
- used similar settings to the _sagrei_ reference genome

**usage**
```
abyss-sealer -b <Bloom filter size> -k <kmer size> -k <kmer size>... -o <output_prefix> -S <path to scaffold file> [options]... <reads1> [reads2]...
```

detailed list of options can be found [here](https://github.com/bcgsc/abyss/tree/master/Sealer#options)

**bloom filters**
- explanation

<details><summary>EXAMPLE</summary>
<p>
  
  ```
  echo "load any Amarel modules that script requires"
  module purge                                    # clears out any pre-existing modules
  module load boost                               # load any modules needed
  

  echo "Bash commands for the analysis you are going to run"
  reads="/projects/f_geneva_1/alyssa/grahami/DTG-SG-"
  longreads="/projects/f_geneva_1/alyssa/grahami/DTG_SG_65_S1"

  abyss-sealer -b150G -v -j32 -s170G -k96 -k80 -P 50 -o run2 -B5000 \
  -S /projects/f_geneva_1/alyssa/grahami/sealer/run2_scaffold.fa \
  ${reads}149_filtered.R1.fq \
  ${reads}149_filtered.R2.fq \
  ${reads}150_filtered.R1.fq \
  ${reads}150_filtered.R2.fq \
  ${longreads}_filtered.R1.fq \
  ${longreads}_filtered.R2.fq
  ```
  
</p>
</details>

# Stats

This program will calculate scaffold length, N50, % gaps, etc.

- calculate statistics for each step of the process
  - Illumina, Chicago, HiC, sealer_run1, sealer_run2, pilon
- find statistic results in the slurm output file
  - will be beneficial to rename the output file


<details><summary>EXAMPLE</summary>
<p>
  
  ```
  echo "load any Amarel modules that script requires"
  module purge                                    # clears out any pre-existing modules
  module load java                                # load any modules needed


  echo "Bash commands for the analysis you are going to run"
  stats.sh in=/projects/f_geneva_1/alyssa/grahami/sealer/run1_scaffold.fa
  ```
  
</p>
</details>



# BUSCO
This stands for **B**enchmarking **S**ingle-**C**opy **O**rthologs

**Objectives**
- We use this to assess genome assembly completeness
- We will run this at each step of the clean-up process

**`BUSCO`** is a program that uses a universal (this is relative to what taxonomic level you are looking at) dataset of genes known to be complete and single-copy for the taxonomic level you are interested in.

Gives us the percentage of expected complete and single-copy genes are present in our genome assembly.

We are using the **vertebrate** dataset: `vertebrata_odb10`

## Installing BUSCO and downloading dataset

I cannot remember how to do this

## Running BUSCO

1. Create a busco conda environment


# bwa
align illumina reads to current genome with bwa

creates bam file

will do separately for each illumina read

tmp bam files cannot already exist (if a run failed)

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

# sort and rename
sort genome file by size and rename into chromosomes

# final busco
run busco again to track improvements

# final stats
run stats again


# Annotation
labeling the genome

## maker
