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
- Program is used to allign illumina short reads to current genome assembly
- Do this separately for each illumina paired-end read
- This will create a `.bam` file
- If a run failed, temporary `.bam` files need to be deleted to re-run.

<details><summary>EXAMPLE</summary>
<p>
  
  ```
  echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load samtools                            # load any modules needed
module load bwa

echo "Bash commands for the analysis you are going to run"

echo "index and align with BWA"
bwa index /projects/f_geneva_1/alyssa/grahami/sealer/run2_scaffold.fa

bwa mem -t 10 /projects/f_geneva_1/alyssa/grahami/sealer/run2_scaffold.fa \
/projects/f_geneva_1/alyssa/grahami/DTG-SG-150_filtered.R1.fq \
/projects/f_geneva_1/alyssa/grahami/DTG-SG-150_filtered.R2.fq \
| samtools sort -@10 -o /projects/f_geneva_1/alyssa/grahami/pilon/150/150_bwa_aligned.bam -
  ```


</p>
</details>



# Pilon
**`Pilon`** is a base call polishing program that improves our assembly further

## Split by Scaffold
Before running `pilon`, the genome needs to be split into scaffolds because of memory issues

<details><summary>Get Scaffold Sizes</summary>
<p>
  
  ```
  echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load java
module load samtools

echo "Bash commands for the analysis you are going to run"
samtools faidx /projects/f_geneva_1/alyssa/grahami/pilon/chr_split/run2_scaffold.fa
 cut -f1-2 /projects/f_geneva_1/alyssa/grahami/pilon/chr_split/run2_scaffold.fa.fai > scaffold_sizes.txt
  ```

</p>
</details>


<details><summary>Sort By Size</summary>
<p>
  
  ```
  cut -f2 scaffold_sizes.txt | sort -n > scaffold_sizes_sort.txt
  ```


</p>
</details>


<details><summary>Split into files with 500 lines each</summary>
<p>
  
  ```
  split -l 500 scaffold_sizes_sort.txt scaffolds_
  ```


</p>
</details>

_The largest scaffolds were then broken down further into smaller files with 100 lines each to make sure we did not run into memory issues_

## pilon_loop
In this step, we are creating a file that will extract each chr from the fasta file, extract each chr from the bam file, index this bam file, and run pilon for each scaffold in the genome assembly separately.
- output will redirect into separate folders


<details><summary>Pilon Loop</summary>
<p>
  
  ```
  echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load java
module load samtools

CHRNAME=$1

echo "####### extract chr from fasta file"
samtools faidx /projects/f_geneva_1/alyssa/grahami/pilon/chr_split/run2_scaffold.fa "${CHRNAME}" > /projects/f_geneva_1/alyssa/grahami/pilon/chr_split/fastas/${CHRNAME}_ONLY.fa


echo ""
echo "####### extract chr from bam file"
samtools view -b /projects/f_geneva_1/alyssa/grahami/pilon/149_bwa_aligned.bam "${CHRNAME}" > /projects/f_geneva_1/alyssa/grahami/pilon/temp_bam/${CHRNAME}_only_149.bam
samtools view -b /projects/f_geneva_1/alyssa/grahami/pilon/150_bwa_aligned.bam "${CHRNAME}" > /projects/f_geneva_1/alyssa/grahami/pilon/temp_bam/${CHRNAME}_only_150.bam


echo ""
echo "####### run pilon"
echo ""
echo "################### index with samtools"
samtools index -b /projects/f_geneva_1/alyssa/grahami/pilon/temp_bam/${CHRNAME}_only_149.bam
samtools index -b /projects/f_geneva_1/alyssa/grahami/pilon/temp_bam/${CHRNAME}_only_150.bam

echo ""
echo "################### run pilon"
java -Xmx170G -jar ~/bin/pilon-1.24.jar \
--genome /projects/f_geneva_1/alyssa/grahami/pilon/chr_split/fastas/${CHRNAME}_ONLY.fa \
--bam /projects/f_geneva_1/alyssa/grahami/pilon/temp_bam/${CHRNAME}_only_149.bam \
--bam /projects/f_geneva_1/alyssa/grahami/pilon/temp_bam/${CHRNAME}_only_150.bam \
--output /projects/f_geneva_1/alyssa/grahami/pilon/pilon_out/run2_pilon_${CHRNAME} --diploid
  ```

</p>
</details>

_to run this loop on just one file, run `sbatch pilon_loop.sh "[scaffold name]"`_

## run the pilon loop
This file will run `pilon_loop.sh` on each scaffold

<details><summary>run_loop.sh</summary>
<p>
  
  ```
  #!/bin/bash
LINES=$(cut -f 1 /projects/f_geneva_1/alyssa/grahami/pilon/chr_split/[split scaffold file])
for LINE in $LINES
do
  sbatch pilon_loop.sh "$LINE"
  sleep 0.25
done


### sleep line will delay job submission so all jobs will not be submitted at once ###
  ```

</p>
</details>

***To run this job***
```
chmod 755 run_loop.sh
./run_loop
```

# gap_summary_stats
create a file pulling number of gaps filled from slurm output files

convert to csv

download from OnDemand and input into excel

shows how well pilon worked

"Corrected 1996 snps; corrected 58 small insertions totaling 818 bases, 375 small deletions totaling 7991 bases"

total snps:small insertions:small deletions


<details><summary>Split into files with 500 lines each</summary>
<p>
  
  ```
  split -l 500 scaffold_sizes_sort.txt scaffolds_
  ```


</p>
</details>



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
