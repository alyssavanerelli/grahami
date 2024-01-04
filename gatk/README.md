# GATK

# FastQC, trimmomatic, and bwa on all illumina reads 
**`FastQC`** is a quality control check. We run this before and after using `trimmomatic`. 

**`Trimmomatic`** is the program that filters and trims low quality reads from our raw reads

- Quality filter our reads
- This needs to be done on each Illumina read file
  - Will submit a separate job for each read pair

## FASTQC, trimmomatic, and bwa loop
- for each fastq file (paired)
- each individual was sequenced multiple times
- this script will run fastqc, trim the reads, then align them to the reference genome
  - **bam output files will be in the same directory as raw files (unless you specify otherwise in your code)**
- all files need to be indexed as well, which is written into this code



[trim_bwa.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/trim_bwa.sh)

[run_trim_bwa.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/run_trim_bwa.sh)

**my reads were already filtered so all I needed to run was bwa**

[bwa.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/bwa.sh)

---

# Calculate depth and breadth stats
 - output is in slurm output file
 - **mean read depth**
   - `s.c` (s:the cumulative depth across all positions // c:the total number of positions)
   - mean read depth is `s/c`
 - **breadth of coverage**
   - c:the total number of positions
   - total:which receives an increment of 1 when the depth is greater than 0
   - breadth of coverage is `(total/c)*100`

[stats_d_b.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/stats_d_b.sh)

[run_stats.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/run_stats.sh)

---

# Calling variants using GATK

## Resources
- [whole-genome reseq for pop genomics](https://informatics.fas.harvard.edu/whole-genome-resquencing-for-population-genomics-fastq-to-vcf.html)
- [Germline short variant discovery (SNPs + Indels)](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-)
- [GATK best practices for non-model organisms](https://evodify.com/gatk-in-non-model-organism/)
- [GATK tutorial](https://hpc.nih.gov/training/gatk_tutorial/workflow-overview.html)
- [Calc mapping stats](https://sarahpenir.github.io/bioinformatics/awk/calculating-mapping-stats-from-a-bam-file-using-samtools-and-awk/)
- OARC tutorial
  - run this script to copy all materials over 
    ```
    /projects/oarc/users/training/Genomics_Workshop/Variant_analysis/lab.sh
    ```

## GATK Overview
- **G**enome **A**nalysis **T**ool**k**it
- Genotype calling in high-throughput sequencing data
- Resource: [Github page for _Bradypodion_ by Jody Taft](https://github.com/lizardroom/Bradypodion-Pop.Gen)

**Steps:**
- [ ] [AddOrReplaceReadGroups](https://github.com/alyssavanerelli/grahami/blob/main/gatk#add-or-replace-read-groups) (10-15 minutes)
- [ ] [MarkDuplicates](https://github.com/alyssavanerelli/grahami/blob/main/gatk#mark-duplicates) (60 minutes)
- [ ] [Index and Dictionary](https://github.com/alyssavanerelli/grahami/blob/main/gatk#index-and-dictionary) (5 minutes)
- [ ] [HaplotypeCaller](https://github.com/alyssavanerelli/grahami/blob/main/gatk#haplotype-caller) (3-14 days)
- [ ] [CombineGVCFs](https://github.com/alyssavanerelli/grahami/blob/main/gatk#combine-gcvfs) (~5 hrs)
- [ ] [GenotypeGVCFs](https://github.com/alyssavanerelli/grahami/blob/main/gatk#genotype-gcvfs) (~2 days)
- [ ] [SelectVariants](https://github.com/alyssavanerelli/grahami/blob/main/gatk#select-variants) (~2 hrs)
- [ ] [VariantsToTable](https://github.com/alyssavanerelli/grahami/blob/main/gatk#variant-to-table) (~1 hr)
- [ ] [VariantFiltration GATK](https://github.com/alyssavanerelli/grahami/blob/main/gatk#filter-snps-and-invariant-sites---gatk)
- [ ] [VariantFiltration vcftools](https://github.com/alyssavanerelli/grahami/blob/main/gatk#filter-snps-and-invariant-sites---vcftools)

---

## Add or replace read groups
- Makes bam format compatible with GATK
- **ID** = Read group identifier - each read group's ID must be unique
- **LB** = DNA preparation library identifier
- **PL** = Platform/technology used to sequence the read
- **PU** = Platform unit
  - This has three types of information: {FLOWCELL_BARCODE}.{LANE}.{SAMPLE_BARCODE}
- **SM** = Sample ID

[add_replace.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/add_replace.sh)

[run_add_replace](https://github.com/alyssavanerelli/grahami/blob/main/gatk/run_add_replace.sh)

---
## Mark Duplicates
- Duplicates are marked, but not removed.
  - Mask duplicated genomic regions and ignore these regions for downstream analyses.
  - This matters because we are using depth to decide if we think the SNP is real
- We will also be combining lanes here if you have multiple lanes per individual
  - This step is very important
  - If not done, each lane will be treated as a different individual which we do not want

[mark_dup.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/mark_dup.sh)

[run_mark_dup.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/run_mark_dup.sh)


<details><summary>make text files with names to submit</summary>
<p>
	
	```
	# text file for samples ran on 4 lanes
	ls -1 /projects/f_geneva_1/alyssa/sagrei/bam/*.bam | cut -d "/" -f 7 | cut -d "_" -f 3 | cut -d "." -f 2 | sort | uniq > all_names.txt 
	grep "Alut" all_names.txt > temp_alut.txt
	grep "Anel" all_names.txt > temp_anel.txt
	grep "Asord" all_names.txt > temp_asord.txt 
	cat temp_alut.txt temp_anel.txt temp_asord.txt > 4_lanes.txt
	
	# text file for samples ran on 2 lanes
	grep "Aoph" all_names.txt > temp_aoph.txt
	grep "Asag" all_names.txt > temp_asag.txt
	grep "Asmay" all_names.txt > temp_asmay.txt
	cat temp_aoph.txt temp_asag.txt temp_asmay.txt > 2_lanes.txt
	```

</p>
</details>


---

## Index and Dictionary
- Create a dictionary file for the reference fasta
- this `.dict` file will not be called with HaplotypeCaller but needs to be in the same directory as the `.fa` file
- `.fai` indexed fasta file will need to be in this same directory as well


[fasta_dict.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/fasta_dict.sh)

---

## Haplotype Caller
- **ALL SITES MODE**
- bam files after mark duplicates need to be indexed before running this step (`--CREATE_INDEX true` flag in MarkDuplicates should have created an indexed file

[hap_call.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/hap_call.sh)


```
I did not run HC in the correct mode at first, which led to a problem downstream of not retaining my invariant sites.
The invariant sites file was quite literally empty and had no sites in it. There is a different mode that HC should be
run in (BP_RESOLUTION), as well as the flag -EMIT-ALL-CONFIDENT-SITES, which makes sure that every site is put into
the file. Elsewise, the homozygous regions get put into the header and then they get lost during the combineGVCF step.
This is because GATK is typically used for population genomics, to find the SNP and indel sites so it doesn't really
matter about the invariant sites.
```

[run_hap_call.sh](https://github.com/alyssavanerelli/grahami/blob/main/gatk/run_hap_call.sh)


<details><summary>splitting up</summary>
<p>
  
- This step can also be run quicker if needed by splitting up the bam file into segments
- The code below is splitting the genome roughly in 3 (which scaffolds will depend on the L50 and L90 of the genome)
- You will need to make `.list` files containing the names of the scaffolds you either want to include or exclude
- For my runs:
  - 1 includes scaffolds 1 and 2
  - 2 includes scaffolds 3-5
  - 3 excludes scaffolds 1-5 (does the rest of the genome)


**example scaffold.list file**
```
scaffold_1
scaffold_2
scaffold_3
scaffold_4
```

<details><summary>1_hap_call_split.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=gatk_HC_split_1
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/haplotype_caller/split/slurmout/slurm-%j-%x.out
	#SBATCH --mem=50G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=6-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759
	module load samtools


	echo ""
	echo "load variables"
	SAMPLE=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/mark_duplicates"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUTDIR="/projects/f_geneva_1/alyssa/sagrei/haplotype_caller/split/thirds"
	SCRATCH_DIR="/scratch/av795"


	echo ""
	echo "run haplotype caller"
	gatk --java-options "-Xms50G -Xmx50g -XX:ParallelGCThreads=2" HaplotypeCaller --native-pair-hmm-threads 2 \
	-I ${INDIR}/${SAMPLE}.marked.bam \
	-O ${OUTDIR}/${SAMPLE}.1.g.vcf.gz \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-ERC GVCF \
	--max-reads-per-alignment-start 0 \
	-RF NotDuplicateReadFilter \
	-L ${GEN_DIR}/scaffolds_1.list


	#--exclude=halc068
	#--exclude=gpuc001,gpuc002


	echo ""
	echo "done"
	```

</p>
</details>

<details><summary>2_hap_call_split.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=gatk_HC_split_2
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/haplotype_caller/split/slurmout/slurm-%j-%x.out
	#SBATCH --mem=50G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=6-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759
	module load samtools


	echo ""
	echo "load variables"
	SAMPLE=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/mark_duplicates"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUTDIR="/projects/f_geneva_1/alyssa/sagrei/haplotype_caller/split/thirds"
	SCRATCH_DIR="/scratch/av795"


	echo ""
	echo "run haplotype caller"
	gatk --java-options "-Xms50G -Xmx50g -XX:ParallelGCThreads=2" HaplotypeCaller --native-pair-hmm-threads 2 \
	-I ${INDIR}/${SAMPLE}.marked.bam \
	-O ${OUTDIR}/${SAMPLE}.2.g.vcf.gz \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-ERC GVCF \
	--max-reads-per-alignment-start 0 \
	-RF NotDuplicateReadFilter \
	-L ${GEN_DIR}/scaffolds_2.list


	#--exclude=halc068
	#--exclude=gpuc001,gpuc002


	echo ""
	echo "done"
	```

</p>
</details>

<details><summary>3_hap_call_split.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=gatk_HC_split_3
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/haplotype_caller/split/slurmout/slurm-%j-%x.out
	#SBATCH --mem=50G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=6-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759
	module load samtools


	echo ""
	echo "load variables"
	SAMPLE=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/mark_duplicates"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUTDIR="/projects/f_geneva_1/alyssa/sagrei/haplotype_caller/split/thirds"
	SCRATCH_DIR="/scratch/av795"


	echo ""
	echo "run haplotype caller"
	gatk --java-options "-Xms50G -Xmx50g -XX:ParallelGCThreads=2" HaplotypeCaller --native-pair-hmm-threads 2 \
	-I ${INDIR}/${SAMPLE}.marked.bam \
	-O ${OUTDIR}/${SAMPLE}.3.g.vcf.gz \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-ERC GVCF \
	--max-reads-per-alignment-start 0 \
	-RF NotDuplicateReadFilter \
	-XL ${GEN_DIR}/scaffolds_exclude.list


	#--exclude=halc068
	#--exclude=gpuc001,gpuc002


	echo ""
	echo "done"
	```

</p>
</details>

- For running these jobs, I created a script to submit all three jobs for one sample back to back
- I submitted certain jobs to different partitions so I created a txt file with sample names to be submitted here

<details><summary>run_hap_call_split.sh </summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(cut -f 1 /projects/f_geneva_1/alyssa/sagrei/names_hap_ccib.txt | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD1="sbatch 1_hap_call_split.sh ${SAMPLE}"
		CMD2="sbatch 2_hap_call_split.sh ${SAMPLE}"
		CMD3="sbatch 3_hap_call_split.sh ${SAMPLE}"
		echo $CMD1
		#eval $CMD1
		sleep 0.25
		echo $CMD2
		#eval $CMD2
		sleep 0.25
		echo $CMD3
		#eval $CMD3
		sleep 0.25
	done
	```

</p>
</details>

</p>
</details>

---

## Combine gCVFs
- In this step we will be combining all the vcf files for our populations (Anel, Alut, and Asord)
- For the groups that only have one sample, we will need to copy these files (and their index) over to this directory
  - I also renamed them to fit with the naming convention of the other samples so I would only have to submit one batch script

1. Create list file for each population

<details><summary>create list files</summary>
<p>
	
	```
	cd /projects/f_geneva_1/alyssa/sagrei
	
	# Anolis leuteosignifer
	find /projects/f_geneva_1/alyssa/sagrei/haplotype_caller -type f -name "Alut*.vcf.gz" > /projects/f_geneva_1/alyssa/sagrei/combine_gvcf/lists/Alut.list
	
	# Anolis nelsoni
	find /projects/f_geneva_1/alyssa/sagrei/haplotype_caller -type f -name "*Anel*.vcf.gz" > /projects/f_geneva_1/alyssa/sagrei/combine_gvcf/lists/Anel.list
	
	# Anolis s. ordinatus
	find /projects/f_geneva_1/alyssa/sagrei/haplotype_caller -type f -name "*Asord*.vcf.gz" > /projects/f_geneva_1/alyssa/sagrei/combine_gvcf/lists/Asord.list
	```

</p>
</details>

2. Run Combine GVCF for each population
- We are combining all of the vcf files made in haplotype caller into one per cohort/population
- Each cohort will have a combined vcf file
- For this step, we need to have a `.list` file that contains the names (and paths) of all the files for a cohort
  - Each cohort will have its own `.list` file
- We only need to do this for the samples in populations (_nelsoni_, _luteosignifer_, and _ordinatus_)

<details><summary>combine_gvcf.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --constraint=oarc
	#SBATCH --job-name=combine
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/combine_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=20G
	#SBATCH -n 5
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759


	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/haplotype_caller"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	LIST_DIR="/projects/f_geneva_1/alyssa/sagrei/combine_gvcf/lists"
	OUTDIR="/projects/f_geneva_1/alyssa/sagrei/combine_gvcf"

	echo "${COHORT}"

	echo ""
	echo "combine gVCFs"
	gatk \
	--java-options "-Xms15G -Xmx15g -XX:ParallelGCThreads=5" \
	CombineGVCFs \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	--variant ${LIST_DIR}/${COHORT}.list \
	-O ${OUTDIR}/${COHORT}_cohort.g.vcf.gz

	
	echo ""
	echo "index gVCF file"
	gatk \
	IndexFeatureFile \
	-I ${OUTDIR}/${COHORT}_cohort.g.vcf.gz


	echo ""
	echo "done"
	```

</p>
</details>

<details><summary>run_combine_gvcf.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/combine_gvcf/lists/*.list | cut -d "/" -f 8 | cut -d "." -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch combine_gvcf.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>

3. Copy over files for the samples not in populations
- We need to copy over the vcf and tbi files from haplotype caller


<details><summary>copy_index.sh</summary>
<p>
	
	```
	cp haplotype_caller/Asag* combine_gvcf/
	cp haplotype_caller/Asmay* combine_gvcf/
	
	mv Asag.g.vcf.gz Asag_cohort.g.vcf.gz
	mv Asag.g.vcf.gz.tbi Asag_cohort.g.vcf.gz.tbi
	
	mv Asmay.g.vcf.gz Asmay_cohort.g.vcf.gz
	mv Asmay.g.vcf.gz.tbi Asmay_cohort.g.vcf.gz.tbi
	```

</p>
</details>

---

## Genotype gCVFs
- Perform joint genotyping on one or more samples

<details><summary>genotype_gvcf.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=genotype
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=100G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=5-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759


	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/combine_gvcf"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUTDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"

	echo "${COHORT}"

	echo ""
	echo "genotype gVCFs"
	gatk --java-options "-Xmx100g" GenotypeGVCFs \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${INDIR}/${COHORT}_cohort.g.vcf.gz \
	-O ${OUTDIR}/${COHORT}_cohort.genotype.g.vcf.gz


	echo ""
	echo "done"
	```

</p>
</details>

<details><summary>run_genotype_gvcf.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/combine_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch genotype_gvcf.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>

---

## Select Variants
- After genotyping, we now need to filter our SNPs, indels, and invariant sites
- Before SNPs can be filtered, SNPs, indels, and invariant sites need to be separated out of the genotype GVCF file using 'SelectVariants'
- **Output SNP file**
  - the output for this file will tell us the sites that are the same as our reference or different
  - to look at this file use zcat
    - "0/0": this means that for this position on the contig, the sample has the same base as the reference
    - "1/1": this means that for this position on the contig, the sample has a different base
    - "0/1" or "1/0": this means that the sample would have both the reference and the variant site
  - to check that this step worked:
	```
	zcat ${COHORT}_snps.vcf.gz | grep "0/0" | wc -l
	zcat ${COHORT}_snps.vcf.gz | grep "1/1" | wc -l
	```

<details><summary>select_variants.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=variants
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=20G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759


	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
	OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
	OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"


	echo ""
	echo "select SNPs"
	gatk SelectVariants \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${INDIR}/${COHORT}_cohort.genotype.g.vcf.gz \
	--select-type-to-include SNP \
	-O ${OUT_SNP}/${COHORT}_snps.vcf.gz


	echo ""
	echo "select indels"
	gatk SelectVariants \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${INDIR}/${COHORT}_cohort.genotype.g.vcf.gz \
	--select-type-to-include INDEL \
	-O ${OUT_INDEL}/${COHORT}_indels.vcf.gz

	echo ""
	echo "select invariant sites"
	gatk SelectVariants \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${INDIR}/${COHORT}_cohort.genotype.g.vcf.gz \
	--select-type-to-include NO_VARIATION \
	-O ${OUT_INVARIANT}/${COHORT}_invariants.vcf.gz


	echo ""
	echo "done"
	```

</p>
</details>

<details><summary>run_select_variants.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch select_variants.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>


---

## Variant to Table
- In this step, we will get information about depth and use that to filter our SNP vcf file
- We don't want to keep reads with low depth because we are not confident
- We also don't want to keep reads with super high depth because this is most likely because of a duplicated region mapping which would not be accurate
- [Really great resource for understanding these parameters](https://gatk.broadinstitute.org/hc/en-us/articles/360035890471-Hard-filtering-germline-short-variants)
- **Options**
  - **DP**: combined depth per SNP across samples (won't be filtering on this though)
  - **QualByDepth (QD):** generic settings are to filter out variants with _**QD < 2**_
    - Variant confidence normalized by the unfiltered depth of variant samples
    - This annotation puts the variant confidence QUAL score into perspective by normalizing for the amount of coverage available.
    - Because each read contributes a little to the QUAL score, variants in regions with deep coverage can have artificially inflated QUAL scores, giving the impression that the call is supported by more evidence than it really is.
    - To compensate for this, we normalize the variant confidence by depth, which gives us a more objective picture of how well-supported the call is.
  - **Fisherstrand (FS):** quantifies the probability of a strand bias. Generic settings are to filter out variants with _**FS > 60**_
    - Phred-scaled probability that there is strand bias at the site
    - Strand bias is a type of sequencing bias in which one DNA strand is favored over the other, which can result in an incorrect evaluation of the amount of evidence observed for one allele vs. the other
    - Strand Bias tells us whether the alternate allele was seen more or less often on the forward or reverse strand than the reference allele.
    - When there is little to no strand bias at the site, the FS value will be close to 0.
  - **StrandOddsRatio (SOR):** also quantifies the probability of strand bias. Generic settings are to filter out variants with _**SOR > 3**_
    - SOR was created because FS tends to penalize variants that occur at the ends of exons.
    - Reads at the ends of exons tend to only be covered by reads in one direction and FS gives those variants a bad score.
    - SOR will take into account the ratios of reads that cover both alleles.
  - **RMSMappingQuality (MQ):** Root mean square mapping quality. Generic settings are to filter out variants with _**MQ < 40**_
    - Mapping quality of a SNP
    - This is the root mean square mapping quality over all the reads at the site.
    - Instead of the average mapping quality of the site, this annotation gives the square root of the average of the squares of the mapping qualities at the site.
    - It is meant to include the standard deviation of the mapping qualities.
    - Including the standard deviation allows us to include the variation in the dataset.
    - A low standard deviation means the values are all close to the mean, whereas a high standard deviation means the values are all far from the mean.
    - When the mapping qualities are good at a site, the MQ will be around 60.
  - **MappingQualityRankSumTest (MQRankSum):** Compares MQ of reads with reference allele vs alternate allele. Generic settings filter out MQRankSum _**< -12.5**_
    - This is the u-based z-approximation from the Rank Sum Test for mapping qualities.
    - It compares the mapping qualities of the reads supporting the reference allele and the alternate allele.
    - A positive value means the mapping qualities of the reads supporting the alternate allele are higher than those supporting the reference allele.
    - A negative value indicates the mapping qualities of the reference allele are higher than those supporting the alternate allele.
    - A value close to zero is best and indicates little difference between the mapping qualities.
  - **ReadPosRankSumTest (ReadPosRankSum):** Compares the position of the ref and alternate alleles across reads. Generic settings filter out ReadPosRankSum _**< -8.0**_
    - This is the u-based z-approximation from the Rank Sum Test for site position within reads.
    - It compares whether the positions of the reference and alternate alleles are different within the reads.
    - Seeing an allele only near the ends of reads is indicative of error because that is where sequencers tend to make the most errors.
    - A negative value indicates that the alternate allele is found at the ends of reads more often than the reference allele.
    - A positive value indicates that the reference allele is found at the ends of reads more often than the alternate allele.
    - A value close to zero is best because it indicates there is little difference between the positions of the reference and alternate alleles in the reads.


<details><summary>variant_table.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --constraint=oarc
	#SBATCH --job-name=variant_table
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=10G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=2-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759


	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
 	OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"


	echo ""
	echo "Variant Table SNP"
	gatk --java-options "-Xmx10g" \
	VariantsToTable \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${OUT_SNP}/${COHORT}_snps.vcf.gz \
	-F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
	-O ${OUT_SNP}/${COHORT}_snps.table

 	echo ""
	echo "Variant Table Indel"
	gatk --java-options "-Xmx10g" \
	VariantsToTable \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${OUT_INDEL}/${COHORT}_indels.vcf.gz \
	-F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
	-O ${OUT_INDEL}/${COHORT}_indels.table

	echo ""
	echo "done"
	```

</p>
</details>


<details><summary>run_variant_table.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch variant_table.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>

Now we will run this [**R code**](https://github.com/lizardroom/sagrei_alyssa/blob/main/Variant_Table.R) to determine what value we should filter each parameter on.
- This R code will create a PDF file of tables for each population

---

## Filter SNPs, Indels, and Invariant sites - `GATK`
- In this step, we will filter our SNP and indel files based on what we determined in the step above.
- We will also be filtering out invariant sites
- I will be doing all of this in the one script below

<details><summary>variant_filter.sh</summary>
<p>

	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=filter_variants
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=40G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load GATK/4.2.2.0-yc759
	
	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
	OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
	OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"
	
	
	
	echo ""
	echo "Variant Filtration SNPs"
	gatk --java-options "-Xmx40g" \
	VariantFiltration \
	-V ${OUT_SNP}/${COHORT}_snps.vcf.gz \
 	--filter-expression "QUAL < 0.00 || MQ < 40.00 || SOR > 3.00 || QD < 2.000 || FS > 60.000 || MQRankSum < -12.50 || ReadPosRankSum < -8.00 || ReadPosRankSum > 8.00" \
 	--filter-name "my_snp_filter" \
	-O ${OUT_SNP}/${COHORT}_snps_filtered.vcf.gz
	
	echo ""
	echo "Extract passing SNPs"
	zcat ${OUT_SNP}/${COHORT}_snps_filtered.vcf.gz | grep -E '^#|PASS' > ${OUT_SNP}/${COHORT}_snps_filtered_passed.vcf
	
	
	
	echo ""
	echo "Variant Filtration indels"
	gatk --java-options "-Xmx40g" \
	VariantFiltration \
	-V ${OUT_INDEL}/${COHORT}_indels.vcf.gz \
  	--filter-expression "QUAL < 0.00 || QD < 2.000 || FS > 60.000 || ReadPosRankSum < -8.00 || ReadPosRankSum > 8.00" \
 	--filter-name "my_indel_filter" \
	-O ${OUT_INDEL}/${COHORT}_indels_filtered.vcf.gz
	
	echo ""
	echo "Extract passing indels"
	zcat ${OUT_INDEL}/${COHORT}_indels_filtered.vcf.gz | grep -E '^#|PASS' > ${OUT_INDEL}/${COHORT}_indels_filtered_passed.vcf
	
	
	
	echo ""
	echo "Mark quality filtered SNPs"
	gatk --java-options "-Xmx40g" \
	VariantFiltration \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${OUT_SNP}/${COHORT}_snps_filtered_passed.vcf \
	-G-filter "DP < 3 || DP > 70" \
	-G-filter-name "depth_filter" \
	-O ${OUT_SNP}/${COHORT}_snps_filtered_depth.vcf.gz
	
	echo ""
	echo "Extract passing SNPs"
	zcat ${OUT_SNP}/${COHORT}_snps_filtered_depth.vcf.gz | grep -E '^#|PASS' > ${OUT_SNP}/${COHORT}_snps_filtered_depth_passed.vcf
	
	
	echo ""
	echo "Mark quality filtered indels"
	gatk --java-options "-Xmx40g" \
	VariantFiltration \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${OUT_INDEL}/${COHORT}_indels_filtered_passed.vcf \
	-G-filter "DP < 3 || DP > 70" \
	-G-filter-name "depth_filter" \
	-O ${OUT_INDEL}/${COHORT}_indels_filtered_depth.vcf.gz
	
	echo ""
	echo "Extract passing indels"
	zcat ${OUT_INDEL}/${COHORT}_indels_filtered_depth.vcf.gz | grep -E '^#|PASS' > ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf
	
	
	
	echo ""
	echo "Mark quality filtered invariants"
	gatk --java-options "-Xmx40g" \
	VariantFiltration \
	-R ${GEN_DIR}/AnoSag2.1.fa \
	-V ${OUT_INVARIANT}/${COHORT}_invariants.vcf.gz \
	-G-filter "DP < 3 || DP > 70" \
	-G-filter-name "depth_filter" \
	-O ${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth.vcf.gz
	
	echo ""
	echo "Extract passing invariants"
	zcat ${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth.vcf.gz | grep -E '^#|PASS' > ${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth_passed.vcf
	
	
	echo ""
	echo "done"
	```

</p>
</details>

<details><summary>run_variant_filter.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch variant_filter.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>


---

## Filter SNPs and Invariant sites - `vcftools`
- Now we will also filter our files using vcftools
- Template for R code found [here](https://speciationgenomics.github.io/filtering_vcfs/)
- **Options**
  - **--gvcf** - input path – denotes a gzipped vcf file
  - **--remove-indels** - remove all indels (SNPs only) - We did this in gatk but you can also use the genotype.g.vcf file here
  - **--maf** - set minor allele frequency - 0.1 here
  - **--max-missing** - set minimum missing data. A little counterintuitive - 0 is totally missing, 1 is none missing. Here 0.9 means we will tolerate 10% missing data.
  - **--minQ** - this is just the minimum quality score required for a site to pass our filtering threshold. Here we set it to 30.
  - **--min-meanDP** - the minimum mean depth for a site.
  - **--max-meanDP** - the maximum mean depth for a site.
  - **--minDP** - the minimum depth allowed for a genotype - any individual failing this threshold is marked as having a missing genotype.
  - **--maxDP** - the maximum depth allowed for a genotype - any individual failing this threshold is marked as having a missing genotype.
  - **--recode** - recode the output - necessary to output a vcf
  - **--stdout** - pipe the vcf out to the stdout (easier for file handling)
- **Can use this code below to check out many loci are in the alignment**
	```
	bcftools view -H genotype_gvcf/snps/jamaica_snps_vcftools_filtered.vcf.gz.recode.vcf | wc -l
	```
### SNPs

**1. We first need to generate stats on our filtered snp file using vcftools**

<details><summary>vcftools_table.sh</summary>
<p>

 	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=vcftools_table
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=10G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=2-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load VCFtools/vcftools-v0.1.16-13-yc759

	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
	OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
	OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"
 	OUTDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/vcftools_tables"
 	SNPS=${OUT_SNP}/${COHORT}_snps_filtered_depth_passed.vcf
  	OUTFILE_SNP=${OUTDIR}/${COHORT}_snps_vcftools
   	INVAR=${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth_passed.vcf
    	OUTFILE_INV=${OUTDIR}/${COHORT}_invariants_vcftools
	
	echo ""
	echo "run vcftools snps"
	vcftools --vcf ${SNPS} --freq2 --out $OUTFILE_SNP --max-alleles 2           # Calculate allele frequency for each variant. --freq2 just outputs the frequencies without information about the alleles. Max-alleles 2 excludes sites that have more than two alleles
	
	vcftools --vcf ${SNPS} --depth --out $OUTFILE_SNP                           # Calculate mean depth of coverage per individual
	
	vcftools --vcf ${SNPS} --site-mean-depth --out $OUTFILE_SNP                 # Calculate mean depth per site
	
	vcftools --vcf ${SNPS} --site-quality --out $OUTFILE_SNP                    # Calculate site quality score for each site
	
	vcftools --vcf ${SNPS} --missing-indv --out $OUTFILE_SNP                    # Calculate proportion of missing data per sample
	
	vcftools --vcf ${SNPS} --missing-site --out $OUTFILE_SNP                    # Calculate missing data per site
	
	vcftools --vcf ${SNPS} --het --out $OUTFILE_SNP                             # Calculate heterozygosity and inbreeding coefficient per individual

	echo ""
	echo "done"
   	```
	
</p>
</details>

<details><summary>run_vcftools_table.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch vcftools_table.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>

**2. Look at stats output in R and use this to inform our filtering**
- We will run [**this R code**](https://github.com/lizardroom/sagrei_alyssa/blob/main/vcftools.R) to determine which value to filter each parameter on.
- [Resource]:(https://speciationgenomics.github.io/filtering_vcfs/)
- **Variant quality:**
  - The first metric we will look at is the (Phred encoded) site quality.
  - This is a measure of how much confidence we have in our variant calls.
  - _**Recommended: a minimum threshold of 30**_
- **Variant mean depth**
  - Next we will examine the mean depth for each of our variants.
  - This is essentially the number of reads that have mapped to this position.
  - The output we generated with vcftools is the mean of the read depth across all individuals - it is for both alleles at a position and is not partitioned between the reference and the alternative.
  - **_Recommended: min cutoff at 10 and maximum of mean depth x2_**
- **Variant missingness**
  - The proportion of missingness at each variant.
  - This is a measure of how many individuals lack a genotype at a call site.
  - vcftools inverts the direction of missingness
  - **_Recommended: so our 10% threshold means we will tolerate 90% missingness (yes this is confusing and counterintuitive… but that’s the way it is!). Typically missingness of 75-95% is used._**
- **Minor allele frequency**
  - Last of all for our per-variant analyses, we will take a look at the distribution of allele frequencies.
  - This will help inform our minor-allele frequency (MAF) thresholds.
  - However, this is simply the allele frequencies.
  - The upper bound of the distribution is 0.5, which makes sense because if MAF was more than this, it wouldn’t be the MAF!
  - How do we interpret MAF? It is an important measure because low MAF alleles may only occur in one or two individuals.
  - It is possible that some of these low-frequency alleles are in fact unreliable base calls - i.e. a source of error.
  - Setting MAF cutoffs is actually not that easy or straightforward. Hard MAF filtering (i.e. setting a high threshold) can severely bias the estimation of the site frequency spectrum and cause problems with demographic analyses.
  - Similarly, an excesss of low frequency, ‘singleton’ SNPs (i.e. only occurring in one individual) can mean you keep many uninformative loci in your dataset that make it hard to model things like population structure.
  - **_Recommended: Usually then, it is best practice to produce one dataset with a good MAF threshold and keep another without any MAF filtering at all. For now however, we will set our MAF to 0.1_**
- **Mean depth per individual**
  - distribution of mean depth among individuals.
  - **_Recommended: If there are no extreme outliers. So this doesn’t suggest any issue with individual sequencing depth._**
- **Proportion of missing data per individual**
  - the proportion of missing data per individual.
  - This is very similar to the missing data per site. 
  - Here we will focus on the fmiss column - i.e. the proportion of missing data.
  - **_Recommended: We want the proportion of missing data per individual to be very small which suggests that our individuals sequenced well_**
- **Heterozygosity and inbreeding coefficient per individual**
  - We would expect slightly negative inbreeding coefficients due to the Wahlund-effect.
  - Given that all individuals seem to show similar inbreeding coefficients, we are happy to keep all of them.
  - None of them shows high levels of allelic dropout (strongly negative F) or DNA contamination (highly positive F).

**3. Do final filtering with vcftools using the information from R**
- **Depth:**
  - You should always include a minimum depth filter and ideally also a maximum depth one too.
  - Minimum depth cutoffs will remove false positive calls and will ensure higher quality calls too.
  - A maximum cut-off is important because regions with very, very high read depths are likely repetitive ones mapping to multiple parts of the genome.
- **Quality:**
  - Genotype quality is also an important filter - essentially you should not trust any genotype with a Phred score below 20 which suggests a less than 99% accuracy.
- **Minor allele frequency:**
  - MAF can cause big problems with SNP calls - and also inflate statistical estimates downstream.
  - Ideally, you want an idea of the distribution of your allelic frequencies but 0.05 to 0.10 is a reasonable cut-off.
  - You should keep in mind however that some analyses, particularly demographic inference can be biased by MAF thresholds.
- **Missing data:**
  - How much missing data are you willing to tolerate? It will depend on the study but typically any site with >25% missing data should be dropped.

<details><summary>vcftools_filter.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=vcftools_filter_snp
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=10G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load VCFtools/vcftools-v0.1.16-13-yc759
	
	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
	OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
	OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"
 	SNPS=${OUT_SNP}/${COHORT}_snps_filtered_depth_passed.vcf
	
	echo ""
	echo "Set filters for vcftools"
	MAF=0                                    # set Minor Allele Frequency
	MISS=0.9                                # set minimum missing data - Here 0.9 means we tolerate 10% missing data
	QUAL=30                                  # minimum quality score for a site to pass filtering threshold
	MIN_DEPTH=3                              # minimum mean depth and minimum depth allowed for a genotype
	MAX_DEPTH=75                           # maximum mean depth and maximum depth allowed for a genotype
	
	echo ""
	echo "Run vcftools"
	# ======
	# --remove-indels                       # I left this here for just incase downstream
	
	vcftools --vcf ${SNPS} \
	--maf ${MAF} --max-missing ${MISS} --minQ ${QUAL} \
	--min-meanDP ${MIN_DEPTH} --max-meanDP ${MAX_DEPTH} \
	--minDP ${MIN_DEPTH} --maxDP ${MAX_DEPTH} --recode --out ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf
			
	echo ""
	echo "done"
	```
	
</p>
</details>

<details><summary>run_vcftools_filter.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch vcftools_filter.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>

**Sites before and after filtering**
- can check this with the following code:
  ```
  bcftools view -H genotype_gvcf/snps/Alut_snps_filtered_depth_passed.vcf | wc -l
  ```

| Population  | Pre-GATK   | Pre-vcftools | 10% missing |
| ----------- | ---------- | ------------ | ----------- |
| Alut        | 56008808   | 43046694     | 38724110    |
| Anel        | 84144517   | 68464080     | 58590099    |
| Asag        | 35507631   | 31496051     | 30936462    |
| Asmay       | 38528547   | 34099049     | 33447921    |
| Asord       | 53108763   | 46386689     | 40857719    |
| Aoph        |            |              |             |

### Invariant sites

<details><summary>invariant_filter_vcftools.sh</summary>
<p>

 	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=vcftools_filter_invar
	#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
	#SBATCH --mem=10G
	#SBATCH -n 2
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load java
	module load VCFtools/vcftools-v0.1.16-13-yc759
	
	echo ""
	echo "load variables"
	COHORT=$1
	INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
	GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
	OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
	OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
	OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"
 	INVAR=${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth_passed.vcf
	
	echo ""
	echo "set filters for vcftools"
	#MAF=0                                    # set Minor Allele Frequency
	MISS=0.9                                # set minimum missing data - Here 0.9 means we tolerate 10% missing data
	QUAL=30                                  # minimum quality score for a site to pass filtering threshold
	MIN_DEPTH=3                              # minimum mean depth and minimum depth allowed for a genotype
	MAX_DEPTH=75                           # maximum mean depth and maximum depth allowed for a genotype
	
	echo ""
	echo "Run vcftools on invariant sites file"
	# ======
	# --remove-indels                       # I left this here for just incase downstream
	
	vcftools --vcf ${INVAR} \
	--max-missing ${MISS} --minDP ${MIN_DEPTH} --maxDP ${MAX_DEPTH} \
 	--min-meanDP ${MIN_DEPTH} --max-meanDP ${MAX_DEPTH} \
  	--recode --recode-INFO-all --out ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf 
	
 	#| bgzip -c > $1_INVARIANT_depth_filterPASSED_0.25max_missing.vcf.gz
 		
	echo ""
	echo "done"
  	```

</p>
</details>

<details><summary>run_invariant_filter_vcftools.sh</summary>
<p>
	
	```
	#!/bin/bash
	SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
	for SAMPLE in $SAMPLES
		do
		CMD="sbatch invariant_filter_vcftools.sh ${SAMPLE}"
		echo $CMD
		#eval $CMD
		sleep 0.25
	done
	```

</p>
</details>

---

## Make allsites file
- Now we will be combining our SNP, indel, and invariant sites files to make one all sites file
- My files will need to be zipped first
- Then, we need to index the files


<details><summary>combine_allsites.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=combine_allsites
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/allsites/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load java
module load VCFtools/vcftools-v0.1.16-13-yc759


echo ""
echo "load variables"
COHORT=$1
INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"
OUT_ALLSITES="/projects/f_geneva_1/alyssa/sagrei/allsites"


echo ""
echo "copy files"
cp ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf ${OUT_SNP}/${COHORT}_snp_final_filtered.vcf
cp ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf ${OUT_INDEL}/${COHORT}_indels_final_filtered.vcf
cp ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf ${OUT_INVARIANT}/${COHORT}_invariants_final_filtered.vcf

echo ""
echo "bgzip files"
bgzip ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf
bgzip ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf
bgzip ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf


echo ""
echo "index files using tabix"
tabix ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf.gz
tabix ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf.gz
tabix ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf.gz


echo ""
echo "combine using bcftools"
bcftools concat \
--allow-overlaps \
${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf.gz ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf.gz ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf.gz \
-O z -o ${OUT_ALLSITES}/${COHORT}_allsites.vcf.gz


echo ""
echo "index files"
bcftools index -t ${OUT_ALLSITES}/${COHORT}_allsites.vcf.gz

echo ""
echo "done"
```
	
</p>
</details>

<details><summary>run_combine_allsites.sh</summary>
<p>

```
#!/bin/bash
SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/*.gz | cut -d "/" -f 7 | cut -d "_" -f 1 | sort | uniq)
for SAMPLE in $SAMPLES
        do
	CMD="sbatch combine_allsites.sh ${SAMPLE}"
        echo $CMD
        #eval $CMD
        sleep 0.25
done
```

</p>
</details>

---
