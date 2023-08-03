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

**4. Now check for changes in the master GFF file**
```
less Agra_rnd4.all.maker.gff
```

**5. We need to split `protein.fasta` file into multiple smaller files**
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

---

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


---

# Now we need to rename the genes 
- We will be using the gene names from our blastn search to change our maker gene model names
- This will use the maker scripts `maker_functional_gff` and `maker_functional_fasta`

<details><summary>rename_genes_blast.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=cmain
	#SBATCH --constraint=oarc
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
	BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast"
	DB_DIR="/projectsc/ccib/shain/blastdb"


	echo ""
	echo "Append the gene names from the BLASTP results to each associated gene prediction"


	echo "Master GFF"
	singularity exec $MAKER_IMAGE maker_functional_gff ${DB_DIR}/nt.fasta \
	${BLAST_DIR}/blast.out SEMI_removed_Agra_rnd4.all.maker.gff > Agra_rnd4.all.maker.functional.blast.gff


	echo "Protein FASTA"
	singularity exec $MAKER_IMAGE maker_functional_fasta ${DB_DIR}/nt.fasta \
	${BLAST_DIR}/blast.out Agra_rnd4.all.maker.proteins.fasta > Agra_rnd4.all.maker.proteins.functional.blast.fasta


	echo "Transcript FASTA"
	singularity exec $MAKER_IMAGE maker_functional_fasta ${DB_DIR}/nt.fasta \
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


<details><summary>annie.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=annie
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
	module load python/3.9.6-gc563

	echo ""
	echo "load variables"
	cd /projects/f_geneva_1/alyssa/grahami/annotation/filtering/annie
	
	MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
	BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast"
	DB_DIR="/projectsc/ccib/shain/blastdb"

	echo ""
	echo "commands to run annie"
	python3 annie.py \
	-b ${BLAST_DIR}/blast.out \
	-g ${MAKER_DIR}/Agra_rnd4.all.maker.gff \
	-db ${DB_DIR}/nt.fasta

	echo ""
	echo "done"
	```

</p>
</details>


```
python3 annie.py \
	-b sample_data/sample.blastout \
        -g sample_data/sample.gff \
        -db sample_data/sample.fasta
```

---

# GAG
- [GAG documentation](http://genomeannotation.github.io/GAG/)
- [Github page](https://github.com/genomeannotation/GAG)
- GAG takes the output from annie and combines it with our annotation 
- Uses `python2`
- Copy `gag.py` script from [here](https://github.com/genomeannotation/GAG/blob/master/gag.py)
- Input
  - Fasta file of nucleotide sequences
  - GFF3 file

<details><summary>gag.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=gag
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
	module load python/2.7.17-gc563

	echo ""
	echo "load variables"
	MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
	ANNIE_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/annie"
	OUTDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/gag"

	echo ""
	echo "commands to run annie"
	python gag.py \
	--fasta ${MAKER_DIR}/Agra_rnd4.all.maker.transcripts.fasta \
	--gff ${ANNIE_DIR}/[GFF FILE FROM ANNIE] \
	--out ${OUTDIR}

	echo ""
	echo "done"
	```

</p>
</details>


```
python gag.py --fasta organism.fasta --gff organism.gff --out gag_output
```

---

# Manual filtering
- We will also be doing manual filtering on the gene models that didnt match to anything during our blast search
- During BLAST, our gene models will really only be matching with _A. carolinensis_ genes which is pretty divergent from _A. grahami_
- By manually filtering our other gene models on certain criteria we can be pretty confident that these are genes that _A. grahami_ has that _A. carolinensis_ doesn't
- Filtering criteria:
  - AED score of X or lower
  - X or more exons (prob 3?)
- Determining criteria:
  - Make a histogram of AED scores
  - Make a histogram of # of exons

---

# Final BUSCO analysis
- Now we want to run BUSCO again to see our completeness scores after all of our filtering
- The completeness will probably decrease some but we don't want to see it drastically change



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

</p>
</details>
