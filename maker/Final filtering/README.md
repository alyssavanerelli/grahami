# Final filtering of annotation
This is code used to filter our maker annotation output file (from round 4) and assign gene names.

---
# Prepare MAKER files
- First, we need to do some preparation of our maker files
- Maker assigned gene names to the gene models but these are not intended to be the final naming scheme that will be uploaded to NCBI
- We will use maker scripts to rename our models to gene names with NCBI style gene IDs
- I will be doing this in a separate folder that I have made for all the final filtering
- This [website](http://weatherby.genetics.utah.edu/MAKER/wiki/index.php/MAKER_Tutorial_for_WGS_Assembly_and_Annotation_Winter_School_2018) is helpful for these maker steps.

```
# Copy over GFF file
cp /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd4.maker.output/Agra_rnd4.all.maker.gff /projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker

# Copy over FASTA file
cp /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd4.maker.output/Agra_rnd4.all.maker.transcripts.fasta /projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker

# Copy over protein file
cp /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd4.maker.output/Agra_rnd4.all.maker.proteins.fasta /projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker
```

**1. Create an ID mapping file with `maker_map_ids`**
- This will create a two-column tab delimited file with the original gene ID in column 1 and the new gene ID in column 2
- `--prefix` is where you enter your registered genome prefix (Mine is `AGRA_`)
- `--justify` is the length of the number following the prefix
  - Need to make sure this is number is long enough to fit all of the gene models that are in the annotation
  - E.g. if you have 10,000 genes, `--justify` should be at least 5

<details><summary>rename_genes_1.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=maker_map_id
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=20G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker

	echo "load modules"
	module purge
	module load singularity/3.1.0

	MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

	echo ""
	echo "map maker IDs to numerical IDs with a specified prefix"
	singularity exec $MAKER_IMAGE  maker_map_ids --prefix AGRA_ --justify 6 \
	Agra_rnd4.all.maker.gff > Agra_rnd4.all.maker.map

	echo ""
	echo "done"
	```

</p>
</details>

**2. Now we will change the IDs in the main files**
- Now we will use the created map file to change all the ID names in our GFF and FASTA files
- This uses `map_gff_ids` and `map_fasta_ids`
- **IMPORTANT:** These scripts do an in-place edit of the file instead of creating a new file. Do NOT interrupt these processes as they run or the files may be corrupted/truncated.

<details><summary>rename_genes_2.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=maker_change_ids
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=20G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker

	echo "load modules"
	module purge
	module load singularity/3.1.0

	MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

	echo ""
	echo "change IDs of a given GFF/FASTA file based off of the map file created"


	echo "Master GFF"
	singularity exec $MAKER_IMAGE map_gff_ids \
	Agra_rnd4.all.maker.map Agra_rnd4.all.maker.gff


	echo "Protein FASTA"
	singularity exec $MAKER_IMAGE map_fasta_ids \
	Agra_rnd4.all.maker.map Agra_rnd4.all.maker.proteins.fasta


	echo "Transcript fasta"
	singularity exec $MAKER_IMAGE map_fasta_ids \
	Agra_rnd4.all.maker.map Agra_rnd4.all.maker.transcripts.fasta


	echo ""
	echo "done"
	```

</p>
</details>

**3. We need to remove semi-colons at the end of the lines in our GFF file**
- `map_gff_ids` erroneously adds semi-colons to the ends of the rows in our gff file
- These will create issues downstream and need to be removed

```
sed 's/;$//' Agra_rnd4.all.maker.gff > SEMI_removed_Agra_rnd4.all.maker.gff
```
---

# Uniprot database
- We need a uniprot database as well as a fasta file representing the database
- Jody has already made this and the path is below
- We will add this path to our blast search script below

```
/projects/f_geneva_1/jody/annotation/ANNIE
```

---

# BLAST search
- Now, we will perform a blast search
- The program BLAST is already installed into our geneva lab path
- This will take our annotation file and search for already published sequences
- This will be used to assign gene names to the genes that match
- We can be confident that these are real genes in our annotation
- Resources:
  - https://open.oregonstate.education/computationalbiology/chapter/command-line-blast/
- Important
  - We will be using `blastp` for proteins
  - For annie, the output needs to be in format 6: `-outfmt 6`
- **Output**
  - Need to have a separate output file than the slurmout (so we can see any errors in the slurmout): use the `-out` flag
  - See information about output table [here](https://www.metagenomics.wiki/tools/blast/blastn-output-format-6)

<details><summary><b>blast.sh</b></summary>
<p>
  
	```
	#!/bin/bash
	#SBATCH --partition=p_geneva_1
	#SBATCH --exclude=halc068
	#SBATCH --job-name=BLAST
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=10G
	#SBATCH -n 32
	#SBATCH -N 1
	#SBATCH --time=14-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	#load modules
	module purge
	
	#load variables
	INDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
	OUTDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/uniprot"
	#DB_DIR="/projectsc/ccib/shain/blastdb"
	DB_DIR="/projects/f_geneva_1/jody/annotation/ANNIE"
	
	#commands to run blast
	blastp -query ${INDIR}/Agra_rnd4.all.maker.proteins.fasta \
	-num_threads 32 \
	-db ${DB_DIR}/uniprot \
	-outfmt 6 \
	-out ${OUTDIR}/blast.out \
	-evalue .000001 \
	-num_alignments 1 \
	-seg yes \
	-soft_masking true \
	-lcase_masking \
	-max_hsps 1

 	#-mt_mode 1
	```

</p>
</details>

---

# Now we need to rename the genes 
- We will be using the gene names from our blastn search to change our maker gene model names
- This will use the maker scripts `maker_functional_gff` and `maker_functional_fasta`

<details><summary><b>rename_genes_blast.sh</b></summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=blast_rename_id
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=20G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker
	
	echo "load modules"
	module purge
	module load singularity/3.1.0
	
	MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif
	BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/uniprot"
	#DB_DIR="/projectsc/ccib/shain/blastdb"
	DB_DIR="/projects/f_geneva_1/jody/annotation/ANNIE"
	
	
	echo ""
	echo "Append the gene names from the BLASTN results to each associated gene prediction"
	
	
	echo "Master GFF"
	singularity exec $MAKER_IMAGE maker_functional_gff ${DB_DIR}/uniprot_sprot.fasta \
	${BLAST_DIR}/blast.out SEMI_removed_Agra_rnd4.all.maker.gff > Agra_rnd4.all.maker.functional.blast.gff
	
	
	echo "Protein FASTA"
	singularity exec $MAKER_IMAGE maker_functional_fasta ${DB_DIR}/uniprot_sprot.fasta \
	${BLAST_DIR}/blast.out Agra_rnd4.all.maker.proteins.fasta > Agra_rnd4.all.maker.proteins.functional.blast.fasta
	
	
	echo "Transcript FASTA"
	singularity exec $MAKER_IMAGE maker_functional_fasta ${DB_DIR}/uniprot_sprot.fasta \
	${BLAST_DIR}/blast.out Agra_rnd4.all.maker.transcripts.fasta > Agra_rnd4.all.maker.transcripts.functional.blast.fasta
	
	
	echo ""
	echo "done"
	```

</p>
</details>

---

# Annie
- [Annie documentation](http://genomeannotation.github.io/annie/)
- [Github page](https://github.com/genomeannotation/Annie)
- We are keeping genes that blasted 
- Uses `python3`
- Input
  - The blast output 6 
  - BLAST database fasta file
  - Transcript gff file
- **To install Annie:** Download `.zip` file from [here](http://genomeannotation.github.io/annie/), upload it to amarel, and unzip.
- **Output**
  - Product annotation in the form `<mrna_id> product <product>`
    - Use the blast file to get the dbxref for the associated mrna 
    - Then we use the fasta file to take that dbxref and get the corresponding product
    - `mrna_id ---blast_file---> dbxref ---fasta_file---> product`
  - Name annotation in the form `<parent_gene_id> name <parent_gene_name>`
    - Obtaining the `<parent_gene_id>`
      - For each mrna in the blast results, we look it up in the gff file to get the corresponding parent gene id
      - `mrna_id ---gff_file---> parent_gene_id`
    - Obtaining the `<parent_gene_name>`
      - We use the blast file to get the associated dbxref from the mrna 
      - Then we use the fasta file to take that dbxref ref and give us the gene name
      - `mrna_id ---blast_file---> dbxref ---fasta_file---> parent_gene_name`

```
python3 annie.py \
	-b sample_data/sample.blastout \
        -g sample_data/sample.gff \
        -db sample_data/sample.fasta
```

<details><summary><b>annie.sh</b></summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=annie
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=10G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load python/3.9.6-gc563
	
	echo ""
	echo "load variables"
	cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/annie
	
	MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
	BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/uniprot"
	#DB_DIR="/projectsc/ccib/shain/blastdb"
	DB_DIR="/projects/f_geneva_1/jody/annotation/ANNIE"
	
	echo ""
	echo "commands to run annie"
	python3 annie.py \
	-b ${BLAST_DIR}/blast.out \
	-g ${MAKER_DIR}/Agra_rnd4.all.maker.functional.nosemi.blast.gff \
	-db ${DB_DIR}/uniprot_sprot.fasta
	
	echo ""
	echo "done"
	```

</p>
</details>

---

# GAG
- [GAG documentation](http://genomeannotation.github.io/GAG/)
- [Github page](https://github.com/genomeannotation/GAG)
- GAG takes the output from annie and combines it with our annotation 
- Uses `python2`
- Copy `gag.py` script from [here](https://github.com/genomeannotation/GAG/blob/master/gag.py)
- Input
  - Fasta file of nucleotide sequences (genome fasta file)
  - GFF3 file (full gff file)
  - Annie output table

```
python gag.py --fasta organism.fasta --gff organism.gff --out gag_output
```

<details><summary><b>gag.sh</b></summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=gag
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=10G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load python/2.7.17-gc563
	
	
	cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/gag
	
	
	echo ""
	echo "load variables"
	MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
	BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/uniprot"
	ANNIE_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/annie"
	GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
	
	echo ""
	echo "commands to run gag"
	python2.7 gag.py \
	-f ${GEN_DIR}/AnoGra1.1.fa \
	-g ${MAKER_DIR}/Agra_rnd4.all.maker.functional.nosemi.blast.gff \
	-a ${ANNIE_DIR}/annie_output.tsv \
	-o gag_grahami
	
	
	echo ""
	echo "done"
	```

</p>
</details>

---

# Manual filtering
- We will also be doing manual filtering on the gene models that didn't match to anything during our blast search
- During BLAST, our gene models will really only be matching with _A. carolinensis_ genes which is pretty divergent from _A. grahami_
- By manually filtering our other gene models on certain criteria we can be pretty confident that these are genes that _A. grahami_ has that _A. carolinensis_ doesn't
- Filtering criteria:
  - AED score of X or lower
  - X or more exons (prob 3?)
- Determining criteria:
  - Make a histogram of AED scores
  - Make a histogram of # of exons

## Preparing files
- I will need to prepare a file of "done" genes that have a name from Annie and a file of genes that need further filtering
- I think that I will make the `gff` files and then paste the genome sequence at the bottom of the file

Total genes: 52458
Good genes: 20706
"Bad" genes: 31752

**Make files of base gene names**
```
# all gene names
grep "\sgene\s" genome.gff | cut -f 9 | cut -d ";" -f 1 | cut -d "-" -f 1 | uniq > base_all_genes.txt

# passed gene names
grep "\sgene\s" genome.gff | grep "Name=" | cut -f 9 | cut -d ";" -f 1 |  cut -d "-" -f 1 | uniq > base_good_genes.txt

# need more filtering gene names
grep -f base_good_genes.txt -Fw -v base_all_genes.txt > base_bad_genes.txt
```

**Subset `genome.gff` file**
```
# gff of passed genes
grep -f base_good_genes.txt -Fw genome.gff > passed.gff

# gff of genes that need more filtering
grep -f base_bad_genes.txt -Fw genome.gff > filter.gff
```

## Filtering based on the number of exons
- Now i will filter the unnamed genes further (the genes in `filter.gff`)
- I will be keeping genes that have more than **2**

<details><summary>exon.sh</summary>
<p>

```
#!/bin/bash
NAMES=$(cut -f 1 base_bad_genes.txt)
for NAME in $NAMES
        do
	BASE=${NAME}
        COUNT=$(grep -E "${BASE}|${BASE}-*" filter.gff | grep "\sexon\s" | wc -l)
        CMD="echo -e '${BASE}\t${COUNT}' >> exon_counts.txt"
        #echo $CMD
        eval $CMD
done

# only keep genes with exon counts over or equal to 2
awk '$2 >=3' exon_counts.txt > filtered_exons_names.txt

# make a file with only gene IDs for the filtered genes (drop exon counts)
cut -f 1 filtered_exons_names.txt > temp_filter.txt ; mv temp_filter.txt filtered_exons_names.txt
```

</p>
</details>




## Filtering based on AED score
- Need to make a file with IDs and AED scores (using the original maker file)
- Then will look at the distribution of AED scores and filter accordingly

**Make AED scores file**
<details><summary>aed.sh</summary>
<p>

```
#!/bin/bash
NAMES=$(cut -f 1 filtered_exons_names.txt)
for NAME in $NAMES
        do
	BASE=${NAME}
	AED=$(grep -E "${BASE}|${BASE}-*" Agra_rnd4.all.maker.functional.nosemi.blast.gff | grep "_AED" | cut -f 9 | cut -d ";" -f 5 | cut -d "=" -f 2)
	CMD="echo -e '${BASE}\t${AED}' >> aed_scores.txt"
	echo $CMD
	#eval $CMD
done
```

</p>
</details>

**Make distribution of AED scores**

<details><summary>manual_filtering.R</summary>
<p>

```
###### Maker AED scores ######

#libraries
library(MetBrewer)
library(tidyverse)
library(ggplot2)

# set working directory
setwd("~/Desktop/grahami/annotation/annotation filtering/")

# load in data
aed = read.table("aed_scores.txt", header = FALSE)
colnames(aed) = c("ID", "AED")

# make histogram
ggplot(data = aed, aes(x=AED)) + geom_histogram(color = "darkblue", fill = "lightblue") + 
  ggtitle("AED Scores") +
  ylab("Frequency") + 
  geom_vline(xintercept = c(0.25, 0.40, 0.50), size = 0.8, color = "firebrick4") +
  theme_bw() +
  geom_text(x = 0.75, y = 1250, label = "Lines at 0.25, 0.40, and 0.50")

ggsave(
  "aed_histogram.png",
  plot = last_plot(),
  width = 10,
  height = 8,
  units = "in"
)
```

</p>
</details>

**Filter by AED**

```
# only keep genes with AED scores less than or equal to XXXX
awk '$2 <=0.50' aed_scores.txt > filtered_aed_names.txt

# make a file with only gene IDs for the filtered genes (drop exon counts)
cut -f 1 filtered_aed_names.txt > temp_filter.txt ; mv temp_filter.txt filtered_aed_names.txt
```

## Make final `genome.gff` file

**Combine filtered files of gene names**
```
cat base_good_genes.txt filtered_aed_names.txt > all_good_genes.txt
```

**Filter `genome.gff` file to only include filtered and named gene models**
```
grep -f all_good_genes.txt -Fw genome.gff > final_genome.gff
```

**Make final mRNA fasta file**
```
gffread -w transcripts.fa -g /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa final_genome.gff
```

## Gene Stats

| Step                 | # gene models |
| :------------------: | :-----------: |
| Maker rnd4           | 52458         |
| **Named from annie** | **20706**     |
| Unfiltered           | 31752         |
| Exon filtering       | 12976         |
| AED filtering        | 11157         |
| **Final**            | **31863**     |

---

# Final Stats

## GAG
- GAG produces a nice table of gene model statistics
- So we will run this analysis once more on the final gff file

<details><summary>final_gag.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=gag_final
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load python/2.7.17-gc563


cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/gag


echo ""
echo "load variables"
MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/uniprot"
ANNIE_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/annie"
GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
FINAL_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/final"

echo ""
echo "commands to run gag"
python2.7 gag.py \
-f ${GEN_DIR}/AnoGra1.1.fa \
-g ${FINAL_DIR}/final_genome.gff \
-a ${ANNIE_DIR}/annie_output.tsv \
-o final_gag


echo ""
echo "done"
```

</p>
</details>

<details><summary>gag_named.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=gag_final
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load python/2.7.17-gc563


cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/gag


echo ""
echo "load variables"
MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/uniprot"
ANNIE_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/annie"
GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
FINAL_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/final"

echo ""
echo "commands to run gag"
python2.7 gag.py \
-f ${GEN_DIR}/AnoGra1.1.fa \
-g ${FINAL_DIR}/passed.gff \
-a ${ANNIE_DIR}/annie_output.tsv \
-o named_genes_gag


echo ""
echo "done"
```

</p>
</details>


## BUSCO
- Now we want to run BUSCO again to see our completeness scores after all of our filtering
- The completeness will probably decrease some but we don't want to see it drastically change
- We will run BUSCO in transcriptome mode

<details><summary>final_busco.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=final_busco
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

echo "activate conda environment"
eval "$(conda shell.bash hook)"
conda activate busco


cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/final

echo "Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database"
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/filtering/final/final_genome.mrna.fasta \
-o final_busco -l vertebrata_odb10 -m transcriptome -c 16

echo "done"
```

</p>
</details>


### Compare BUSCO scores pre- and post-filtering
- We need to make sure that the annotation completeness did not decrease dramatically after filtering out gene models

**Pre-filtering**
- Results from MAKER round 4

```
C:57.1%[S:56.1%,D:1.0%],F:16.8%,M:26.1%,n:3354
    
1914    Complete BUSCOs (C)                        
1881    Complete and single-copy BUSCOs (S)        
33      Complete and duplicated BUSCOs (D)         
562     Fragmented BUSCOs (F)                      
878     Missing BUSCOs (M)                         
3354    Total BUSCO groups searched 
```

**Post-filtering**
- final genome annotation

```
C:57.1%[S:56.1%,D:1.0%],F:16.7%,M:26.2%,n:3354     
        
1913    Complete BUSCOs (C)                        
1880    Complete and single-copy BUSCOs (S)        
33      Complete and duplicated BUSCOs (D)         
561     Fragmented BUSCOs (F)                      
880     Missing BUSCOs (M)                         
3354    Total BUSCO groups searched
```




---


<details><summary>name</summary>
<p>

</p>
</details>































<details><summary>stuff unused</summary>
<p>


# Prepare a fasta file of the BLAST database
- For BLAST, we will be using the database already on amarel
- For the next MAKER step and annie, we will need to have the fasta file representing the BLAST nucleotide db
  - This file is large so the downlod will take a little while
- [Useful intructions](https://ncbi.github.io/magicblast/cook/blastdb.html)
- Nobody else in the lab should have to do this. I will copy the results over to **`/projects/f_geneva_1/data/blastdb`**

**1. Download fasta file**
```
cd blast/
wget https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz
gunzip nt.gz
cp nt nt.fasta
```

**2. Index and create the database**

<details><summary>make_db.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=blastdb
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=100G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load blast/2.10.1-zz109


	cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/db

	echo ""
	echo "commands to run blast"
	makeblastdb -in nt.fasta -parse_seqids -blastdb_version 5 -parse_seqids -out nt -dbtype nucl


	echo ""
	echo "done"
	```

</p>
</details>

**Copy over blast database**
```
mkdir /projects/f_geneva_1/data/blastdb
cp db/* /projects/f_geneva_1/data/blastdb/
```

**4. We need to split `protein.fasta` file into multiple smaller files**
- BLAST takes a long time to run with the protein database so we need to split our input file into multiple smaller files
- First, we need to **reformat the file** by changing the line wrapping so the file is header, seq, header, seq, etc.
  ```
  # Remove carriage returns from fasta file
  awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n } ' Agra_rnd4.all.maker.proteins.fasta > Agra_rnd4.all.maker.proteins.unwrapped.fasta
  ```
- Then, we need to **split the file** into multiple smaller files (i split mine into files of 20,000 lines each so 10,000 sequences)
  ```
  split -l 20000 Agra_rnd4.all.maker.proteins.unwrapped.fasta Agra_rnd4_proteins_
  ```
- I also renamed my split files
  ```
  mv Agra_rnd4_proteins_aa Agra_rnd4_proteins_1.fasta
  ```


# Prepare a fasta file of the BLAST database
- For BLAST, we will be using the database already on amarel
- For the next MAKER step and annie, we will need to have a fasta file representing the BLAST nucleotide db
- I will be creating this file and copying it over into the blastdb

```
blastdbcmd -entry all -db /projectsc/ccib/shain/blastdb/nr -out nr.fasta
cp nr.fasta /projectsc/ccib/shain/blastdb/
```

---

# BLAST search
- Now, we will perform a blast search
- The program BLAST is already installed into our geneva lab path
- This will take our annotation file and search for already published sequences
- This will be used to assign gene names to the genes that match
- We can be confident that these are real genes in our annotation
- Resources:
  - https://open.oregonstate.education/computationalbiology/chapter/command-line-blast/
- Important
  - We will be using `blastp` for proteins
  - For annie, the output needs to be in format 6: `-outfmt 6`
  - The location of the nucleotide database on amarel: `/projectsc/ccib/shain/blastdb`
    - We will use the `nr` files (for protein)
- This step took ~16 hours for me
- **Output**
  - Need to have a separate output file than the slurmout (so we can see any errors in the slurmout): use the `-out` flag
  - See information about output table [here](https://www.metagenomics.wiki/tools/blast/blastn-output-format-6)

<details><summary>blast.sh (full version)</summary>
<p>
  
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=BLAST
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=100G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge

	echo ""
	echo "load variables"
	INDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
	OUTDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast"
	DB_DIR="/projectsc/ccib/shain/blastdb"

	echo ""
	echo "commands to run blast"
	blastp -query ${INDIR}/Agra_rnd4.all.maker.transcripts.fasta \
	-db ${DB_DIR}/nr \
	-outfmt 6 \
	-out ${OUTDIR}/blast.out \
	-evalue .000001 \
	-num_alignments 1 \
	-seg yes \
	-soft_masking true \
	-lcase_masking \
	-max_hsps 1
	
	echo ""
	echo "done"
	```

</p>
</details>


<details><summary>blast.sh (split version)</summary>
<p>
  
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=BLAST_2
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=50G
	#SBATCH -n 32
	#SBATCH -N 1
	#SBATCH --time=11-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL
	
	
	#load modules
	module purge
	
	#load variables
	INDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker/split"
	OUTDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast/split"
	DB_DIR="/projectsc/ccib/shain/blastdb"
	
	
	#commands to run blast
	blastp -query ${INDIR}/Agra_rnd4_proteins_2.fasta \
	-num_threads 32 \
	-db ${DB_DIR}/nr \
	-outfmt 6 \
	-out ${OUTDIR}/blast_2.out \
	-evalue .000001 \
	-num_alignments 1 \
	-seg yes \
	-soft_masking true \
	-lcase_masking \
	-max_hsps 1
	
	#-mt_mode 1
	#blastp -query ${INDIR}/Agra_rnd4.all.maker.proteins.fasta \
	```

</p>
</details>


</p>
</details>
