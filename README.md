# Assembling _Anolis grahami_ Reference Genome

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

**rename slurm output files to whichever step of assembly you ran this for (that information is not included in the slurm file)**


# BUSCO
This stands for **B**enchmarking **U**niversal **S**ingle-**C**opy **O**rthologs

**Objectives**
- We use this to assess genome assembly completeness
- We will run this at each step of the clean-up process

**`BUSCO`** is a program that uses a universal (this is relative to what taxonomic level you are looking at) dataset of genes known to be complete and single-copy for the taxonomic level you are interested in.

Gives us the percentage of expected complete and single-copy genes are present in our genome assembly.

We are using the **vertebrate** dataset: `vertebrata_odb10`

## Installing BUSCO and downloading dataset

Install busco using conda
1. Load anaconda from your home directory
   ```
   module load anaconda/2020.07-gc563
   ```
2. Create a new conda environment just for busco
   
   _this step will take a while and will ask some yes/no questions_
   ```
   conda create -n busco -c conda-forge -c bioconda busco=5.2.2
   ```
3. Initialize your environment to run bash
   ```
   conda init bash
   ```
4. Log out of amarel and log back in
5. Check if everything was installed properly
   ```
   conda activate busco
   busco --help
   ```
5. To launch the busco environment in a SLURM script (needed anytime using busco)
   ```
   module purge

   eval "$(conda shell.bash hook)"
   conda activate busco
   ```
6. In the script, you will call a dataset: `vertebrata_odb10` (will be retrieved from online database)
## Running BUSCO
1. Launch busco environment
2. Download any genome file you want to analyze (in fasta format)
3. Submit a job running busco

   example submission script:
   ```
   module purge

   eval "$(conda shell.bash hook)"
   conda activate busco

   busco -i path_to_fasta.fa -c 16 \
   -l vertebrata_odb10 \
   -o output_file_name \
   -m genome
   ```


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

## Directory Setup

- `Pilon`: top directory
  - `chr_split`
    - Directory where sorted scaffold sizes are
    - Also contains broken up scaffold files (used an input for `run_loop.sh`)
    - `fastas`
      - Where individual chr fasta files will be deposited
  - `pilon_out`
    - Where output for pilon run on each scaffold will be deposited
  - `slurm_out`
    - Where slurm output files (containing corrected statistics) will be deposited for each scaffold
  - `pilon_loop.sh`
    - Job script with commands
  - `run_loop.sh`
    - Script that will run `pilon_loop.sh` through each split scaffold sizes file


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
- This file will run `pilon_loop.sh` on each scaffold
- Will need to submit this job for each 500 line scaffold file (and smaller 100 line files)

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

# Calculate Pilon Improvement Statistics
- This code will create a file of base corrections done by `pilon`
- We need to extract this information from the slurm output file

**Steps**
1. Create a file pulling number of gaps filled/bases corrected from slurm output files for each scaffold
2. Convert this file to `.csv`
3. Download file through OnDemand and open in excel
4. Summarize SNPs, small insertions, and small deletions corrected

_this code can be ran from the command line_


<details><summary>Code</summary>
<p>
  
  ```
  s### pull certain lines from text file and add to a text file ###

grep "Corrected" slurm-*-pilonloop.out | cut -f 2,5,11 -d " " > summary_data

  #2,5,11 refers to "column" with numbers - columns are separated by spaces in document
  
  
### convert file to csv

sed 's/ \+/,/g' summary_data > summary_data.csv

### download from OnDemand and export into excel to get summary of gaps filled
  ```

</p>
</details>



<details><summary>Output Format</summary>
<p>
  
  ```
  "Corrected 1996 snps; corrected 58 small insertions totaling 818 bases, 375 small deletions totaling 7991 bases"

  total snps:small insertions:small deletions
  ```

</p>
</details>



# Creat Final Genome File
We next need to merge all of our separate pilon fasta files into one

_run this from the command line_

<details><summary>Code</summary>
<p>
  
  ```
  ## cd into pilon_out

  cat * > grahami.fa
  ```

</p>
</details>

# Sort and Rename Scaffolds
Sort genome scaffolds by size and name accordingly

<details><summary>Sort and Rename</summary>
<p>
  
  ```
  species=$1

echo "Bash commands for the analysis you are going to run"
echo ""
echo "##### sort by size and rename sequence"
sortbyname.sh -Xmx4g in=${species}.fa out=${species}_sorted.fa length descending

# add dummy to beginning
printf ">dummy\nNNN\n" | cat - ${species}_sorted.fa > temp && mv temp ${species}_sorted.fa


#rename
rename.sh in=${species}_sorted.fa out=${species}_sorted_renamed.fa prefix=scaffold -Xmx10g fastawrap=500000000

# remove single sequence entry from multifasta
cat ${species}_sorted_renamed.fa | awk '{if (substr($0,1) == ">scaffold_0") censor=1; else if (substr($0,1,1) == ">") censor=0; if (censor==0) print $0}' > ${species}_fixed.fasta

rm ${species}_sorted.fa
rm ${species}_sorted_renamed.fa

  ```

</p>
</details>

**To run this file**
```
sbatch sort_rename.sh grahami.fa
```

# Final BUSCO run
Follow instructions above to run BUSCO on this final genome assembly

# Final Stats Calc
Follow instructions above to run stats on this final genome assembly

# Next Steps: Go to Maker folder then analyses folder

- Annotate genome with **`MAKER`**
- Use **`busco_phylogenomics`** to make phylogeny 
- Chromosome synteny analysis using **`satsuma`**
- Create hic file using **`juicer`** to make sure genome is assembled correctly
- Create **busco scores figure**
